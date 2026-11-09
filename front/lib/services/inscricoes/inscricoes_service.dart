import '../../models/dto_inscricao.dart';
import '../../models/dto_inscricao_pesquisa_pessoa.dart';
import '../base_api_service.dart';

class InscricoesService {
  InscricoesService(this._apiService);

  final BaseApiService _apiService;
  
  /// Pesquisar inscrição existente por CPF
  Future<DTOInscricaoPesquisaPessoa> pesquisarCPF(int idEvento, String cpf) async {
    var response = await _apiService.get('/inscricoes/pesquisar/evento/$idEvento/cpf/$cpf');
    return DTOInscricaoPesquisaPessoa.fromJson(response.data);
  }
  
  Future<DTOInscricao> incluir(DTOInscricao inscricao) async {
    var response = await _apiService.post(
        '/inscricoes/incluir',
        body: inscricao.toJson()
    );

    return DTOInscricao.fromJson(response.data);
  }

    Future<void> atualizar(DTOInscricao inscricao) async => await _apiService.put(
      '/inscricoes/atualizar',
      body: inscricao.toJson());
}
