import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/pantry_item_model.dart';
import '../../data/models/recipe_model.dart';
import '../../data/repositories/pantry_repository.dart';
import '../../data/repositories/recipe_repository.dart';

/// Recipe matching from the **combined** club pantry:
/// my items + other members' shared items.
///
/// MVVM Rule: No setState() — notifyListeners() only.
class RecipeViewModel extends ChangeNotifier {
  RecipeViewModel(this._recipeRepo, this._pantryRepo);

  final RecipeRepository _recipeRepo;
  final PantryRepository _pantryRepo;

  List<RecipeModel> _recipes = [];
  List<PantryItemModel> _aggregatedPantry = [];
  bool _isLoading = false;
  bool _hasLoadedSuggestions = false;
  String? _error;
  List<String> _activeFilters = [];
  String? _suggestionClubId;
  String? _suggestionClubName;
  int _otherClubMemberCount = 0;

  List<RecipeModel> get recipes => _recipes;
  List<PantryItemModel> get aggregatedPantry => _aggregatedPantry;
  bool get isLoading => _isLoading;
  bool get hasLoadedSuggestions => _hasLoadedSuggestions;
  String? get error => _error;
  List<String> get activeFilters => _activeFilters;
  bool get hasRecipes => _recipes.isNotEmpty;
  int get combinedItemCount => _aggregatedPantry.length;
  String? get suggestionClubId => _suggestionClubId;
  String? get suggestionClubName => _suggestionClubName;

  int get myItemCount {
    final me = _pantryRepo.currentUserId;
    if (me == null) return 0;
    return _aggregatedPantry.where((i) => i.ownerId == me).length;
  }

  int get othersItemCount => combinedItemCount - myItemCount;

  /// Unique other members who contributed shared items to this match.
  int get otherContributorCount {
    final me = _pantryRepo.currentUserId;
    return _aggregatedPantry
        .map((i) => i.ownerId)
        .where((id) => me == null || id != me)
        .toSet()
        .length;
  }

  /// Other club members (excludes you). From real membership count.
  int get otherClubMemberCount => _otherClubMemberCount;

  RecipeModel? get topRecipe =>
      _recipes.isEmpty ? null : _recipes.first;

  /// e.g. "You + 2 members can make Tomato Pasta"
  String? get cookTogetherHeadline {
    final recipe = topRecipe;
    if (recipe == null) return null;
    final others = _otherClubMemberCount > 0
        ? _otherClubMemberCount
        : otherContributorCount;
    if (others > 0) {
      return 'You + $others member${others == 1 ? '' : 's'} can make ${recipe.title}';
    }
    return 'You can make ${recipe.title} — share pantry items so club members can join';
  }

  String? get cookTogetherSubtitle {
    final recipe = topRecipe;
    if (recipe == null) return null;
    final club = _suggestionClubName;
    final match = recipe.matchPercentage.toStringAsFixed(0);
    final missing = recipe.missedIngredients.length;
    final clubPart = club != null ? '$club · ' : '';
    return '$clubPart$match% match'
        '${missing > 0 ? ' · $missing missing' : ' · ready to cook'}';
  }

  // ── Event: my pantry + attendees'/club members' shared items ───────────────
  Future<void> loadRecipesForEvent({
    required String clubId,
    required List<String> attendeeIds,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _aggregatedPantry = await _pantryRepo.fetchCombinedForEvent(
        clubId: clubId,
        attendeeIds: attendeeIds,
      );

      if (_aggregatedPantry.isEmpty) {
        _recipes = [];
        _setError(
          'Combined pantry is empty. Add items and ask members to share theirs.',
        );
        return;
      }

      _recipes = await _recipeRepo.fetchRecipesByIngredients(
        pantryItems: _aggregatedPantry,
        dietaryFilters: _activeFilters,
      );
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load recipes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Used when user has no clubs yet — shows join CTA on pantry banner.
  void clearSuggestionsForNoClub() {
    _suggestionClubId = null;
    _suggestionClubName = null;
    _otherClubMemberCount = 0;
    _recipes = [];
    _aggregatedPantry = [];
    _error = null;
    _hasLoadedSuggestions = true;
    notifyListeners();
  }

  /// Allow pantry/club screens to force a fresh DB reload.
  void invalidateSuggestions() {
    _hasLoadedSuggestions = false;
  }

  // ── Club: my pantry + all club members' shared items ───────────────────────
  Future<void> loadRecipesForClub(
    String clubId, {
    String? clubName,
    int? memberCount,
  }) async {
    if (clubId.isEmpty) {
      clearSuggestionsForNoClub();
      return;
    }
    _suggestionClubId = clubId;
    _suggestionClubName = clubName;
    // Real club size minus you — never invent members.
    _otherClubMemberCount =
        memberCount != null && memberCount > 0 ? memberCount - 1 : 0;
    _setLoading(true);
    _clearError();
    try {
      _aggregatedPantry = await _pantryRepo.fetchCombinedForClub(clubId);

      if (_aggregatedPantry.isEmpty) {
        _recipes = [];
        _setError(
          'No pantry items yet. Add yours and ask members to share theirs.',
        );
        return;
      }

      _recipes = await _recipeRepo.fetchRecipesByIngredients(
        pantryItems: _aggregatedPantry,
        dietaryFilters: _activeFilters,
      );
    } on AppException catch (e) {
      _setError(e.message);
    } catch (e) {
      _setError('Failed to load recipes: $e');
    } finally {
      _hasLoadedSuggestions = true;
      _setLoading(false);
    }
  }

  void toggleFilter(String filter) {
    if (_activeFilters.contains(filter)) {
      _activeFilters = _activeFilters.where((f) => f != filter).toList();
    } else {
      _activeFilters = [..._activeFilters, filter];
    }
    notifyListeners();
  }

  void clearFilters() {
    _activeFilters = [];
    notifyListeners();
  }

  Future<Map<String, dynamic>?> lookupBarcode(String barcode) async {
    return await _recipeRepo.lookupBarcode(barcode);
  }

  void clearError() => _clearError();

  void _setLoading(bool v) {
    _isLoading = v;
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
