import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home.dart';
import 'login_types.dart';
import '../../Models/erp_login_api.dart';
import '../../providers/menu_provider.dart';
import '../../utils/device_service.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

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
  String? _errorText;
  String? _appSignature;
  
  // Stored login data for OTP verification
  String _currentContact = "";
  LoginType _currentLoginType = LoginType.sms;
  String _currentCid = "";
  String _currentToken = "";

  static const String defaultUrl = "https://erpsmart.in/total/api/m_api/";

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
    // We let PinFieldAutoFill handle the UI update and verification
    // via its own internal listener when it detects the code.
    debugPrint("Code received via Autofill: $code");
  }

  Future<void> _pickPhoneNumber() async {
    try {
      final String? phone = await SmsAutoFill().hint;
      if (phone != null && phone.isNotEmpty) {
        // Extract 10 digits if needed
        String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
        if (cleanPhone.length > 10) {
          cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
        }
        setState(() {
          _mobileController.text = cleanPhone;
        });
      }
    } catch (e) {
      debugPrint("Phone hint error: $e");
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
    } catch (_) {}
  }

  Future<void> _loadSavedDomain() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('company_domain_url') ?? '';
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

  void _validateAndSubmit() async {
      // Force fresh device/location info before login
      await DeviceService.initDeviceInfo();
      
      if (!DeviceService.isInitialized) {
        setState(() => _errorText = "Location and Device Info required. Please enable GPS.");
        return;
      }
      
      if (_isMobileLogin) {
        final mobile = _mobileController.text.trim();
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
          setState(() {
            _currentContact = username;
            _currentLoginType = LoginType.password;
            _currentCid = cid;
            _currentToken = token;
            _showOtpView = true;
            _lastVerifiedOtp = null;
          });
          
          listenForCode();
          
          // Autofill OTP if provided in response
          if (otp.length == 6) {
            for (int i = 0; i < 6; i++) {
              _otpControllers[i].text = otp[i];
            }
            Future.delayed(const Duration(milliseconds: 500), () => _verifyOtp());
          }
          
          _startTimer();
        } else {
          _finalizeLogin(response);
        }
      } else {
        setState(() => _errorText = response['error_msg'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _errorText = 'Connection error: $e');
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
        appSignature: _appSignature,
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
          _lastVerifiedOtp = null;
        });

        listenForCode();

        // Autofill OTP if provided in response
        if (otp.length == 6) {
          for (int i = 0; i < 6; i++) {
            _otpControllers[i].text = otp[i];
          }
          Future.delayed(const Duration(milliseconds: 500), () => _verifyOtp());
        }
        _startTimer();
      } else {
        setState(() => _errorText = response['error_msg'] ?? 'Request failed');
      }
    } catch (e) {
      setState(() => _errorText = 'Authentication failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _lastVerifiedOtp;
  Future<void> _verifyOtp() async {
    final enteredOtp = _otpControllers.map((c) => c.text).join();
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
        setState(() => _errorText = response['error_msg'] ?? 'Invalid OTP');
      }
    } catch (e) {
      setState(() => _errorText = 'Verification failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_timerSeconds > 0 || _isLoading) return;
    _validateAndSubmit();
  }

  Future<void> _finalizeLogin(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('login_response', jsonEncode(response));
    final uid = response['uid']?.toString() ?? response['cus_id']?.toString() ?? '';
    final cid = response['cid']?.toString() ?? '44555666';
    final roleId = response['role_id']?.toString() ?? '1';
    await prefs.setString('uid', uid);
    await prefs.setString('cid', cid);
    await prefs.setString('role_id', roleId);
    await prefs.setString('login_cus_id', uid); // For HRM module compatibility
    if (response['menu'] != null) if (mounted) context.read<MenuProvider>().setMenu(response['menu']);
    debugPrint("Finalizing login, navigating to HomeScreen...");
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
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('company_domain_url', url);
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
            GestureDetector(
              onTap: _pickPhoneNumber,
              child: AbsorbPointer(
                absorbing: false,
                child: _buildField("Phone Number", _mobileController, isPhone: true, autofillHints: [AutofillHints.telephoneNumber]),
              ),
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
        SizedBox(height: 60.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PinFieldAutoFill(
                currentCode: _otpControllers.map((c) => c.text).join(),
                decoration: BoxLooseDecoration(
                  radius: Radius.circular(10.r),
                  strokeColorBuilder: FixedColorBuilder(const Color(0xFF26A69A).withOpacity(0.3)),
                  bgColorBuilder: FixedColorBuilder(Colors.white),
                  textStyle: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                onCodeChanged: (code) {
                  if (code != null && code.length == 6) {
                    for (int i = 0; i < 6; i++) {
                      _otpControllers[i].text = code[i];
                    }
                    // Wrap in post frame callback to avoid "setState during build" error
                    WidgetsBinding.instance.addPostFrameCallback((_) => _verifyOtp());
                  }
                },
                codeLength: 6,
              ),
            ),
          ],
        ),
        if (_errorText != null) Padding(padding: EdgeInsets.only(top: 16.h), child: Text(_errorText!, style: GoogleFonts.outfit(color: Colors.red, fontSize: 13.sp))),
        SizedBox(height: 40.h),
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
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      autofillHints: autofillHints,
      keyboardType: isPhone ? TextInputType.number : (isPassword ? TextInputType.visiblePassword : TextInputType.text),
      inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)] : null,
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
        style: GoogleFonts.outfit(fontSize: 22.sp, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF00897B), width: 1.5)),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) _otpFocusNodes[index + 1].requestFocus();
          if (v.isEmpty && index > 0) _otpFocusNodes[index - 1].requestFocus();
          if (_otpControllers.every((c) => c.text.isNotEmpty)) _verifyOtp();
        },
      ),
    );
  }
}
