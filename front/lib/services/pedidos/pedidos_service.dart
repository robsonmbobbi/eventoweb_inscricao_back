import '../../models/dto_pedido.dart';
import '../../models/dto_resultado_pedido.dart';
import '../base_api_service.dart';

/// Service para gerenciar endpoints de pedidos/pagamentos
class PedidosService extends BaseApiService {
  PedidosService(super.httpClient);
  
  /// Incluir novo pedido de pagamento
  Future<DTOResultadoPedido> incluirPedido(DTOPedido pedido) async => post(
      '/pedidos/incluir',
      body: pedido.toJson(),
      parser: DTOResultadoPedido.fromJson,
    );
}
