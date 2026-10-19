import 'package:equatable/equatable.dart';

import '../../core/utils/ingredient_matcher.dart';

/// Recipe model — sourced from Supabase `recipes` + `recipe_ingredients`.
class RecipeModel extends Equatable {
  const RecipeModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.usedIngredients,
    required this.missedIngredients,
    required this.readyInMinutes,
    this.servings,
    this.sourceUrl,
    this.matchPercentage = 0.0,
    this.dietaryTags = const [],
  });

  final String id;
  final String title;
  final String imageUrl;
  final List<RecipeIngredient> usedIngredients;
  final List<RecipeIngredient> missedIngredients;
  final int readyInMinutes;
  final int? servings;
  final String? sourceUrl;
  final double matchPercentage;
  final List<String> dietaryTags;

  int get usedCount => usedIngredients.length;
  int get missedCount => missedIngredients.length;
  int get totalCount => usedCount + missedCount;

  /// Build a ranked match from a DB recipe row + shared pantry names.
  factory RecipeModel.fromSupabaseMatch({
    required Map<String, dynamic> recipeJson,
    required List<Map<String, dynamic>> ingredientRows,
    required Set<String> pantryNamesLower,
  }) {
    final used = <RecipeIngredient>[];
    final missed = <RecipeIngredient>[];

    for (var i = 0; i < ingredientRows.length; i++) {
      final row = ingredientRows[i];
      final ingredient = RecipeIngredient.fromSupabase(row, fallbackId: i);
      final inPantry = IngredientMatcher.isInPantry(
        ingredient.name,
        pantryNamesLower,
      );
      if (inPantry) {
        used.add(ingredient);
      } else {
        missed.add(ingredient);
      }
    }

    final total = used.length + missed.length;
    final matchPct = total > 0 ? (used.length / total) * 100.0 : 0.0;

    return RecipeModel(
      id: recipeJson['id'] as String,
      title: recipeJson['title'] as String,
      imageUrl: recipeJson['image_url'] as String? ?? '',
      usedIngredients: used,
      missedIngredients: missed,
      readyInMinutes: recipeJson['ready_in_minutes'] as int? ?? 30,
      servings: recipeJson['servings'] as int?,
      matchPercentage: matchPct,
      dietaryTags: List<String>.from(recipeJson['dietary_tags'] ?? const []),
    );
  }

  @override
  List<Object?> get props => [id, title, matchPercentage];
}

class RecipeIngredient extends Equatable {
  const RecipeIngredient({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    this.imageUrl,
  });

  final int id;
  final String name;
  final double amount;
  final String unit;
  final String? imageUrl;

  factory RecipeIngredient.fromSupabase(
    Map<String, dynamic> json, {
    int fallbackId = 0,
  }) =>
      RecipeIngredient(
        id: fallbackId,
        name: json['name'] as String,
        amount: (json['amount'] as num?)?.toDouble() ?? 1,
        unit: json['unit'] as String? ?? '',
        imageUrl: null,
      );

  String get displayAmount => amount == amount.truncateToDouble()
      ? '${amount.toInt()} $unit'
      : '${amount.toStringAsFixed(1)} $unit';

  @override
  List<Object?> get props => [id, name, amount, unit];
}

/// Impact log model (mirrors `impact_logs` table)
class ImpactLogModel extends Equatable {
  const ImpactLogModel({
    required this.id,
    this.eventId,
    this.clubId,
    this.userId,
    required this.weightSavedKg,
    required this.costSaved,
    required this.carbonOffsetKg,
    required this.loggedAt,
  });

  final String id;
  final String? eventId;
  final String? clubId;
  final String? userId;
  final double weightSavedKg;
  final double costSaved;
  final double carbonOffsetKg;
  final DateTime loggedAt;

  factory ImpactLogModel.fromJson(Map<String, dynamic> json) =>
      ImpactLogModel(
        id: json['id'] as String,
        eventId: json['event_id'] as String?,
        clubId: json['club_id'] as String?,
        userId: json['user_id'] as String?,
        weightSavedKg: (json['weight_saved_kg'] as num).toDouble(),
        costSaved: (json['cost_saved'] as num).toDouble(),
        carbonOffsetKg: (json['carbon_offset_kg'] as num).toDouble(),
        loggedAt: DateTime.parse(
          (json['logged_at'] ?? json['created_at']) as String,
        ),
      );

  @override
  List<Object?> get props => [id, weightSavedKg, costSaved, carbonOffsetKg];
}
