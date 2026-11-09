import 'package:front2/models/dto_forma_pagamento.dart';

import '../base_api_service.dart';

class FormasPagamentoService {

  FormasPagamentoService(this._apiService);

  final BaseApiService _apiService;
  
  Future<List<DTOFormaPagamento>> listar() async {
    var response = await _apiService.get('/formaspagamento/listar');
    if (response.data != null && response.data.isNotEmpty) {
      return List<DTOFormaPagamento>.from(
          response.data.map((e) => DTOFormaPagamento.fromJson(e)));
    }

    return [];
  }
}
