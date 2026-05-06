import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/api_service.dart';
import '../../core/app_colors.dart';
import '../../core/size_utils.dart';
import 'otp_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  late final AnimationController _motionController;
  bool _isPhoneValid = false;
  String _countryCode = '+91';

  static const List<String> _countryCodes = ['+91', '+1', '+44', '+971'];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _motionController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.trim().length == 10;
    });
  }

  Future<void> _requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {}
  }

  Future<Position?> _getLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }

  Future<void> _handleLogin() async {
    final mobile = _phoneController.text.trim();
    _showOtpSheet(
      mobile: mobile,
      loginFuture: Future<Map<String, String>?>.microtask(
        () => _requestOtp(mobile),
      ),
    );
  }

  Future<Map<String, String>?> _requestOtp(String mobile) async {
    Position? position = await _getLocation();

    String lat = position?.latitude.toString() ?? "0";
    String lon = position?.longitude.toString() ?? "0";

    var response = await ApiService.login(mobile: mobile, lat: lat, lon: lon);

    print("LOGIN RESPONSE: $response");
    print("MOBILE: $mobile");
    print("LAT: $lat");
    print("LON: $lon");

    bool isSuccess =
        response != null &&
        (response["error"] == false || response["error"] == 0);

    if (isSuccess) {
      return {
        'token': response["token"].toString(),
        'cid': response["cid"].toString(),
        'cus_id': (response["cus_id"] ?? "").toString(),
        'engineer_id': (response["engineer_id"] ?? "").toString(),
        'name': (response["name"] ?? "").toString(),
        'email': (response["email"] ?? "").toString(),
        'mobile': (response["mobile"] ?? "").toString(),
      };
    }

    throw Exception(response?["error_msg"] ?? "Login failed");
  }

  void _showOtpSheet({
    required String mobile,
    required Future<Map<String, String>?> loginFuture,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OtpBottomSheet(
        phoneNumber: mobile,
        countryCode: _countryCode,
        loginFuture: loginFuture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _motionController,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_motionController.value);
              return Stack(
                children: [
                  Positioned(
                    top: -220.h + (t * 14.h),
                    right: -40.w,
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(
                        width: 340.w,
                        height: 340.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.5),
                              AppColors.primary,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -80.h + (t * 10.h),
                    left: -60.w,
                    child: Transform.rotate(
                      angle: -0.785,
                      child: Container(
                        width: 100.w,
                        height: 240.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.r),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.3),
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -320.h + (t * 18.h),
                    left: -100.w,
                    right: -100.w,
                    child: Center(
                      child: Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 380.w,
                          height: 380.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60.r),
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                AppColors.primary.withValues(alpha: 0.5),
                                AppColors.primary,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -120.h + (t * 12.h),
                    right: -80.w,
                    child: Transform.rotate(
                      angle: -0.785,
                      child: Container(
                        width: 100.w,
                        height: 240.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.r),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.3),
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24.w,
                    0,
                    24.w,
                    bottomInset + 24.h,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          AnimatedBuilder(
                            animation: _motionController,
                            builder: (context, child) {
                              final t = Curves.easeInOut.transform(
                                _motionController.value,
                              );
                              return Transform.translate(
                                offset: Offset(0, -8.h + (t * 16.h)),
                                child: child,
                              );
                            },
                            child: Center(
                              child: Image.asset(
                                'assets/login.png',
                                height: 240.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                          Text(
                            'Enter Your Mobile Number',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _countryCode,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18.sp,
                                      ),
                                      items: _countryCodes
                                          .map(
                                            (code) => DropdownMenuItem<String>(
                                              value: code,
                                              child: Text(
                                                code,
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() => _countryCode = value);
                                      },
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 24.h,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Your 10-Digit Mobile Number',
                                      hintStyle: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: _isPhoneValid ? _handleLogin : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPhoneValid
                                  ? AppColors.primary
                                  : const Color(0xFFC8D0E6),
                              disabledBackgroundColor: const Color(0xFFC8D0E6),
                              foregroundColor: Colors.white,
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: Size(double.infinity, 48.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                            ),
                            child: Text(
                              'Get OTP',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: EdgeInsets.only(bottom: 24.h, top: 32.h),
                            child: Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'By Continuing you agree to our\n',
                                    ),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        height: 1.5,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Navigate to terms
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
