using EventoWeb.Comum.Negocio.Entidades;
using Microsoft.Extensions.DependencyInjection;
using NHibernate;
using Xunit;

namespace EventoWeb.Inscricao.Testes;

public class TestFixture : IAsyncLifetime
{
    private const string SeedEventoNome = "Evento Teste Endpoints";
    private const int SeedIdadeMaxInfantil = 12;
    private const int SeedIdadeMaxAdulto = 99;
    private const double SeedPrecoInfantil = 120.50;
    private const double SeedPrecoAdulto = 250.00;

    public TestWebApplicationFactory Factory { get; } = new();
    public TestSeedData SeedData { get; private set; } = null!;

    public Task InitializeAsync()
    {
        SeedData = Seed();
        return Task.CompletedTask;
    }

    public Task DisposeAsync()
    {
        Factory.Dispose();
        return Task.CompletedTask;
    }

    public Task AtualizarPeriodoInscricaoAsync(DateTime dataInicial, DateTime dataFinal)
    {
        using var scope = Factory.Services.CreateScope();
        var sessionFactory = scope.ServiceProvider.GetRequiredService<ISessionFactory>();
        using var session = sessionFactory.OpenSession();
        using var tx = session.BeginTransaction();

        var evento = session.Get<Evento>(SeedData.EventoId);
        if (evento == null)
        {
            throw new InvalidOperationException("Evento seed nao encontrado para atualizacao.");
        }

        evento.PeriodoInscricaoOnLine = new Periodo(dataInicial, dataFinal);
        session.Update(evento);
        tx.Commit();
        return Task.CompletedTask;
    }

    private TestSeedData Seed()
    {
        using var scope = Factory.Services.CreateScope();
        var sessionFactory = scope.ServiceProvider.GetRequiredService<ISessionFactory>();
        using var session = sessionFactory.OpenSession();
        using var tx = session.BeginTransaction();

        var evento = session.QueryOver<Evento>()
            .Where(e => e.Nome.Nome == SeedEventoNome)
            .SingleOrDefault();

        var agora = DateTime.Now;
        var periodoInscricao = new Periodo(agora.AddDays(-1), agora.AddDays(1));
        var periodoEvento = new Periodo(agora.AddDays(30), agora.AddDays(33));

        if (evento == null)
        {
            evento = new Evento(
                new NomeCompleto(SeedEventoNome),
                periodoInscricao,
                periodoEvento
            );

            session.Save(evento);
            session.Flush();
        }
        else
        {
            evento.PeriodoInscricaoOnLine = periodoInscricao;
            evento.PeriodoRealizacaoEvento = periodoEvento;
            session.Update(evento);
        }

        var precoInfantil = session.QueryOver<PrecoInscricao>()
            .Where(p => p.Evento.Id == evento.Id && p.IdadeMax == SeedIdadeMaxInfantil)
            .SingleOrDefault();

        if (precoInfantil == null)
        {
            precoInfantil = new PrecoInscricao(evento, SeedIdadeMaxInfantil, SeedPrecoInfantil);
            session.Save(precoInfantil);
        }
        else
        {
            precoInfantil.Preco = SeedPrecoInfantil;
            session.Update(precoInfantil);
        }

        var precoAdulto = session.QueryOver<PrecoInscricao>()
            .Where(p => p.Evento.Id == evento.Id && p.IdadeMax == SeedIdadeMaxAdulto)
            .SingleOrDefault();

        if (precoAdulto == null)
        {
            precoAdulto = new PrecoInscricao(evento, SeedIdadeMaxAdulto, SeedPrecoAdulto);
            session.Save(precoAdulto);
        }
        else
        {
            precoAdulto.Preco = SeedPrecoAdulto;
            session.Update(precoAdulto);
        }

        tx.Commit();

        return new TestSeedData(
            evento.Id,
            precoInfantil.Id,
            precoAdulto.Id,
            SeedIdadeMaxInfantil,
            SeedIdadeMaxAdulto,
            SeedPrecoInfantil,
            SeedPrecoAdulto);
    }
}
