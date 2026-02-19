import 'package:flutter/material.dart';
import '../../models/dto_inscricao.dart';
import '../../models/dto_inscricao_pesquisa_pessoa.dart';
import '../../models/dto_pessoa.dart';
import '../../models/dto_responsavel.dart';
import '../../models/enums/enum_sexo.dart';
import '../../models/enums/enum_situacao_pesquisa_pessoa.dart';
import '../../models/enums/enum_tipo_inscricao.dart';
import '../../services/eventos/eventos_service.dart';
import '../../services/inscricoes/inscricoes_service.dart';

class RegistrationViewModel extends ChangeNotifier {
  final EventosService eventoService;
  final InscricoesService inscricoesService;
  final int idEvento;

  // Form state
  String _cpf = '';
  DateTime? _dataNascimento;
  String _nome = '';
  String? _alergiaAlimentos;
  String _celular = '';
  bool _ehDiabetico = false;
  bool _ehVegetariano = false;
  String _email = '';
  EnumSexo? _sexo;
  bool _usaAdocanteDiariamente = false;
  String? _instituicoesEspiritasFrequenta;
  bool _dormeEvento = true;
  String? _nomeCracha;
  String? _observacoes;
  String? _cpfResponsavel1;
  String? _nomeResponsavel1;
  String? _cpfResponsavel2;
  String? _nomeResponsavel2;

  // State
  DTOInscricaoPesquisaPessoa? _pesquisa;
  bool _cpfBuscado = false;
  bool _dataNascimentoInformada = false;
  bool _regulamentoAceito = false;

  EnumTipoInscricao? _tipoInscricao;

  bool _isLoading = false;
  String? _error;
  int? _idade;

  RegistrationViewModel({
    required this.eventoService,
    required this.inscricoesService,
    required this.idEvento,
  });

  // Getters
  String get cpf => _cpf;
  DateTime? get dataNascimento => _dataNascimento;
  String get nome => _nome;
  String? get alergiaAlimentos => _alergiaAlimentos;
  String get celular => _celular;
  bool get ehDiabetico => _ehDiabetico;
  bool get ehVegetariano => _ehVegetariano;
  String get email => _email;
  EnumSexo? get sexo => _sexo;
  bool get usaAdocanteDiariamente => _usaAdocanteDiariamente;
  String? get instituicoesEspiritasFrequenta => _instituicoesEspiritasFrequenta;
  bool get dormeEvento => _dormeEvento;
  String? get nomeCracha => _nomeCracha;
  String? get observacoes => _observacoes;
  String? get cpfResponsavel1 => _cpfResponsavel1;
  String? get nomeResponsavel1 => _nomeResponsavel1;
  String? get cpfResponsavel2 => _cpfResponsavel2;
  String? get nomeResponsavel2 => _nomeResponsavel2;

  EnumTipoInscricao? get tipoInscricao => _tipoInscricao;
  DTOInscricaoPesquisaPessoa? get pesquisa => _pesquisa;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get cpfBuscado => _cpfBuscado;
  bool get dataNascimentoInformada => _dataNascimentoInformada;
  int? get idade => _idade;
  bool get regulamentoAceito => _regulamentoAceito;

