using EventoWeb.Comum.Aplicacao.Eventos;
using EventoWeb.Comum.Negocio.Repositorios;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class EventosController(AppEventoListagem appListagem, AppEventoCalcularIdade appCalculaIdade) : ControllerBase
{
    [HttpGet("listar")]
    public IList<DTOEvento> Listar()
    {
        return appListagem.Listar(EnumFiltroListagemEventos.EmPeriodoInscricao);
    }

    [HttpGet("{idEvento: int}/obter-idade/${dataNascimento: date}")]
    public Object ObterIdade(int idEvento, DateTime dataNascimento)
    {
        return new
        {
            idade = appCalculaIdade.CalcularIdade(idEvento, dataNascimento)
        };
    }
}
