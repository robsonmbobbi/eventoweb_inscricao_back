using EventoWeb.Comum.Aplicacao.Pedidos;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PedidosController(AppPedidoInclusao appInclusao) : ControllerBase
{
    [HttpPost("incluir")]
    public DTOResultadoPedido Incluir([FromBody] DTOPedidoInclusao dto)
    {
        return appInclusao.Incluir(dto);
    }
}
