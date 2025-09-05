import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

/// Service class for handling location permissions with user-friendly dialogs
class PermissionService {
  final BuildContext context;

  const PermissionService(this.context);

  /// Checks and requests location permissions with appropriate user dialogs
  Future<bool> checkAndRequestLocationPermission() async {
    try {
      // Check if location services are enabled
      if (!await LocationService.isLocationServiceEnabled()) {
        await _showLocationServiceDialog();
        throw const LocationException('Location services are disabled.');
      }

      // Check current permission status
      var permission = await LocationService.getPermissionStatus();

      if (permission == LocationPermission.denied) {
        permission = await _requestPermissionWithDialog();
        if (permission == LocationPermission.denied) {
          throw const LocationException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await _showPermanentlyDeniedDialog();
        throw const LocationException('Location permissions are permanently denied');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Shows dialog when location services are disabled
  Future<void> _showLocationServiceDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enable Location Services'),
        content: const Text(
          'Location services are disabled. Please enable them in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await LocationService.openLocationSettings();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Requests permission with explanatory dialog
  Future<LocationPermission> _requestPermissionWithDialog() async {
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs access to your location to provide location-based services. Your location data will only be used for the intended functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Allow'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Deny'),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      return await LocationService.requestPermission();
    }

    return LocationPermission.denied;
  }

  /// Shows dialog when permissions are permanently denied
  Future<void> _showPermanentlyDeniedDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permissions are permanently denied. Please enable them in app settings to use location features.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await LocationService.openAppSettings();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Quick permission check without dialogs
  static Future<bool> hasLocationPermission() async {
    final permission = await LocationService.getPermissionStatus();
    return permission == LocationPermission.whileInUse ||
           permission == LocationPermission.always;
  }
}
