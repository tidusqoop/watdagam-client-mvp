import 'dart:math';
import 'value_object.dart';

/// Represents a geographical location with latitude, longitude, and optional accuracy.
/// Provides distance calculation capabilities using the Haversine formula.
class Location extends ValueObject {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const Location({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  /// Creates a Location with current timestamp
  factory Location.now({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) {
    return Location(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      timestamp: DateTime.now(),
    );
  }

  /// Calculates the distance to another location using the Haversine formula
  /// Returns distance in kilometers
  double distanceTo(Location other) {
    const double earthRadiusKm = 6371.0;

    final double lat1Rad = latitude * pi / 180;
    final double lat2Rad = other.latitude * pi / 180;
    final double deltaLatRad = (other.latitude - latitude) * pi / 180;
    final double deltaLngRad = (other.longitude - longitude) * pi / 180;

    final double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Validates if the location coordinates are within valid ranges
  bool isValid() {
    return latitude >= -90 &&
           latitude <= 90 &&
           longitude >= -180 &&
           longitude <= 180;
  }

  /// Returns true if this location is within the specified radius of another location
  bool isWithinRadius(Location other, double radiusKm) {
    return distanceTo(other) <= radiusKm;
  }

  /// Creates a copy of this location with optionally updated values
  Location copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return Location(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, accuracy, timestamp];

  @override
  String toString() {
    return 'Location(lat: ${latitude.toStringAsFixed(6)}, '
           'lng: ${longitude.toStringAsFixed(6)}, '
           'accuracy: $accuracy, '
           'timestamp: $timestamp)';
  }
}