  // Setters
  void setCpf(String value) {
    _cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setDataNascimento(DateTime? value) {
    _dataNascimento = value;
    if (value != null) {
      _dataNascimentoInformada = true;
    } else {
      _dataNascimentoInformada = false;
    }
    notifyListeners();
  }

  void setRegulamentoAceito() {
    _regulamentoAceito = true;
  }

  void setNome(String value) {
    _nome = value;
    notifyListeners();
  }

  void setAlergiaAlimentos(String? value) {
    _alergiaAlimentos = value;
    notifyListeners();
  }

  void setCelular(String value) {
    _celular = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setEhDiabetico(bool value) {
    _ehDiabetico = value;
    notifyListeners();
  }

  void setEhVegetariano(bool value) {
    _ehVegetariano = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setSexo(EnumSexo? value) {
    _sexo = value;
    notifyListeners();
  }

  void setUsaAdocanteDiariamente(bool value) {
    _usaAdocanteDiariamente = value;
    notifyListeners();
  }

  void setInstituicoesEspiritasFrequenta(String? value) {
    _instituicoesEspiritasFrequenta = value;
    notifyListeners();
  }

  void setDormeEvento(bool value) {
    _dormeEvento = value;
    notifyListeners();
  }

  void setNomeCracha(String? value) {
    _nomeCracha = value;
    notifyListeners();
  }

  void setObservacoes(String? value) {
    _observacoes = value;
    notifyListeners();
  }

  void setCpfResponsavel1(String? value) {
    _cpfResponsavel1 = value?.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setNomeResponsavel1(String? value) {
    _nomeResponsavel1 = value;
    notifyListeners();
  }

  void setCpfResponsavel2(String? value) {
    _cpfResponsavel2 = value?.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setNomeResponsavel2(String? value) {
    _nomeResponsavel2 = value;
    notifyListeners();
  }

  // Search CPF
  Future<void> pesquisarCPF(String cpf) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cleanCpf = cpf.replaceAll(RegExp(r'[^\d]'), '');
      _pesquisa = await inscricoesService.pesquisarCPF(idEvento, cleanCpf);
      _cpfBuscado = true;

      // If inscription found, load data
      if (_pesquisa!.pessoa != null) {
        _nome = _pesquisa!.pessoa!.nome;
        _email = _pesquisa!.pessoa!.email;
        _celular = _pesquisa!.pessoa!.celular;
        _dataNascimento = _pesquisa!.pessoa!.dataNascimento;
        _dataNascimentoInformada = true;
        _alergiaAlimentos = _pesquisa!.pessoa!.alergiaAlimentos;
        _ehDiabetico = _pesquisa!.pessoa!.ehDiabetico;
        _ehVegetariano = _pesquisa!.pessoa!.ehVegetariano;
        _sexo = _pesquisa!.pessoa!.sexo;
        _usaAdocanteDiariamente = _pesquisa!.pessoa!.usaAdocanteDiariamente;
      }

      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _pesquisa = null;
    } catch (e) {
      _error = 'Erro ao pesquisar CPF $e';
      _pesquisa = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate age
  Future<void> calcularIdade(DateTime dataNascimento) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _idade = await eventoService.obterIdade(idEvento, dataNascimento);
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _idade = null;
    } catch (e) {
      _error = 'Erro ao calcular idade $e';
      _idade = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save registration
  Future<DTOInscricao?> salvarInscricao() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pessoa = DTOPessoa(
        nome: _nome,
        dataNascimento: _dataNascimento!,
        cpf: _cpf,
        alergiaAlimentos: _alergiaAlimentos,
        celular: _celular,
        ehDiabetico: _ehDiabetico,
        ehVegetariano: _ehVegetariano,
        email: _email,
        sexo: _sexo,
        usaAdocanteDiariamente: _usaAdocanteDiariamente,
      );

      final inscricao = DTOInscricao(
        id: _pesquisa?.inscricao?.id,
        tipo: _tipoInscricao ?? EnumTipoInscricao.adulto,
        idEvento: idEvento,
        instituicoesEspiritasFrequenta: _instituicoesEspiritasFrequenta,
        dormeEvento: _dormeEvento,
        nomeCracha: _nomeCracha,
        observacoes: _observacoes,
        pessoa: pessoa,
        responsavel1: _tipoInscricao == EnumTipoInscricao.infantil && _cpfResponsavel1 != null
            ? DTOResponsavel(
                idInscricao: 0,
                cpf: _cpfResponsavel1,
                nome: _nomeResponsavel1,
              )
            : null,
        responsavel2: _tipoInscricao == EnumTipoInscricao.infantil && _cpfResponsavel2 != null
            ? DTOResponsavel(
                idInscricao: 0,
                cpf: _cpfResponsavel2,
                nome: _nomeResponsavel2,
              )
            : null,
      );

      DTOInscricao resultado;
      if (_pesquisa?.situacao == EnumSituacaoPesquisaPessoa.inscricaoNaoExiste) {
        resultado = (await inscricoesService.incluir(inscricao));
      } else {
        await inscricoesService.atualizar(inscricao);
        resultado = inscricao;
      }

      _error = null;
      return resultado;
    } on Exception catch (e) {
      _error = e.toString();
      return null;
    } catch (e) {
      _error = 'Erro ao salvar inscrição';
      return null;
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
    _cpf = '';
    _dataNascimento = null;
    _nome = '';
    _alergiaAlimentos = null;
    _celular = '';
    _ehDiabetico = false;
    _ehVegetariano = false;
    _email = '';
    _sexo = null;
    _usaAdocanteDiariamente = false;
    _instituicoesEspiritasFrequenta = null;
    _dormeEvento = true;
    _nomeCracha = null;
    _observacoes = null;
    _cpfResponsavel1 = null;
    _nomeResponsavel1 = null;
    _cpfResponsavel2 = null;
    _nomeResponsavel2 = null;
    _tipoInscricao = null;
    _pesquisa = null;
    _isLoading = false;
    _error = null;
    _cpfBuscado = false;
    _dataNascimentoInformada = false;
    _idade = null;
    notifyListeners();
  }
}
