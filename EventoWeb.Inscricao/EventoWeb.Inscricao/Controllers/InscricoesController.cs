using EventoWeb.Comum.Aplicacao.Inscricoes;
using EventoWeb.Inscricao.Seguranca;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InscricoesController(
    AppInscricaoInclusao appInclusao,
    AppInscricaoAtualizacao appAtualizacao,
    AppInscricaoPesquisaPessoa appPesquisa) : ControllerBase
{
    [HttpPost("incluir")]
    [EnableRateLimiting(PoliticasLimite.GravacaoInscricao)]
    public DTOInscricao Incluir([FromBody] DTOInscricao dto)
    {
        appInclusao.DtoInscricao = dto;
        return appInclusao.Incluir();
    }

    [HttpPut("atualizar")]
    [EnableRateLimiting(PoliticasLimite.GravacaoInscricao)]
    public void Atualizar([FromBody] DTOInscricao dto)
    {
        appAtualizacao.DtoInscricao = dto;
        appAtualizacao.Atualizar();
    }

    [HttpGet("pesquisar/evento/{idEvento}/cpf/{cpf}")]
    [EnableRateLimiting(PoliticasLimite.PesquisaCpf)]
    public DTOInscricaoPesquisaPessoa Pesquisar(int idEvento, string cpf)
    {
        return appPesquisa.Pesquisar(idEvento, cpf);
    }
}
