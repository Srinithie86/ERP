import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../login/sign_in_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // 3D Rotating Image
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(_rotationController.value * 2 * math.pi),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: tealColor.withValues(alpha: 0.1),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/animation_object.png',
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
              const SizedBox(height: 60),
              // Text Content
              Text(
                'Global Erp Notifications',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color:
                      Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black,
                  letterSpacing: -1.0,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              const SizedBox(height: 16),
              Text(
                'Stay updated with real-time business alerts, sales reports, and team collaboration notifications directly in your pocket.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, 
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6), 
                  height: 1.6
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
              const Spacer(),
              // Get Started Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: tealColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                  final navigator = Navigator.of(context);
                  // Trigger Native permission dialog prompt on click
                  await Geolocator.requestPermission();

                  if (mounted) {
                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  }
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tealColor,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
