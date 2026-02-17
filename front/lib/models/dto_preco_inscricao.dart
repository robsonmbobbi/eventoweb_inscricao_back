import 'dto_precos_inscricao_forma.dart';

/// Representa um preço de inscrição para um tipo específico
class DTOPrecoInscricao {
  final int id;
  final int idadeMax;
  final List<DTOPrecosInscricaoForma> valores;


  DTOPrecoInscricao({
    required this.id,
    required this.idadeMax,
    required this.valores
  });

  factory DTOPrecoInscricao.fromJson(Map<String, dynamic> json) => DTOPrecoInscricao(
      id: json['id'],
      idadeMax: json['idadeMax'],
      valores: (json['valores'] as List<dynamic>)
          .map((e) => DTOPrecosInscricaoForma.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'idadeMax': idadeMax,
      'valores': valores.map((e) => e.toJson()).toList(),
    };
}
