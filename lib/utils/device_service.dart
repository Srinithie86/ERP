import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static String _deviceId = "";
  static String _ln = "";
  static String _lt = "";

  static String get deviceId => _deviceId;
  static String get longitude => _ln;
  static String get latitude => _lt;
  
  static bool get isInitialized => _deviceId.isNotEmpty && _ln.isNotEmpty && _lt.isNotEmpty;

  static Future<void> initDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Load cached values first
    _deviceId = prefs.getString('device_id') ?? '';
    _ln = prefs.getString('ln') ?? prefs.getString('lng') ?? prefs.getDouble('lng')?.toString() ?? '';
    _lt = prefs.getString('lt') ?? prefs.getString('lat') ?? prefs.getDouble('lat')?.toString() ?? '';

    // Sync cached values to all variants immediately
    if (_lt.isNotEmpty) {
      await prefs.setString('lt', _lt);
      await prefs.setString('lat', _lt);
      final dlt = double.tryParse(_lt);
      if (dlt != null) await prefs.setDouble('lat', dlt);
    }
    if (_ln.isNotEmpty) {
      await prefs.setString('ln', _ln);
      await prefs.setString('lng', _ln);
      final dln = double.tryParse(_ln);
      if (dln != null) await prefs.setDouble('lng', dln);
    }
    if (_deviceId.isNotEmpty) await prefs.setString('device_id', _deviceId);

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        _deviceId = "Android|${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        _deviceId = "iOS|${iosInfo.model}";
      }
    } catch (e) {
      debugPrint("DeviceService => Error getting device info: $e");
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint("DeviceService => ERROR: Location services are disabled (GPS is OFF).");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("DeviceService => Current Permission Status: $permission");
      
      if (permission == LocationPermission.denied) {
        debugPrint("DeviceService => Requesting permission...");
        permission = await Geolocator.requestPermission();
        debugPrint("DeviceService => Permission after request: $permission");
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("DeviceService => ERROR: Location permissions are permanently denied.");
      } else if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        
        // 1. Try Last Known Position (Fastest)
        Position? lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          debugPrint("DeviceService => Using Last Known Position: ${lastPos.latitude}, ${lastPos.longitude}");
          await _syncAll(prefs, lastPos);
        }

        // 2. Try Current Position with Tiered Accuracy and ForceLocationManager
        int retries = 4;
        while (retries > 0 && (_lt.isEmpty || _ln.isEmpty)) {
          try {
            debugPrint("DeviceService => Attempting location fix (Mode: $retries)...");
            
            LocationAccuracy accuracy;
            if (retries == 4) accuracy = LocationAccuracy.high;
            else if (retries == 3) accuracy = LocationAccuracy.medium;
            else if (retries == 2) accuracy = LocationAccuracy.low;
            else accuracy = LocationAccuracy.lowest;

            LocationSettings settings;
            if (Platform.isAndroid) {
              settings = AndroidSettings(
                accuracy: accuracy,
                timeLimit: const Duration(seconds: 8),
                forceLocationManager: true,
              );
            } else {
              settings = AppleSettings(
                accuracy: accuracy,
                timeLimit: const Duration(seconds: 8),
              );
            }

            Position position = await Geolocator.getCurrentPosition(locationSettings: settings);
            
            debugPrint("DeviceService => SUCCESS! Fix found: ${position.latitude}, ${position.longitude}");
            await _syncAll(prefs, position);
            break; 
          } catch (e) {
            debugPrint("DeviceService => Attempt $retries failed: $e");
            retries--;
            if (retries > 0) await Future.delayed(const Duration(milliseconds: 300));
          }
        }
      }
    } catch (e) {
      debugPrint("DeviceService => UNEXPECTED ERROR: $e");
    }

    await prefs.setString('device_id', _deviceId);
    debugPrint("DeviceService => FINAL STATE: ID=$_deviceId, LT=$_lt, LN=$_ln");
  }

  static Future<void> _syncAll(SharedPreferences prefs, Position pos) async {
    _ln = pos.longitude.toString();
    _lt = pos.latitude.toString();
    await prefs.setString('lt', _lt);
    await prefs.setString('lat', _lt);
    await prefs.setDouble('lat', pos.latitude);
    await prefs.setString('ln', _ln);
    await prefs.setString('lng', _ln);
    await prefs.setDouble('lng', pos.longitude);
  }
}
