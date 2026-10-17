using EventoWeb.Comum.Aplicacao.Inscricoes;
using EventoWeb.Comum.Aplicacao.Pessoas;
using EventoWeb.Inscricao.Seguranca;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace EventoWeb.Inscricao.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PessoasController(AppPessoaPesquisaCPF appPesquisaCPF) : ControllerBase
{
    [HttpGet("pesquisar/cpf/{cpf}")]
    [EnableRateLimiting(PoliticasLimite.PesquisaCpf)]
    public DTOPessoa? PesquisarPorCPF(string cpf)
    {
        return appPesquisaCPF.Pesquisar(cpf);
    }
}
