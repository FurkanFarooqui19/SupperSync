/// SupperSync — Route Name Constants
abstract final class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Shell routes (bottom nav)
  static const String home = '/home';
  static const String pantry = '/pantry';
  static const String clubs = '/clubs';
  static const String events = '/events';
  static const String profile = '/profile';

  // Sub-routes
  static const String addPantryItem = '/pantry/add';
  static const String editPantryItem = '/pantry/edit';

  static const String createClub = '/clubs/create';
  static const String joinClub = '/clubs/join';
  static const String clubDetail = '/clubs/:clubId';

  static const String createEvent = '/events/create';
  static const String eventDetail = '/events/:eventId';

  static const String recipes = '/events/:eventId/recipes';
  static const String editProfile = '/profile/edit';
}
