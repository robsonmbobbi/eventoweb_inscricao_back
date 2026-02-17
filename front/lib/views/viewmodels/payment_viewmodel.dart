import 'package:flutter/material.dart';
import '../../models/dto_pedido.dart';
import '../../models/dto_preco_inscricao.dart';
import '../../models/dto_precos_inscricao_forma.dart';
import '../../models/dto_resultado_pedido.dart';
import '../../models/enums/enum_tipo_pedido.dart';
import '../../services/pedidos/pedidos_service.dart';
import '../../services/precos/precos_service.dart';

class PaymentViewModel extends ChangeNotifier {

  PaymentViewModel({required this.precosService, required this.pedidosService});

  final PrecosService precosService;
  final PedidosService pedidosService;

  // Payment form state
  EnumTipoPedido _tipoPedido = EnumTipoPedido.debito;
  int? _idFormaPagamento;
  double _valorTotal = 0.0;
  String _nomePagador = '';
  String _cpfPagador = '';
  String _celularPagador = '';
  String _emailPagador = '';
  String? _descricaoPedido;

  // Credit card fields (shown only if forma de pagamento is credit)
  String _numeroCartao = '';
  String _nomeImpressoCartao = '';
  String _mesExpiracao = '';
  String _anoExpiracao = '';
  String _codigoSeguranca = '';
  String _nomeTitular = '';
  String _emailTitular = '';
  String _cpfOuCnpjTitular = '';
  String _cepTitular = '';
  String _numeroEnderecoTitular = '';
  String _telefoneTitular = '';
  int _numeroParcelas = 1;

  // State
  DTOPrecoInscricao? _precoDisponivel;
  List<DTOPrecosInscricaoForma>? _formasPagamento;
  bool _isLoading = false;
  String? _error;
  DTOResultadoPedido? _resultado;

  // Getters
  EnumTipoPedido get tipoPedido => _tipoPedido;
  int? get idFormaPagamento => _idFormaPagamento;
  double get valorTotal => _valorTotal;
  String get nomePagador => _nomePagador;
  String get cpfPagador => _cpfPagador;
  String get celularPagador => _celularPagador;
  String get emailPagador => _emailPagador;
  String? get descricaoPedido => _descricaoPedido;

  String get numeroCartao => _numeroCartao;
  String get nomeImpressoCartao => _nomeImpressoCartao;
  String get mesExpiracao => _mesExpiracao;
  String get anoExpiracao => _anoExpiracao;
  String get codigoSeguranca => _codigoSeguranca;
  String get nomeTitular => _nomeTitular;
  String get emailTitular => _emailTitular;
  String get cpfOuCnpjTitular => _cpfOuCnpjTitular;
  String get cepTitular => _cepTitular;
  String get numeroEnderecoTitular => _numeroEnderecoTitular;
  String get telefoneTitular => _telefoneTitular;
  int get numeroParcelas => _numeroParcelas;

  DTOPrecoInscricao? get precoDisponivel => _precoDisponivel;
  List<DTOPrecosInscricaoForma>? get formasPagamento => _formasPagamento;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DTOResultadoPedido? get resultado => _resultado;

  // Setters
  void setTipoPedido(EnumTipoPedido value) {
    _tipoPedido = value;
    notifyListeners();
  }

  void setIdFormaPagamento(int? value) {
    _idFormaPagamento = value;
    notifyListeners();
  }

  void setValorTotal(double value) {
    _valorTotal = value;
    notifyListeners();
  }

  void setNomePagador(String value) {
    _nomePagador = value;
    notifyListeners();
  }

  void setCpfPagador(String value) {
    _cpfPagador = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setCelularPagador(String value) {
    _celularPagador = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setEmailPagador(String value) {
    _emailPagador = value;
    notifyListeners();
  }

  void setDescricaoPedido(String? value) {
    _descricaoPedido = value;
    notifyListeners();
  }

  void setNumeroCartao(String value) {
    _numeroCartao = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setNomeImpressoCartao(String value) {
    _nomeImpressoCartao = value;
    notifyListeners();
  }

  void setMesExpiracao(String value) {
    _mesExpiracao = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setAnoExpiracao(String value) {
    _anoExpiracao = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setCodigoSeguranca(String value) {
    _codigoSeguranca = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setNomeTitular(String value) {
    _nomeTitular = value;
    notifyListeners();
  }

  void setEmailTitular(String value) {
    _emailTitular = value;
    notifyListeners();
  }

  void setCpfOuCnpjTitular(String value) {
    _cpfOuCnpjTitular = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setCepTitular(String value) {
    _cepTitular = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setNumeroEnderecoTitular(String value) {
    _numeroEnderecoTitular = value;
    notifyListeners();
  }

  void setTelefoneTitular(String value) {
    _telefoneTitular = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setNumeroParcelas(int value) {
    _numeroParcelas = value;
    notifyListeners();
  }

  // Load payment forms for a given date of birth
  Future<void> carregarFormasPagamento(int idEvento, DateTime dataNascimento) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _precoDisponivel = await precosService.obterPrecosInscricao(idEvento, dataNascimento);
      _formasPagamento = _precoDisponivel?.valores;
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _precoDisponivel = null;
      _formasPagamento = null;
    } catch (e) {
      _error = 'Erro ao carregar formas de pagamento';
      _precoDisponivel = null;
      _formasPagamento = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit payment order
  Future<bool> finalizarPedido(List<int> idsInscricoes) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pedido = DTOPedido(
        idsInscricoes: idsInscricoes,
        idForma: _idFormaPagamento ?? 0,
        valor: _valorTotal,
        tipo: _tipoPedido,
        descricao: _descricaoPedido,
        dadosCartao: _tipoPedido == EnumTipoPedido.debito && (_idFormaPagamento != null)
            ? DadosCartaoCredito(
                numeroCartao: _numeroCartao,
                nomeImpressoCartao: _nomeImpressoCartao,
                mesExpiracao: _mesExpiracao,
                anoExpiracao: _anoExpiracao,
                codigoSeguranca: _codigoSeguranca,
                nomeTitular: _nomeTitular,
                emailTitular: _emailTitular,
                cpfouCnpjTitular: _cpfOuCnpjTitular,
                cepTitular: _cepTitular,
                numeroEnderecoTitular: _numeroEnderecoTitular,
                telefoneTitular: _telefoneTitular,
                numeroParcelas: _numeroParcelas,
              )
            : null,
      );

      _resultado = await pedidosService.incluirPedido(pedido);
      _error = null;
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      _resultado = null;
      return false;
    } catch (e) {
      _error = 'Erro ao finalizar pedido';
      _resultado = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset form
  void reset() {
    _tipoPedido = EnumTipoPedido.debito;
    _idFormaPagamento = null;
    _valorTotal = 0.0;
    _nomePagador = '';
    _cpfPagador = '';
    _celularPagador = '';
    _emailPagador = '';
    _descricaoPedido = null;
    _numeroCartao = '';
    _nomeImpressoCartao = '';
    _mesExpiracao = '';
    _anoExpiracao = '';
    _codigoSeguranca = '';
    _nomeTitular = '';
    _emailTitular = '';
    _cpfOuCnpjTitular = '';
    _cepTitular = '';
    _numeroEnderecoTitular = '';
    _telefoneTitular = '';
    _numeroParcelas = 1;
    _precoDisponivel = null;
    _formasPagamento = null;
    _error = null;
    _resultado = null;
    notifyListeners();
  }
}
