import 'package:flutter/foundation.dart';
import '../../data/models/observation_model.dart';
import '../../data/repositories/observation_repository.dart';

enum LoadingState { idle, loading, success, error }

class ObservationProvider extends ChangeNotifier {
  final ObservationRepository _repo = ObservationRepository();

  List<ObservationModel> _observations = [];
  LoadingState           _state        = LoadingState.idle;
  String?                _errorMessage;

  // Filtros activos
  String? _filtroCategoria;
  String? _filtroFechaDesde;
  String? _filtroFechaHasta;

  // ── Getters ───────────────────────────────────────────────
  List<ObservationModel> get observations  => _observations;
  LoadingState           get state         => _state;
  String?                get errorMessage  => _errorMessage;
  String?                get filtroCategoria => _filtroCategoria;
  bool get hasActiveFilters =>
      _filtroCategoria != null ||
      _filtroFechaDesde != null ||
      _filtroFechaHasta != null;

  // ── Cargar observaciones ──────────────────────────────────
  Future<void> loadObservations() async {
    _setState(LoadingState.loading);
    try {
      _observations = await _repo.getAll(
        categoria:  _filtroCategoria,
        fechaDesde: _filtroFechaDesde,
        fechaHasta: _filtroFechaHasta,
      );
      _setState(LoadingState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(LoadingState.error);
    }
  }

  // ── Guardar ───────────────────────────────────────────────
  Future<bool> saveObservation(ObservationModel obs) async {
    try {
      await _repo.save(obs);
      await loadObservations(); // Recarga la lista completa
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Eliminar una ─────────────────────────────────────────
  Future<bool> deleteObservation(int id) async {
    try {
      await _repo.delete(id);
      _observations.removeWhere((o) => o.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Borrar todo ───────────────────────────────────────────
  Future<bool> deleteAll() async {
    try {
      await _repo.deleteAll();
      _observations = [];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Filtros ───────────────────────────────────────────────
  void setFiltroCategoria(String? categoria) {
    _filtroCategoria = categoria;
    loadObservations();
  }

  void clearFilters() {
    _filtroCategoria  = null;
    _filtroFechaDesde = null;
    _filtroFechaHasta = null;
    loadObservations();
  }

  // ── Helpers ───────────────────────────────────────────────
  void _setState(LoadingState s) {
    _state = s;
    notifyListeners();
  }
}