import 'dto_debito_pedido.dart';
import 'enums/enum_tipo_pedido.dart';

/// Representa o resultado final de um pedido de pagamento
class DTOResultadoPedido {
  final int idPedido;
  final double valor;
  final EnumTipoPedido tipo;
  final int? idFormaPagamento;   
  final DTODebitoPedido? debito;

  DTOResultadoPedido({
    required this.idPedido,
    required this.valor,
    required this.tipo,
    this.idFormaPagamento,
    this.debito,
  });

  factory DTOResultadoPedido.fromJson(Map<String, dynamic> json) => DTOResultadoPedido(
      idPedido: json['idPedido'],
      valor: json['valor'],
      tipo: EnumTipoPedido.values[json['tipoPedido']],
      idFormaPagamento: json['idFormaPagamento'],
      debito: json['debito'] != null
          ? DTODebitoPedido.fromJson(json['debito'])
          : null,
    );

  Map<String, dynamic> toJson() => {
      'idPedido': idPedido,
      'valor': valor,
      'tipoPedido': tipo.index,
      'idFormaPagamento': idFormaPagamento,
      'debito': debito?.toJson(),
    };
}