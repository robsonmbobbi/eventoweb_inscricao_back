using EventoWeb.Comum.Aplicacao.FormasPagamento;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FormasPagamento (AppFormasPagamentoListagem appListagem) : ControllerBase
    {
        [HttpGet("listar/{idEvento}")]
        public IEnumerable<DTOFormaPagamento> Listar(int idEvento)
        {
            return appListagem.ListarTodas(idEvento);
        }

    }
}
