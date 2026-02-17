import 'package:get_it/get_it.dart';

import '../services/eventos/eventos_service.dart';
import '../services/inscricoes/inscricoes_service.dart';
import '../services/pedidos/pedidos_service.dart';
import '../services/precos/precos_service.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setup() async {
    var baseUrl = 'http://localhost:3000/api';

    getIt
     ..registerFactory<EventosService>(() => EventosService(baseUrl))
     ..registerFactory<InscricoesService>(() => InscricoesService(baseUrl))
     ..registerFactory<PedidosService>(() => PedidosService(baseUrl))
     ..registerFactory<PrecosService>(() => PrecosService(baseUrl));

    // More services can be registered here as needed
  }
}
