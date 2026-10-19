import 'package:equatable/equatable.dart';

/// Event status enum
enum EventStatus { planning, confirmed, completed, cancelled }

extension EventStatusExt on EventStatus {
  String get label {
    switch (this) {
      case EventStatus.planning:
        return 'Planning';
      case EventStatus.confirmed:
        return 'Confirmed';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }

  static EventStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return EventStatus.confirmed;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.planning;
    }
  }
}

/// RSVP status enum
enum RsvpStatus { invited, confirmed, declined, maybe }

extension RsvpStatusExt on RsvpStatus {
  String get value => name;

  static RsvpStatus fromString(String value) {
    switch (value) {
      case 'confirmed':
        return RsvpStatus.confirmed;
      case 'declined':
        return RsvpStatus.declined;
      case 'maybe':
        return RsvpStatus.maybe;
      default:
        return RsvpStatus.invited;
    }
  }
}

/// Supper event model (mirrors `supper_events` table)
class EventModel extends Equatable {
  const EventModel({
    required this.id,
    required this.clubId,
    required this.hostId,
    required this.title,
    this.description,
    required this.eventDate,
    this.location,
    this.maxAttendees,
    required this.status,
    this.theme,
    this.selectedRecipes = const [],
    required this.createdAt,
    required this.updatedAt,
    this.clubName,
    this.hostName,
    this.attendeeCount = 0,
    this.myRsvpStatus,
  });

  final String id;
  final String clubId;
  final String hostId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? location;
  final int? maxAttendees;
  final EventStatus status;
  final String? theme;
  final List<dynamic> selectedRecipes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? clubName;
  final String? hostName;
  final int attendeeCount;
  final RsvpStatus? myRsvpStatus;

  bool get isUpcoming => eventDate.isAfter(DateTime.now());
  bool get isPast => eventDate.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as String,
        clubId: json['club_id'] as String,
        hostId: json['host_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        eventDate: DateTime.parse(json['event_date'] as String),
        location: json['location'] as String?,
        maxAttendees: json['max_attendees'] as int?,
        status:
            EventStatusExt.fromString(json['status'] as String? ?? 'planning'),
        theme: json['theme'] as String?,
        selectedRecipes: json['selected_recipes'] as List<dynamic>? ?? [],
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        clubName: (json['supper_clubs'] as Map<String, dynamic>?)?['name']
            as String?,
        hostName:
            (json['profiles'] as Map<String, dynamic>?)?['display_name']
                as String?,
        attendeeCount: _parseAttendeeCount(json),
        myRsvpStatus: json['my_rsvp'] != null
            ? RsvpStatusExt.fromString(json['my_rsvp'] as String)
            : null,
      );

  static int _parseAttendeeCount(Map<String, dynamic> json) {
    final flat = json['attendee_count'];
    if (flat is int) return flat;
    if (flat is num) return flat.toInt();

    final nested = json['event_attendees'];
    if (nested is List && nested.isNotEmpty) {
      final count = nested.first['count'];
      if (count is int) return count;
      if (count is num) return count.toInt();
      // Full attendee rows returned instead of aggregate
      return nested.length;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'club_id': clubId,
        'host_id': hostId,
        'title': title,
        'description': description,
        'event_date': eventDate.toIso8601String(),
        'location': location,
        'max_attendees': maxAttendees,
        'status': status.name,
        'theme': theme,
        'selected_recipes': selectedRecipes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  EventModel copyWith({
    String? id,
    String? clubId,
    String? hostId,
    String? title,
    String? description,
    DateTime? eventDate,
    String? location,
    int? maxAttendees,
    EventStatus? status,
    String? theme,
    List<dynamic>? selectedRecipes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? clubName,
    String? hostName,
    int? attendeeCount,
    RsvpStatus? myRsvpStatus,
  }) =>
      EventModel(
        id: id ?? this.id,
        clubId: clubId ?? this.clubId,
        hostId: hostId ?? this.hostId,
        title: title ?? this.title,
        description: description ?? this.description,
        eventDate: eventDate ?? this.eventDate,
        location: location ?? this.location,
        maxAttendees: maxAttendees ?? this.maxAttendees,
        status: status ?? this.status,
        theme: theme ?? this.theme,
        selectedRecipes: selectedRecipes ?? this.selectedRecipes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        clubName: clubName ?? this.clubName,
        hostName: hostName ?? this.hostName,
        attendeeCount: attendeeCount ?? this.attendeeCount,
        myRsvpStatus: myRsvpStatus ?? this.myRsvpStatus,
      );

  @override
  List<Object?> get props => [id, clubId, title, eventDate, status];
}

/// Ingredient assignment for an event
class IngredientAssignmentModel extends Equatable {
  const IngredientAssignmentModel({
    required this.id,
    required this.eventId,
    this.assignedTo,
    required this.ingredientName,
    required this.quantity,
    required this.unit,
    required this.status,
    this.notes,
    required this.createdAt,
    this.assigneeName,
  });

  final String id;
  final String eventId;
  final String? assignedTo;
  final String ingredientName;
  final double quantity;
  final String unit;
  final String status; // 'pending' | 'claimed' | 'acquired' | 'delivered'
  final String? notes;
  final DateTime createdAt;
  final String? assigneeName;

  bool get isClaimed => assignedTo != null;
  bool get isAcquired => status == 'acquired' || status == 'delivered';

  factory IngredientAssignmentModel.fromJson(Map<String, dynamic> json) =>
      IngredientAssignmentModel(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        assignedTo: json['assigned_to'] as String?,
        ingredientName: json['ingredient_name'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        status: json['status'] as String? ?? 'pending',
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        assigneeName:
            (json['profiles'] as Map<String, dynamic>?)?['display_name']
                as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'assigned_to': assignedTo,
        'ingredient_name': ingredientName,
        'quantity': quantity,
        'unit': unit,
        'status': status,
        'notes': notes,
      };

  @override
  List<Object?> get props =>
      [id, eventId, ingredientName, assignedTo, status];
}
