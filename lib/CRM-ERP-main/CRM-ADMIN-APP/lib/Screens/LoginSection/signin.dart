import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isLoading = false;

  void _handleSignIn() {
    if (_inputController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate OTP sending delay
    Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
      });
      _showOTPBottomSheet();
    });
  }

  void _showOTPBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OTPBottomSheet(mobileNumber: _inputController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenHeight = size.height;
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),
              Image.asset(
                'assets/images/smart.png',
                height: 100,
                width: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'CRM Admin',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to manage your business',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: screenHeight * 0.08),
              TextField(
                controller: _inputController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: 'Enter 10 digit number',
                  prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF26A69A)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF26A69A), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Get OTP',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OTPBottomSheet extends StatefulWidget {
  final String mobileNumber;
  const _OTPBottomSheet({required this.mobileNumber});

  @override
  State<_OTPBottomSheet> createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends State<_OTPBottomSheet> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isVerifying = false;

  void _verifyOTP() {
    setState(() {
      _isVerifying = true;
    });

    // Simulate verification success
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Verify with OTP',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Sent to +91 ${widget.mobileNumber}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) => _buildOTPField(index)),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isVerifying
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Verify & Proceed',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('Resend Code', style: TextStyle(color: Color(0xFF26A69A))),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF26A69A), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (index == 5 && value.isNotEmpty) {
            _verifyOTP();
          }
        },
      ),
    );
  }
}
