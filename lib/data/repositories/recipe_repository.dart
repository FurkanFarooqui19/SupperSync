import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_exception.dart';
import '../models/pantry_item_model.dart';
import '../models/recipe_model.dart';

/// Recipe suggestions from Supabase `recipes` catalog (no mock data).
/// Barcode lookup still uses Open Food Facts (external product DB).
class RecipeRepository {
  RecipeRepository() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  static const String _openFoodFactsBase =
      'https://world.openfoodfacts.org/api/v0/product';

  // ── Match recipes from DB against collective pantry ────────────────────────
  ///
  /// Always returns recipes ranked by pantry match, **including ones with
  /// missing ingredients** (so the club can claim/buy what's left).
  Future<List<RecipeModel>> fetchRecipesByIngredients({
    required List<PantryItemModel> pantryItems,
    List<String> dietaryFilters = const [],
    int number = 12,
  }) async {
    if (pantryItems.isEmpty) return [];

    try {
      final rows = await _client
          .from('recipes')
          .select('*, recipe_ingredients(*)')
          .order('title');

      if (rows.isEmpty) {
        throw const DatabaseException(
          'No recipes in database. Run supabase/recipes_catalog.sql in the SQL Editor.',
        );
      }

      final pantryNames = pantryItems
          .map((e) => e.name.toLowerCase().trim())
          .where((n) => n.isNotEmpty)
          .toSet();

      final dietLower =
          dietaryFilters.map((d) => d.toLowerCase().trim()).toList();

      final matched = <RecipeModel>[];

      for (final row in rows) {
        final recipe = Map<String, dynamic>.from(row as Map);
        final tags = List<String>.from(recipe['dietary_tags'] ?? const []);

        if (dietLower.isNotEmpty) {
          final tagLower = tags.map((t) => t.toLowerCase()).toList();
          final ok = dietLower.every(
            (f) => tagLower.any((t) => t.contains(f) || f.contains(t)),
          );
          if (!ok) continue;
        }

        final ingredients = List<Map<String, dynamic>>.from(
          (recipe['recipe_ingredients'] as List<dynamic>? ?? const [])
              .map((e) => Map<String, dynamic>.from(e as Map)),
        );

        if (ingredients.isEmpty) continue;

        matched.add(
          RecipeModel.fromSupabaseMatch(
            recipeJson: recipe,
            ingredientRows: ingredients,
            pantryNamesLower: pantryNames,
          ),
        );
      }

      // Prefer highest match; still keep recipes with missing ingredients.
      // Among ties, fewer missing first.
      matched.sort((a, b) {
        final byMatch = b.matchPercentage.compareTo(a.matchPercentage);
        if (byMatch != 0) return byMatch;
        return a.missedCount.compareTo(b.missedCount);
      });

      return matched.take(number).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Failed to load recipes from database: $e');
    }
  }

  // ── Barcode lookup via Open Food Facts ─────────────────────────────────────
  Future<Map<String, dynamic>?> lookupBarcode(String barcode) async {
    try {
      final uri = Uri.parse('$_openFoodFactsBase/$barcode.json');
      final response = await http.get(uri);

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] == 0) return null;

      final product = json['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      return {
        'name': product['product_name'] ?? product['product_name_en'] ?? '',
        'category': _mapOpenFoodCategory(
          product['categories_tags'] as List<dynamic>? ?? [],
        ),
        'imageUrl': product['image_url'],
        'barcode': barcode,
      };
    } catch (_) {
      return null;
    }
  }

  String _mapOpenFoodCategory(List<dynamic> tags) {
    final tagStr = tags.join(' ').toLowerCase();
    if (tagStr.contains('vegetable')) return 'Vegetables';
    if (tagStr.contains('fruit')) return 'Fruits';
    if (tagStr.contains('dairy') || tagStr.contains('milk')) return 'Dairy';
    if (tagStr.contains('meat') || tagStr.contains('fish')) {
      return 'Meat & Seafood';
    }
    if (tagStr.contains('cereal') ||
        tagStr.contains('pasta') ||
        tagStr.contains('bread')) {
      return 'Grains & Pasta';
    }
    if (tagStr.contains('beverage') || tagStr.contains('drink')) {
      return 'Beverages';
    }
    if (tagStr.contains('snack')) return 'Snacks';
    return 'Other';
  }
}
