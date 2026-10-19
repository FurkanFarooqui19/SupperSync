import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/event_model.dart';
import '../../data/models/pantry_item_model.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/pantry_repository.dart';

/// Home dashboard state — expiring items + upcoming events + quick stats.
///
/// MVVM Rule: No setState() — notifyListeners() only.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._pantryRepo, this._eventRepo);

  final PantryRepository _pantryRepo;
  final EventRepository _eventRepo;

  // ── State ──────────────────────────────────────────────────────────────────
  List<PantryItemModel> _expiringSoon = [];
  List<EventModel> _upcomingEvents = [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;

  List<PantryItemModel> get expiringSoon => _expiringSoon;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;

  int get expiringCount => _expiringSoon.length;
  int get upcomingEventCount => _upcomingEvents.length;

  // ── Load all home data ─────────────────────────────────────────────────────
  Future<void> loadDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      final results = await Future.wait([
        _pantryRepo.fetchExpiringSoon(days: 7),
        _eventRepo.fetchMyEvents(upcomingOnly: true, limit: 5),
      ]);

      _expiringSoon = results[0] as List<PantryItemModel>;
      _upcomingEvents = results[1] as List<EventModel>;
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load dashboard. Please try again.');
    } finally {
      _hasLoaded = true;
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
