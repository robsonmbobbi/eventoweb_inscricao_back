import 'package:flutter/material.dart';
import 'package:front2/models/dto_forma_pagamento.dart';
import 'package:front2/models/dto_inscricao.dart';
import 'package:front2/models/enums/enum_tipo_pagamento.dart';
import 'package:front2/services/formas_pagamento/formas_pagamento_service.dart';
import 'package:front2/utils/result.dart';
import '../../models/dto_excecao.dart';
import '../../models/dto_inscricao_valor.dart';
import '../../models/dto_pedido.dart';
import '../../models/dto_resultado_pedido.dart';
import '../../models/enums/enum_tipo_pedido.dart';
import '../../services/pedidos/pedidos_service.dart';
import '../../services/precos/precos_service.dart';

class PaymentViewModel extends ChangeNotifier {

  PaymentViewModel({required this.precosService, required this.pedidosService, required this.formasPagamentoService}){
    tipoPedido.addListener(_processarAlteracaoTipo);
    formaPagamentoEscolhida.addListener(_processarAlteracaoFormaPagamento);
  }

  final PrecosService precosService;
  final PedidosService pedidosService;
  final FormasPagamentoService formasPagamentoService;

  // Payment form state
  List<DTOInscricaoValor> _inscricoes = [];
  double? _valorTotal;
  DTOExcecao? _erro;

  final ValueNotifier<EnumTipoPedido> tipoPedido = ValueNotifier<EnumTipoPedido>(EnumTipoPedido.debito);
  final ValueNotifier<String> nomePagador = ValueNotifier<String>('');
  final ValueNotifier<String> cpfPagador = ValueNotifier<String>('');
  final ValueNotifier<String> celularPagador = ValueNotifier<String>('');
  final ValueNotifier<String> emailPagador = ValueNotifier<String>('');

  // Credit card fields (shown only if forma de pagamento is credit)
  final ValueNotifier<String> numeroCartao = ValueNotifier<String>('');
  final ValueNotifier<String> nomeImpressoCartao = ValueNotifier<String>('');
  final ValueNotifier<String> mesExpiracao = ValueNotifier<String>('');
  final ValueNotifier<String> anoExpiracao = ValueNotifier<String>('');
  final ValueNotifier<String> codigoSeguranca = ValueNotifier<String>('');
  final ValueNotifier<String> nomeTitular = ValueNotifier<String>('');
  final ValueNotifier<String> emailTitular = ValueNotifier<String>('');
  final ValueNotifier<String> cpfOuCnpjTitular = ValueNotifier<String>('');
  final ValueNotifier<String> cepTitular = ValueNotifier<String>('');
  final ValueNotifier<String> numeroEnderecoTitular = ValueNotifier<String>('');
  final ValueNotifier<String> telefoneTitular = ValueNotifier<String>('');
  final ValueNotifier<int?> numeroParcelas = ValueNotifier<int?>(null);

  final ValueNotifier<String?> motivo = ValueNotifier<String?>(null);

  // State
  final ValueNotifier<List<DTOFormaPagamento>> formasPagamento = ValueNotifier<List<DTOFormaPagamento>>([]);
  final ValueNotifier<DTOFormaPagamento?> formaPagamentoEscolhida = ValueNotifier<DTOFormaPagamento?>(null);


  List<DTOInscricaoValor> get inscricoes => _inscricoes;
  double? get valorTotal  => _valorTotal;
  DTOExcecao? get erro => _erro;

