import 'package:front2/services/formas_pagamento/formas_pagamento_service.dart';
import 'package:get_it/get_it.dart';

import '../services/base_api_service.dart';
import '../services/eventos/eventos_service.dart';
import '../services/inscricoes/inscricoes_service.dart';
import '../services/pedidos/pedidos_service.dart';
import '../services/precos/precos_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    var baseUrl = 'http://localhost:5020/api';

    getIt
     .. registerFactory(()=> BaseApiService(baseUrl))
     ..registerFactory<EventosService>(() => EventosService(getIt()))
     ..registerFactory<InscricoesService>(() => InscricoesService(getIt()))
     ..registerFactory<PedidosService>(() => PedidosService(getIt()))
     ..registerFactory<PrecosService>(() => PrecosService(getIt()))
     ..registerFactory<FormasPagamentoService>(()=> FormasPagamentoService(getIt()));

    // More services can be registered here as needed
  }
}
