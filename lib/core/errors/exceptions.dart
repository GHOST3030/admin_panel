class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});
  final String message;
  final String? statusCode;
}

class AuthException implements Exception {
  const AuthException({required this.message});
  final String message;
}
