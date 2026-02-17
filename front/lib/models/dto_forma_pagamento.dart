import 'enums/enum_tipo_integracao.dart';

/// Representa uma forma de pagamento
class DTOFormaPagamento {

  DTOFormaPagamento({
    this.id,
    required this.nome,
    required this.nrParcelasMinima,
    required this.nrParcelasMaxima,
    required this.tipo,
  });

  final int? id;
  final String nome;
  final int nrParcelasMinima;
  final int nrParcelasMaxima;
  final EnumTipoIntegracao tipo;

  
  factory DTOFormaPagamento.fromJson(Map<String, dynamic> json) => DTOFormaPagamento(
      id: json['Id'],
      nome: json['Nome'],
      nrParcelasMinima: json['NrParcelasMinima'],
      nrParcelasMaxima: json['NrParcelasMaxima'],
      tipo: EnumTipoIntegracao.values.firstWhere(
        (e) => e.toString().split('.').last == json['Tipo'],
        orElse: () => EnumTipoIntegracao.creditoVista, // Valor padrão
      ),
    );

  Map<String, dynamic> toJson() => {
      'Id': id,
      'Nome': nome,
      'NrParcelasMinima': nrParcelasMinima,
      'NrParcelasMaxima': nrParcelasMaxima,
      'Tipo': tipo.toString().split('.').last,
    };
}
