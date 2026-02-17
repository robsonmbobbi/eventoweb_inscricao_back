import 'package:flutter/material.dart';
import '../../models/dto_evento.dart';
import '../../services/eventos/eventos_service.dart';

class EventsViewModel extends ChangeNotifier {
  final EventosService apiService;

  List<DTOEvento> _eventos = [];
  bool _isLoading = false;
  String? _error;

  EventsViewModel({required this.apiService});

  // Getters
  List<DTOEvento> get eventos => _eventos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load events from API
  Future<void> loadEventos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _eventos = await apiService.listar();
      _error = null;
    } on Exception catch (e) {
      _error = e.toString();
      _eventos = [];
    } catch (e) {
      _error = 'Erro desconhecido ao carregar eventos';
      _eventos = [];
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
}
