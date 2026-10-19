import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/club_model.dart';

class ClubRepository {
  ClubRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  // ── Fetch user's clubs with real member counts from DB ─────────────────────
  Future<List<ClubModel>> fetchMyClubs() async {
    try {
      final data = await _client
          .from('club_memberships')
          .select('role, supper_clubs(*)')
          .eq('user_id', _userId);

      if (data.isEmpty) return [];

      final clubMaps = data.map((row) {
        final club = Map<String, dynamic>.from(
          row['supper_clubs'] as Map<String, dynamic>,
        );
        club['my_role'] = row['role'];
        return club;
      }).toList();

      final clubIds =
          clubMaps.map((c) => c['id'].toString()).toList(growable: false);
      final counts = await _memberCountsForClubs(clubIds);

      return clubMaps.map((club) {
        final id = club['id'].toString();
        club['member_count'] = counts[id] ?? 0;
        return ClubModel.fromJson(club);
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to load clubs: $e');
    }
  }

  /// Counts membership rows per club_id from `club_memberships` (real DB rows).
  Future<Map<String, int>> _memberCountsForClubs(List<String> clubIds) async {
    if (clubIds.isEmpty) return {};

    // Query each club so RLS + filters stay simple and counts stay accurate.
    final entries = await Future.wait(
      clubIds.map((id) async => MapEntry(id, await _memberCountForClub(id))),
    );
    return Map<String, int>.fromEntries(entries);
  }

  Future<int> _memberCountForClub(String clubId) async {
    final rows = await _client
        .from('club_memberships')
        .select('id')
        .eq('club_id', clubId);
    return rows.length;
  }

  // ── Create club ────────────────────────────────────────────────────────────
  Future<ClubModel> createClub({
    required String name,
    String? description,
  }) async {
    try {
      final data = await _client
          .from('supper_clubs')
          .insert({
            'name': name.trim(),
            'description': description?.trim(),
            'created_by': _userId,
          })
          .select()
          .single();

      await _client.from('club_memberships').insert({
        'club_id': data['id'],
        'user_id': _userId,
        'role': 'host',
      });

      return await fetchClubById(data['id'] as String);
    } catch (e) {
      throw DatabaseException('Failed to create club: $e');
    }
  }

  // ── Join club by invite code ────────────────────────────────────────────────
  Future<ClubModel> joinClubByCode(String inviteCode) async {
    try {
      final clubData = await _client
          .from('supper_clubs')
          .select()
          .eq('invite_code', inviteCode.trim().toUpperCase())
          .maybeSingle();

      if (clubData == null) {
        throw const NotFoundException('No club found with that invite code.');
      }

      final clubId = clubData['id'] as String;

      final existing = await _client
          .from('club_memberships')
          .select()
          .eq('club_id', clubId)
          .eq('user_id', _userId)
          .maybeSingle();

      if (existing != null) {
        throw const ValidationException(
          'You are already a member of this club.',
        );
      }

      await _client.from('club_memberships').insert({
        'club_id': clubId,
        'user_id': _userId,
        'role': 'member',
      });

      return await fetchClubById(clubId);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to join club: $e');
    }
  }

  // ── Fetch club detail ──────────────────────────────────────────────────────
  Future<ClubModel> fetchClubById(String clubId) async {
    try {
      final clubData = await _client
          .from('supper_clubs')
          .select()
          .eq('id', clubId)
          .single();

      final membership = await _client
          .from('club_memberships')
          .select('role')
          .eq('club_id', clubId)
          .eq('user_id', _userId)
          .maybeSingle();

      clubData['my_role'] = membership?['role'];
      clubData['member_count'] = await _memberCountForClub(clubId);

      return ClubModel.fromJson(clubData);
    } catch (e) {
      throw DatabaseException('Failed to load club: $e');
    }
  }

  // ── Fetch club members ─────────────────────────────────────────────────────
  Future<List<MembershipModel>> fetchClubMembers(String clubId) async {
    try {
      final data = await _client
          .from('club_memberships')
          .select('*, profiles(id, display_name, avatar_url, email)')
          .eq('club_id', clubId)
          .order('joined_at');

      return data.map((e) => MembershipModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load members: $e');
    }
  }

  // ── Leave club ─────────────────────────────────────────────────────────────
  Future<void> leaveClub(String clubId) async {
    try {
      await _client
          .from('club_memberships')
          .delete()
          .eq('club_id', clubId)
          .eq('user_id', _userId);
    } catch (e) {
      throw DatabaseException('Failed to leave club: $e');
    }
  }

  // ── Update club ────────────────────────────────────────────────────────────
  Future<ClubModel> updateClub(
    String clubId, {
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updates['name'] = name.trim();
      if (description != null) updates['description'] = description.trim();
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client.from('supper_clubs').update(updates).eq('id', clubId);
      return await fetchClubById(clubId);
    } catch (e) {
      throw DatabaseException('Failed to update club: $e');
    }
  }
}
