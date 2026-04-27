// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';

// class BiometricService {
//   static final LocalAuthentication _auth = LocalAuthentication();
//   static const String _biometricKey = 'biometric_enabled';

//   static Future<bool> isBiometricAvailable() async {
//     try {
//       final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
//       final bool canAuthenticate =
//           canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
//       debugPrint(
//         'Biometric Availability: canCheckBiometrics=$canAuthenticateWithBiometrics, isDeviceSupported=${await _auth.isDeviceSupported()}',
//       );
//       return canAuthenticate;
//     } on PlatformException catch (e) {
//       debugPrint('Biometric Availability Error: $e');
//       return false;
//     }
//   }

//   static Future<bool> isEnabled() async {
//     final prefs = await SharedPreferences.getInstance();
//     final bool enabled =
//         prefs.getBool(_biometricKey) ?? true; // Changed default to true
//     debugPrint('Biometric Enabled in prefs: $enabled');
//     return enabled;
//   }

//   static Future<void> setEnabled(bool enabled) async {
//     final prefs = await SharedPreferences.getInstance();
//     debugPrint('Setting Biometric Enabled in prefs: $enabled');
//     await prefs.setBool(_biometricKey, enabled);
//   }

//   static Future<bool> authenticate() async {
//     try {
//       debugPrint('Starting Biometric Authentication... biometricOnly=false');
//       final bool didAuthenticate = await _auth.authenticate(
//         localizedReason: 'Please authenticate to access the app',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly:
//               false, // Allows PIN/Pattern if biometrics fail or not available
//         ),
//       );
//       debugPrint('Authentication Result: $didAuthenticate');
//       return didAuthenticate;
//     } on PlatformException catch (e) {
//       debugPrint('Authentication Error: $e');
//       return false;
//     }
//   }
// }
