import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Following Either<Failure, Success> pattern for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  List<Object?> get props => [message, code, details];
}

/// Generic failure for unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when operation cannot be performed due to business rules
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when creating or saving data
class CreationFailure extends Failure {
  const CreationFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when updating existing data
class UpdateFailure extends Failure {
  const UpdateFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when deleting data
class DeletionFailure extends Failure {
  const DeletionFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure related to location services
class LocationFailure extends Failure {
  const LocationFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure related to permission access
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure related to image processing
class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when operation involves network communication
class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when caching operations fail
class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when database operations fail
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when authentication is required but not provided
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when user doesn't have permission for the operation
class AuthorizationFailure extends Failure {
  const AuthorizationFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when trying to access expired data or tokens
class ExpirationFailure extends Failure {
  const ExpirationFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}

/// Failure when resource conflicts with existing data
class ConflictFailure extends Failure {
  const ConflictFailure(String message, {String? code, dynamic details})
      : super(message, code: code, details: details);
}