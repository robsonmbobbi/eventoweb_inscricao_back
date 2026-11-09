using EventoWeb.Comum.Aplicacao.Pedidos;
using EventoWeb.Comum.Negocio.Entidades.Notificacoes;
using EventoWeb.Comum.Negocio.Repositorios;
using EventoWeb.Comum.Negocio.Servicos.Notificacoes;
using EventoWeb.Comum.Negocio.Servicos.Notificacoes.Pedidos;
using EventoWeb.Inscricao.Seguranca;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PedidosController(AppPedidoInclusao appInclusao) : ControllerBase
{
    [HttpPost("incluir")]
    [EnableRateLimiting(PoliticasLimite.Pedido)]
    public DTOResultadoPedido Incluir([FromBody] DTOPedidoInclusao dto)
    {
        var ipRemoto = HttpContext.Connection.RemoteIpAddress?.MapToIPv4().ToString();
        return appInclusao.Incluir(dto, ipRemoto);
    }

    [HttpGet("teste")]
    public IActionResult Teste([FromServices] IEnvioNotificacao envioNotificacao, 
                               [FromServices] IMensagens mensagens,
                               [FromServices] IModelosMensagemNotificacao modelosNotificacao,
                               [FromServices] IPedidos pedidos)
    {
        var pedido = pedidos.ObterPorInscricao(190);
        new SrvNotificacaoPedidoRealizado(modelosNotificacao, mensagens, envioNotificacao)
            .Notificar(pedido!);

        return Ok("Notificação enviada com sucesso.");
    }
}
