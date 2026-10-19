import 'package:equatable/equatable.dart';

/// Storage location enum
enum StorageType { pantry, fridge, freezer }

extension StorageTypeExt on StorageType {
  String get label {
    switch (this) {
      case StorageType.pantry:
        return 'Pantry';
      case StorageType.fridge:
        return 'Fridge';
      case StorageType.freezer:
        return 'Freezer';
    }
  }

  String get emoji {
    switch (this) {
      case StorageType.pantry:
        return '🥫';
      case StorageType.fridge:
        return '❄️';
      case StorageType.freezer:
        return '🧊';
    }
  }

  static StorageType fromString(String value) {
    switch (value) {
      case 'fridge':
        return StorageType.fridge;
      case 'freezer':
        return StorageType.freezer;
      default:
        return StorageType.pantry;
    }
  }
}

/// Visibility enum for pantry items
enum ItemVisibility { private, shared }

extension ItemVisibilityExt on ItemVisibility {
  String get value => name;

  static ItemVisibility fromString(String value) =>
      value == 'shared' ? ItemVisibility.shared : ItemVisibility.private;
}

/// Pantry item categories
abstract final class PantryCategory {
  static const List<String> all = [
    'Vegetables',
    'Fruits',
    'Dairy',
    'Meat & Seafood',
    'Grains & Pasta',
    'Legumes',
    'Seasonings & Spices',
    'Oils & Condiments',
    'Beverages',
    'Snacks',
    'Baked Goods',
    'Frozen',
    'Canned',
    'Other',
  ];

  static const Map<String, String> emoji = {
    'Vegetables': '🥦',
    'Fruits': '🍎',
    'Dairy': '🥛',
    'Meat & Seafood': '🥩',
    'Grains & Pasta': '🌾',
    'Legumes': '🫘',
    'Seasonings & Spices': '🧂',
    'Oils & Condiments': '🫙',
    'Beverages': '🥤',
    'Snacks': '🍿',
    'Baked Goods': '🍞',
    'Frozen': '🧊',
    'Canned': '🥫',
    'Other': '📦',
  };
}

/// Common units for pantry items
abstract final class PantryUnit {
  static const List<String> all = [
    'pieces',
    'kg',
    'g',
    'L',
    'ml',
    'cups',
    'tbsp',
    'tsp',
    'bunches',
    'bags',
    'boxes',
    'cans',
    'bottles',
    'packets',
  ];
}

/// Represents a pantry item (mirrors `pantry_items` table)
class PantryItemModel extends Equatable {
  const PantryItemModel({
    required this.id,
    required this.ownerId,
    this.clubId,
    required this.name,
    this.category,
    required this.quantity,
    required this.unit,
    required this.storageType,
    this.expiryDate,
    required this.visibility,
    this.barcode,
    this.notes,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.ownerName,
  });

  final String id;
  final String ownerId;
  final String? clubId;
  final String name;
  final String? category;
  final double quantity;
  final String unit;
  final StorageType storageType;
  final DateTime? expiryDate;
  final ItemVisibility visibility;
  final String? barcode;
  final String? notes;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ownerName; // joined from profiles

  bool get isShared => visibility == ItemVisibility.shared;

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysLeft = expiryDate!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 7;
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return 999;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  String get categoryEmoji {
    if (category != null && PantryCategory.emoji.containsKey(category)) {
      return PantryCategory.emoji[category]!;
    }
    // Infer from item name when category is missing/wrong
    final n = name.toLowerCase();
    if (n.contains('tomato')) return '🍅';
    if (n.contains('egg')) return '🥚';
    if (n.contains('milk') || n.contains('cheese') || n.contains('butter')) {
      return '🥛';
    }
    if (n.contains('chicken') ||
        n.contains('beef') ||
        n.contains('meat') ||
        n.contains('fish')) {
      return '🥩';
    }
    if (n.contains('apple') || n.contains('banana') || n.contains('fruit')) {
      return '🍎';
    }
    if (n.contains('broccoli') ||
        n.contains('carrot') ||
        n.contains('onion') ||
        n.contains('lettuce') ||
        n.contains('veg')) {
      return '🥦';
    }
    if (n.contains('pasta') || n.contains('rice') || n.contains('bread')) {
      return '🌾';
    }
    return '📦';
  }

  factory PantryItemModel.fromJson(Map<String, dynamic> json) =>
      PantryItemModel(
        id: json['id'] as String,
        ownerId: json['owner_id'] as String,
        clubId: json['club_id'] as String?,
        name: json['name'] as String,
        category: json['category'] as String?,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        storageType:
            StorageTypeExt.fromString(json['storage_type'] as String? ?? 'pantry'),
        expiryDate: json['expiry_date'] != null
            ? DateTime.parse(json['expiry_date'] as String)
            : null,
        visibility:
            ItemVisibilityExt.fromString(json['visibility'] as String? ?? 'private'),
        barcode: json['barcode'] as String?,
        notes: json['notes'] as String?,
        imageUrl: json['image_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        ownerName: (json['profiles'] as Map<String, dynamic>?)?['display_name']
            as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'club_id': clubId,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'storage_type': storageType.name,
        'expiry_date': expiryDate?.toIso8601String().split('T').first,
        'visibility': visibility.value,
        'barcode': barcode,
        'notes': notes,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  PantryItemModel copyWith({
    String? id,
    String? ownerId,
    String? clubId,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    StorageType? storageType,
    DateTime? expiryDate,
    ItemVisibility? visibility,
    String? barcode,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerName,
  }) =>
      PantryItemModel(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        clubId: clubId ?? this.clubId,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        storageType: storageType ?? this.storageType,
        expiryDate: expiryDate ?? this.expiryDate,
        visibility: visibility ?? this.visibility,
        barcode: barcode ?? this.barcode,
        notes: notes ?? this.notes,
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        ownerName: ownerName ?? this.ownerName,
      );

  @override
  List<Object?> get props =>
      [id, ownerId, name, quantity, unit, expiryDate, visibility];
}
