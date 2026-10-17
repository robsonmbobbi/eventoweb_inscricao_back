using System.Net;
using System.Threading.RateLimiting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.RateLimiting;

namespace EventoWeb.Inscricao.Seguranca;

public static class PoliticasLimite
{
    /// <summary>Buscas por CPF: evita enumeração de CPFs.</summary>
    public const string PesquisaCpf = "pesquisa-cpf";

    /// <summary>Inclusão/atualização de inscrições.</summary>
    public const string GravacaoInscricao = "gravacao-inscricao";

    /// <summary>Finalização de pedido (cobrança no cartão): evita teste de cartões.</summary>
    public const string Pedido = "pedido";
}

public static class SegurancaExtensions
{
    private const string PoliticaCors = "front-inscricao";

    public static IServiceCollection AdicionarSeguranca(this IServiceCollection services, IConfiguration configuration)
    {
        // Sem origens configuradas, nenhuma chamada cross-origin é aceita (o SPA servido pelo próprio back é same-origin).
        var origens = OrigensPermitidas(configuration);
        services.AddCors(options => options.AddPolicy(PoliticaCors, policy => policy
            .WithOrigins(origens)
            .AllowAnyHeader()
            .AllowAnyMethod()));

        services.Configure<ForwardedHeadersOptions>(options =>
        {
            options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
            // O IP do pagador é exigido pelo Asaas no pagamento com cartão e é a chave do rate limit, então
            // só se aceita X-Forwarded-For vindo do proxy reverso. Sem configuração, vale o padrão (loopback).
            var proxies = configuration.GetSection("ProxyReverso:Ips").Get<string[]>() ?? [];
            foreach (var ip in proxies)
                options.KnownProxies.Add(IPAddress.Parse(ip));
        });

        services.AddRateLimiter(options =>
        {
            options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
            options.OnRejected = async (context, cancellationToken) =>
            {
                await context.HttpContext.Response.WriteAsJsonAsync(
                    new { mensagemErro = "Muitas tentativas em pouco tempo. Aguarde alguns instantes e tente novamente." },
                    cancellationToken);
            };

            options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
                EhApi(context)
                    ? RateLimitPartition.GetFixedWindowLimiter(ChaveIp(context), _ => Janela(120, TimeSpan.FromMinutes(1)))
                    : RateLimitPartition.GetNoLimiter(""));

            options.AddPolicy(PoliticasLimite.PesquisaCpf, context =>
                RateLimitPartition.GetFixedWindowLimiter(ChaveIp(context), _ => Janela(10, TimeSpan.FromMinutes(1))));
            options.AddPolicy(PoliticasLimite.GravacaoInscricao, context =>
                RateLimitPartition.GetFixedWindowLimiter(ChaveIp(context), _ => Janela(20, TimeSpan.FromMinutes(10))));
            options.AddPolicy(PoliticasLimite.Pedido, context =>
                RateLimitPartition.GetFixedWindowLimiter(ChaveIp(context), _ => Janela(5, TimeSpan.FromMinutes(10))));
        });

        return services;
    }

    public static WebApplication UsarSeguranca(this WebApplication app)
    {
        if (!app.Environment.IsDevelopment())
            app.UseHsts();

        app.Use(async (context, next) =>
        {
            var headers = context.Response.Headers;
            headers.XContentTypeOptions = "nosniff";
            headers.XFrameOptions = "DENY";
            headers["Referrer-Policy"] = "strict-origin-when-cross-origin";
            headers.ContentSecurityPolicy =
                "default-src 'self'; " +
                "connect-src 'self' https://servicodados.ibge.gov.br; " +
                "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
                "font-src 'self' https://fonts.gstatic.com; " +
                "img-src 'self' data:; " +
                "object-src 'none'; base-uri 'self'; frame-ancestors 'none'";
            await next();
        });

        app.UseCors(PoliticaCors);

        if (!app.Environment.IsDevelopment())
            app.UsarValidacaoOrigem(OrigensPermitidas(app.Configuration));

        app.UseRateLimiter();
        return app;
    }

    /// <summary>
    /// Recusa chamadas à API que não venham do próprio site ou de uma origem em <c>Cors:Origens</c>.
    /// Usa o header Origin e, na falta dele (GET same-origin), o Referer. Barra outros sites e scripts
    /// ingênuos, mas não é autenticação: um cliente fora do navegador pode forjar esses headers.
    /// </summary>
    private static void UsarValidacaoOrigem(this WebApplication app, string[] origensConfiguradas)
    {
        var permitidas = new HashSet<string>(origensConfiguradas.Select(o => o.TrimEnd('/')), StringComparer.OrdinalIgnoreCase);

        app.Use(async (context, next) =>
        {
            if (EhApi(context) && !HttpMethods.IsOptions(context.Request.Method))
            {
                var request = context.Request;
                var origem = OrigemDaRequisicao(request);
                var propria = $"{request.Scheme}://{request.Host}";

                if (origem == null || !(string.Equals(origem, propria, StringComparison.OrdinalIgnoreCase) || permitidas.Contains(origem)))
                {
                    context.Response.StatusCode = StatusCodes.Status403Forbidden;
                    await context.Response.WriteAsJsonAsync(new { mensagemErro = "Acesso não permitido." });
                    return;
                }
            }

            await next();
        });
    }

    private static string? OrigemDaRequisicao(HttpRequest request)
    {
        var origin = request.Headers.Origin.FirstOrDefault();
        if (!string.IsNullOrEmpty(origin) && origin != "null")
            return origin.TrimEnd('/');

        return Uri.TryCreate(request.Headers.Referer.FirstOrDefault(), UriKind.Absolute, out var referer)
            ? referer.GetLeftPart(UriPartial.Authority)
            : null;
    }

    private static string[] OrigensPermitidas(IConfiguration configuration) =>
        configuration.GetSection("Cors:Origens").Get<string[]>() ?? [];

    private static bool EhApi(HttpContext context) => context.Request.Path.StartsWithSegments("/api");

    private static string ChaveIp(HttpContext context) =>
        context.Connection.RemoteIpAddress?.ToString() ?? "desconhecido";

    private static FixedWindowRateLimiterOptions Janela(int limite, TimeSpan janela) => new()
    {
        PermitLimit = limite,
        Window = janela,
        QueueLimit = 0
    };
}
