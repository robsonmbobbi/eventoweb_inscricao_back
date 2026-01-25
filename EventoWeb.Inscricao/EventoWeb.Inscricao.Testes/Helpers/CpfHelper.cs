namespace EventoWeb.Inscricao.Testes.Helpers;

public static class CpfHelper
{
    public static string GerarCpfValido()
    {
        var digits = GerarNoveDigitos();
        var digito1 = CalcularDigito(digits, new[] { 10, 9, 8, 7, 6, 5, 4, 3, 2 });
        var digito2 = CalcularDigito(digits.Concat(new[] { digito1 }).ToArray(), new[] { 11, 10, 9, 8, 7, 6, 5, 4, 3, 2 });

        return string.Concat(digits) + digito1 + digito2;
    }

    private static int[] GerarNoveDigitos()
    {
        int[] digits;
        do
        {
            digits = Enumerable.Range(0, 9)
                .Select(_ => Random.Shared.Next(0, 10))
                .ToArray();
        }
        while (digits.All(d => d == digits[0]));

        return digits;
    }

    private static int CalcularDigito(int[] digits, int[] pesos)
    {
        var soma = digits.Zip(pesos, (d, p) => d * p).Sum();
        var resto = soma % 11;
        return resto < 2 ? 0 : 11 - resto;
    }
}
