import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/club_model.dart';
import '../../data/repositories/club_repository.dart';

/// Club listing, creation, joining, and detail state.
///
/// MVVM Rule: No setState() — notifyListeners() only.
class ClubViewModel extends ChangeNotifier {
  ClubViewModel(this._repository);

  final ClubRepository _repository;

  // ── State ──────────────────────────────────────────────────────────────────
  List<ClubModel> _clubs = [];
  ClubModel? _selectedClub;
  List<MembershipModel> _selectedClubMembers = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  String? _loadedDetailId;
  String? _error;

  List<ClubModel> get clubs => _clubs;
  ClubModel? get selectedClub => _selectedClub;
  List<MembershipModel> get selectedClubMembers => _selectedClubMembers;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoaded => _hasLoaded;
  String? get loadedDetailId => _loadedDetailId;
  String? get error => _error;
  bool get hasClubs => _clubs.isNotEmpty;

  // ── Load my clubs ──────────────────────────────────────────────────────────
  Future<void> loadClubs() async {
    _setLoading(true);
    _clearError();
    try {
      _clubs = await _repository.fetchMyClubs();
    } on AppException catch (e) {
      _setError(e.message);
    } finally {
      _hasLoaded = true;
      _setLoading(false);
    }
  }

  // ── Load club detail ───────────────────────────────────────────────────────
  Future<void> loadClubDetail(String clubId) async {
    if (_isLoading && _loadedDetailId == clubId) return;
    _setLoading(true);
    _clearError();
    try {
      final results = await Future.wait([
        _repository.fetchClubById(clubId),
        _repository.fetchClubMembers(clubId),
      ]);
      final club = results[0] as ClubModel;
      final members = results[1] as List<MembershipModel>;
      // Prefer explicit members query length when it differs from aggregate
      _selectedClub = club.copyWith(
        memberCount: members.isNotEmpty ? members.length : club.memberCount,
      );
      _selectedClubMembers = members;
      _loadedDetailId = clubId;
      _syncClubInList(_selectedClub!);
    } on AppException catch (e) {
      _setError(e.message);
      _loadedDetailId = clubId;
    } finally {
      _setLoading(false);
    }
  }

  void _syncClubInList(ClubModel club) {
    final index = _clubs.indexWhere((c) => c.id == club.id);
    if (index == -1) return;
    _clubs = [..._clubs]..[index] = club;
  }

  // ── Create club ────────────────────────────────────────────────────────────
  Future<ClubModel?> createClub({
    required String name,
    String? description,
  }) async {
    _setSaving(true);
    _clearError();
    try {
      final club = await _repository.createClub(
        name: name,
        description: description,
      );
      _clubs = [club, ..._clubs];
      notifyListeners();
      return club;
    } on AppException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  // ── Join club by code ──────────────────────────────────────────────────────
  Future<ClubModel?> joinClub(String inviteCode) async {
    _setSaving(true);
    _clearError();
    try {
      final club = await _repository.joinClubByCode(inviteCode);
      _clubs = [club, ..._clubs];
      notifyListeners();
      return club;
    } on AppException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  // ── Leave club ─────────────────────────────────────────────────────────────
  Future<bool> leaveClub(String clubId) async {
    _clearError();
    try {
      await _repository.leaveClub(clubId);
      _clubs = _clubs.where((c) => c.id != clubId).toList();
      if (_selectedClub?.id == clubId) _selectedClub = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  void clearSelectedClub() {
    _selectedClub = null;
    _selectedClubMembers = [];
    _loadedDetailId = null;
    notifyListeners();
  }

  void clearError() => _clearError();

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
}
