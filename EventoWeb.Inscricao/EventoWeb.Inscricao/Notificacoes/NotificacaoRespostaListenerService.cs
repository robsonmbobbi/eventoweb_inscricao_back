using System.Text.Json;
using EventoWeb.Comum.Negocio.ObjetosValor;
using EventoWeb.Comum.Negocio.Repositorios;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace EventoWeb.Inscricao.Notificacoes;

public class NotificacaoRespostaListenerService : BackgroundService
{
    private static readonly TimeSpan MinRetryDelay = TimeSpan.FromSeconds(2);
    private static readonly TimeSpan MaxRetryDelay = TimeSpan.FromSeconds(30);

    private readonly ConfiguracaoRabbitMqNotificacao m_Configuracao;
    private readonly IServiceScopeFactory m_ScopeFactory;
    private readonly ILogger<NotificacaoRespostaListenerService> m_Logger;

    public NotificacaoRespostaListenerService(
        ConfiguracaoRabbitMqNotificacao configuracao,
        IServiceScopeFactory scopeFactory,
        ILogger<NotificacaoRespostaListenerService> logger)
    {
        m_Configuracao = configuracao;
        m_ScopeFactory = scopeFactory;
        m_Logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var retryDelay = MinRetryDelay;

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await RunOnceAsync(stoppingToken).ConfigureAwait(false);
                retryDelay = MinRetryDelay;
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                break;
            }
            catch (Exception ex)
            {
                m_Logger.LogWarning(
                    ex,
                    "Conexão com a fila de retorno de notificações perdida. Tentando novamente em {Delay}s.",
                    retryDelay.TotalSeconds);

                try { await Task.Delay(retryDelay, stoppingToken).ConfigureAwait(false); }
                catch (OperationCanceledException) { break; }

                retryDelay = TimeSpan.FromSeconds(Math.Min(retryDelay.TotalSeconds * 2, MaxRetryDelay.TotalSeconds));
            }
        }
    }

    private async Task RunOnceAsync(CancellationToken stoppingToken)
    {
        var factory = new ConnectionFactory
        {
            HostName = m_Configuracao.HostName,
            Port = m_Configuracao.Port,
            UserName = m_Configuracao.UserName,
            Password = m_Configuracao.Password,
            VirtualHost = m_Configuracao.VirtualHost,
            AutomaticRecoveryEnabled = true,
            ClientProvidedName = "EventoWeb.Inscricao (listener de retorno)"
        };

        await using var conexao = await factory.CreateConnectionAsync(stoppingToken).ConfigureAwait(false);
        await using var canal = await conexao.CreateChannelAsync(cancellationToken: stoppingToken).ConfigureAwait(false);

        await canal.BasicQosAsync(
            prefetchSize: 0,
            prefetchCount: 1,
            global: false,
            cancellationToken: stoppingToken).ConfigureAwait(false);

        var conexaoPerdida = new TaskCompletionSource(TaskCreationOptions.RunContinuationsAsynchronously);
        conexao.ConnectionShutdownAsync += (_, _) =>
        {
            conexaoPerdida.TrySetResult();
            return Task.CompletedTask;
        };

        var consumidor = new AsyncEventingBasicConsumer(canal);
        consumidor.ReceivedAsync += (_, ea) => ProcessarRespostaAsync(canal, ea);

        await canal.BasicConsumeAsync(
            queue: m_Configuracao.ResponseQueueName,
            autoAck: false,
            consumer: consumidor,
            cancellationToken: stoppingToken).ConfigureAwait(false);

        m_Logger.LogInformation(
            "Consumindo fila de retorno de notificações '{Queue}' em {Host}:{Port}",
            m_Configuracao.ResponseQueueName, m_Configuracao.HostName, m_Configuracao.Port);

        using var registro = stoppingToken.Register(() => conexaoPerdida.TrySetResult());
        await conexaoPerdida.Task.ConfigureAwait(false);

        stoppingToken.ThrowIfCancellationRequested();
    }

    private async Task ProcessarRespostaAsync(IChannel canal, BasicDeliverEventArgs ea)
    {
        var correlationId = ea.BasicProperties.CorrelationId;

        // CorrelationId ausente/não numérico não é recuperável por retry (a mensagem nunca vai
        // ficar válida) — loga e descarta em vez de reenfileirar em loop.
        if (!int.TryParse(correlationId, out var idMensagem))
        {
            m_Logger.LogError(
                "Resposta de notificação recebida com CorrelationId inválido/ausente: '{CorrelationId}'. Descartando.",
                correlationId);
            await canal.BasicAckAsync(ea.DeliveryTag, multiple: false).ConfigureAwait(false);
            return;
        }

        NotificacaoResponse? response;
        try
        {
            response = JsonSerializer.Deserialize<NotificacaoResponse>(ea.Body.Span);
        }
        catch (Exception ex)
        {
            m_Logger.LogError(ex, "Falha ao desserializar resposta de notificação para mensagem Id={IdMensagem}. Descartando.", idMensagem);
            await canal.BasicAckAsync(ea.DeliveryTag, multiple: false).ConfigureAwait(false);
            return;
        }

        if (response is null)
        {
            m_Logger.LogError("Resposta de notificação vazia para mensagem Id={IdMensagem}. Descartando.", idMensagem);
            await canal.BasicAckAsync(ea.DeliveryTag, multiple: false).ConfigureAwait(false);
            return;
        }

        try
        {
            using var escopo = m_ScopeFactory.CreateScope();
            var contexto = escopo.ServiceProvider.GetRequiredService<IContexto>();
            var mensagens = escopo.ServiceProvider.GetRequiredService<IMensagens>();

            contexto.IniciarTransacao();

            var mensagem = mensagens.Obter(idMensagem);
            if (mensagem is null)
            {
                m_Logger.LogWarning("Mensagem de notificação Id={IdMensagem} não encontrada no banco. Descartando resposta.", idMensagem);
                contexto.CancelarTransacao();
                await canal.BasicAckAsync(ea.DeliveryTag, multiple: false).ConfigureAwait(false);
                return;
            }

            if (response.Sucesso)
                mensagem.RegistrarEnvio();
            else
                mensagem.RegistrarErroEnvio(new StringClob(response.MensagemErro ?? "Falha ao enviar notificação."));

            mensagens.Atualizar(mensagem);
            contexto.SalvarTransacao();

            await canal.BasicAckAsync(ea.DeliveryTag, multiple: false).ConfigureAwait(false);
        }
        catch (Exception ex)
        {
            // Falha transitória (ex.: banco indisponível) — vale a pena reprocessar mais tarde.
            m_Logger.LogError(ex, "Falha ao processar resposta de notificação para mensagem Id={IdMensagem}. Será reprocessada.", idMensagem);
            await canal.BasicNackAsync(ea.DeliveryTag, multiple: false, requeue: true).ConfigureAwait(false);
        }
    }
}
