import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Handles all Supabase Auth operations and profile management
class AuthRepository {
  AuthRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  // ── Current user helpers ───────────────────────────────────────────────────
  User? get currentAuthUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isAuthenticated => currentSession != null;
  String? get currentUserId => currentAuthUser?.id;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Sign Up ────────────────────────────────────────────────────────────────
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': displayName.trim()},
      );

      if (response.user == null) {
        throw const AuthException('Sign up failed. Please try again.');
      }

      // Profile row is created by DB trigger `handle_new_user` (SECURITY DEFINER).
      // Do NOT insert/upsert from the client — that hits RLS when there is no
      // session yet (e.g. email confirmation required).
      if (response.session == null) {
        throw const AuthException(
          'Account created. Confirm your email, then sign in.',
        );
      }

      // Wait briefly for the trigger, then sync display name via UPDATE only.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _client.from('profiles').update({
        'display_name': displayName.trim(),
        'email': email.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', response.user!.id);

      return await _fetchProfileWithRetry(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      throw AuthException(e.message, code: e.statusCode.toString());
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  Future<UserModel> _fetchProfileWithRetry(String userId) async {
    Object? lastError;
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        return await fetchProfile(userId);
      } catch (e) {
        lastError = e;
        await Future<void>.delayed(Duration(milliseconds: 200 * (attempt + 1)));
      }
    }
    throw DatabaseException('Failed to load profile: $lastError');
  }

  // ── Sign In ────────────────────────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Sign in failed. Check your credentials.');
      }

      return await fetchProfile(response.user!.id);
    } on AuthException {
      rethrow;
    } on AuthApiException catch (e) {
      if (e.statusCode == '400') {
        throw const AuthException('Invalid email or password.');
      }
      throw AuthException(e.message, code: e.statusCode.toString());
    } catch (e) {
      throw AuthException('An unexpected error occurred: $e');
    }
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  // ── Fetch Profile ─────────────────────────────────────────────────────────
  Future<UserModel> fetchProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserModel.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to load profile: $e');
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    List<String>? dietaryTags,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (displayName != null) updates['display_name'] = displayName.trim();
      if (bio != null) updates['bio'] = bio.trim();
      if (dietaryTags != null) updates['dietary_tags'] = dietaryTags;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client.from('profiles').update(updates).eq('id', userId);
      return await fetchProfile(userId);
    } catch (e) {
      throw DatabaseException('Failed to update profile: $e');
    }
  }

  // ── Fetch Impact Summary (always from impact_logs table) ───────────────────
  Future<Map<String, double>> fetchImpactSummary(String userId) async {
    try {
      final data = await _client
          .from('impact_logs')
          .select('weight_saved_kg, cost_saved, carbon_offset_kg')
          .eq('user_id', userId);

      double totalWeight = 0;
      double totalCost = 0;
      double totalCarbon = 0;

      for (final row in data) {
        totalWeight += (row['weight_saved_kg'] as num?)?.toDouble() ?? 0;
        totalCost += (row['cost_saved'] as num?)?.toDouble() ?? 0;
        totalCarbon += (row['carbon_offset_kg'] as num?)?.toDouble() ?? 0;
      }

      // Empty table → real zeros from DB, not a swallowed error
      return {
        'weight_saved_kg': totalWeight,
        'cost_saved': totalCost,
        'carbon_offset_kg': totalCarbon,
      };
    } catch (e) {
      throw DatabaseException('Failed to load impact summary: $e');
    }
  }
}
