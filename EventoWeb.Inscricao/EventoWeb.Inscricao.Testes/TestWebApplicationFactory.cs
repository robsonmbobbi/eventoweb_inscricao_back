using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NHibernate;

namespace EventoWeb.Inscricao.Testes;

public class TestWebApplicationFactory : WebApplicationFactory<Program>
{
    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Testing");

        builder.ConfigureAppConfiguration((_, config) =>
        {
            var basePath = AppContext.BaseDirectory;
            config.AddJsonFile(Path.Combine(basePath, "appsettings.Testing.json"), optional: true);
            config.AddEnvironmentVariables();
        });

        builder.ConfigureServices(services =>
        {
            services.AddScoped<ISession>(provider =>
            {
                var factory = provider.GetRequiredService<ISessionFactory>();
                return factory.OpenSession();
            });
        });
    }
}
