import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/size_utils.dart';
import '../technician_dashboard.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class OtpBottomSheet extends StatefulWidget {
  const OtpBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    required this.loginFuture,
  });

  final String phoneNumber;
  final String countryCode;
  final Future<Map<String, String>?> loginFuture;

  @override
  State<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<OtpBottomSheet> {
  late final TextEditingController _otpController;
  late final FocusNode _otpFocusNode;
  int _secondsLeft = 60;
  bool _isVerifying = false;
  Timer? _countdownTimer;
  bool _canResend = false;
  bool _hasVerificationError = false;
  String _errorMessage = '';
  bool _isOtpPreparing = true;
  String _token = '';
  String _cid = '';
  String _userName = '';
  String _userEmail = '';
  String _userMobile = '';

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _otpFocusNode = FocusNode();
    _otpController.addListener(() {
      if (!mounted) return;
      if (_hasVerificationError || _errorMessage.isNotEmpty) {
        setState(() {
          _hasVerificationError = false;
          _errorMessage = '';
        });
      } else {
        setState(() {});
      }
    });
    _startTimer();
    _loadLoginSession();
  }

  Future<void> _loadLoginSession() async {
    try {
      final result = await widget.loginFuture;
      if (!mounted) return;
      if (result != null) {
        final prefs = await SharedPreferences.getInstance();
        if (result.containsKey('cus_id')) {
          await prefs.setString('cus_id', result['cus_id'].toString());
          await prefs.setString('engineer_id', result['cus_id'].toString());
        }
        setState(() {
          _token = result['token'] ?? '';
          _cid = result['cid'] ?? '';
          _userName = result['name'] ?? '';
          _userEmail = result['email'] ?? '';
          _userMobile = result['mobile'] ?? '';
          _isOtpPreparing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isOtpPreparing = false;
        _hasVerificationError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft == 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _resendOtp() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
      _hasVerificationError = false;
      _errorMessage = '';
    });
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  Future<void> _verifyAndContinue() async {
    final enteredOtp = _otpController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (enteredOtp.length != 6 ||
        _isOtpPreparing ||
        _token.isEmpty ||
        _cid.isEmpty)
      return;

    setState(() => _isVerifying = true);

    var response = await ApiService.verifyOtp(
      mobile: widget.phoneNumber,
      otp: enteredOtp,
      lat: "12.1796",
      lon: "76.9284",
      cid: _cid,
      token: _token,
    );

    setState(() => _isVerifying = false);

    bool isSuccess =
        response != null &&
        (response["error"] == 0 || response["error"] == false);

    if (isSuccess) {
      if (response != null) {
        if (_userName.isNotEmpty) response['user_name'] ??= _userName;
        if (_userEmail.isNotEmpty) response['email'] ??= _userEmail;
        if (_userMobile.isNotEmpty) response['mobile'] ??= _userMobile;
      }
      
      await StorageService.saveUser(response ?? {});

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TechnicianDashboard()),
        (route) => false,
      );
    } else {
      setState(() {
        _hasVerificationError = true;
        _errorMessage = response?["error_msg"] ?? "Invalid OTP";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final digits = _otpController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final canVerify =
        digits.length == 6 &&
        !_isOtpPreparing &&
        _token.isNotEmpty &&
        _cid.isNotEmpty;
    final borderColor = _hasVerificationError
        ? Colors.red
        : AppColors.primary.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: () => _otpFocusNode.requestFocus(),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  28.h,
                  24.w,
                  bottomInset + 28.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0D5DD),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'Verify with OTP',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Image.asset(
                      'assets/otp.png',
                      height: 128.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 18.h),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Enter the 6 digit OTP sent to\n',
                          ),
                          TextSpan(
                            text: '${widget.countryCode} ${widget.phoneNumber}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final char = index < digits.length ? digits[index] : '';
                        return Container(
                          width: 45.w,
                          height: 50.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            char,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 10.h),
                    if (_errorMessage.isNotEmpty) ...[
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    SizedBox(
                      height: 1,
                      child: TextField(
                        controller: _otpController,
                        focusNode: _otpFocusNode,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          counterText: '',
                        ),
                        style: const TextStyle(
                          fontSize: 1,
                          color: Colors.transparent,
                        ),
                        cursorColor: Colors.transparent,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text('Wrong Number?'),
                        ),
                        _isOtpPreparing
                            ? Text(
                                'Sending OTP...',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : _canResend
                            ? TextButton(
                                onPressed: _resendOtp,
                                child: const Text('Resend OTP'),
                              )
                            : Text(
                                '00:${_secondsLeft.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: canVerify && !_isVerifying
                            ? _verifyAndContinue
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canVerify && !_isVerifying
                              ? AppColors.primary
                              : const Color(0xFFAFE0D8),
                          disabledBackgroundColor: const Color(0xFFAFE0D8),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: Size(double.infinity, 48.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Verify OTP',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
