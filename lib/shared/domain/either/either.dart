/// Simple Either implementation for error handling
/// Represents a value that can be either Left (error) or Right (success)
abstract class Either<L, R> {
  const Either();

  /// Creates a Left (error) value
  factory Either.left(L value) = Left<L, R>;

  /// Creates a Right (success) value
  factory Either.right(R value) = Right<L, R>;

  /// Returns true if this is a Left value
  bool get isLeft => this is Left<L, R>;

  /// Returns true if this is a Right value
  bool get isRight => this is Right<L, R>;

  /// Transforms the right value using the provided function
  Either<L, T> map<T>(T Function(R) transform) {
    if (isRight) {
      return Either.right(transform((this as Right<L, R>).value));
    }
    return Either.left((this as Left<L, R>).value);
  }

  /// Transforms the left value using the provided function
  Either<T, R> mapLeft<T>(T Function(L) transform) {
    if (isLeft) {
      return Either.left(transform((this as Left<L, R>).value));
    }
    return Either.right((this as Right<L, R>).value);
  }

  /// Returns the right value or throws if this is a Left
  R getOrThrow() {
    if (isRight) {
      return (this as Right<L, R>).value;
    }
    throw (this as Left<L, R>).value;
  }

  /// Returns the right value or the provided default
  R getOrElse(R Function() defaultValue) {
    if (isRight) {
      return (this as Right<L, R>).value;
    }
    return defaultValue();
  }

  /// Returns the left value or null if this is a Right
  L? getLeftOrNull() {
    if (isLeft) {
      return (this as Left<L, R>).value;
    }
    return null;
  }

  /// Returns the right value or null if this is a Left
  R? getRightOrNull() {
    if (isRight) {
      return (this as Right<L, R>).value;
    }
    return null;
  }

  /// Executes one of the provided functions based on the type
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (isLeft) {
      return onLeft((this as Left<L, R>).value);
    }
    return onRight((this as Right<L, R>).value);
  }
}

/// Left side of Either - represents an error or failure
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Left &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Right side of Either - represents a success value
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}