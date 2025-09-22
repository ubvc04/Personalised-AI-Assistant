class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException(this.message);
}