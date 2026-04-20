import 'dart:async';
import 'package:crm/Screens/Home/dashboard_screen.dart';
import 'package:crm/Screens/SignIn/signup.dart';
import 'package:crm/Screens/SignIn/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:crm/Services/preference_service.dart';
import 'package:crm/Models/login_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LoginMethod { mobile, whatsapp, mail, sms }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  LoginMethod _selectedMethod = LoginMethod.mobile;
  bool _isLoading = false;

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your details')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String inputValue = _inputController.text.trim();
      final responseData = await LoginApi.signIn(mobile: inputValue);
      final prefs = await SharedPreferences.getInstance();

      await PreferenceService.setToken(
        responseData['token']?.toString() ?? 'local-login-token',
      );
      await PreferenceService.setLedId(
        responseData['led_id']?.toString() ?? 'local-led-id',
      );
      await PreferenceService.setCusId(
        responseData['cus_id']?.toString() ?? 'local-cus-id',
      );
      await PreferenceService.setCid(
        responseData['cid']?.toString() ?? '21472147',
      );

      if (_selectedMethod == LoginMethod.mail) {
        await PreferenceService.setEmail(inputValue);
        await PreferenceService.setUname(inputValue);
      } else {
        await PreferenceService.setMobile(inputValue);
      }

      await PreferenceService.setName(
        responseData['name']?.toString() ?? 'CRM User',
      );
      await prefs.setString(
        'com_name',
        responseData['comp_name']?.toString() ?? 'CRM',
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Sign in error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOTPDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OTPBottomSheet(
        inputValue: _inputController.text,
        isEmail: _selectedMethod == LoginMethod.mail,
        onWrongInput: () {
          Navigator.pop(context);
          _inputFocusNode.requestFocus();
        },
      ),
    );
  }

  String _getHintText() {
    switch (_selectedMethod) {
      case LoginMethod.mobile:
        return 'Enter Mobile Number';
      case LoginMethod.whatsapp:
        return 'Enter Whatsapp Number';
      case LoginMethod.mail:
        return 'Enter User Mail';
      case LoginMethod.sms:
        return 'Enter Mobile Number';
    }
  }

  TextInputType _getKeyboardType() {
    if (_selectedMethod == LoginMethod.mail) {
      return TextInputType.emailAddress;
    }
    return TextInputType.phone;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.06,
                vertical: screenHeight * 0.02,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (screenHeight * 0.04),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.15),
                      Image.asset(
                        'assets/images/smart.png',
                        width: screenWidth * 0.7,
                      ),
                      const SizedBox(height: 7),
                      // Image.asset(
                      //   'assets/images/TOTAL ERP.png',
                      //   width: screenWidth * 0.45,
                      // ),
                      SizedBox(height: screenHeight * 0.06),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: screenWidth * 0.045,
                                fontWeight: FontWeight.w600,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.color ??
                                    Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your customers, sales & business anywhere.',
                              style: TextStyle(
                                fontSize: screenWidth * 0.032,
                                color:
                                    (Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color ??
                                            Colors.black)
                                        .withAlpha(178),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.045),
                      TextField(
                        controller: _inputController,
                        focusNode: _inputFocusNode,
                        keyboardType: _getKeyboardType(),
                        inputFormatters: _selectedMethod == LoginMethod.mail
                            ? null
                            : [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                        decoration: InputDecoration(
                          hintText: _getHintText(),
                          hintStyle: TextStyle(color: Color(0xffA2A2A2)),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xffA2A2A2)),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF26A69A)),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.045),
                      SizedBox(
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.065,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF26A69A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or continue with',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color ??
                                    Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Row(children: _buildMethodButtons()),
                      SizedBox(height: screenHeight * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t Have An Account? ",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: screenWidth * 0.035,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: const Color(0xFF000080),
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.035,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Text(
                              'By Continuing you agree to our',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.color ??
                                    Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Text(
                              'Terms and Conditions',
                              style: TextStyle(
                                color: Color(0xFF26A69A),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
    );
  }

  List<Widget> _buildMethodButtons() {
    List<Widget> buttons = [];

    if (_selectedMethod != LoginMethod.whatsapp) {
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedMethod = LoginMethod.whatsapp;
              });
            },
            icon: Image.asset(
              'assets/icons/whats app.png',
              width: 20,
              height: 20,
            ),
            label: const Text(
              'Whatsapp',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color(0xFF60D669), fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFF26A69A).withAlpha(127)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
    }

    if (_selectedMethod != LoginMethod.mail) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 16));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedMethod = LoginMethod.mail;
              });
            },
            icon: const Icon(Icons.mail, color: Color(0xFF26A69A)),
            label: const Text(
              'Via Mail',
              style: TextStyle(color: Color(0xFF26A69A)),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: const Color(0xFF26A69A).withAlpha(127),
                width: 1.5,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
    }

    if (_selectedMethod != LoginMethod.sms &&
        (_selectedMethod == LoginMethod.mail ||
            _selectedMethod == LoginMethod.whatsapp)) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 16));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedMethod = LoginMethod.sms;
              });
            },
            icon: const Icon(Icons.smartphone, color: Color(0xFF26A69A)),
            label: const Text(
              'Via SMS',
              style: TextStyle(color: Color(0xFF26A69A)),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFF26A69A).withAlpha(127)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
    }

    if (buttons.length == 1 && _selectedMethod == LoginMethod.mobile) {
      buttons.add(const SizedBox(width: 16));
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedMethod = LoginMethod.sms;
              });
            },
            icon: const Icon(Icons.smartphone, color: Colors.blue),
            label: const Text(
              'Via SMS',
              style: TextStyle(color: Color(0xFF26A69A)),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: const Color(0xFF26A69A).withAlpha(127)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      );
    }

    return buttons;
  }
}

