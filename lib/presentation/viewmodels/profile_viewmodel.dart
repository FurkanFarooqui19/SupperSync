import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Profile display + impact metrics state.
///
/// MVVM Rule: No setState() — notifyListeners() only.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._authRepository);

  final AuthRepository _authRepository;

  // ── State ──────────────────────────────────────────────────────────────────
  Map<String, double> _impact = {};
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  Map<String, double> get impact => _impact;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  double get weightSaved => _impact['weight_saved_kg'] ?? 0;
  double get costSaved => _impact['cost_saved'] ?? 0;
  double get carbonOffset => _impact['carbon_offset_kg'] ?? 0;

  // ── Load impact data ───────────────────────────────────────────────────────
  Future<void> loadImpact(String userId) async {
    _setLoading(true);
    try {
      _impact = await _authRepository.fetchImpactSummary(userId);
    } on AppException catch (e) {
      _setError(e.message);
    } finally {
      _hasLoaded = true;
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }
}
