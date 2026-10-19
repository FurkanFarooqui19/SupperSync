import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/pantry_item_model.dart';

class PantryRepository {
  PantryRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;
  String? get currentUserId => _client.auth.currentUser?.id;

  // ── Fetch personal pantry items ────────────────────────────────────────────
  Future<List<PantryItemModel>> fetchMyItems() async {
    try {
      final data = await _client
          .from('pantry_items')
          .select()
          .eq('owner_id', _userId)
          .order('expiry_date', ascending: true, nullsFirst: false);

      return data.map((e) => PantryItemModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load pantry: $e');
    }
  }

  // ── Fetch club shared pantry ───────────────────────────────────────────────
  Future<List<PantryItemModel>> fetchClubSharedItems(String clubId) async {
    try {
      // Get all member IDs in the club
      final memberIds = await _client
          .from('club_memberships')
          .select('user_id')
          .eq('club_id', clubId);

      final userIds = memberIds.map((e) => e['user_id'] as String).toList();

      final data = await _client
          .from('pantry_items')
          .select('*, profiles(display_name, avatar_url)')
          .inFilter('owner_id', userIds)
          .eq('visibility', 'shared')
          .order('expiry_date', ascending: true, nullsFirst: false);

      return data.map((e) => PantryItemModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load club pantry: $e');
    }
  }

  // ── Fetch expiring items (for home dashboard) ──────────────────────────────
  Future<List<PantryItemModel>> fetchExpiringSoon({int days = 7}) async {
    try {
      final cutoff = DateTime.now().add(Duration(days: days));
      final data = await _client
          .from('pantry_items')
          .select()
          .eq('owner_id', _userId)
          .lte('expiry_date', cutoff.toIso8601String().split('T').first)
          .gte('expiry_date', DateTime.now().toIso8601String().split('T').first)
          .order('expiry_date', ascending: true);

      return data.map((e) => PantryItemModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load expiring items: $e');
    }
  }

  // ── Add pantry item ────────────────────────────────────────────────────────
  Future<PantryItemModel> addItem(Map<String, dynamic> itemData) async {
    try {
      final data = await _client
          .from('pantry_items')
          .insert({
            ...itemData,
            'owner_id': _userId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return PantryItemModel.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to add item: $e');
    }
  }

  // ── Update pantry item (owner only) ────────────────────────────────────────
  Future<PantryItemModel> updateItem(
    String itemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Never allow changing ownership via client
      updates.remove('owner_id');
      updates.remove('id');

      final data = await _client
          .from('pantry_items')
          .update({
            ...updates,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', itemId)
          .eq('owner_id', _userId)
          .select()
          .maybeSingle();

      if (data == null) {
        throw const PermissionException(
          'You can only edit items in your own pantry.',
        );
      }

      return PantryItemModel.fromJson(data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to update item: $e');
    }
  }

  // ── Delete pantry item (owner only) ────────────────────────────────────────
  Future<void> deleteItem(String itemId) async {
    try {
      final deleted = await _client
          .from('pantry_items')
          .delete()
          .eq('id', itemId)
          .eq('owner_id', _userId)
          .select('id');

      if (deleted.isEmpty) {
        throw const PermissionException(
          'You can only delete items in your own pantry.',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to delete item: $e');
    }
  }

  // ── Toggle visibility (owner only) ─────────────────────────────────────────
  Future<PantryItemModel> toggleVisibility(PantryItemModel item) async {
    if (item.ownerId != _userId) {
      throw const PermissionException(
        'You can only change sharing on your own items.',
      );
    }
    final newVisibility = item.isShared ? 'private' : 'shared';
    return await updateItem(item.id, {'visibility': newVisibility});
  }

  // ── Combined club pantry: MY items + others' SHARED items ──────────────────
  ///
  /// Privacy model:
  /// - Current user: all personal pantry items (private + shared)
  /// - Other members: only items marked `shared`
  Future<List<PantryItemModel>> fetchCombinedForClub(String clubId) async {
    try {
      final memberRows = await _client
          .from('club_memberships')
          .select('user_id')
          .eq('club_id', clubId);

      final memberIds =
          memberRows.map((e) => e['user_id'] as String).toSet().toList();
      if (memberIds.isEmpty) return await fetchMyItems();

      return _combineMyPantryWithOthersShared(memberIds);
    } catch (e) {
      throw DatabaseException('Failed to load combined club pantry: $e');
    }
  }

  // ── Combined pantry for an event (attendees + me) ──────────────────────────
  Future<List<PantryItemModel>> fetchCombinedForEvent({
    required String clubId,
    required List<String> attendeeIds,
  }) async {
    try {
      // Prefer confirmed attendees; always include me; fall back to full club
      var people = <String>{...attendeeIds, _userId};

      if (people.length <= 1) {
        final memberRows = await _client
            .from('club_memberships')
            .select('user_id')
            .eq('club_id', clubId);
        people = memberRows.map((e) => e['user_id'] as String).toSet();
        people.add(_userId);
      }

      return _combineMyPantryWithOthersShared(people.toList());
    } catch (e) {
      throw DatabaseException('Failed to aggregate event pantry: $e');
    }
  }

  /// @deprecated Use [fetchCombinedForEvent] — kept for call-site compatibility
  Future<List<PantryItemModel>> fetchAggregatedForEvent(
    List<String> attendeeIds,
  ) async {
    try {
      return _combineMyPantryWithOthersShared(
        {...attendeeIds, _userId}.toList(),
      );
    } catch (e) {
      throw DatabaseException('Failed to aggregate pantry: $e');
    }
  }

  Future<List<PantryItemModel>> _combineMyPantryWithOthersShared(
    List<String> userIds,
  ) async {
    final myItems = await fetchMyItems();

    final otherIds = userIds.where((id) => id != _userId).toList();
    if (otherIds.isEmpty) return myItems;

    final othersData = await _client
        .from('pantry_items')
        .select('*, profiles(display_name)')
        .inFilter('owner_id', otherIds)
        .eq('visibility', 'shared')
        .order('name');

    final othersShared =
        othersData.map((e) => PantryItemModel.fromJson(e)).toList();

    // Deduplicate by id (mine may already be shared)
    final byId = <String, PantryItemModel>{
      for (final item in myItems) item.id: item,
      for (final item in othersShared) item.id: item,
    };
    return byId.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
