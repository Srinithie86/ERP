import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String defaultBaseUrl = "https://erpsmart.in/total/api/m_api/";
  static const String _prefsKey = "company_domain_url";

  static String _cachedBaseUrl = defaultBaseUrl;

  static Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != defaultBaseUrl) return _cachedBaseUrl;
    final prefs = await SharedPreferences.getInstance();
    _cachedBaseUrl = _normalize(prefs.getString(_prefsKey));
    return _cachedBaseUrl;
  }

  static String _normalize(String? value) {
    final raw = (value ?? "").trim();
    if (raw.isEmpty) return defaultBaseUrl;
    final withScheme = raw.startsWith("http://") || raw.startsWith("https://")
        ? raw
        : "https://$raw";
    return withScheme.endsWith("/") ? withScheme : "$withScheme/";
  }
}
