using EventoWeb.Comum.Aplicacao.Inscricoes;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InscricoesController(
    AppInscricaoInclusaoOnLine appInclusao,
    AppInscricaoAtualizacao appAtualizacao,
    AppInscricaoObtencao appObtencao) : ControllerBase
{
    [HttpPost("incluir")]
    public DTOInscricao Incluir([FromBody] DTOInscricao dto)
    {
        appInclusao.DtoInscricao = dto;
        return appInclusao.Incluir();
    }

    [HttpPut("atualizar")]
    public void Atualizar([FromBody] DTOInscricao dto)
    {
        appAtualizacao.DtoInscricao = dto;
        appAtualizacao.Atualizar();
    }

    [HttpGet("obter/{id:int}")]
    public DTOInscricao? Obter(int id)
    {
        return appObtencao.Obter(id);
    }
}
