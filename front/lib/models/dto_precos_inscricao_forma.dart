import 'dto_forma_pagamento.dart';

/// Representa os preços de inscrição agrupados por forma de pagamento
class DTOPrecosInscricaoForma {
  final DTOFormaPagamento forma;
  final double valor;

  DTOPrecosInscricaoForma({
    required this.forma,
    required this.valor,
  });

  factory DTOPrecosInscricaoForma.fromJson(Map<String, dynamic> json) => DTOPrecosInscricaoForma(
      forma: DTOFormaPagamento.fromJson(json['forma']),
      valor: (json['preco'] as num).toDouble()
    );

  Map<String, dynamic> toJson() => {
      'forma': forma.toJson(),
      'preco': valor
    };
}
