import 'enums/enum_tipo_pagamento.dart';

/// Representa uma forma de pagamento
class DTOFormaPagamento {

  DTOFormaPagamento({
    required this.id,
    required this.nome,
    required this.nrParcelasMinima,
    required this.nrParcelasMaxima,
    required this.tipo,
  });

  final int id;
  final String nome;
  final int nrParcelasMinima;
  final int nrParcelasMaxima;
  final EnumTipoPagamento tipo;

  
  factory DTOFormaPagamento.fromJson(Map<String, dynamic> json) => DTOFormaPagamento(
      id: json['id'],
      nome: json['nome'],
      nrParcelasMinima: json['nrParcelasMinima'],
      nrParcelasMaxima: json['nrParcelasMaxima'],
      tipo: EnumTipoPagamento.values[json['tipo']]
    );

  Map<String, dynamic> toJson() => {
      'Id': id,
      'Nome': nome,
      'NrParcelasMinima': nrParcelasMinima,
      'NrParcelasMaxima': nrParcelasMaxima,
      'Tipo': tipo.toString().split('.').last,
    };
}
