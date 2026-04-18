import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _sameAsMobile = false;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    // Media Query for responsiveness
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.08, vertical: 20),
        child: Column(
          children: [
            SizedBox(height: height * 0.08),

            /// LOGO
            Image.asset(
              'assets/logo.png',
              width: width * 0.5,
              fit: BoxFit.contain,
            ),

            SizedBox(height: height * 0.02),

            /// "Create your account" SUBTITLE
            Text(
              "Create your account",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            SizedBox(height: height * 0.02),

            /// "Signup" TITLE
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Signup",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            SizedBox(height: 20),

            /// FORM FIELDS
            _buildOutlinedTextField("Enter Your Name"),
            SizedBox(height: 15),
            _buildOutlinedTextField("Enter Business Email"),
            SizedBox(height: 15),
            _buildOutlinedTextField("Enter Mobile Number"),
            SizedBox(height: 15),
            _buildOutlinedTextField("Enter Whatsapp Number"),

            SizedBox(height: 10),

            /// CHECKBOXES
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _sameAsMobile,
                    activeColor: const Color(0xff26A69A),
                    onChanged: (val) {
                      setState(() {
                        _sameAsMobile = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Same as Mobile Number",
                  style: TextStyle(color: Color(0xff26A69A), fontSize: 13),
                ),
              ],
            ),

            SizedBox(height: 15),

            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _agreeToTerms,
                    activeColor: const Color(0xff26A69A),
                    onChanged: (val) {
                      setState(() {
                        _agreeToTerms = val ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: "I agree to the ",
                      style: const TextStyle(color: Colors.black, fontSize: 13),
                      children: [
                        TextSpan(
                          text: "Terms of Service",
                          style: const TextStyle(color: Color(0xff26A69A)),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(color: Color(0xff26A69A)),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            /// GET STARTED BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff26A69A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "GET STARTED",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            /// OR SIGNUP WITH
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "or  signup with",
                  style: TextStyle(color: Color(0xff26A69A), fontSize: 13),
                ),
              ],
            ),

            SizedBox(height: 20),

            /// SOCIAL ICONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/google.png', width: 45),
                const SizedBox(width: 30),
                Image.asset('assets/apple.png', width: 45),
              ],
            ),

            SizedBox(height: 30),

            /// ALREADY HAVE AN ACCOUNT
            RichText(
              text: TextSpan(
                text: "Already have an Account? ",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: "Signin",
                    style: const TextStyle(
                      color: Color(0xff26A69A),
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pop(context);
                      },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xff26A69A), width: 2),
        ),
      ),
    );
  }
}
