using EventoWeb.Comum.Aplicacao.FormasPagamento;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FormasPagamento (AppFormasPagamentoListagem appListagem) : ControllerBase
    {
        [HttpGet("listar")]
        public IEnumerable<DTOFormaPagamento> Listar()
        {
            return appListagem.ListarTodas();
        }

    }
}
