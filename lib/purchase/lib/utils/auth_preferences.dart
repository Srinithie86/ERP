import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static Future<String?> getCusId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('cus_id');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

}