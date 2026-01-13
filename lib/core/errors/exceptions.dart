/// Base exception class for all server exceptions
abstract class ServerException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  
  const ServerException(this.message, {this.code, this.statusCode});
  
  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when API request fails
class ApiException extends ServerException {
  const ApiException(String message, {int? statusCode, String? code}) 
      : super(message, code: code, statusCode: statusCode);
}

/// Exception thrown when authentication fails
class AuthenticationException extends ServerException {
  const AuthenticationException(String message) : super(message);
}

/// Exception thrown when authorization fails (insufficient permissions)
class AuthorizationException extends ServerException {
  const AuthorizationException(String message) : super(message);
}

/// Exception thrown when requested resource is not found
class NotFoundException extends ServerException {
  const NotFoundException(String message) : super(message);
}

/// Exception thrown when validation fails
class ValidationException extends ServerException {
  final Map<String, List<String>>? errors;
  
  const ValidationException(String message, {this.errors}) : super(message);
}

/// Exception thrown when there's a timeout
class TimeoutException extends ServerException {
  const TimeoutException(String message) : super(message);
}

/// Exception thrown when parsing data fails
class ParseException extends ServerException {
  const ParseException(String message) : super(message);
}

/// Exception thrown when there's an issue with the cache
class CacheException extends ServerException {
  const CacheException(String message) : super(message);
}

/// Exception specific to preinscription operations
class PreinscriptionException extends ServerException {
  const PreinscriptionException(String message, {String? code}) 
      : super(message, code: code);
}
