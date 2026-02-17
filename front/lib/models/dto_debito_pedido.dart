import 'enums/enums.dart';

/// Representa um débito de um pedido de pagamento
class DTODebitoPedido {
  final EnumTipoIntegracao tipoIntegracao;
  final EnumStatusTransacao status;
  final String? imagemQRCodePixBase64;
  final String? pixCopiaECola;

  DTODebitoPedido({
    required this.tipoIntegracao,
    required this.status,
    this.imagemQRCodePixBase64,
    this.pixCopiaECola,
  });

  factory DTODebitoPedido.fromJson(Map<String, dynamic> json) => DTODebitoPedido(
      tipoIntegracao: EnumTipoIntegracao.values[json['tipoIntegracao']],
      status: EnumStatusTransacao.values[json['status']],
      imagemQRCodePixBase64: json['imagemQRCodePixBase64'],
      pixCopiaECola: json['pixCopiaECola'],
    );

  Map<String, dynamic> toJson() => {
      'tipoIntegracao': tipoIntegracao.index,
      'status': status.index,
      'imagemQRCodePixBase64': imagemQRCodePixBase64,
      'pixCopiaECola': pixCopiaECola,
    };
}