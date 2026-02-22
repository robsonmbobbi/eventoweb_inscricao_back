import 'package:flutter/material.dart';
import 'package:front2/models/dto_evento.dart';
import '../../common/ExceptionCommand.dart';
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

  DTOEvento? _evento;

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
  String _cidade = '';
  String _uf = '';

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
    required this.inscricoesService
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
  String get cidade => _cidade;
  String get uf => _uf;

  EnumTipoInscricao? get tipoInscricao => _tipoInscricao;
  DTOInscricaoPesquisaPessoa? get pesquisa => _pesquisa;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get cpfBuscado => _cpfBuscado;
  bool get dataNascimentoInformada => _dataNascimentoInformada;
  int? get idade => _idade;
  bool get regulamentoAceito => _regulamentoAceito;

  DTOEvento? get evento => _evento;

  // Setters
  void setCpf(String value) {
    _cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setDataNascimento(DateTime? value) {
    _dataNascimento = value;
    notifyListeners();
  }

  void setRegulamentoAceito() {
    _regulamentoAceito = true;
    notifyListeners();
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

  void setCidade(String value) {
    _cidade = value;
    notifyListeners();
  }

  void setUF(String value) {
    _uf = value;
    notifyListeners();
  }

  Future<void> processarCPF() async {
    final cleanCpf = _cpf.replaceAll(RegExp(r'[^\d]'), '');
    var pesquisa = await inscricoesService.pesquisarCPF(_evento!.id!, cleanCpf);

    if (pesquisa.situacao == EnumSituacaoPesquisaPessoa.inscricaoRealizada) {
      throw ExceptionCommand("A pessoa dona deste CPF já está inscrita no evento e não poderá fazer nova inscrição.");
    }

    _pesquisa = pesquisa;
    _cpfBuscado = true;
    DTOPessoa? pessoa = null;

    if (_pesquisa!.inscricao != null) {
      pessoa = _pesquisa!.inscricao!.pessoa; 
      _tipoInscricao = _pesquisa!.inscricao!.tipo;
      _dormeEvento = _pesquisa!.inscricao!.dormeEvento;
      _instituicoesEspiritasFrequenta = _pesquisa!.inscricao!.instituicoesEspiritasFrequenta;
      _nomeCracha  = _pesquisa!.inscricao!.nomeCracha;
      _observacoes = _pesquisa!.inscricao!.observacoes;
      _cpfResponsavel1 = _pesquisa!.inscricao!.responsavel1?.cpf;
      _nomeResponsavel1= _pesquisa!.inscricao!.responsavel1?.nome;
      _cpfResponsavel2 = _pesquisa!.inscricao!.responsavel2?.cpf;
      _nomeResponsavel2= _pesquisa!.inscricao!.responsavel2?.nome;
    }
    else {
      pessoa = _pesquisa!.pessoa;
    }     

    if (pessoa != null) {
      _nome = pessoa.nome;
      _email = pessoa.email;
      _celular = pessoa.celular;
      _dataNascimento = pessoa.dataNascimento;
      //_dataNascimentoInformada = true;
      _alergiaAlimentos = pessoa.alergiaAlimentos;
      _ehDiabetico = pessoa.ehDiabetico;
      _ehVegetariano = pessoa.ehVegetariano;
      _sexo = pessoa.sexo;
      _usaAdocanteDiariamente = pessoa.usaAdocanteDiariamente;
    }    

    notifyListeners();
  }

  Future<void> processarDataNascimento() async {
    if (_dataNascimento != null) {
      _dataNascimentoInformada = true;

      _idade = await eventoService.obterIdade(_evento!.id!, _dataNascimento!);
    } else {
      _dataNascimentoInformada = false;
    }

    notifyListeners();
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
        idEvento: _evento!.id!,
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

  void init(DTOEvento evento) {
    _evento = evento;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetSearch() {
    _cpf = '';
    _cpfBuscado = false;
    _pesquisa = null;

    notifyListeners();
  }

  void resetVerification() {
    _cpf = '';
    _pesquisa = null;
    _dataNascimento = null;
    _cpfBuscado = false;
    _dataNascimentoInformada = false;

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
    _regulamentoAceito = false;
    _evento = null;

    notifyListeners();
  }
}
