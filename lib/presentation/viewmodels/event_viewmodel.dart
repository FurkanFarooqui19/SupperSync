import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

/// Event listing, creation, RSVP, and ingredient assignment state.
///
/// MVVM Rule: No setState() — notifyListeners() only.
class EventViewModel extends ChangeNotifier {
  EventViewModel(this._repository);

  final EventRepository _repository;

  // ── State ──────────────────────────────────────────────────────────────────
  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  List<IngredientAssignmentModel> _assignments = [];
  List<Map<String, dynamic>> _attendees = [];
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoaded = false;
  String? _loadedDetailId;
  String? _error;
  bool _showingUpcoming = true;

  List<EventModel> get events => _events;
  EventModel? get selectedEvent => _selectedEvent;
  List<IngredientAssignmentModel> get assignments => _assignments;
  List<Map<String, dynamic>> get attendees => _attendees;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoaded => _hasLoaded;
  String? get loadedDetailId => _loadedDetailId;
  String? get error => _error;
  bool get showingUpcoming => _showingUpcoming;

  List<EventModel> get filteredEvents => _showingUpcoming
      ? _events.where((e) => e.isUpcoming).toList()
      : _events.where((e) => e.isPast).toList();

  int get pendingAssignments =>
      _assignments.where((a) => !a.isClaimed).length;

  // ── Load events ────────────────────────────────────────────────────────────
  Future<void> loadEvents() async {
    _setLoading(true);
    _clearError();
    try {
      _events = await _repository.fetchMyEvents();
    } on AppException catch (e) {
      _setError(e.message);
    } finally {
      _hasLoaded = true;
      _setLoading(false);
    }
  }

  // ── Load event detail ──────────────────────────────────────────────────────
  Future<void> loadEventDetail(String eventId, {bool force = false}) async {
    if (!force && _isLoading && _loadedDetailId == eventId) return;
    _setLoading(true);
    _clearError();
    try {
      final results = await Future.wait([
        _repository.fetchEventById(eventId),
        _repository.fetchAttendees(eventId),
        _repository.fetchAssignments(eventId),
      ]);
      _selectedEvent = results[0] as EventModel;
      _attendees = results[1] as List<Map<String, dynamic>>;
      _assignments = results[2] as List<IngredientAssignmentModel>;
      _loadedDetailId = eventId;
    } on AppException catch (e) {
      _setError(e.message);
      _loadedDetailId = eventId;
    } finally {
      _setLoading(false);
    }
  }

  // ── Create event ───────────────────────────────────────────────────────────
  Future<EventModel?> createEvent({
    required String clubId,
    required String title,
    required DateTime eventDate,
    String? description,
    String? location,
    int? maxAttendees,
    String? theme,
  }) async {
    _setSaving(true);
    _clearError();
    try {
      final event = await _repository.createEvent(
        clubId: clubId,
        title: title,
        eventDate: eventDate,
        description: description,
        location: location,
        maxAttendees: maxAttendees,
        theme: theme,
      );
      _events = [event, ..._events];
      notifyListeners();
      return event;
    } on AppException catch (e) {
      _setError(e.message);
      return null;
    } finally {
      _setSaving(false);
    }
  }

  // ── RSVP ──────────────────────────────────────────────────────────────────
  Future<void> rsvp(String eventId, RsvpStatus status) async {
    _clearError();
    try {
      await _repository.rsvp(eventId, status);
      // Re-query event + attendees from DB (no optimistic fake values)
      if (_selectedEvent?.id == eventId) {
        await loadEventDetail(eventId, force: true);
      } else {
        await loadEvents();
      }
    } on AppException catch (e) {
      _setError(e.message);
    }
  }

  // ── Claim ingredient ───────────────────────────────────────────────────────
  Future<void> claimAssignment(String assignmentId) async {
    _clearError();
    try {
      await _repository.claimAssignment(assignmentId);
      if (_selectedEvent != null) {
        _assignments =
            await _repository.fetchAssignments(_selectedEvent!.id);
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    }
  }

  // ── Mark acquired ──────────────────────────────────────────────────────────
  Future<void> markAcquired(String assignmentId) async {
    _clearError();
    try {
      await _repository.markAcquired(assignmentId);
      if (_selectedEvent != null) {
        _assignments =
            await _repository.fetchAssignments(_selectedEvent!.id);
        notifyListeners();
      }
    } on AppException catch (e) {
      _setError(e.message);
    }
  }

  // ── Toggle view ────────────────────────────────────────────────────────────
  void setShowingUpcoming(bool value) {
    if (_showingUpcoming == value) return;
    _showingUpcoming = value;
    notifyListeners();
  }

  void clearSelectedEvent() {
    _selectedEvent = null;
    _assignments = [];
    _attendees = [];
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
