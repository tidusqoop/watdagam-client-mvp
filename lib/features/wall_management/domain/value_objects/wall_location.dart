import '../../../../shared/domain/value_objects/value_object.dart';
import '../../../../shared/domain/value_objects/location.dart';

/// Represents the location of a wall with address information and distance calculation capabilities
class WallLocation extends ValueObject {
  final double latitude;
  final double longitude;
  final String address;

  const WallLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  /// Creates a WallLocation from a Location and address
  factory WallLocation.fromLocation(Location location, String address) {
    return WallLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      address: address,
    );
  }

  /// Creates a WallLocation with coordinates only (address will be empty)
  factory WallLocation.fromCoordinates({
    required double latitude,
    required double longitude,
  }) {
    return WallLocation(
      latitude: latitude,
      longitude: longitude,
      address: '',
    );
  }

  /// Converts this WallLocation to a Location object
  Location toLocation() {
    return Location.now(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Calculates the distance to another location using the Haversine formula
  /// Returns distance in kilometers
  double distanceTo(Location other) {
    return toLocation().distanceTo(other);
  }

  /// Calculates the distance to another WallLocation
  /// Returns distance in kilometers
  double distanceToWall(WallLocation other) {
    return distanceTo(other.toLocation());
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

  /// Checks if this wall location has a valid address
  bool get hasAddress => address.trim().isNotEmpty;

  /// Returns the display address or coordinates if no address is available
  String get displayAddress {
    if (hasAddress) return address;
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  /// Creates a copy of this wall location with optionally updated values
  WallLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return WallLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }

  /// Updates the address of this wall location
  WallLocation updateAddress(String newAddress) {
    return copyWith(address: newAddress);
  }

  @override
  List<Object?> get props => [latitude, longitude, address];

  @override
  String toString() {
    return 'WallLocation(lat: ${latitude.toStringAsFixed(6)}, '
           'lng: ${longitude.toStringAsFixed(6)}, '
           'address: "$address")';
  }
}