import 'package:equatable/equatable.dart';

/// Represents a Supper Club (mirrors `supper_clubs` table)
class ClubModel extends Equatable {
  const ClubModel({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount = 0,
    this.myRole,
  });

  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String inviteCode;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;
  final String? myRole; // 'host' | 'member' | 'guest'

  bool get isHost => myRole == 'host';

  factory ClubModel.fromJson(Map<String, dynamic> json) => ClubModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        inviteCode: json['invite_code'] as String,
        createdBy: json['created_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        memberCount: _parseMemberCount(json),
        myRole: json['my_role'] as String?,
      );

  /// Supports int/num/string `member_count` or PostgREST `club_memberships: [{count}]`.
  static int _parseMemberCount(Map<String, dynamic> json) {
    final flat = json['member_count'];
    if (flat is int) return flat;
    if (flat is num) return flat.toInt();
    if (flat is String) return int.tryParse(flat) ?? 0;

    final nested = json['club_memberships'];
    if (nested is List && nested.isNotEmpty) {
      final first = nested.first;
      if (first is Map) {
        final count = first['count'];
        if (count is int) return count;
        if (count is num) return count.toInt();
        if (count is String) return int.tryParse(count) ?? 0;
      }
      // Full membership rows instead of aggregate
      return nested.length;
    }
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'avatar_url': avatarUrl,
        'invite_code': inviteCode,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ClubModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatarUrl,
    String? inviteCode,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
    String? myRole,
  }) =>
      ClubModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        inviteCode: inviteCode ?? this.inviteCode,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        memberCount: memberCount ?? this.memberCount,
        myRole: myRole ?? this.myRole,
      );

  @override
  List<Object?> get props => [id, name, inviteCode, memberCount, myRole];
}

/// Club membership record
class MembershipModel extends Equatable {
  const MembershipModel({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.user,
  });

  final String id;
  final String clubId;
  final String userId;
  final String role; // 'host' | 'member' | 'guest'
  final DateTime joinedAt;
  final Map<String, dynamic>? user; // joined profile data

  String get displayName =>
      user?['display_name'] as String? ?? 'Unknown Member';
  String? get avatarUrl => user?['avatar_url'] as String?;

  factory MembershipModel.fromJson(Map<String, dynamic> json) =>
      MembershipModel(
        id: json['id'] as String,
        clubId: json['club_id'] as String,
        userId: json['user_id'] as String,
        role: json['role'] as String,
        joinedAt: DateTime.parse(json['joined_at'] as String),
        user: json['profiles'] as Map<String, dynamic>?,
      );

  @override
  List<Object?> get props => [id, clubId, userId, role];
}
