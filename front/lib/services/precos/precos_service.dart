import '../../models/dto_preco_inscricao.dart';
import '../base_api_service.dart';

/// Service para gerenciar endpoints de preços de inscrição
class PrecosService extends BaseApiService {
  PrecosService(super.httpClient);
  
  /// Obter preços de inscrição para um evento específico
  Future<DTOPrecoInscricao> obterPrecosInscricao(int idEvento, DateTime dataNascimento) async => get(
      '/precosinscricao/evento/$idEvento/obter/nascimento/${dataNascimento.toIso8601String()}',
      parser: DTOPrecoInscricao.fromJson,
    );
}
