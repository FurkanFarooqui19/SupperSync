import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Authentication state and operations.
///
/// MVVM Rule: No setState() — notifyListeners() only.
/// Extends ChangeNotifier AND acts as a Listenable for go_router refresh.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authRepository) {
    _init();
  }

  final AuthRepository _authRepository;

  // ── State ──────────────────────────────────────────────────────────────────
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String? get userId => _user?.id;

  // ── Init: listen to Supabase auth state ───────────────────────────────────
  void _init() {
    Supabase.instance.client.auth.onAuthStateChange.listen((state) async {
      final session = state.session;
      if (session != null) {
        await _loadProfile(session.user.id);
      } else {
        _user = null;
        notifyListeners();
      }
    });

    // Load existing session on startup
    final existingSession = Supabase.instance.client.auth.currentSession;
    if (existingSession != null) {
      _loadProfile(existingSession.user.id);
    }
  }

  Future<void> _loadProfile(String userId) async {
    try {
      _user = await _authRepository.fetchProfile(userId);
    } catch (_) {
      _user = null;
    }
    notifyListeners();
  }

  // ── Sign In ────────────────────────────────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authRepository.signIn(email: email, password: password);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _user = null;
      notifyListeners();
    } on AppException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // ── Update profile ─────────────────────────────────────────────────────────
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    List<String>? dietaryTags,
    String? avatarUrl,
  }) async {
    if (_user == null) return false;
    _setLoading(true);
    _clearError();

    try {
      _user = await _authRepository.updateProfile(
        userId: _user!.id,
        displayName: displayName,
        bio: bio,
        dietaryTags: dietaryTags,
        avatarUrl: avatarUrl,
      );
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Error management ───────────────────────────────────────────────────────
  void clearError() => _clearError();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
