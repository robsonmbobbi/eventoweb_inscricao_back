using EventoWeb.Comum.Aplicacao.Eventos;
using EventoWeb.Comum.Negocio.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EventosController(AppEventoListagem appListagem) : ControllerBase
{
    [HttpGet("listar")]
    public IList<DTOEvento> Listar()
    {
        return appListagem.Listar(EnumFiltroListagemEventos.EmPeriodoInscricao);
    }
}
