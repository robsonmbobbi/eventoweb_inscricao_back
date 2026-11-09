import 'enums/enums.dart';

/// Representa um pedido/pagamento a ser enviado para o servidor
class DTOPedido {
  final List<int> idsInscricoes;
  final double valor;
  final EnumTipoPedido tipo;
  final int? idFormaPagamento;
  final String nomePagador;
  final String cpfPagador;
  final String celularPagador;
  final String emailPagador;
  final DadosCartaoCredito? dadosCartao;
  final String? motivo;

  DTOPedido({
    required this.idsInscricoes,
    required this.valor,
    required this.tipo,
    required this.nomePagador,
    required this.cpfPagador,
    required this.celularPagador,
    required this.emailPagador,
    this.idFormaPagamento,
    this.dadosCartao,
    this.motivo
  });

  factory DTOPedido.fromJson(Map<String, dynamic> json) => DTOPedido(

    idsInscricoes: json['idsInscricoes'],
    idFormaPagamento: json['idFormaPagamento'],
    valor: (json['valor'] as num).toDouble(),
    tipo: EnumTipoPedido.values[json['tipo']],
    nomePagador: json['nomePagador'],
    cpfPagador: json['cpfPagador'],
    celularPagador: json['celularPagador'],
    emailPagador: json['emailPagador'],
    motivo: json['motivo'],
    dadosCartao: json['dadosCartao'] != null
          ? DadosCartaoCredito.fromJson(json['dadosCartao'])
          : null,
    );

  Map<String, dynamic> toJson() => {
      'idsInscricoes': idsInscricoes,
      'idFormaPagamento': idFormaPagamento,
      'valor': valor,
      'tipo': tipo.index,
      'nomePagador': nomePagador,
      'cpfPagador': cpfPagador,
      'celularPagador': celularPagador,
      'emailPagador': emailPagador,
      'motivo': motivo,
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
