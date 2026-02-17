import '../../models/dto_inscricao.dart';
import '../../models/dto_inscricao_pesquisa_pessoa.dart';
import '../base_api_service.dart';

/// Service para gerenciar endpoints de inscrições
class InscricoesService extends BaseApiService {
  InscricoesService(super.baseUrl);
  
  /// Pesquisar inscrição existente por CPF
  Future<DTOInscricaoPesquisaPessoa> pesquisarCPF(int idEvento, String cpf) async => get(
      '/inscricoes/pesquisar/evento/$idEvento/cpf/$cpf',
      parser: DTOInscricaoPesquisaPessoa.fromJson,
    );
  
 
  /// Incluir/registrar nova inscrição
  Future<DTOInscricao> incluir(DTOInscricao inscricao) async => post(
      '/inscricoes/incluir',
      body: inscricao.toJson(),
      parser: DTOInscricao.fromJson,
    );
  
  /// Atualizar inscrição existente
  Future<void> atualizar(DTOInscricao inscricao) async => put(
      '/inscricoes/atualizar',
      body: inscricao.toJson(),
      parser: (json) {},
    );
}
