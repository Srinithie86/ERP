import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/storage_service.dart';
import 'login/login_screen.dart';
import 'technician_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    bool isLoggedIn = await StorageService.isLoggedIn();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            isLoggedIn ? const TechnicianDashboard() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Media Query for true responsiveness
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Center content: Logo and Slogans
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo SVG
                Image.asset(
                  'assets/logo.png',
                  width: width * 0.65,
                ),
                SizedBox(height: height * 0.02),

                Text(
                  'Simplifying Your\nService Experience',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: const Color(0xFF00AEEF),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Bottom content: Powered by and Version
          Positioned(
            bottom: height * 0.05,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'powered by SMM Company',
                  style: TextStyle(
                    fontSize: width * 0.04,
                    color: const Color(0xFF2D2D2D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 0.1',
                  style: TextStyle(
                    fontSize: width * 0.035,
                    color: const Color(0xFF8E8E8E),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
