using EventoWeb.Comum.Aplicacao.Eventos;
using EventoWeb.Comum.Aplicacao.Inscricoes;
using EventoWeb.Comum.Aplicacao.Pedidos;
using EventoWeb.Comum.Aplicacao.Precos;
using EventoWeb.Comum.Negocio.Entidades;
using EventoWeb.Comum.Negocio.Repositorios;
using EventoWeb.Comum.Persistencia.Mapeamentos;
using EventoWeb.Comum.Persistencia.Repositorios;
using EventoWeb.Inscricao;
using NHibernate;
using NHibernate.Cfg;
using NHibernate.Mapping.ByCode;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddControllers();
builder.Services.AddOpenApi();

builder.Services.AddSingleton<ISessionFactory>(_ =>
{
    NHibernate.Cfg.Environment.UseReflectionOptimizer = false;
    var configuration = new Configuration();
    configuration.Configure();
    var mapper = new ModelMapper();
    var mappingAssembly = typeof(InscricaoMapping).Assembly;
    mapper.AddMappings(mappingAssembly.GetExportedTypes());
    configuration.AddMapping(mapper.CompileMappingForAllExplicitlyAddedEntities());
    
    return configuration.BuildSessionFactory();
});

builder.Services.AddScoped<IContexto>((provider) => {
    var factory = provider.GetService<ISessionFactory>() ?? 
                  throw new ArgumentNullException(nameof(ISessionFactory));
    
    return new ContextoNH(factory.OpenSession());
});

builder.Services.AddScoped<IInscricoes, InscricoesNH>();
builder.Services.AddScoped<IPessoas, PessoasNH>();
builder.Services.AddScoped<IEventos, EventosNH>();
builder.Services.AddScoped<IPrecosInscricao, PrecosInscricaoNH>();
builder.Services.AddScoped<IPersistencia<Pedido>, PersistenciaNH<Pedido>>();
builder.Services.AddScoped<AppEventoListagem>();
builder.Services.AddScoped<AppInscricaoInclusaoOnLine>();
builder.Services.AddScoped<AppInscricaoAtualizacao>();
builder.Services.AddScoped<AppInscricaoObtencao>();
builder.Services.AddScoped<AppPrecoInscricaoObtencaoIdade>();
builder.Services.AddScoped<AppPedidoInclusao>();

builder.Services.AddCors();

var app = builder.Build();

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

app.UseHttpsRedirection();
app.MapControllers();
app.ConfigureExceptionHandler();

app.Run();
