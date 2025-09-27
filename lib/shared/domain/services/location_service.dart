import '../value_objects/location.dart';

/// Service interface for location-related operations including GPS, permissions, and distance calculations
abstract class LocationService {
  /// Gets the current location of the device
  Future<Location> getCurrentLocation();

  /// Returns a stream of location updates
  Stream<Location> getLocationStream();

  /// Requests location permissions from the user
  Future<bool> requestPermissions();

  /// Checks if location services are enabled on the device
  Future<bool> isLocationEnabled();

  /// Checks if the app has location permissions
  Future<bool> hasLocationPermissions();

  /// Gets the permission status (granted, denied, etc.)
  Future<LocationPermissionStatus> getPermissionStatus();

  /// Opens the device settings for location permissions
  Future<bool> openLocationSettings();

  /// Opens the app settings for permissions
  Future<bool> openAppSettings();

  // Distance and geographic calculations

  /// Calculates the distance between two locations using the Haversine formula
  /// Returns distance in kilometers
  double calculateDistance(Location from, Location to);

  /// Calculates the distance in meters between two locations
  double calculateDistanceInMeters(Location from, Location to);

  /// Calculates the bearing from one location to another in degrees
  double calculateBearing(Location from, Location to);

  /// Checks if a location is within a specified radius of another location
  bool isWithinRadius(Location from, Location to, double radiusKm);

  /// Gets the closest location from a list of locations
  Location? getClosestLocation(Location userLocation, List<Location> locations);

  /// Sorts locations by distance from a reference location
  List<Location> sortByDistance(Location reference, List<Location> locations);

  // Location validation and utilities

  /// Validates if coordinates are valid (within valid lat/lng ranges)
  bool validateCoordinates(double latitude, double longitude);

  /// Normalizes longitude to be within -180 to 180 range
  double normalizeLongitude(double longitude);

  /// Normalizes latitude to be within -90 to 90 range
  double normalizeLatitude(double latitude);

  /// Converts coordinates to a human-readable string
  String coordinatesToString(double latitude, double longitude, {int precision = 6});

  /// Parses coordinates from a string
  Location? parseCoordinatesFromString(String coordinatesString);

  // Area and boundary calculations

  /// Checks if a location is within a rectangular boundary
  bool isWithinBounds(
    Location location,
    Location southWest,
    Location northEast,
  );

  /// Calculates the center point of multiple locations
  Location calculateCenterPoint(List<Location> locations);

  /// Creates a bounding box around a location with the specified radius
  Map<String, Location> createBoundingBox(Location center, double radiusKm);

  /// Calculates the area of a polygon defined by locations (in square kilometers)
  double calculatePolygonArea(List<Location> polygon);

  // Privacy and security

  /// Adds random noise to coordinates for privacy protection
  Location obfuscateLocation(Location original, {double radiusMeters = 100});

  /// Reduces precision of coordinates for privacy
  Location reducePrecision(Location original, {int decimalPlaces = 3});

  // Mock and testing support

  /// Sets a mock location for testing purposes
  void setMockLocation(Location mockLocation);

  /// Enables/disables mock location mode
  void setMockLocationEnabled(bool enabled);

  /// Clears the mock location
  void clearMockLocation();

  // Caching and optimization

  /// Sets the minimum time interval between location updates (in milliseconds)
  void setLocationUpdateInterval(int intervalMs);

  /// Sets the minimum distance change required for location updates (in meters)
  void setLocationUpdateDistance(double distanceMeters);

  /// Gets the last known location from cache
  Future<Location?> getLastKnownLocation();

  /// Clears the location cache
  void clearLocationCache();

  // Error handling and diagnostics

  /// Gets the current location service status
  Future<LocationServiceStatus> getServiceStatus();

  /// Performs a location service health check
  Future<LocationHealthCheck> performHealthCheck();

  /// Gets location accuracy information
  Future<LocationAccuracyInfo> getAccuracyInfo();
}

/// Enum representing location permission status
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  whileInUse,
  unknown,
}

/// Enum representing location service status
enum LocationServiceStatus {
  enabled,
  disabled,
  restricted,
  unknown,
}

/// Class representing location service health check results
class LocationHealthCheck {
  final bool isHealthy;
  final List<String> issues;
  final Map<String, dynamic> diagnostics;

  const LocationHealthCheck({
    required this.isHealthy,
    required this.issues,
    required this.diagnostics,
  });
}

/// Class representing location accuracy information
class LocationAccuracyInfo {
  final double? horizontalAccuracy;
  final double? verticalAccuracy;
  final DateTime timestamp;
  final String accuracyLevel; // 'high', 'medium', 'low'

  const LocationAccuracyInfo({
    this.horizontalAccuracy,
    this.verticalAccuracy,
    required this.timestamp,
    required this.accuracyLevel,
  });
}