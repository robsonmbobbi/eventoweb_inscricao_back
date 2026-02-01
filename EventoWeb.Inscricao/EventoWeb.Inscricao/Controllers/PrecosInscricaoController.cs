using EventoWeb.Comum.Aplicacao.Precos;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PrecosInscricaoController(
    AppPrecoInscricaoObtencaoIdade appObtencaoIdade) : ControllerBase
{
    [HttpGet("evento/{idEvento:int}/obter/nascimento/{dataNascimento:datetime}")]
    public DTOPrecoInscricao? ObterPorIdade(int idEvento, DateTime dataNascimento)
    {
        return appObtencaoIdade.Obter(idEvento, dataNascimento);
    }
}
