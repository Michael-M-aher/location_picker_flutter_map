import 'dart:async';

import 'dart:math';
import '../classes.dart';

/// Enhanced stream controller for managing location updates
class LocationUpdateController {
  final StreamController<LatLong> _controller =
      StreamController<LatLong>.broadcast();

  /// Stream of location updates
  Stream<LatLong> get stream => _controller.stream;

  /// Add a new location update
  void addLocation(LatLong location) {
    if (!_controller.isClosed) {
      _controller.add(location);
    }
  }

  /// Close the controller
  void dispose() {
    _controller.close();
  }
}

/// Utility class for coordinate calculations and validations
class CoordinateUtils {
  /// Validates if coordinates are within valid ranges
  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  /// Calculates the center point between two coordinates
  static LatLong calculateCenter(LatLong point1, LatLong point2) {
    final centerLat = (point1.latitude + point2.latitude) / 2;
    final centerLng = (point1.longitude + point2.longitude) / 2;
    return LatLong(centerLat, centerLng);
  }

  /// Formats coordinates for display
  static String formatCoordinates(LatLong coordinates, {int precision = 6}) {
    return '${coordinates.latitude.toStringAsFixed(precision)}, '
        '${coordinates.longitude.toStringAsFixed(precision)}';
  }

  /// Converts degrees to radians
  static double toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Converts radians to degrees
  static double toDegrees(double radians) {
    return radians * (180 / pi);
  }
}

/// Constants used throughout the location picker
class LocationPickerConstants {
  static const Duration defaultAnimationDuration = Duration(milliseconds: 2000);
  static const Duration defaultDebounceDuration = Duration(milliseconds: 500);
  static const double defaultMarkerOffset = 50.0;
  static const int defaultSearchResultLimit = 5;
  static const String defaultNominatimHost = 'nominatim.openstreetmap.org';
  static const String defaultTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
