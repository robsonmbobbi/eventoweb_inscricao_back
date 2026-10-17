using EventoWeb.Comum.Aplicacao.Pedidos;
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
}
