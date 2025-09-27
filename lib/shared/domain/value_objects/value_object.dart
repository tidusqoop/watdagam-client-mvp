import 'package:equatable/equatable.dart';

/// Base class for all value objects in the domain layer.
/// Value objects are immutable objects whose equality is based on their values
/// rather than their identity.
abstract class ValueObject extends Equatable {
  const ValueObject();

  @override
  bool get stringify => true;
}