import 'dto_inscricao.dart';
import 'dto_pessoa.dart';
import 'enums/enums.dart';

/// Representa o resultado da pesquisa de inscrição por CPF
class DTOInscricaoPesquisaPessoa {
  final EnumSituacaoPesquisaPessoa situacao;
  final DTOInscricao? inscricao;
  final DTOPessoa? pessoa;

  DTOInscricaoPesquisaPessoa({
    required this.situacao,
    this.inscricao,
    this.pessoa,
  });

  factory DTOInscricaoPesquisaPessoa.fromJson(Map<String, dynamic> json) => DTOInscricaoPesquisaPessoa(
      situacao: EnumSituacaoPesquisaPessoa.values[json['situacao']],
      inscricao: json['inscricao'] != null ? DTOInscricao.fromJson(json['inscricao']) : null,
      pessoa: json['pessoa'] != null ? DTOPessoa.fromJson(json['pessoa']) : null,
    );

  Map<String, dynamic> toJson() => {
      'situacao': situacao.index,
      'inscricao': inscricao?.toJson(),
      'pessoa': pessoa?.toJson(),
    };
}




