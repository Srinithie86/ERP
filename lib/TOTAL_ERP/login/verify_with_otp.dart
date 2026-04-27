import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'login_types.dart';
import '../home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Models/erp_login_api.dart';
import '../../providers/menu_provider.dart';
import '../../utils/device_service.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyWithOtp extends StatefulWidget {
  final String contactInfo;
  final LoginType type;
  final String? otp;
  final String? cid;
  final String? token;
  final VoidCallback? onVerified;

  const VerifyWithOtp({
    super.key,
    required this.contactInfo,
    required this.type,
    this.otp,
    this.cid,
    this.token,
    this.onVerified,
  });

  @override
  State<VerifyWithOtp> createState() => _VerifyWithOtpState();
}

class _VerifyWithOtpState extends State<VerifyWithOtp> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _timerSeconds = 57;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // listenForCode(); // Removed to prevent unwanted autofill as per user request
  }


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) { setState(() => _timerSeconds--); }
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _formattedTimer {
    final minutes = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_timerSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _resendOtp() async {
    if (_timerSeconds > 0 || _isLoading) { return; }
    setState(() => _isLoading = true);
    try {
      final response = await ErpLoginApi.sendOtp(
        mobile: widget.contactInfo,
        cid: widget.cid ?? "44555666",
        deviceId: DeviceService.deviceId,
        lat: DeviceService.latitude,
        lng: DeviceService.longitude,
        appSignature: await SmsAutoFill().getAppSignature,
      );

      if (response['error'] == false) {
        setState(() => _timerSeconds = 57);
        _startTimer();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Resent Successfully'), backgroundColor: Colors.green));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['error_msg'] ?? 'Resend failed'), backgroundColor: Colors.redAccent));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error, please try again'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) { setState(() => _isLoading = false); }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // cancel(); // Removed as CodeAutoFill is disabled
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF26A69A);
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 3, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 18),
          Text('Verify Account', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: const Color(0xFF00695C))),
          const SizedBox(height: 12),
          Text("Enter OTP sent to +91 ${widget.contactInfo}", textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(6, (i) => _buildOtpField(i))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_timerSeconds > 0 ? "Resend in $_formattedTimer" : "Didn't receive code?", style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 13)),
              TextButton(onPressed: _timerSeconds == 0 ? _resendOtp : null, child: Text('Resend OTP', style: GoogleFonts.outfit(color: _timerSeconds == 0 ? tealColor : Colors.grey.shade400, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: tealColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = _controllers.map((c) => c.text).join();
    if (enteredOtp.length < 6) return;
    setState(() => _isLoading = true);
    try {
      final response = await ErpLoginApi.verifyOtp(
        mobile: widget.contactInfo,
        otp: enteredOtp,
        cid: widget.cid ?? "44555666",
        token: widget.token ?? "",
        deviceId: DeviceService.deviceId,
        lat: DeviceService.latitude,
        lng: DeviceService.longitude,
      );

      if (response['error'] == false) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('token', response['token']?.toString() ?? widget.token ?? "");
        await prefs.setString('login_response', jsonEncode(response));

        final uid = response['uid']?.toString() ?? response['cus_id']?.toString() ?? '';
        final cid = response['cid']?.toString() ?? widget.cid ?? '44555666';
        final roleId = response['role_id']?.toString() ?? '1';

        await prefs.setString('uid', uid);
        await prefs.setString('cid', cid);
        await prefs.setString('role_id', roleId);
        await prefs.setString('name', response['data']?['name']?.toString() ?? '');

        if (response['menu'] != null) {
          if (mounted) context.read<MenuProvider>().setMenu(response['menu']);
        }
        
        if (mounted) {
          if (widget.onVerified != null) {
            Navigator.pop(context);
            widget.onVerified?.call();
          } else {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
          }
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['error_msg'] ?? 'Invalid OTP')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification failed')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 45, height: 50,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: _controllers[index], focusNode: _focusNodes[index],
        textAlign: TextAlign.center, keyboardType: TextInputType.number,
        maxLength: 1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(counterText: '', border: InputBorder.none),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
          if (v.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
        },
      ),
    );
  }
}
