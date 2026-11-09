using EventoWeb.Comum.Negocio.Entidades.Notificacoes;

namespace EventoWeb.Inscricao.Notificacoes;

internal sealed class NotificacaoRequest
{
    public Guid Id { get; set; }
    public EnumMeioNotificacao Meio { get; set; }
    public string Destinatario { get; set; } = string.Empty;
    public string? TemplateAssunto { get; set; }
    public string TemplateConteudo { get; set; } = string.Empty;
    public string? DadosJson { get; set; }

    // Só WhatsApp: nome e idioma do template aprovado na Meta.
    public string? TemplateWhatsapp { get; set; }
    public string? IdiomaTemplateWhatsapp { get; set; }
    public List<NotificacaoAnexo> Anexos { get; set; } = new();
}
