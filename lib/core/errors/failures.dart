import 'package:equatable/equatable.dart';

/// Base failure class for all failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'Failure: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Failure representing a server error
class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure(String message, {this.statusCode, String? code}) 
      : super(message, code: code);
  
  @override
  List<Object?> get props => [message, statusCode, code];
}

/// Failure representing a network connectivity issue
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Failure representing an authentication error
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

/// Failure representing an authorization error (insufficient permissions)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(String message) : super(message);
}

/// Failure representing a not found error
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Failure representing a validation error
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;
  
  const ValidationFailure(String message, {this.errors}) : super(message);
  
  @override
  List<Object?> get props => [message, errors];
}

/// Failure representing a timeout error
class TimeoutFailure extends Failure {
  const TimeoutFailure(String message) : super(message);
}

/// Failure representing a parsing error
class ParseFailure extends Failure {
  const ParseFailure(String message) : super(message);
}

/// Failure representing a cache error
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Failure specific to preinscription operations
class PreinscriptionFailure extends Failure {
  const PreinscriptionFailure(String message, {String? code}) 
      : super(message, code: code);
}

/// Failure representing an unknown error
class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}
