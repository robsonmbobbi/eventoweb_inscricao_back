import '../../models/dto_preco_inscricao.dart';
import '../base_api_service.dart';

class PrecosService {
  PrecosService(this._apiService);

  final BaseApiService _apiService;
  
  /// Obter preços de inscrição para um evento específico
  Future<DTOPrecoInscricao> obterPrecosInscricao(int idEvento, DateTime dataNascimento) async {
    var response = await _apiService.get(
      '/precosinscricao/evento/$idEvento/obter/nascimento/${dataNascimento.toIso8601String()}');

    return DTOPrecoInscricao.fromJson(response.data);
  }
}
