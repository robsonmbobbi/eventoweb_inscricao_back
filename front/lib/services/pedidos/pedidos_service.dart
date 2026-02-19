import '../../models/dto_pedido.dart';
import '../../models/dto_resultado_pedido.dart';
import '../base_api_service.dart';

/// Service para gerenciar endpoints de pedidos/pagamentos
class PedidosService {
  PedidosService(this._apiService);

  final BaseApiService _apiService;
  
  /// Incluir novo pedido de pagamento
  Future<DTOResultadoPedido> incluirPedido(DTOPedido pedido) async {
    var response = await _apiService.post(
      '/pedidos/incluir',
      body: pedido.toJson()
    );

    return DTOResultadoPedido.fromJson(response.data);
  }
}
