import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static String _deviceId = '1';
  static String _ln = '145';
  static String _lt = '123';

  static String get deviceId => _deviceId;
  static String get longitude => _ln;
  static String get latitude => _lt;

  static Future<void> initDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();

    // Load cached values first
    _deviceId = prefs.getString('device_id') ?? '1';
    _ln = prefs.getString('ln') ?? '145';
    _lt = prefs.getString('lt') ?? '123';

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
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
          ).timeout(const Duration(seconds: 5));
          _ln = position.longitude.toString();
          _lt = position.latitude.toString();
        }
      }
    } catch (e) {
      debugPrint("DeviceService => Error getting location: $e");
    }

    await prefs.setString('device_id', _deviceId);
    await prefs.setString('ln', _ln);
    await prefs.setString('lt', _lt);
    
    debugPrint("DeviceService => Initialized: ID=$_deviceId, LT=$_lt, LN=$_ln");
  }
}
