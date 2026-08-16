using EventoWeb.Comum.Aplicacao.Inscricoes;
using Microsoft.AspNetCore.Mvc;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InscricoesController(
    AppInscricaoInclusao appInclusao,
    AppInscricaoAtualizacao appAtualizacao,
    AppInscricaoObtencao appObtencao,
    AppInscricaoPesquisaPessoa appPesquisa) : ControllerBase
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

    [HttpGet("pesquisar/evento/{idEvento}/cpf/{cpf}")]
    public DTOInscricaoPesquisaPessoa Pesquisar(int idEvento, string cpf)
    {
        return appPesquisa.Pesquisar(idEvento, cpf);
    }
}
