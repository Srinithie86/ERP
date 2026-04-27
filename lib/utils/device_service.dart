import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'widgets/location_dialog.dart';

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
        debugPrint("DeviceService => Location services are disabled (GPS is OFF).");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("DeviceService => Current Permission Status: $permission");
      
      if (permission == LocationPermission.denied) {
        debugPrint("DeviceService => Requesting permission...");
        permission = await Geolocator.requestPermission();
        debugPrint("DeviceService => Permission after request: $permission");
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint("DeviceService => Location permissions are permanently denied.");
      } else if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        
        // 1. Try Last Known Position (Fastest)
        Position? lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          debugPrint("DeviceService => Using Last Known Position: ${lastPos.latitude}, ${lastPos.longitude}");
          await _syncAll(prefs, lastPos);
        }

        // 2. Try Current Position only if location service is enabled
        if (serviceEnabled) {
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
        } else {
          debugPrint("DeviceService => Skipped current position check because GPS is OFF.");
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

  static Future<void> forceFetchLocation(BuildContext context) async {
    try {
      await ensureLocationPermission(context);

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Please enable location services (GPS) to continue.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        // Show a small loader if possible, but for now just fetch
        try {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );
          
          final prefs = await SharedPreferences.getInstance();
          await _syncAll(prefs, position);
          debugPrint("DeviceService => Dashboard Location Update: ${position.latitude}, ${position.longitude}");
        } catch (e) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Location Error"),
                content: const Text("Could not get your real-time location. Please check your GPS signal."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("DeviceService => forceFetchLocation Error: $e");
    }
  }

  static Future<void> ensureLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationPermissionDialog(
          isServiceDisabled: true,
          onAllow: () {},
          onOpenSettings: () => Geolocator.openLocationSettings(),
        ),
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!context.mounted) return;
      
      bool? shouldRequest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationPermissionDialog(
          onAllow: () => Navigator.pop(context, true),
          onOpenSettings: () => Geolocator.openAppSettings(),
        ),
      );

      if (shouldRequest == true) {
        await Geolocator.requestPermission();
      }
    } else if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LocationPermissionDialog(
          isPermanent: true,
          onAllow: () {},
          onOpenSettings: () => Geolocator.openAppSettings(),
        ),
      );
    }
  }
}
