/// Fuzzy ingredient matching for pantry ↔ recipe names.
/// Handles plurals, typos, and common aliases (e.g. tomatos → tomato).
abstract final class IngredientMatcher {
  IngredientMatcher._();

  static const Map<String, String> _aliases = {
    'tomatos': 'tomato',
    'tomatoes': 'tomato',
    'tomatoe': 'tomato',
    'eggs': 'egg',
    'garlic cloves': 'garlic',
    'cloves garlic': 'garlic',
    'bell peppers': 'bell pepper',
    'peppers': 'bell pepper',
    'onions': 'onion',
    'carrots': 'carrot',
    'potatoes': 'potato',
    'potatos': 'potato',
    'lentil': 'lentils',
    'oliveoil': 'olive oil',
    'soysauce': 'soy sauce',
    'cheeses': 'cheese',
    'butters': 'butter',
    'milks': 'milk',
    'brocolli': 'broccoli',
    'brocoli': 'broccoli',
  };

  static String normalize(String raw) {
    var s = raw.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (_aliases.containsKey(s)) return _aliases[s]!;

    // Simple plural normalization
    if (s.endsWith('ies') && s.length > 4) {
      s = '${s.substring(0, s.length - 3)}y';
    } else if (s.endsWith('oes') && s.length > 4) {
      s = s.substring(0, s.length - 2); // tomatoes → tomato
    } else if (s.endsWith('ses') && s.length > 4) {
      s = s.substring(0, s.length - 2);
    } else if (s.endsWith('s') && !s.endsWith('ss') && s.length > 3) {
      s = s.substring(0, s.length - 1);
    }

    if (_aliases.containsKey(s)) return _aliases[s]!;
    return s;
  }

  static bool matches(String pantryName, String recipeIngredient) {
    final a = normalize(pantryName);
    final b = normalize(recipeIngredient);
    if (a.isEmpty || b.isEmpty) return false;
    if (a == b) return true;
    if (a.contains(b) || b.contains(a)) return true;

    final tokensA = a.split(' ').where((t) => t.length > 2).toSet();
    final tokensB = b.split(' ').where((t) => t.length > 2).toSet();
    if (tokensA.isEmpty || tokensB.isEmpty) return false;
    return tokensA.intersection(tokensB).isNotEmpty;
  }

  static bool isInPantry(String recipeIngredient, Set<String> pantryNames) {
    return pantryNames.any((p) => matches(p, recipeIngredient));
  }
}
