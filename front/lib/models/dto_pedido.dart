import 'enums/enums.dart';

/// Representa um pedido/pagamento a ser enviado para o servidor
class DTOPedido {
  final List<int> idsInscricoes;
  final int idForma;
  final double valor;
  final EnumTipoPedido tipo;
  final String? descricao;
  final DadosCartaoCredito? dadosCartao;

  DTOPedido({
    required this.idsInscricoes,
    required this.idForma,
    required this.valor,
    required this.tipo,
    this.descricao,
    this.dadosCartao,
  });

  factory DTOPedido.fromJson(Map<String, dynamic> json) => DTOPedido(
      idsInscricoes: json['idInscricao'],
      idForma: json['idForma'],
      valor: (json['valor'] as num).toDouble(),
      tipo: EnumTipoPedido.values[json['tipo']],
      descricao: json['descricao'],
      dadosCartao: json['dadosCartao'] != null
          ? DadosCartaoCredito.fromJson(json['dadosCartao'])
          : null,
    );

  Map<String, dynamic> toJson() => {
      'idInscricao': idsInscricoes,
      'idForma': idForma,
      'valor': valor,
      'tipo': tipo.index,
      'descricao': descricao,
      'dadosCartao': dadosCartao?.toJson(),
    };
}

/// Representa os dados de um cartão de crédito para pagamento
class DadosCartaoCredito {
  final String numeroCartao;
  final String nomeImpressoCartao;
  final String mesExpiracao;
  final String anoExpiracao;
  final String codigoSeguranca;

  final String nomeTitular;
  final String emailTitular;
  final String cpfouCnpjTitular;
  final String cepTitular;
  final String numeroEnderecoTitular;
  final String telefoneTitular;

  final int? numeroParcelas;

  DadosCartaoCredito({
    required this.numeroCartao,
    required this.nomeImpressoCartao,
    required this.mesExpiracao,
    required this.anoExpiracao,
    required this.codigoSeguranca,
    required this.nomeTitular,
    required this.emailTitular,
    required this.cpfouCnpjTitular,
    required this.cepTitular,
    required this.numeroEnderecoTitular,
    required this.telefoneTitular,
    this.numeroParcelas,
  });

  factory DadosCartaoCredito.fromJson(Map<String, dynamic> json) => DadosCartaoCredito(
      numeroCartao: json['numeroCartao'],
      nomeImpressoCartao: json['nomeImpressoCartao'],
      mesExpiracao: json['mesExpiracao'],
      anoExpiracao: json['anoExpiracao'],
      codigoSeguranca: json['codigoSeguranca'],
      nomeTitular: json['nomeTitular'],
      emailTitular: json['emailTitular'],
      cpfouCnpjTitular: json['cpfouCnpjTitular'],
      cepTitular: json['cepTitular'],
      numeroEnderecoTitular: json['numeroEnderecoTitular'],
      telefoneTitular: json['telefoneTitular'],
      numeroParcelas: json['numeroParcelas'],
    );

  Map<String, dynamic> toJson() => {
      'numeroCartao': numeroCartao,
      'nomeImpressoCartao': nomeImpressoCartao,
      'mesExpiracao': mesExpiracao,
      'anoExpiracao': anoExpiracao,
      'codigoSeguranca': codigoSeguranca,
      'nomeTitular': nomeTitular,
      'emailTitular': emailTitular,
      'cpfouCnpjTitular': cpfouCnpjTitular,
      'cepTitular': cepTitular,
      'numeroEnderecoTitular': numeroEnderecoTitular,
      'telefoneTitular': telefoneTitular,
      'numeroParcelas': numeroParcelas,
    };
}
