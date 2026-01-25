using System.Net.Http.Json;
using EventoWeb.Comum.Aplicacao.Eventos;
using Xunit;

namespace EventoWeb.Inscricao.Testes.Endpoints;

[Collection("EventoWebApiCollection")]
public class EventosEndpointsTests
{
    private readonly TestFixture _fixture;

    public EventosEndpointsTests(TestFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task Listar_retorna_evento_seed_quando_periodo_encerrado()
    {
        await _fixture.AtualizarPeriodoInscricaoAsync(DateTime.Now.AddDays(-3), DateTime.Now.AddDays(-1));

        using var client = _fixture.Factory.CreateClient();
        var eventos = await client.GetFromJsonAsync<List<DTOEvento>>("/api/eventos");

        Assert.NotNull(eventos);
        Assert.Contains(eventos, e => e.Id == _fixture.SeedData.EventoId);
    }
}
