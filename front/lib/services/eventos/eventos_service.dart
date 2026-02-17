import '../../models/dto_evento.dart';
import '../base_api_service.dart';

/// Service para gerenciar endpoints de eventos
class EventosService extends BaseApiService {
  EventosService(super.httpClient);
  
  Future<List<DTOEvento>> listar() async => get(
      '/eventos/listar',
      parser: (json) {
        final eventos = json['eventos'] as List? ?? [];
        return eventos.map((e) => DTOEvento.fromJson(e as Map<String, dynamic>)).toList();
      },
    );

  Future<int> obterIdade(int idEvento, DateTime dataNascimento) async => get(
      '/eventos/$idEvento/obter-idade/${dataNascimento.toIso8601String()}',
      parser: (json) => json['idade'] as int,
    );
}
