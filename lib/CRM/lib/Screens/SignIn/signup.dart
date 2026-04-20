import 'package:crm/Screens/SignIn/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crm/Services/social_auth_service.dart';
import 'package:crm/Screens/Home/dashboard_screen.dart';
import '../../Models/login_api.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _sameAsMobile = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    if (_sameAsMobile) {
      _whatsappController.text = _phoneController.text;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String whatsapp = _whatsappController.text.trim();

    debugPrint(
      "DEBUG: Name: '$name', Email: '$email', Phone: '$phone', WhatsApp: '$whatsapp', sameAsMobile: $_sameAsMobile",
    );

    if (name.isEmpty || email.isEmpty || phone.isEmpty || whatsapp.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    final emailLower = email.toLowerCase();

    if (!(emailLower.endsWith('@gmail.com') ||
        emailLower.endsWith('@sgsapp.in'))) {
      _showError('Email must be @gmail.com or @sgsapp.in');
      return;
    }
    if (phone.length != 10) {
      _showError('Mobile number must be 10 digits');
      return;
    }

    if (whatsapp.length != 10) {
      _showError('Whatsapp number must be 10 digits');
      return;
    }

    if (!_agreedToTerms) {
      _showError('Please agree to the Terms and Conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final responseData = await LoginApi.signUp(
        name: name,
        email: email,
        mobile: phone,
      );

      debugPrint("------------ API RESPONSE ------------");
      debugPrint("BODY: $responseData");

      bool error = responseData['error'] ?? true;
      String message = responseData['error_msg'] ?? 'Something went wrong';

      if (!error) {
        // Success - Navigate to Sign In
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        }
      } else {
        _showError(message);
      }
    } catch (e) {
      _showError('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await SocialAuthService().signInWithGoogle();
      if (googleUser != null) {
        // TODO: Backend authentication with googleUser.authentication
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-In Successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      _showError('Google Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final appleCredential = await SocialAuthService().signInWithApple();
      if (appleCredential != null) {
        // TODO: Backend authentication with appleCredential
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Apple Sign-In Successful!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      _showError('Apple Sign-In failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.04),
                        Image.asset(
                          'assets/images/smart.png',
                          width: screenWidth * 0.7,
                        ),
                        const SizedBox(height: 7),
                        // Image.asset(
                        //   'assets/images/TOTAL ERP.png',
                        //   width: screenWidth * 0.45,
                        // ),
                        SizedBox(height: screenHeight * 0.025),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Create your account',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color ??
                                  Colors.black87,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Signup',
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.color,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildTextField(
                          'Enter Your Name',
                          screenWidth,
                          screenHeight,
                          controller: _nameController,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildTextField(
                          'Enter Business Email',
                          screenWidth,
                          screenHeight,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildTextField(
                          'Enter Mobile Number',
                          screenWidth,
                          screenHeight,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        _buildTextField(
                          'Enter Whatsapp Number',
                          screenWidth,
                          screenHeight,
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onChanged: (val) {
                            if (_sameAsMobile && val != _phoneController.text) {
                              setState(() {
                                _sameAsMobile = false;
                              });
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Checkbox(
                                value: _sameAsMobile,
                                onChanged: (val) {
                                  setState(() {
                                    _sameAsMobile = val!;
                                  });

                                  if (_sameAsMobile) {
                                    _whatsappController.text =
                                        _phoneController.text;
                                  }
                                },

                                activeColor: const Color(0xFF26A69A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF26A69A),
                                  width: 1.5,
                                ),
                                visualDensity: const VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'Same as Mobile Number',
                              style: TextStyle(
                                fontSize: 13.8,
                                color: Color(0xFF26A69A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (val) =>
                                    setState(() => _agreedToTerms = val!),
                                activeColor: const Color(0xFF26A69A),
                                side: const BorderSide(
                                  color: Color(0xFF26A69A),
                                  width: 1.5,
                                ),
                                visualDensity: const VisualDensity(
                                  horizontal: -4,
                                  vertical: -4,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 13.7,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color ??
                                        Colors.black87,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: Color(0xFF26A69A),
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xFF26A69A),
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        SizedBox(
                          width: screenWidth * 0.72,
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26A69A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'GET STARTED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'or ',
                              style: TextStyle(color: const Color(0xFF26A69A)),
                            ),
                            const Text(
                              'signup with',
                              style: TextStyle(color: Color(0xFF26A69A)),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _handleGoogleSignIn,
                              child: Image.asset(
                                'assets/icons/google.png',
                                width: 35,
                                height: 35,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.g_mobiledata,
                                  size: 35,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 30),
                            GestureDetector(
                              onTap: _handleAppleSignIn,
                              child: Image.asset(
                                'assets/icons/apple.png',
                                width: 45,
                                height: 45,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.apple, size: 40),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an Account? ",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Signin",
                                style: TextStyle(
                                  color: Color(0xFF26A69A),
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    double screenWidth,
    double screenHeight, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: screenWidth * 0.04,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFF8F8F8F),
          fontSize: screenWidth * 0.038,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.012,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF26A69A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF26A69A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF26A69A), width: 2),
        ),
      ),
    );
  }
}
