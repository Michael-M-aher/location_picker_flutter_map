import 'package:geolocator/geolocator.dart';
import '../classes.dart';

/// Service class for handling location-related operations
class LocationService {
  /// Gets the current position of the device
  static Future<LatLong> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLong(position.latitude, position.longitude);
    } catch (e) {
      throw LocationException(
          'Failed to get current position: ${e.toString()}');
    }
  }

  /// Checks if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Gets the current location permission status
  static Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Opens location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Opens app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Calculates the distance between two coordinates in meters
  static double calculateDistance(LatLong start, LatLong end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}

/// Custom exception for location-related errors
class LocationException implements Exception {
  final String message;

  const LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}
