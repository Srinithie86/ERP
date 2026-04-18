import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceServices {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const Uuid _uuid = Uuid();
  
  // Singleton cache to prevent redundant OS calls
  static Map<String, String>? _cachedData;
  static DateTime? _lastFetchTime;

  /// Gets device info with optimization: caches result to avoid multiple slow GPS hits
  static Future<Map<String, String>> getAndStoreDeviceInfo({bool forceRefresh = false}) async {
    final now = DateTime.now();
    
    // Return cached data if it's fresh (last 5 minutes)
    if (!forceRefresh && _cachedData != null && _lastFetchTime != null) {
      if (now.difference(_lastFetchTime!).inMinutes < 5) {
        return _cachedData!;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    String deviceId = await getStableDeviceId(prefs);

    // If we have cached but stale location, use it while fetching new one? 
    // For now, let's just make the find faster.
    
    // Attempt to get accurate location (this may trigger permission requests)
    // Reduce timeout for better UX - 10s is too long for a network request dependency
    final locationData = await _getLocationWithPermission();

    final lt = locationData['lt']!;
    final ln = locationData['ln']!;

    await prefs.setString('device_id', deviceId);
    await prefs.setString('lt', lt);
    await prefs.setString('ln', ln);

    _cachedData = {'device_id': deviceId, 'lt': lt, 'ln': ln};
    _lastFetchTime = now;

    return _cachedData!;
  }
  
  // Quick getter that doesn't trigger OS location requests
  static Future<Map<String, String>> getQuickDeviceInfo() async {
    if (_cachedData != null) return _cachedData!;
    
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    String? lt = prefs.getString('lt');
    String? ln = prefs.getString('ln');
    
    if (deviceId != null && lt != null && ln != null) {
      _cachedData = {'device_id': deviceId, 'lt': lt, 'ln': ln};
      return _cachedData!;
    }
    
    // If nothing in prefs, fall back to slow version
    return getAndStoreDeviceInfo();
  }

  /// Create a stable device ID
  static Future<String> getStableDeviceId(SharedPreferences prefs) async {
    String? storedId = prefs.getString('device_id');
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    String? hardwareId;
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        hardwareId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        hardwareId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      debugPrint("Failed to get hardware device ID: $e");
    }

    final stableId = (hardwareId != null && hardwareId.isNotEmpty && hardwareId != "unknown")
        ? hardwareId
        : _uuid.v4();

    return stableId;
  }

  /// Get location with permission check and service enabling
  static Future<Map<String, String>> _getLocationWithPermission() async {
    String lt = "0.0";
    String ln = "0.0";

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {'lt': lt, 'ln': ln};
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return {'lt': lt, 'ln': ln};
      }

      if (permission == LocationPermission.deniedForever) return {'lt': lt, 'ln': ln};

      Position? position;
      try {
        // Use a much smaller timeout for blocking calls. 
        // Try getting last known position first as it's instant.
        position = await Geolocator.getLastKnownPosition();
        
        // If no last known position, try a very quick hit
        if (position == null) {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low, // Use low accuracy for speed
            timeLimit: const Duration(seconds: 3), // Reduced from 10s to 3s
          );
        }
      } catch (e) {
        debugPrint("Location fetch failed: $e. Using local fallback.");
      }

      if (position != null) {
        lt = position.latitude.toStringAsFixed(6);
        ln = position.longitude.toStringAsFixed(6);
      }
    } catch (e) {
      debugPrint("Location service error: $e");
    }

    return {'lt': lt, 'ln': ln};
  }

  /// Show a dialog if location is disabled or missing
  static void showLocationRequiredPopup(BuildContext context, {VoidCallback? onRetry}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Location Required"),
        content: const Text("Please enable location services and grant permission for optimized app performance."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Geolocator.openLocationSettings();
              if (onRetry != null) onRetry();
            },
            child: const Text("Enable / Settings"),
          ),
        ],
      ),
    );
  }
}