  Result<void> carregarInscricoes(List<DTOInscricao> inscricoes) {
    try {
      _inscricoes =
          inscricoes
              .map((e) => DTOInscricaoValor(inscricao: e, valor: null))
              .toList();
      _valorTotal = null;
      _erro = null;

      notifyListeners();

      _processarAlteracaoTipo();

      return Result.ok(null);
    }
    catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  void _processarAlteracaoTipo() async {
    if (tipoPedido.value == EnumTipoPedido.debito){
      try {
        formasPagamento.value = await formasPagamentoService.listar();
        notifyListeners();
      } on Exception catch (e) {
        _erro = DTOExcecao(descricao: 'Alteração do tipo de pedido', excecao: e);
        notifyListeners();
      } catch(e) {
        _erro = DTOExcecao(descricao: 'Alteração do tipo de pedido', excecao: Exception(e.toString()));
        notifyListeners();
      }
    }
    else {
      _inscricoes = _inscricoes.map((e) => DTOInscricaoValor(inscricao: e.inscricao, valor: null)).toList();
      _valorTotal = null;
      _erro = null;
      notifyListeners();
    }

    formaPagamentoEscolhida.value = null;
  }

  void _processarAlteracaoFormaPagamento() async {
    if (formaPagamentoEscolhida.value == null) {
      _inscricoes = _inscricoes.map((e) => DTOInscricaoValor(inscricao: e.inscricao, valor: null)).toList();
      _valorTotal = null;
      _erro = null;
      notifyListeners();
    }
    else {
      var lista = <DTOInscricaoValor>[];
      double? total = 0.0;

      try {
        for (var inscricaoValor in _inscricoes) {
          var preco = await precosService.obterPrecosInscricao(
              inscricaoValor.inscricao.idEvento,
              inscricaoValor.inscricao.pessoa.dataNascimento!);
          if (preco == null) {
            total = null;
            lista.add(DTOInscricaoValor(
                inscricao: inscricaoValor.inscricao, valor: null));
          }
          else {
            var valor = preco.valores
                .where((e) => e.forma.id == formaPagamentoEscolhida.value!.id)
                .firstOrNull;
            if (valor == null) {
              lista.add(DTOInscricaoValor(
                  inscricao: inscricaoValor.inscricao, valor: null));
            }
            else {
              lista.add(DTOInscricaoValor(
                  inscricao: inscricaoValor.inscricao, valor: valor.valor));
              if (total != null) {
                total += valor.valor;
              }
            }
          }
        }
        _inscricoes = lista;
        _valorTotal = total;
        _erro = null;
        notifyListeners();
      }
      on Exception catch(e) {
        _erro = DTOExcecao(descricao: 'Alteração de forma de pagamento', excecao: e);
        notifyListeners();
      }
    }
  }

  // Submit payment order
  Future<Result<DTOResultadoPedido>> finalizarPedido() async {
    try {
      final pedido = DTOPedido(
        idsInscricoes: _inscricoes.map((e) => e.inscricao.id!).toList(),
        idFormaPagamento: formaPagamentoEscolhida.value?.id,
        valor: _valorTotal ?? 0.0,
        tipo: tipoPedido.value,
        celularPagador: celularPagador.value.replaceAll(RegExp(r'[^\d]'), ''),
        cpfPagador: cpfPagador.value.replaceAll(RegExp(r'[^\d]'), ''),
        emailPagador: emailPagador.value,
        nomePagador: nomePagador.value,
        motivo: motivo.value,
        dadosCartao: tipoPedido.value == EnumTipoPedido.debito && (formaPagamentoEscolhida.value!.tipo == EnumTipoPagamento.credito)
            ? DadosCartaoCredito(
          numeroCartao: numeroCartao.value.replaceAll(RegExp(r'[^\d]'), ''),
          nomeImpressoCartao: nomeImpressoCartao.value,
          mesExpiracao: mesExpiracao.value,
          anoExpiracao: anoExpiracao.value,
          codigoSeguranca: codigoSeguranca.value,
          nomeTitular: nomeTitular.value,
          emailTitular: emailTitular.value,
          cpfouCnpjTitular: cpfOuCnpjTitular.value.replaceAll(RegExp(r'[^\d]'), ''),
          cepTitular: cepTitular.value,
          numeroEnderecoTitular: numeroEnderecoTitular.value,
          telefoneTitular: telefoneTitular.value,
          numeroParcelas: numeroParcelas.value,
        )
            : null,
      );

      return Result.ok(await pedidosService.incluirPedido(pedido));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
