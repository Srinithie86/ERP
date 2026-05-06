import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns the Company ID (cid) stored in SharedPreferences.
  static Future<String> getCid() async {
    final prefs = await _instance;
    return prefs.getString('cid') ?? prefs.get('cid_str')?.toString() ?? '';
  }

  /// Returns the Device ID storde in SharedPreferences.
  static Future<String> getDeviceId() async {
    final prefs = await _instance;
    return prefs.getString('device_id') ?? '';
  }

  /// Returns the Latitude (lt/lat) stored in SharedPreferences.
  static Future<String> getLat() async {
    final prefs = await _instance;
    String? lt = prefs.getString('lt');
    if (lt == null || lt.isEmpty || lt == "0.0") {
      final double? lat = prefs.getDouble('lat');
      if (lat != null) lt = lat.toString();
    }
    return lt ?? '0.0';
  }

  /// Returns the Longitude (ln/lng) stored in SharedPreferences.
  static Future<String> getLng() async {
    final prefs = await _instance;
    String? ln = prefs.getString('ln');
    if (ln == null || ln.isEmpty || ln == "0.0") {
      final double? lng = prefs.getDouble('lng');
      if (lng != null) ln = lng.toString();
    }
    return ln ?? '0.0';
  }

  /// Returns the UID/Employee ID.
  static Future<String> getUid() async {
    final prefs = await _instance;
    return prefs.getString('uid') ??
        prefs.getString('login_cus_id') ??
        prefs.getString('employee_table_id') ??
        '';
  }

  /// Returns the session Token.
  static Future<String> getToken() async {
    final prefs = await _instance;
    return prefs.getString('token') ?? '';
  }

  /// Returns a map of all common parameters to avoid multiple SharedPreferences calls.
  static Future<Map<String, String>> getCommonParams() async {
    final prefs = await _instance;
    
    String cid = prefs.getString('cid') ?? prefs.get('cid_str')?.toString() ?? '';
    String deviceId = prefs.getString('device_id') ?? '';
    String uid = prefs.getString('uid') ??
           prefs.getString('login_cus_id') ??
           prefs.getString('employee_table_id') ??
           '';
    String token = prefs.getString('token') ?? '';
    
    // Latitude
    String? lt = prefs.getString('lt');
    if (lt == null || lt.isEmpty || lt == "0.0") {
      final double? lat = prefs.getDouble('lat');
      if (lat != null) lt = lat.toString();
    }
    lt ??= '0.0';

    // Longitude
    String? ln = prefs.getString('ln');
    if (ln == null || ln.isEmpty || ln == "0.0") {
      final double? lng = prefs.getDouble('lng');
      if (lng != null) ln = lng.toString();
    }
    ln ??= '0.0';

    return {
      'cid': cid,
      'uid': uid,
      'token': token,
      'device_id': deviceId,
      'lt': lt,
      'ln': ln,
    };
  }
}
