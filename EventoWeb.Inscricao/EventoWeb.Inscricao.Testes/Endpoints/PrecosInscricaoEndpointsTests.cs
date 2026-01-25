using System.Net.Http.Json;
using EventoWeb.Comum.Aplicacao.Precos;
using Xunit;

namespace EventoWeb.Inscricao.Testes.Endpoints;

[Collection("EventoWebApiCollection")]
public class PrecosInscricaoEndpointsTests
{
    private readonly TestFixture _fixture;

    public PrecosInscricaoEndpointsTests(TestFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task ObterPorIdade_retorna_preco_infantil()
    {
        using var client = _fixture.Factory.CreateClient();
        var dataNascimento = DateTime.Today.AddYears(-10);
        var url = $"/api/precosinscricao/{_fixture.SeedData.EventoId}/{dataNascimento:yyyy-MM-dd}";

        var preco = await client.GetFromJsonAsync<DTOPrecoInscricao>(url);

        Assert.NotNull(preco);
        Assert.Equal(_fixture.SeedData.IdadeMaxInfantil, preco!.IdadeMax);
        Assert.Equal(_fixture.SeedData.PrecoInfantil, preco.Preco);
    }

    [Fact]
    public async Task ObterPorIdade_retorna_preco_adulto()
    {
        using var client = _fixture.Factory.CreateClient();
        var dataNascimento = DateTime.Today.AddYears(-30);
        var url = $"/api/precosinscricao/{_fixture.SeedData.EventoId}/{dataNascimento:yyyy-MM-dd}";

        var preco = await client.GetFromJsonAsync<DTOPrecoInscricao>(url);

        Assert.NotNull(preco);
        Assert.Equal(_fixture.SeedData.IdadeMaxAdulto, preco!.IdadeMax);
        Assert.Equal(_fixture.SeedData.PrecoAdulto, preco.Preco);
    }
}
