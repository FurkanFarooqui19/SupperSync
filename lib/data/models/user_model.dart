import 'package:equatable/equatable.dart';

/// Represents a user profile (mirrors `profiles` table in Supabase)
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.dietaryTags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final List<String> dietaryTags;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        bio: json['bio'] as String?,
        dietaryTags: List<String>.from(json['dietary_tags'] ?? []),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'bio': bio,
        'dietary_tags': dietaryTags,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    List<String>? dietaryTags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        bio: bio ?? this.bio,
        dietaryTags: dietaryTags ?? this.dietaryTags,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props =>
      [id, email, displayName, avatarUrl, bio, dietaryTags];

  @override
  String toString() => 'UserModel(id: $id, displayName: $displayName)';
}
