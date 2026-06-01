import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:erp_smart/theme/Service /lib/core/size_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../home/home.dart';
import 'login_types.dart';
import '../../Models/erp_login_api.dart';
import '../../providers/menu_provider.dart';
import '../../utils/device_service.dart';
import '../../utils/api_config.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with CodeAutoFill {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();
  
  // OTP Related
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  int _timerSeconds = 57;
  Timer? _timer;

  bool _isMobileLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showWorkspaceStep = true;
  bool _showOtpView = false;
  bool _isOtpProcessed = false; // STRICT: Prevents double verification
  String? _errorText;
  String? _appSignature;
  
  // Stored login data for OTP verification
  String _currentContact = "";
  LoginType _currentLoginType = LoginType.sms;
  String _currentCid = "";
  String _currentToken = "";

  static const String defaultUrl = ApiConfig.defaultBaseUrl;

  @override
  void initState() {
    super.initState();
    _loadSavedDomain();
    _initDevice();
    _getAppSignature();
    
    _usernameController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _mobileController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _domainController.dispose();
    for (var c in _otpControllers) c.dispose();
    for (var n in _otpFocusNodes) n.dispose();
    super.dispose();
  }

  @override
  void codeUpdated() {
    final autoCode = code;
    // STRICT: Only process if valid, exactly 6 digits, and not already processed
    if (autoCode != null && autoCode.length >= 6 && !_isOtpProcessed && _showOtpView) {
      final match = RegExp(r'\d{6}').firstMatch(autoCode);
      if (match == null) return;

      final otp = match.group(0)!;
      for (int i = 0; i < 6; i++) {
        _otpControllers[i].text = otp[i];
      }

      debugPrint("📩 Code received via Autofill: $otp");
      setState(() => _isOtpProcessed = true);
      
      // Call verify with a small delay to ensure UI updates
      Future.delayed(const Duration(milliseconds: 300), () => _verifyOtp());
    }
  }

  Future<void> _initDevice() async {
    await DeviceService.initDeviceInfo();
  }

  Future<void> _getAppSignature() async {
    try {
      final sig = await SmsAutoFill().getAppSignature;
      setState(() => _appSignature = sig);
      debugPrint("App Signature for SMS: $sig");
    } catch (e) {
      debugPrint("Unable to get app signature: $e");
    }
  }

  Future<void> _loadSavedDomain() async {
    final saved = await ApiConfig.getBaseUrl();
    if (saved.isNotEmpty) {
      _domainController.text = saved;
      setState(() => _showWorkspaceStep = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 57;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
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

  Future<bool> _ensureLocationBeforeLogin() async {
    // STRICT: Check service and permission first
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      await DeviceService.ensureLocationPermission(context);
    }

    // Refresh status after dialogs
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
       // Still not ready, return false to stop login
       return false;
    }

    // Capture fresh coordinates
    await DeviceService.initDeviceInfo();

    if (DeviceService.isInitialized) return true;
    if (!mounted) return false;

    final shouldRetry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
          actionsPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: const Color(0xFF00897B), size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Turn on Location",
                  style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            "To continue login, please enable GPS and allow location permission. "
            "After enabling, tap \"I Enabled, Continue\".",
            style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black87, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text("Cancel", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () async {
                await Geolocator.openLocationSettings();
                await Geolocator.openAppSettings();
              },
              child: Text("Enable Location", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text("I Enabled, Continue", style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (shouldRetry == true) {
      await DeviceService.ensureLocationPermission(context);
      await DeviceService.initDeviceInfo();
      return DeviceService.isInitialized;
    }

    return false;
  }

  void _validateAndSubmit() async {
      final locationReady = await _ensureLocationBeforeLogin();
      if (!locationReady) {
        setState(() {
          _errorText = "Please enable location services to continue login.";
        });
        return;
      }

      if (_isMobileLogin) {
        String mobile = _mobileController.text.trim();
        if (mobile.startsWith('+91')) {
          mobile = mobile.replaceFirst('+91', '');
        }
        mobile = mobile.replaceAll(RegExp(r'\D'), '');
        if (mobile.length > 10) {
          mobile = mobile.substring(mobile.length - 10);
        }
        if (mobile.length < 10) {
          setState(() => _errorText = "Enter valid mobile number");
          return;
        }
        await _handleMobileLogin(mobile);
      } else {
        final username = _usernameController.text.trim();
        final password = _passwordController.text.trim();
        if (username.isEmpty || password.isEmpty) {
          setState(() => _errorText = "Enter User ID and Password");
          return;
        }
        await _handlePasswordLogin(username, password);
      }
  }

  Future<void> _handlePasswordLogin(String username, String password) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await ErpLoginApi.loginWithUserPass(
        userId: username,
        password: password,
        deviceId: DeviceService.deviceId,
        lat: DeviceService.latitude,
        lng: DeviceService.longitude,
        cid: prefs.getString('cid') ?? "44555666",
      );

      if (response['error'] == false) {
        final token = response['token']?.toString() ?? "";
        final cid = response['cid']?.toString() ?? "44555666";
        final otp = response['otp']?.toString() ?? "";
        if (otp.isNotEmpty) {
          final verifyContact = (response['mobile']?.toString() ?? '').trim();
          setState(() {
            _currentContact = verifyContact.isNotEmpty ? verifyContact : username;
            _currentLoginType = LoginType.password;
            _currentCid = cid;
            _currentToken = token;
            _showOtpView = true;
            _lastVerifiedOtp = null;
          });
          
          cancel();
          listenForCode(smsCodeRegexPattern: r'\d{6}');
          _startTimer();
        } else {
          _finalizeLogin(response);
        }
      } else {
        final message = response['error_msg']?.toString() ?? 'Login failed';
        setState(() => _errorText = message);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      final message = 'Connection error: $e';
      setState(() => _errorText = message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleMobileLogin(String mobile) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final response = await ErpLoginApi.sendOtp(
        mobile: mobile,
        cid: prefs.getString('cid') ?? "44555666",
        deviceId: DeviceService.deviceId,
        lat: DeviceService.latitude,
        lng: DeviceService.longitude,
        appSignature: _appSignature ?? '',
      );

      if (response['error'] == false) {
        final token = response['token']?.toString() ?? "";
        final cid = response['cid']?.toString() ?? "44555666";
        final otp = response['otp']?.toString() ?? "";
        
        setState(() {
          _currentContact = mobile;
          _currentLoginType = LoginType.sms;
          _currentCid = cid;
          _currentToken = token;
          _showOtpView = true;
          _isOtpProcessed = false; // Reset for new OTP
          _lastVerifiedOtp = null;
        });

        cancel();
        listenForCode(smsCodeRegexPattern: r'\d{6}');
        _startTimer();
      } else {
        final message = response['error_msg']?.toString() ?? 'Request failed';
        setState(() => _errorText = message);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      final message = 'Authentication failed: $e';
      setState(() => _errorText = message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _lastVerifiedOtp;
  String get _enteredOtp => _otpControllers.map((c) => c.text).join();

  void _clearOtp() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _lastVerifiedOtp = null;
    if (_otpFocusNodes.isNotEmpty) {
      _otpFocusNodes.first.requestFocus();
    }
  }

  Future<void> _pasteOtpFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (text.length < 6) return;
    final code = text.substring(0, 6);
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].text = code[i];
    }
    _otpFocusNodes.last.unfocus();
    _verifyOtp();
  }

  Future<void> _verifyOtp() async {
    final enteredOtp = _enteredOtp;
    if (enteredOtp.length < 6) return;
    if (_isLoading || _lastVerifiedOtp == enteredOtp) return;
    
    _lastVerifiedOtp = enteredOtp;
    setState(() => _isLoading = true);
    try {
      final response = await ErpLoginApi.verifyOtp(
        mobile: _currentContact,
        otp: enteredOtp,
        cid: _currentCid,
        token: _currentToken,
        deviceId: DeviceService.deviceId,
        lat: DeviceService.latitude,
        lng: DeviceService.longitude,
      );
      debugPrint("OTP Verify API Response: $response");

      if (response['error'] == false) {
        _finalizeLogin(response);
      } else {
        _lastVerifiedOtp = null; // Allow retry on error
        final message = response['error_msg']?.toString() ?? 'Invalid OTP';
        setState(() => _errorText = message);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      _lastVerifiedOtp = null; // Allow retry after transient/network failures
      const message = 'Verification failed';
      setState(() => _errorText = message);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _isOtpProcessed = false; 
    }
  }

  Future<void> _resendOtp() async {
    if (_timerSeconds > 0 || _isLoading) return;
    _validateAndSubmit();
  }

  Future<void> _finalizeLogin(Map<String, dynamic> response) async {
    debugPrint("DEBUG LOGIN RESPONSE: $response");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('login_response', jsonEncode(response));
    final uid = response['uid']?.toString() ?? response['cus_id']?.toString() ?? '';
    final cid = response['cid']?.toString() ?? '44555666';
    final roleId = response['role_id']?.toString() ?? '1';
    await prefs.setString('uid', uid);
    await prefs.setString('cid', cid);
    await prefs.setString('role_id', roleId);
    
    final rawName = response['name']?.toString() ?? '';
    if (rawName.isNotEmpty && rawName != response['cus_id']?.toString()) {
      await prefs.setString('name', rawName);
    } else {
       await prefs.setString('name', ''); // Force repair later if it's just the ID
    }
    final ledId = response['led_id']?.toString() ?? response['user_id']?.toString() ?? '';
    await prefs.setString('led_id', ledId);
    
    // STRICT: Save token for all modules to use
    final String token = response['token']?.toString() ?? response['Token']?.toString() ?? _currentToken;
    if (token.isNotEmpty) {
      await prefs.setString('token', token);
      debugPrint("MainRoot => Token Persisted: $token");
    }
    
    await prefs.setString('login_cus_id', uid); // For HRM module compatibility
    if (response['menu'] != null) if (mounted) context.read<MenuProvider>().setMenu(response['menu']);
    debugPrint("Finalizing login, navigating to HomeScreen...");
    cancel();
    TextInput.finishAutofillContext();
    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top),
            child: _showWorkspaceStep ? _buildWorkspaceStep() : _buildLoginStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceStep() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset("assets/images/logo.png", height: 80.h, errorBuilder: (_, __, ___) => Icon(Icons.business, size: 80.sp, color: const Color(0xFF00695C)))),
            SizedBox(height: 12.h),
            Center(child: Text("GLOBAL ERP", style: GoogleFonts.outfit(fontSize: 24.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00695C), letterSpacing: 1))),
            SizedBox(height: 24.h),
            Text("Connect to workspace", style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black)),
            Text("Enter your company's ERP domain to get started", style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black54)),
            SizedBox(height: 16.h),
            Text("Workspace URL", style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 8.h),
            TextField(
              controller: _domainController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(height: 6.h),
            Text("Example: $defaultUrl", style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.black26)),
            SizedBox(height: 16.h),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _showWorkspaceStep = false),
                child: Text("Skip Now", style: GoogleFonts.outfit(fontSize: 16.sp, color: const Color(0xFF00897B), decoration: TextDecoration.underline)),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () async {
                  final url = _domainController.text.trim().isEmpty ? defaultUrl : _domainController.text.trim();
                  await ApiConfig.saveBaseUrl(url);
                  setState(() => _showWorkspaceStep = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                child: Text("Continue", style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginStep() {
    return IntrinsicHeight(
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Center(
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
              child: Image.asset("assets/images/logo.png", height: 70.h, errorBuilder: (_, __, ___) => Icon(Icons.business, size: 60.sp, color: const Color(0xFF00695C))),
            ),
          ),
          SizedBox(height: 12.h),
          Text("GLOBAL ERP", style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00695C), letterSpacing: 1.2)),
          SizedBox(height: 32.h),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            padding: EdgeInsets.fromLTRB(28.w, 32.h, 28.w, 32.h),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showOtpView ? _buildOtpPortion() : _buildFormPortion(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPortion() {
    return AutofillGroup(
      child: Column(
        key: const ValueKey("LoginForm"),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(27.r), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(
              children: [
                _buildToggle("Via Password", !_isMobileLogin, () => setState(() { _isMobileLogin = false; _errorText = null; })),
                _buildToggle("Via OTP", _isMobileLogin, () => setState(() { _isMobileLogin = true; _errorText = null; })),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text("Log in the best experience", style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 8.h),
          Text(_isMobileLogin ? "Enter your mobile number to continue" : "Enter your user id and password to continue", style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black54)),
          SizedBox(height: 16.h),
          if (_isMobileLogin)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField("Phone Number", _mobileController, isPhone: true),
              ],
            )
          else ...[
            _buildField("User ID", _usernameController, autofillHints: [AutofillHints.username]),
            SizedBox(height: 16.h),
            _buildField("Password", _passwordController, isPassword: true, autofillHints: [AutofillHints.password]),
          ],
        SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _validateAndSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF047466),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: _isLoading ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Continue", style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  Widget _buildOtpPortion() {
    return Column(
      key: const ValueKey("OtpForm"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() { _showOtpView = false; _errorText = null; }),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
            Text("Verify Account", style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        SizedBox(height: 16.h),
        Text("Enter the 6-digit code sent to", style: GoogleFonts.outfit(fontSize: 14.sp, color: Colors.black54)),
        Text(_currentContact, style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF00897B))),
        SizedBox(height: 24.h),
        Row(
          children: [
            Text("OTP", style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            const Spacer(),
            TextButton(
              onPressed: _pasteOtpFromClipboard,
              child: Text("Paste Code", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, _buildOtpField),
        ),
        if (_errorText != null) Padding(padding: EdgeInsets.only(top: 16.h), child: Text(_errorText!, style: GoogleFonts.outfit(color: Colors.red, fontSize: 13.sp))),
        SizedBox(height: 14.h),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _clearOtp,
            child: Text("Clear", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_timerSeconds > 0 ? "Resend in $_formattedTimer" : "Didn't receive code?", style: GoogleFonts.outfit(color: Colors.grey.shade500, fontSize: 13.sp)),
            TextButton(
              onPressed: _timerSeconds == 0 ? _resendOtp : null,
              child: Text('Resend OTP', style: GoogleFonts.outfit(color: _timerSeconds == 0 ? const Color(0xFF00897B) : Colors.grey.shade400, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SizedBox(height: 40.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF047466),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: _isLoading ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Verify Account", style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: 60.h),
      ],
    );
  }

  Widget _buildToggle(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(color: active ? const Color(0xFF26A69A) : Colors.transparent, borderRadius: BorderRadius.circular(23.r)),
          alignment: Alignment.center,
          child: Text(label, style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.bold, color: active ? Colors.white : const Color(0xFF26A69A))),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isPassword = false, bool isPhone = false, Iterable<String>? autofillHints}) {
    if (isPhone) {
      return TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        autofillHints: autofillHints ?? const [AutofillHints.telephoneNumber],
        style: GoogleFonts.outfit(fontSize: 16.sp),
        decoration: InputDecoration(
          labelText: label,
          prefixText: '+91 ',
          prefixStyle: GoogleFonts.outfit(fontSize: 16.sp, color: Colors.black87),
          labelStyle: GoogleFonts.outfit(color: Colors.black87),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF047466))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF047466))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF047466), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    }
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      autofillHints: autofillHints,
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.text,
      style: GoogleFonts.outfit(fontSize: 16.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF047466))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF047466))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF047466), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.grey), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45.w,
      height: 52.h,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 1,
        style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5)),
        ),
        onChanged: (v) {
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
          _lastVerifiedOtp = null; // User changed OTP, allow fresh verification
          if (v.length > 1) {
            final clean = v.replaceAll(RegExp(r'\D'), '');
            if (clean.length >= 6) {
              for (int i = 0; i < 6; i++) {
                _otpControllers[i].text = clean[i];
              }
              _verifyOtp();
              return;
            }
            _otpControllers[index].text = clean.isEmpty ? '' : clean.substring(clean.length - 1);
            _otpControllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _otpControllers[index].text.length),
            );
          }
          if (_otpControllers[index].text.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          }
          if (_otpControllers[index].text.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
          if (_otpControllers.every((c) => c.text.isNotEmpty)) {
            _otpFocusNodes.last.unfocus();
            _verifyOtp();
          }
        },
      ),
    );
  }
}
