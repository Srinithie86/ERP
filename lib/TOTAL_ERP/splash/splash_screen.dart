import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/security_pin_screen.dart';
import 'walkthrough_screen.dart';
import '../home/home.dart';
import '../../utils/widgets/location_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    _fetchLocationAndNavigate();
  }

  Future<void> _fetchLocationAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    
    String ln = '145'; // Default fallback
    String lt = '123';

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LocationPermissionDialog(
            isServiceDisabled: true,
            onAllow: () {},
            onOpenSettings: () => Geolocator.openLocationSettings(),
          ),
        );
        // Re-check after returning from settings
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        
        // Show friendly dialog first instead of jumping straight to system prompt
        bool? shouldRequest = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => LocationPermissionDialog(
            onAllow: () => Navigator.pop(context, true),
            onOpenSettings: () => Geolocator.openAppSettings(),
          ),
        );

        if (shouldRequest == true) {
          permission = await Geolocator.requestPermission();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LocationPermissionDialog(
            isPermanent: true,
            onAllow: () {}, // Not used for permanent
            onOpenSettings: () => Geolocator.openAppSettings(),
          ),
        );
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          );
          ln = position.longitude.toString();
          lt = position.latitude.toString();
        } catch (e) {
          debugPrint("Splash Location Fix Error: $e");
          if (mounted) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Location Error"),
                content: const Text("Could not get your real-time location. Please check your GPS signal."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Location error in Splash: $e");
    }

    await prefs.setString('ln', ln);
    await prefs.setString('lt', lt);

    // Reduced delay for smoother transition
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) { return; }

    final String? savedPin = prefs.getString('app_pin');
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (savedPin != null && savedPin.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SecurityPinScreen(
            isSetup: false,
            isAppLock: true,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WalkthroughScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
