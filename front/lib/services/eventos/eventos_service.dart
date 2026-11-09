import '../../models/dto_evento.dart';
import '../base_api_service.dart';

class EventosService {

  EventosService(this._apiService);

  final BaseApiService _apiService;
  
  Future<List<DTOEvento>?> listar() async {
    var response = await _apiService.get('/eventos/listar');
    if (response.data != null && response.data.isNotEmpty) {
      return List<DTOEvento>.from(
          response.data.map((e) => DTOEvento.fromJson(e)));
    }

    return [];
  }

  Future<DTOEvento?> obter(int id) async {
    var response = await _apiService.get('/eventos/obter/$id');
    if (response.data != null && response.data.isNotEmpty) {
      return DTOEvento.fromJson(response.data);
    }

    return null;
  }


  Future<int> obterIdade(int idEvento, DateTime dataNascimento) async {

    var response = await _apiService.get('/eventos/$idEvento/obter-idade/${dataNascimento.toIso8601String()}');
    if (response.data != null && response.data.isNotEmpty) {
      return response.data['idade'] as int;
    }

    return -1;
  }
}