class OTPBottomSheet extends StatefulWidget {
  final String inputValue;
  final bool isEmail;
  final VoidCallback onWrongInput;
  const OTPBottomSheet({
    super.key,
    required this.inputValue,
    required this.onWrongInput,
    this.isEmail = false,
  });

  @override
  State<OTPBottomSheet> createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  int _timerSeconds = 60;
  Timer? _timer;
  late TapGestureRecognizer _tapRecognizer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _tapRecognizer = TapGestureRecognizer()..onTap = widget.onWrongInput;

    // Initialize focus nodes with key events handling
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].onKeyEvent = (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_otpControllers[i].text.isEmpty && i > 0) {
            _focusNodes[i - 1].requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tapRecognizer.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _formatTimer() {
    int minutes = _timerSeconds ~/ 60;
    int seconds = _timerSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter 6-digit OTP')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String currentCid = await PreferenceService.getCid();
      final responseData = await LoginApi.verifyOtp(
        otp: otp,
        mobile: widget.inputValue,
        cid: currentCid,
      );

      debugPrint("------------ OTP VERIFY API RESPONSE ------------");
      debugPrint("BODY: $responseData");

      bool error = responseData['error'] ?? true;

      String? apiMsg = responseData['error_msg']?.toString();
      String message = (apiMsg != null && apiMsg.trim().isNotEmpty)
          ? apiMsg
          : 'Invalid OTP. Please try again.';

      if (!error) {
        // Store token and IDs from top level or data if present
        String? token =
            responseData['token']?.toString() ??
            responseData['data']?['token']?.toString();
        if (token != null && token.isNotEmpty) {
          await PreferenceService.setToken(token);
          debugPrint("SignInScreen: Token saved: $token");
        }

        String? cusIdFromResponse = responseData['cus_id']?.toString() ?? responseData['led_id']?.toString();
        if (cusIdFromResponse != null) {
          await PreferenceService.setCusId(cusIdFromResponse);
        }

        final userData = responseData['data'];

        // Extract led_id - prioritize userData, then responseData['led_id'], then responseData['cus_id']
        String? ledId =
            (userData != null ? userData['led_id']?.toString() : null) ??
            responseData['led_id']?.toString() ??
            cusIdFromResponse;

        if (ledId != null && ledId.isNotEmpty) {
          await PreferenceService.setLedId(ledId);
          debugPrint("SignInScreen: LedId saved: $ledId");
        }

        // Extract basic info
        String? name =
            (userData != null ? userData['name'] : null) ??
            responseData['name'];
        if (name != null) await PreferenceService.setName(name);

        String? mobile =
            (userData != null ? userData['number'] : null) ??
            responseData['mobile'] ??
            responseData['number'];
        if (mobile != null) await PreferenceService.setMobile(mobile);

        String? uname =
            (userData != null ? userData['uname'] : null) ??
            responseData['uname'];
        if (uname != null) await PreferenceService.setUname(uname);

        // Extract CID
        String? cid =
            (userData != null ? userData['cid']?.toString() : null) ??
            responseData['cid']?.toString();
        if (cid != null) {
          await PreferenceService.setCid(cid);
        }

        // Role info (SharedPreferences for now as it was before)
        final prefs = await SharedPreferences.getInstance();
        String? roleId =
            (userData != null ? userData['role_id'] : null) ??
            responseData['role_id'];
        if (roleId != null) await prefs.setString('role_id', roleId);

        if (userData != null && userData['com'] != null) {
          await prefs.setString('com_name', userData['com']['name'] ?? '');
          await prefs.setString(
            'com_address',
            userData['com']['address'] ?? '',
          );
        } else if (responseData['comp_name'] != null) {
          await prefs.setString('com_name', responseData['comp_name'] ?? '');
        }

        // Store location from splash
        String ln = SplashScreen.ln ?? '123';
        String lt = SplashScreen.lt ?? '123';
        await prefs.setString('lt', lt);
        await prefs.setString('ln', ln);

        if (mounted) {
          Navigator.pop(context); // Close OTP bottom sheet
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = message;
          });
          // Also show SnackBar as backup
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint("OTP verification error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
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
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Verify with OTP',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color:
                      (Theme.of(context).textTheme.bodyMedium?.color ??
                              Colors.black)
                          .withValues(alpha: 0.7),
                  fontSize: screenWidth * 0.035,
                ),
                children: [
                  TextSpan(
                    text: widget.isEmail
                        ? 'Waiting to automatically detect an OTP sent to your mail\n${widget.inputValue}. '
                        : 'Waiting to automatically detect an OTP sent to\n+91 ${widget.inputValue}. ',
                  ),
                  TextSpan(
                    text: widget.isEmail ? 'Wrong Email?' : 'Wrong Number?',
                    recognizer: _tapRecognizer,
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 45,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6), // Allow 6 for paste
                    ],
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF26A69A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF26A69A),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }

                      if (value.length > 1) {
                        // Handle Paste
                        for (
                          int i = 0;
                          i < value.length && (index + i) < 6;
                          i++
                        ) {
                          _otpControllers[index + i].text = value[i];
                        }
                        // Focus appropriate next node
                        int nextToFocus = index + value.length;
                        if (nextToFocus >= 6) nextToFocus = 5;
                        _focusNodes[nextToFocus].requestFocus();
                      } else if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _timerSeconds == 0 ? _startTimer : null,
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: _timerSeconds == 0
                          ? const Color(0xFF26A69A)
                          : (Theme.of(context).textTheme.bodyMedium?.color ??
                                    Colors.black)
                                .withValues(alpha: 0.7),
                      fontWeight: _timerSeconds == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  _formatTimer(),
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
