import 'package:flutter/material.dart';
import 'package:front2/models/dto_evento.dart';
import 'package:front2/services/eventos/eventos_service.dart';
import '../../models/dto_inscricao.dart';
import '../../services/pedidos/pedidos_service.dart';

class OrdersViewModel extends ChangeNotifier {
  final EventosService _eventosService;

  OrdersViewModel(this._eventosService);

  DTOEvento? _evento;

  List<DTOInscricao> _inscricoes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DTOInscricao> get inscricoes => _inscricoes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DTOEvento? get evento => _evento;

  // Add inscription to the order
  void adicionarInscricao(DTOInscricao inscricao) {
    _inscricoes.add(inscricao);
    notifyListeners();
  }

  // Remove inscription from the order
  void removerInscricao(int index) {
    if (index >= 0 && index < _inscricoes.length) {
      _inscricoes.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> init(int idEvento) async {

    if (_evento != null) {
      throw Exception("OrdersViewModel já iniciado!");
    }

    _evento = await _eventosService.obter(idEvento);
    if (_evento == null) {
      _error = "Evento não encontrado com o id $idEvento";
    }

    notifyListeners();
  }

  // Get total inscriptions count
  int get totalInscricoes => _inscricoes.length;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset order
  void reset() {
    _evento = null;
    _inscricoes = [];
    _error = null;

    notifyListeners();
  }
}
