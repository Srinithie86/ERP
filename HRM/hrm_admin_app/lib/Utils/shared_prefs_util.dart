import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil {
  /// Returns the Company ID (cid) stored in SharedPreferences.
  static Future<String> getCid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cid') ?? prefs.get('cid_str')?.toString() ?? '';
  }

  /// Returns the Device ID storde in SharedPreferences.
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_id') ?? '';
  }

  /// Returns the Latitude (lt/lat) stored in SharedPreferences.
  /// Handles both String (lt) and Double (lat) types.
  static Future<String> getLat() async {
    final prefs = await SharedPreferences.getInstance();
    // Check both 'lt' (String) and 'lat' (Double)
    String? lt = prefs.getString('lt');
    if (lt == null || lt.isEmpty || lt == "0.0") {
      final double? lat = prefs.getDouble('lat');
      if (lat != null) lt = lat.toString();
    }
    return lt ?? '0.0';
  }

  /// Returns the Longitude (ln/lng) stored in SharedPreferences.
  /// Handles both String (ln) and Double (lng) types.
  static Future<String> getLng() async {
    final prefs = await SharedPreferences.getInstance();
    // Check both 'ln' (String/Double) and 'lng' (Double)
    String? ln = prefs.getString('ln');
    if (ln == null || ln.isEmpty || ln == "0.0") {
      final double? lng = prefs.getDouble('lng');
      if (lng != null) ln = lng.toString();
    }
    return ln ?? '0.0';
  }

  /// Returns the UID/Employee ID.
  static Future<String> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid') ??
           prefs.getString('login_cus_id') ??
           prefs.getString('employee_table_id') ??
           '';
  }
}
