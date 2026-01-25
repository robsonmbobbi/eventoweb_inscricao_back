using Xunit;

namespace EventoWeb.Inscricao.Testes;

[CollectionDefinition("EventoWebApiCollection", DisableParallelization = true)]
public class TestCollection : ICollectionFixture<TestFixture>
{
}
