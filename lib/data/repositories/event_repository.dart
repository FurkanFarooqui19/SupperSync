import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/event_model.dart';

class EventRepository {
  EventRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  // ── Fetch events for user's clubs ──────────────────────────────────────────
  Future<List<EventModel>> fetchMyEvents({
    bool upcomingOnly = false,
    int? limit,
  }) async {
    try {
      final memberships = await _client
          .from('club_memberships')
          .select('club_id')
          .eq('user_id', _userId);

      final clubIds = memberships.map((e) => e['club_id'] as String).toList();
      if (clubIds.isEmpty) return [];

      var query = _client
          .from('supper_events')
          .select(
            '*, supper_clubs(name), profiles(display_name), '
            'event_attendees(count)',
          )
          .inFilter('club_id', clubIds);

      if (upcomingOnly) {
        query = query.gte(
          'event_date',
          DateTime.now().toIso8601String(),
        );
      }

      final ordered = query.order('event_date', ascending: upcomingOnly);
      final data = limit != null
          ? await ordered.limit(limit)
          : await ordered;

      return data.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load events: $e');
    }
  }

  // ── Fetch single event ─────────────────────────────────────────────────────
  Future<EventModel> fetchEventById(String eventId) async {
    try {
      final data = await _client
          .from('supper_events')
          .select(
            '*, supper_clubs(name), profiles(display_name), '
            'event_attendees(count)',
          )
          .eq('id', eventId)
          .single();

      // Confirmed attendees only (accurate RSVP count from DB)
      final confirmed = await _client
          .from('event_attendees')
          .select('id')
          .eq('event_id', eventId)
          .eq('status', 'confirmed');
      data['attendee_count'] = confirmed.length;

      final myRsvp = await _client
          .from('event_attendees')
          .select('status')
          .eq('event_id', eventId)
          .eq('user_id', _userId)
          .maybeSingle();

      data['my_rsvp'] = myRsvp?['status'];

      return EventModel.fromJson(data);
    } catch (e) {
      throw DatabaseException('Failed to load event: $e');
    }
  }

  // ── Create event ───────────────────────────────────────────────────────────
  Future<EventModel> createEvent({
    required String clubId,
    required String title,
    required DateTime eventDate,
    String? description,
    String? location,
    int? maxAttendees,
    String? theme,
  }) async {
    try {
      final data = await _client
          .from('supper_events')
          .insert({
            'club_id': clubId,
            'host_id': _userId,
            'title': title.trim(),
            'description': description?.trim(),
            'event_date': eventDate.toIso8601String(),
            'location': location?.trim(),
            'max_attendees': maxAttendees,
            'theme': theme?.trim(),
            'status': 'planning',
          })
          .select()
          .single();

      // Auto-RSVP host as confirmed
      await _client.from('event_attendees').insert({
        'event_id': data['id'],
        'user_id': _userId,
        'status': 'confirmed',
      });

      return await fetchEventById(data['id'] as String);
    } catch (e) {
      throw DatabaseException('Failed to create event: $e');
    }
  }

  // ── RSVP ──────────────────────────────────────────────────────────────────
  Future<void> rsvp(String eventId, RsvpStatus status) async {
    try {
      await _client.from('event_attendees').upsert({
        'event_id': eventId,
        'user_id': _userId,
        'status': status.value,
      }, onConflict: 'event_id, user_id');
    } catch (e) {
      throw DatabaseException('Failed to update RSVP: $e');
    }
  }

  // ── Fetch attendees ────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> fetchAttendees(String eventId) async {
    try {
      final data = await _client
          .from('event_attendees')
          .select('*, profiles(id, display_name, avatar_url)')
          .eq('event_id', eventId);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw DatabaseException('Failed to load attendees: $e');
    }
  }

  // ── Ingredient assignments ─────────────────────────────────────────────────
  Future<List<IngredientAssignmentModel>> fetchAssignments(
      String eventId) async {
    try {
      final data = await _client
          .from('ingredient_assignments')
          .select('*, profiles(display_name)')
          .eq('event_id', eventId)
          .order('created_at');

      return data.map((e) => IngredientAssignmentModel.fromJson(e)).toList();
    } catch (e) {
      throw DatabaseException('Failed to load assignments: $e');
    }
  }

  // ── Claim ingredient assignment ────────────────────────────────────────────
  Future<void> claimAssignment(String assignmentId) async {
    try {
      await _client.from('ingredient_assignments').update({
        'assigned_to': _userId,
        'status': 'claimed',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', assignmentId);
    } catch (e) {
      throw DatabaseException('Failed to claim ingredient: $e');
    }
  }

  // ── Mark assignment acquired ───────────────────────────────────────────────
  Future<void> markAcquired(String assignmentId) async {
    try {
      await _client.from('ingredient_assignments').update({
        'status': 'acquired',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', assignmentId).eq('assigned_to', _userId);
    } catch (e) {
      throw DatabaseException('Failed to update assignment: $e');
    }
  }

  // ── Add ingredient assignments in bulk ─────────────────────────────────────
  Future<void> addAssignments(
    String eventId,
    List<Map<String, dynamic>> ingredients,
  ) async {
    try {
      final rows = ingredients
          .map((ing) => {
                'event_id': eventId,
                'ingredient_name': ing['name'],
                'quantity': ing['quantity'],
                'unit': ing['unit'],
                'status': 'pending',
              })
          .toList();

      await _client.from('ingredient_assignments').insert(rows);
    } catch (e) {
      throw DatabaseException('Failed to add assignments: $e');
    }
  }

  // ── Realtime stream for assignments ───────────────────────────────────────
  Stream<List<Map<String, dynamic>>> streamAssignments(String eventId) {
    return _client
        .from('ingredient_assignments')
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId)
        .order('created_at');
  }
}
