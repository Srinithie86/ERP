import 'package:flutter/material.dart';
import '../login/sign_in_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onGetStarted() async {
    final navigator = Navigator.of(context);
    await Geolocator.requestPermission();
    if (mounted) {
      navigator.pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF26A69A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _onGetStarted,
            child: Text(
              "Skip",
              style: GoogleFonts.outfit(
                color: Colors.grey.shade400,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                decorationColor: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    imagePath: 'assets/images/animation_object.png', 
                    title: 'Welcome to Total ERP',
                    description: 'Manage your entire business in one powerful platform.',
                  ),
                  _buildPage(
                    imagePath: 'assets/images/financials.png', 
                    title: 'Track Everything in One Place',
                    description: 'Monitor sales, finance, inventory, and operations with real-time insights.',
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _onNext,
                  child: Text(
                    _currentPage == 0 ? 'Next' : 'Get Start',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({required String imagePath, required String title, required String description}) {
    const primaryColor = Color(0xFF26A69A);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(2, (index) => _buildDot(index: index, primaryColor: primaryColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required int index, required Color primaryColor}) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 6),
      height: 4,
      width: isActive ? 24 : 12,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
