using EventoWeb.Comum.Aplicacao.Eventos;
using EventoWeb.Comum.Aplicacao.FormasPagamento;
using EventoWeb.Comum.Aplicacao.Inscricoes;
using EventoWeb.Comum.Aplicacao.Pedidos;
using EventoWeb.Comum.Aplicacao.Precos;
using EventoWeb.Comum.Negocio.Entidades;
using EventoWeb.Comum.Negocio.Entidades.Financeiro;
using EventoWeb.Comum.Negocio.Entidades.IntegracaoFinanceira;
using EventoWeb.Comum.Negocio.Repositorios;
using EventoWeb.Comum.Negocio.Servicos;
using EventoWeb.Comum.Persistencia.Integracoes.Asaas;
using EventoWeb.Comum.Persistencia.Mapeamentos;
using EventoWeb.Comum.Persistencia.MigracoesBD;
using EventoWeb.Comum.Persistencia.Repositorios;
using EventoWeb.Inscricao;
using EventoWeb.Inscricao.Logging;
using FluentMigrator.Runner;
using NHibernate;
using NHibernate.Cfg;
using NHibernate.Mapping.ByCode;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddControllers();
builder.Services.AddOpenApi();
//builder.Services.AddLettuceEncrypt();

var databaseSection = builder.Configuration.GetSection("Database");
var connectionString = databaseSection.GetValue<string>("ConnectionString")
                        ?? throw new InvalidOperationException("Database:ConnectionString nao configurado.");
var nhDialect = databaseSection.GetValue<string>("Dialect")
               ?? "NHibernate.Dialect.MySQL5Dialect";
var nhDriver = databaseSection.GetValue<string>("Driver")
              ?? "NHibernate.Driver.MySqlDataDriver";

var logFilePath = builder.Configuration["Logging:File:Path"];
if (!string.IsNullOrWhiteSpace(logFilePath))
{
    var contentRoot = builder.Environment.ContentRootPath;
    var fullPath = Path.IsPathRooted(logFilePath)
        ? logFilePath
        : Path.Combine(contentRoot, logFilePath);
    builder.Logging.AddProvider(new FileLoggerProvider(fullPath));
}

builder.Services
    .AddFluentMigratorCore()
    .ConfigureRunner(rb => rb
        .AddMySql5()
        .WithGlobalConnectionString(connectionString)
        .ScanIn(typeof(Migracao01).Assembly).For.Migrations())
    .AddLogging(lb => lb.AddFluentMigratorConsole());

builder.Services.AddSingleton<ISessionFactory>(_ =>
{
    NHibernate.Cfg.Environment.UseReflectionOptimizer = false;
    var configuration = new Configuration();
    configuration.SetProperty(NHibernate.Cfg.Environment.ConnectionProvider,
        "NHibernate.Connection.DriverConnectionProvider");
    configuration.SetProperty(NHibernate.Cfg.Environment.ConnectionString, connectionString);
    configuration.SetProperty(NHibernate.Cfg.Environment.Dialect, nhDialect);
    configuration.SetProperty(NHibernate.Cfg.Environment.ConnectionDriver, nhDriver);
    var mapper = new ModelMapper();
    var mappingAssembly = typeof(InscricaoMapping).Assembly;
    mapper.AddMappings(mappingAssembly.GetExportedTypes());
    configuration.AddMapping(mapper.CompileMappingForAllExplicitlyAddedEntities());
    
    return configuration.BuildSessionFactory();
});

builder.Services.AddSingleton<IDictionary<EnumIntegracaoExterna, IIntegracaoExterna>, Dictionary<EnumIntegracaoExterna, IIntegracaoExterna>>(provider =>
{
    var dict = new Dictionary<EnumIntegracaoExterna, IIntegracaoExterna>() 
    { 
        { EnumIntegracaoExterna.Asaas, new IntegracaoFinanceiraAsaas() } 
    };
    
    return dict;
});

builder.Services.AddScoped((provider) => {
    var factory = provider.GetService<ISessionFactory>() ?? 
                  throw new ArgumentNullException(nameof(ISessionFactory));
    
    return new ContextoNH(factory.OpenSession());
});

builder.Services.AddScoped<IContexto>(p => p.GetRequiredService<ContextoNH>());
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().Inscricoes);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().Pessoas);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().Eventos);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().PrecosInscricao);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().Pedidos);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().FormasPagamento);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().IntegracoesFinanceirasPorFormasPagamento);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().RegistrosIntegracoesFinanceiras);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().ModelosMensagemNotificacao);
builder.Services.AddScoped(p => p.GetRequiredService<ContextoNH>().MensagensNotificacao);
builder.Services.AddScoped<AppEventoListagem>();
builder.Services.AddScoped<AppEventoCalcularIdade>();
builder.Services.AddScoped<AppEventoObtencao>();
builder.Services.AddScoped<AppInscricaoInclusaoOnLine>();
builder.Services.AddScoped<AppInscricaoAtualizacao>();
builder.Services.AddScoped<AppInscricaoObtencao>();
builder.Services.AddScoped<AppInscricaoPesquisaPessoa>();
builder.Services.AddScoped<AppPrecoInscricaoObtencaoIdade>();
builder.Services.AddScoped<AppPedidoInclusao>();
builder.Services.AddScoped<AppFormasPagamentoListagem>();

builder.Services.AddCors();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var runner = scope.ServiceProvider.GetRequiredService<IMigrationRunner>();
    runner.MigrateUp();
}

app.Services.GetService<ISessionFactory>();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors(builder => builder
    .AllowAnyHeader()
    .AllowAnyMethod()
    .SetIsOriginAllowed(_ => true)
    .AllowCredentials()
);

//app.UseHttpsRedirection();
app.MapControllers();
app.ConfigureExceptionHandler();

app.Run();

public partial class Program
{
}
