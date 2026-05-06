import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/Login%20Section/Sign-up.dart';
import 'package:purchase_erp/Login%20Section/Sign-In.dart';
import 'package:purchase_erp/Login%20Section/Sign-in-whatsapp.dart';
import 'package:purchase_erp/utils/device_services.dart';
import '../dashboard.dart';
import 'otp_mobille_verify.dart';
import 'package:purchase_erp/core/api_config.dart';

class MailLoginScreen extends StatefulWidget {
  const MailLoginScreen({super.key});

  @override
  State<MailLoginScreen> createState() => _MailLoginScreenState();
}

class _MailLoginScreenState extends State<MailLoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginWithMail() async {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please enter mail id")));
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Dynamically get and store device ID, Latitude, and Longitude
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      debugPrint("🔍 DEVICE INFO FETCHED (Mail)");
      debugPrint("   Device ID  : $deviceId");
      debugPrint("   Latitude   : $lt");
      debugPrint("   Longitude  : $ln");

      // Validate Location
      if (lt == "0.0" || ln == "0.0") {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          DeviceServices.showLocationRequiredPopup(
            context,
            onRetry: () {
              // User can retry by clicking Next again
            },
          );
        }
        return;
      }

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "5001",
          "ln": ln,
          "lt": lt,
          "device_id": deviceId,
          "mobile": mobile,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          // Store in shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cid', data['cid']?.toString() ?? '');
          await prefs.setString('id', data['id']?.toString() ?? '');
          await prefs.setString('cus_id', data['cus_id']?.toString() ?? '');
          await prefs.setString('led_id', data['led_id']?.toString() ?? '');
          await prefs.setString('uid', data['uid']?.toString() ?? '');
          await prefs.setString('f_token', data['f_token']?.toString() ?? '');
          await prefs.setString('name', data['name']?.toString() ?? '');
          await prefs.setString('user_data', response.body);

          if (mounted) {
            _showOTPBottomSheet(mobile);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['error_msg'] ?? "Login failed")),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Server error. Please try again.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOTPBottomSheet(String mobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MobileverifyOTP(
          phoneNumber: mobile,
          onVerify: () {
            debugPrint("Mail: onVerify callback triggered");
            Navigator.pop(context); // Close bottom sheet
            debugPrint("Mail: Bottom sheet popped, pushing Dashboard");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Media Query for responsiveness
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Scale factor based on standard width
    final scale = width / 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          children: [
            SizedBox(height: height * 0.15),

            /// LOGO
            Image.asset(
              'assets/logo.png',
              width: width * 0.55,
              fit: BoxFit.contain,
            ),

            SizedBox(height: height * 0.08),

            /// SIGN IN TITLE & SUBTITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sign in",
                style: TextStyle(
                  fontSize: 24 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Manage your customers, sales & business anywhere.",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 13 * scale,
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: 40 * scale),

            /// MOBILE NUMBER INPUT
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: "Enter Your Mail Id",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14 * scale,
                ),
                contentPadding: const EdgeInsets.only(bottom: 8),
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF26A69A), width: 2),
                ),
              ),
            ),

            SizedBox(height: 35 * scale),

            /// NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: height * 0.065,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loginWithMail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff26A69A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  disabledBackgroundColor: const Color(
                    0xff26A69A,
                  ).withValues(alpha: 0.6),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 40 * scale),

            /// OR CONTINUE WITH
            Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.grey.shade300, thickness: 1),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                  child: Text(
                    "or continue with",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13 * scale,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.grey.shade300, thickness: 1),
                ),
              ],
            ),

            SizedBox(height: 30 * scale),

            /// SOCIAL LOGIN BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WhatsappLoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      side: const BorderSide(color: Color(0xff66BB6A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_calling_3,
                          color: Color(0xff66BB6A),
                          size: 18,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          "Whatsapp",
                          style: TextStyle(
                            color: const Color(0xff66BB6A),
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 15 * scale),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MobileLoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      side: const BorderSide(color: Color(0xFF26A69A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.message,
                          color: Color(0xFF26A69A),
                          size: 18,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          "Via SMS",
                          style: TextStyle(
                            color: const Color(0xFF26A69A),
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 60 * scale),

            /// FOOTER - SIGN UP
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: "Don't Have An Account? "),
                  TextSpan(
                    text: "Sign Up",
                    style: const TextStyle(color: Color(0xff2D228E)),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),

            SizedBox(height: 50 * scale),

            /// FOOTER - TERMS
            Column(
              children: [
                Text(
                  "By Continuing you agree to our",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  "Terms and Conditions",
                  style: TextStyle(
                    color: const Color(0xff26A69A),
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30 * scale),
          ],
        ),
      ),
    );
  }
}