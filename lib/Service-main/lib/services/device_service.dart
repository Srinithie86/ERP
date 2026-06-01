import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceService {
  static const String key = "device_id";

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedId = prefs.getString(key);
    if (savedId != null && savedId.isNotEmpty) {
      return savedId;
    }

    final deviceInfo = DeviceInfoPlugin();
    String deviceId = "unknown_device";

    try {
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceId = android.id;
        if (deviceId.isEmpty || deviceId == "unknown") {
          deviceId = android.model + "_" + android.fingerprint;
        }
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceId = ios.identifierForVendor ?? "ios_unknown";
      }
    } catch (e) {
      print("DEVICE ERROR: $e");
    }

    await prefs.setString(key, deviceId);

    print("DEVICE ID SAVED: $deviceId");

    return deviceId;
  }
}
