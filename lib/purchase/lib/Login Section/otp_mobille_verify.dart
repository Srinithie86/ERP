import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:purchase_erp/core/api_config.dart';

class MobileverifyOTP extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onVerify;

  const MobileverifyOTP({
    super.key,
    required this.phoneNumber,
    required this.onVerify,
  });

  @override
  State<MobileverifyOTP> createState() => _MobileverifyOTPState();
}

class _MobileverifyOTPState extends State<MobileverifyOTP> {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  bool _isLoading = false;

  Future<void> _verifyOTP() async {
    if (_isLoading) { return; }
    FocusScope.of(context).unfocus();
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter complete 6-digit OTP")),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final fToken = prefs.getString('f_token') ?? '';
      final ln = prefs.getString('ln') ?? '145';
      final lt = prefs.getString('lt') ?? '123';
      final deviceId = prefs.getString('device_id') ?? '1';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "type": 5002,
          "ln": int.tryParse(ln) ?? 145,
          "lt": int.tryParse(lt) ?? 123,
          "device_id": int.tryParse(deviceId) ?? 1,
          "cid": int.tryParse(cid) ?? 44555666,
          "mobile": widget.phoneNumber,
          "otp": int.tryParse(otp) ?? 0,
          "token": fToken,
        }),
      ).timeout(const Duration(seconds: 15));

      debugPrint("OTP Verify Response: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error'] == "false") {
          // Store token and user_id in shared preferences
          await prefs.setString('token', data['token']?.toString() ?? '');
          await prefs.setString('user_id', data['user_id']?.toString() ?? '');
          await prefs.setString('uid', data['uid']?.toString() ?? '');
          await prefs.setString('led_id', data['led_id']?.toString() ?? '');
          await prefs.setBool('is_logged_in', true);
          await prefs.setString('verify_response', response.body);

          if (mounted) {
            debugPrint("Verification successful, triggering onVerify callback");
            widget.onVerify(); 
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? "OTP verification failed")),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final scale = width / 360;

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30 * scale),
          topRight: Radius.circular(30 * scale),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP ROW: BACK BUTTON & TITLE
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8 * scale),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 24 * scale,
                  ),
                ),
              ),
              SizedBox(width: 15 * scale),
              Text(
                "Verify with OTP",
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: 30 * scale),

          /// INSTRUCTION TEXT
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13 * scale,
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text: "Waiting to automatically detect an OTP sent to\n",
                ),
                TextSpan(text: "${widget.phoneNumber}. "),
                const TextSpan(
                  text: "Wrong Number?",
                  style: TextStyle(
                    color: Color(0xff2D228E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20 * scale),

          /// OTP INPUT BOXES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45 * scale,
                height: 50 * scale,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF26A69A),
                  ),
                  readOnly: _isLoading,
                  decoration: InputDecoration(
                    counterText: "",
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scale),
                      borderSide: const BorderSide(
                        color: Color(0xFF26A69A),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10 * scale),
                      borderSide: const BorderSide(
                        color: Color(0xFF26A69A),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    
                    // Auto-verify if 6th digit is entered
                    if (value.isNotEmpty && index == 5) {
                      _verifyOTP();
                    }
                  },
                ),
              );
            }),
          ),

          SizedBox(height: 15 * scale),

          /// RESEND OTP & TIMER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Resend OTP",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "00:57",
                style: TextStyle(
                  color: const Color(0xFF26A69A),
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 35 * scale),

          /// VERIFY BUTTON
          SizedBox(
            width: double.infinity,
            height: 55 * scale,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                disabledBackgroundColor: const Color(0xFF26A69A).withValues(alpha: 0.6),
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
                      "Verify",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 10 * scale),
        ],
      ),
    );
  }
}