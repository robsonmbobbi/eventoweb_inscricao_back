using EventoWeb.Comum.Aplicacao.Inscricoes;
using EventoWeb.Comum.Negocio.Entidades;

namespace EventoWeb.Inscricao.Testes.Helpers;

public static class DtoFactory
{
    public static DTOInscricao CriarInscricaoAdulta(int idEvento)
    {
        var cpf = CpfHelper.GerarCpfValido();

        return new DTOInscricao
        {
            Tipo = EnumTipoInscricao.Adulto,
            IdEvento = idEvento,
            DormeEvento = true,
            NomeCracha = "Cracha Teste",
            Observacoes = "Inscricao criada nos testes",
            InstituicoesEspiritasFrequenta = "Centro Espirita",
            Pessoa = new DTOPessoa
            {
                Nome = "Participante Teste",
                DataNascimento = DateTime.Today.AddYears(-20),
                CPF = cpf,
                AlergiaAlimentos = string.Empty,
                Celular = "11999998888",
                EhDiabetico = false,
                EhVegetariano = false,
                Email = "participante.teste@example.com",
                Sexo = EnumSexo.Masculino,
                UsaAdocanteDiariamente = false
            },
            Responsavel1 = new DTOResponsavel
            {
                IdInscricao = 0,
                CPF = cpf,
                Nome = "Participante Teste"
            }
        };
    }
}
