import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../splash/walkthrough_screen.dart';
import 'home.dart';
import 'package:erp_localization/erp_localization.dart';

class SecurityPinScreen extends StatefulWidget {
  final bool isSetup; // Setting up the PIN for the first time
  final bool isAppLock; // Entering PIN to unlock the app at launch
  final bool isTurningOff; // Entering PIN to turn off the security

  const SecurityPinScreen({
    super.key,
    this.isSetup = false,
    this.isAppLock = false,
    this.isTurningOff = false,
  });

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  String _pin = "";
  final int _pinLength = 4;
  String? _savedPin;
  bool _isVerifyingOldPin = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPin();
  }

  Future<void> _loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString('app_pin');
      if (widget.isSetup && _savedPin != null) {
        _isVerifyingOldPin = true;
      }
    });
  }

  void _onNumberTap(String number) {
    if (_pin.length < _pinLength) {
      HapticFeedback.lightImpact();
      setState(() {
        _pin += number;
      });
    }

    if (_pin.length == _pinLength) {
      _processPin();
    }
  }

  Future<void> _processPin() async {
    final prefs = await SharedPreferences.getInstance();

    if (widget.isSetup) {
      if (_isVerifyingOldPin) {
        if (_pin == _savedPin) {
          setState(() {
            _isVerifyingOldPin = false;
            _pin = "";
          });
          return;
        } else {
          _showErrorAndReset(AppLocalization.of('Incorrect Old PIN.'));
          return;
        }
      }
      // First time setting PIN or old PIN verified
      await prefs.setString('app_pin', _pin);
      if (!mounted) { return; }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalization.of('Security PIN Updated Successfully')),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return success
    } else if (widget.isAppLock) {
      // Opening the app, verifying PIN
      if (_pin == _savedPin) {
        final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
        if (!mounted) { return; }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => isLoggedIn ? const HomeScreen() : const WalkthroughScreen()),
        );
      } else {
        _showErrorAndReset(AppLocalization.of('Incorrect PIN. Try again.'));
      }
    } else if (widget.isTurningOff) {
      // Trying to disable the PIN
      if (_pin == _savedPin) {
        await prefs.remove('app_pin');
        if (!mounted) { return; }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalization.of('Security PIN Disabled')),
            backgroundColor: Colors.grey,
          ),
        );
        Navigator.pop(context, false); // Return new state (disabled = false)
      } else {
        _showErrorAndReset(AppLocalization.of('Incorrect PIN. Cannot disable.'));
      }
    } else {
      // Normal verification
      if (_pin == _savedPin) {
        if (!mounted) { return; }
        Navigator.pop(context, true);
      } else {
        _showErrorAndReset(AppLocalization.of('Incorrect PIN.'));
      }
    }
  }

  void _showErrorAndReset(String message) {
    if (!mounted) { return; }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
    setState(() {
      _pin = ""; // Reset PIN
    });
  }

  void _onDeleteTap() {
    if (_pin.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tealColor = const Color(0xFF26A69A);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String headerText = AppLocalization.of('Enter Security PIN');
    if (widget.isSetup) {
      headerText = _isVerifyingOldPin 
          ? AppLocalization.of('Enter Old PIN') 
          : AppLocalization.of('Create New PIN');
    } else if (widget.isTurningOff) {
      headerText = AppLocalization.of('Enter PIN to Disable');
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isAppLock 
            ? const SizedBox.shrink() 
            : IconButton(
                icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Header Section
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: tealColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_rounded, color: tealColor, size: 45),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text(
                    headerText,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppLocalization.of('Your PIN keeps your data safe'),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 800.ms).moveY(begin: 20, end: 0),

              const SizedBox(height: 50),

              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  bool isFilled = index < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                    width: isFilled ? 18 : 14,
                    height: isFilled ? 18 : 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? tealColor : (isDark ? Colors.grey[800] : Colors.grey[300]),
                      boxShadow: isFilled ? [
                        BoxShadow(
                          color: tealColor.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ] : [],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 40),

              // Keypad
              Container(
                padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: 20),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: 20),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 70), // Balance for 0
                        _buildKeypadButton('0'),
                        _buildKeypadButton('del', isIcon: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).moveY(begin: 100, end: 0),
            ],
          ),
        ),
      ),
    );
}

  Widget _buildKeypadRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) => _buildKeypadButton(val)).toList(),
    );
  }

  Widget _buildKeypadButton(String value, {bool isIcon = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tealColor = const Color(0xFF26A69A);

    return InkWell(
      onTap: () => isIcon ? _onDeleteTap() : _onNumberTap(value),
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900]?.withOpacity(0.5) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: isIcon 
            ? Icon(Icons.backspace_outlined, color: Colors.red[400], size: 24)
            : Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(
       begin: const Offset(1, 1), 
       end: const Offset(1, 1), 
       duration: 100.ms,
     ); // Basic setup for tap animation
  }
}
