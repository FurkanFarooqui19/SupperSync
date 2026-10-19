/// SupperSync — Custom Exception Types
///
/// Provides typed exceptions so ViewModels can surface meaningful
/// error messages rather than raw Supabase/HTTP exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

/// Authentication related failures
final class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Network / connectivity failures
final class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Database query / write failures
final class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

/// Resource not found
final class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

/// Permission / authorization denied
final class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// Validation failure (client-side)
final class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// External API failures (Spoonacular, Open Food Facts, etc.)
final class ApiException extends AppException {
  const ApiException(super.message, {super.code});
}

/// Unknown / unclassified error
final class UnknownException extends AppException {
  const UnknownException(super.message, {super.code});
}
