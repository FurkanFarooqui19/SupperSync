import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/pantry_item_model.dart';
import '../../data/repositories/pantry_repository.dart';

/// Manages personal + club shared pantry state, search, and filtering.
///
/// MVVM Rule: No setState() — notifyListeners() only.
class PantryViewModel extends ChangeNotifier {
  PantryViewModel(this._repository);

  final PantryRepository _repository;

  // ── State ──────────────────────────────────────────────────────────────────
  List<PantryItemModel> _myItems = [];
  List<PantryItemModel> _clubItems = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;
  StorageType? _selectedStorage;
  bool _showingClub = false; // tab: false=personal, true=club

  // ── Getters ────────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoaded => _hasLoaded;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  StorageType? get selectedStorage => _selectedStorage;
  bool get showingClub => _showingClub;

  List<PantryItemModel> get allMyItems => _myItems;
  List<PantryItemModel> get allClubItems => _clubItems;

  /// Filtered items based on active tab + search + filters
  List<PantryItemModel> get filteredItems {
    final source = _showingClub ? _clubItems : _myItems;
    return source.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesStorage =
          _selectedStorage == null || item.storageType == _selectedStorage;
      return matchesSearch && matchesCategory && matchesStorage;
    }).toList();
  }

  /// Items expiring within 7 days (for badge count)
  int get expiringCount =>
      _myItems.where((i) => i.isExpiringSoon || i.isExpired).length;

  // ── Load personal pantry ───────────────────────────────────────────────────
  Future<void> loadMyPantry() async {
    _setLoading(true);
    _clearError();
    try {
      _myItems = await _repository.fetchMyItems();
    } on AppException catch (e) {
      _setError(e.message);
    } finally {
      _hasLoaded = true;
      _setLoading(false);
    }
  }

  // ── Load club shared pantry ────────────────────────────────────────────────
  Future<void> loadClubPantry(String clubId) async {
    _setLoading(true);
    _clearError();
    try {
      _clubItems = await _repository.fetchClubSharedItems(clubId);
    } on AppException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // ── Add item ───────────────────────────────────────────────────────────────
  Future<bool> addItem({
    required String name,
    required double quantity,
    required String unit,
    String? category,
    StorageType storageType = StorageType.pantry,
    DateTime? expiryDate,
    ItemVisibility visibility = ItemVisibility.private,
    String? clubId,
    String? barcode,
    String? notes,
  }) async {
    _setSaving(true);
    _clearError();
    try {
      final item = await _repository.addItem({
        'name': name.trim(),
        'quantity': quantity,
        'unit': unit,
        'category': category,
        'storage_type': storageType.name,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'visibility': visibility.value,
        'club_id': clubId,
        'barcode': barcode,
        'notes': notes?.trim(),
      });
      _myItems = [item, ..._myItems];
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  String? get currentUserId => _repository.currentUserId;

  bool isOwnedByMe(PantryItemModel item) {
    final me = currentUserId;
    return me != null && item.ownerId == me;
  }

  bool isOwnerId(String? ownerId) {
    final me = currentUserId;
    return me != null && ownerId != null && ownerId == me;
  }

  // ── Update item ────────────────────────────────────────────────────────────
  Future<bool> updateItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    _setSaving(true);
    _clearError();
    try {
      final updated = await _repository.updateItem(itemId, updates);
      _myItems = _myItems.map((i) => i.id == itemId ? updated : i).toList();
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // ── Delete item ────────────────────────────────────────────────────────────
  Future<bool> deleteItem(String itemId) async {
    _clearError();
    try {
      await _repository.deleteItem(itemId);
      _myItems = _myItems.where((i) => i.id != itemId).toList();
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Toggle visibility ──────────────────────────────────────────────────────
  Future<void> toggleVisibility(PantryItemModel item) async {
    if (!isOwnedByMe(item)) {
      _setError('You can only change sharing on your own items.');
      return;
    }
    try {
      final updated = await _repository.toggleVisibility(item);
      _myItems = _myItems.map((i) => i.id == item.id ? updated : i).toList();
      notifyListeners();
    } on AppException catch (e) {
      _setError(e.message);
    }
  }

  // ── Search & filter ────────────────────────────────────────────────────────
  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String? category) {
    _selectedCategory = _selectedCategory == category ? null : category;
    notifyListeners();
  }

  void setStorage(StorageType? type) {
    _selectedStorage = _selectedStorage == type ? null : type;
    notifyListeners();
  }

  void setShowingClub(bool value) {
    if (_showingClub == value) return;
    _showingClub = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedStorage = null;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setSaving(bool v) {
    _isSaving = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() => _clearError();
}
