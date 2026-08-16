using System.Text.Json;
using System.Threading;
using EventoWeb.Comum.Negocio.Entidades.Notificacoes;
using EventoWeb.Comum.Negocio.Servicos.Notificacoes;
using RabbitMQ.Client;

namespace EventoWeb.Inscricao.Notificacoes;

public class EnvioNotificacaoRabbitMq : IEnvioNotificacao, IAsyncDisposable
{
    private readonly ConfiguracaoRabbitMqNotificacao m_Configuracao;
    private readonly SemaphoreSlim m_SemaforoConexao = new(1, 1);
    private readonly SemaphoreSlim m_SemaforoPublicacao = new(1, 1);

    private IConnection? m_Conexao;
    private IChannel? m_Canal;

    public EnvioNotificacaoRabbitMq(ConfiguracaoRabbitMqNotificacao configuracao)
    {
        m_Configuracao = configuracao ?? throw new ArgumentNullException(nameof(configuracao));
    }

    public async Task Enviar(MensagemNotificacao mensagem)
    {
        ArgumentNullException.ThrowIfNull(mensagem);

        var canal = await ObterCanalAsync().ConfigureAwait(false);

        var request = new NotificacaoRequest
        {
            Id = Guid.NewGuid(),
            Meio = mensagem.Modelo.Meio,
            Destinatario = mensagem.Destinatario.Valor,
            TemplateAssunto = mensagem.Modelo.Assunto?.Valor,
            TemplateConteudo = mensagem.Modelo.Mensagem.Valor,
            DadosJson = mensagem.VariaveisJson?.Valor
        };

        var props = new BasicProperties
        {
            // A correlação com a mensagem no banco é feita pelo próprio Id (int), não pelo Guid
            // opaco do corpo — o NotificacaoRespostaListenerService usa este mesmo valor para
            // localizar a MensagemNotificacao quando a resposta chegar na fila de retorno.
            CorrelationId = mensagem.Id.ToString(),
            ReplyTo = m_Configuracao.ResponseQueueName
        };
        var body = JsonSerializer.SerializeToUtf8Bytes(request);

        // Publica e retorna: o resultado (sucesso/erro) chega de forma assíncrona na fila de
        // retorno e é processado pelo NotificacaoRespostaListenerService, que atualiza
        // mensagem.Situacao numa sessão própria — desacoplado da requisição HTTP atual.
        await PublicarAsync(canal, props, body).ConfigureAwait(false);
    }

    private async Task PublicarAsync(IChannel canal, BasicProperties props, byte[] body)
    {
        await m_SemaforoPublicacao.WaitAsync().ConfigureAwait(false);
        try
        {
            await canal.BasicPublishAsync(
                exchange: string.Empty,
                routingKey: m_Configuracao.RequestQueueName,
                mandatory: false,
                basicProperties: props,
                body: body).ConfigureAwait(false);
        }
        finally
        {
            m_SemaforoPublicacao.Release();
        }
    }

    private async Task<IChannel> ObterCanalAsync()
    {
        if (m_Canal is { IsOpen: true })
            return m_Canal;

        await m_SemaforoConexao.WaitAsync().ConfigureAwait(false);
        try
        {
            if (m_Canal is { IsOpen: true })
                return m_Canal;

            await FecharConexaoAsync().ConfigureAwait(false);

            var factory = new ConnectionFactory
            {
                HostName = m_Configuracao.HostName,
                Port = m_Configuracao.Port,
                UserName = m_Configuracao.UserName,
                Password = m_Configuracao.Password,
                VirtualHost = m_Configuracao.VirtualHost,
                AutomaticRecoveryEnabled = true,
                ClientProvidedName = "EventoWeb.Inscricao (publisher)"
            };

            m_Conexao = await factory.CreateConnectionAsync().ConfigureAwait(false);
            m_Canal = await m_Conexao.CreateChannelAsync().ConfigureAwait(false);

            // Declaração idempotente: garante que a fila de retorno exista antes do primeiro
            // publish, independentemente da ordem de inicialização em relação ao
            // NotificacaoRespostaListenerService (que também a declara, com os mesmos argumentos).
            await m_Canal.QueueDeclareAsync(
                queue: m_Configuracao.ResponseQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false).ConfigureAwait(false);

            return m_Canal;
        }
        finally
        {
            m_SemaforoConexao.Release();
        }
    }

    private async Task FecharConexaoAsync()
    {
        if (m_Canal is not null)
        {
            try { await m_Canal.CloseAsync().ConfigureAwait(false); }
            catch { /* canal já pode estar em estado inválido; ignora erro ao fechar */ }
            await m_Canal.DisposeAsync().ConfigureAwait(false);
            m_Canal = null;
        }

        if (m_Conexao is not null)
        {
            try { await m_Conexao.CloseAsync().ConfigureAwait(false); }
            catch { /* conexão já pode estar em estado inválido; ignora erro ao fechar */ }
            await m_Conexao.DisposeAsync().ConfigureAwait(false);
            m_Conexao = null;
        }
    }

    public async ValueTask DisposeAsync()
    {
        await FecharConexaoAsync().ConfigureAwait(false);

        m_SemaforoConexao.Dispose();
        m_SemaforoPublicacao.Dispose();

        GC.SuppressFinalize(this);
    }
}
