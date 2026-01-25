using System.Net.Http.Json;
using EventoWeb.Comum.Aplicacao.Inscricoes;
using EventoWeb.Inscricao.Testes.Helpers;
using Xunit;

namespace EventoWeb.Inscricao.Testes.Endpoints;

[Collection("EventoWebApiCollection")]
public class InscricoesEndpointsTests
{
    private readonly TestFixture _fixture;

    public InscricoesEndpointsTests(TestFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task Incluir_obter_e_atualizar_inscricao_adulta()
    {
        await _fixture.AtualizarPeriodoInscricaoAsync(DateTime.Now.AddDays(-1), DateTime.Now.AddDays(1));

        using var client = _fixture.Factory.CreateClient();
        var dto = DtoFactory.CriarInscricaoAdulta(_fixture.SeedData.EventoId);

        var inclusaoResponse = await client.PostAsJsonAsync("/api/inscricoes", dto);
        inclusaoResponse.EnsureSuccessStatusCode();

        var inscricaoCriada = await inclusaoResponse.Content.ReadFromJsonAsync<DTOInscricao>();
        Assert.NotNull(inscricaoCriada);
        Assert.NotNull(inscricaoCriada!.Id);

        var obtida = await client.GetFromJsonAsync<DTOInscricao>($"/api/inscricoes/{inscricaoCriada.Id}");
        Assert.NotNull(obtida);
        Assert.Equal(inscricaoCriada.Id, obtida!.Id);

        inscricaoCriada.NomeCracha = "Cracha Atualizado";
        inscricaoCriada.Observacoes = "Atualizado nos testes";
        inscricaoCriada.DormeEvento = false;
        inscricaoCriada.Responsavel1 = new DTOResponsavel
        {
            IdInscricao = 0,
            CPF = inscricaoCriada.Pessoa.CPF,
            Nome = inscricaoCriada.Pessoa.Nome
        };

        var atualizacaoResponse = await client.PutAsJsonAsync($"/api/inscricoes/{inscricaoCriada.Id}", inscricaoCriada);
        atualizacaoResponse.EnsureSuccessStatusCode();

        var atualizada = await client.GetFromJsonAsync<DTOInscricao>($"/api/inscricoes/{inscricaoCriada.Id}");
        Assert.NotNull(atualizada);
        Assert.Equal("Cracha Atualizado", atualizada!.NomeCracha);
        Assert.False(atualizada.DormeEvento);
    }
}
