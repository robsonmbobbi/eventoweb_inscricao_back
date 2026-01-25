using System.Net;
using System.Text.Json;
using Microsoft.AspNetCore.Diagnostics;

namespace EventoWeb.Inscricao;

public static class ExceptionMiddlewareExtensions
{
    public static void ConfigureExceptionHandler(this IApplicationBuilder app)
    {
        app.UseExceptionHandler(appError =>
        {
            appError.Run(async context =>
            {
                context.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
                context.Response.ContentType = "application/json";

                var contextFeature = context.Features.Get<IExceptionHandlerFeature>();
                if (contextFeature != null)
                {
                    await context.Response.WriteAsync(
                        JsonSerializer.Serialize(ProcessarErro(contextFeature.Error)));
                }
            });
        });
    }

    private static Object? ProcessarErro(Exception? erro)
    {
        if (erro == null)
            return null;
        else
            return new
            {
                ClasseErro = erro.GetType().Name,
                MensagemErro = erro.Message,
                ErroInterno = ProcessarErro(erro.InnerException),
                PilhaExecucao = erro.StackTrace
            };
    }
}