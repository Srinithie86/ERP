import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Checks location status and returns a map with:
  /// - status: bool (true if all okay)
  /// - type: String (PERMANENTLY_DENIED, SERVICES_OFF, etc.)
  /// - error: String (User-friendly message)
  static Future<Map<String, dynamic>> checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return {
        'status': false,
        'type': 'SERVICES_OFF',
        'error': 'Location services are disabled. Please enable GPS in settings.'
      };
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return {
          'status': false,
          'type': 'DENIED',
          'error': 'Location permissions are denied.'
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return {
        'status': false,
        'type': 'PERMANENTLY_DENIED',
        'error': 'Location permissions are permanently denied. Please enable in app settings.'
      };
    }

    return {'status': true};
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
