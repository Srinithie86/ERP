import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../splash/notification_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSavedPin();
  }

  Future<void> _loadSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPin = prefs.getString('app_pin');
    });
  }

  void _onNumberTap(String number) {
    if (_pin.length < _pinLength) {
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
      // First time setting PIN
      await prefs.setString('app_pin', _pin);
      if (!mounted) { return; }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security PIN Enabled Successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return success
    } else if (widget.isAppLock) {
      // Opening the app, verifying PIN
      if (_pin == _savedPin) {
        if (!mounted) { return; }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NotificationScreen()),
        );
      } else {
        _showErrorAndReset('Incorrect PIN. Try again.');
      }
    } else if (widget.isTurningOff) {
      // Trying to disable the PIN
      if (_pin == _savedPin) {
        await prefs.remove('app_pin');
        if (!mounted) { return; }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security PIN Disabled'),
            backgroundColor: Colors.grey,
          ),
        );
        Navigator.pop(context, false); // Return new state (disabled = false)
      } else {
        _showErrorAndReset('Incorrect PIN. Cannot disable.');
      }
    } else {
      // Normal verification
      if (_pin == _savedPin) {
        if (!mounted) { return; }
        Navigator.pop(context, true);
      } else {
        _showErrorAndReset('Incorrect PIN.');
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
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tealColor = const Color(0xFF26A69A);
    String headerText = 'Enter Security PIN';
    if (widget.isSetup) {
      headerText = 'Set up Security PIN';
    } else if (widget.isTurningOff) {
      headerText = 'Enter PIN to Disable';
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: widget.isAppLock 
            ? const SizedBox.shrink() // Can't go back from app lock
            : IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Google Pay Type Logo/Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tealColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_person_rounded, color: tealColor, size: 40),
          ),
          const SizedBox(height: 24),
          // Header Text
          Text(
            headerText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Enter your 4-digit code to continue',
            style: TextStyle(
              fontSize: 14, 
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.black54,
            ),
          ),
          const SizedBox(height: 48),

          // Visual Pin Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pinLength, (index) {
              bool isFilled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? tealColor : (Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white),
                  border: Border.all(
                    color: isFilled ? tealColor : Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
              );
            }),
          ),
          const Spacer(),

          // Keypad Layout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3']),
                const SizedBox(height: 16),
                _buildKeypadRow(['4', '5', '6']),
                const SizedBox(height: 16),
                _buildKeypadRow(['7', '8', '9']),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(width: 80), // Empty placeholder for balance
                    _buildKeypadButton('0'),
                    _buildIconButton(Icons.backspace_outlined, _onDeleteTap),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((val) => _buildKeypadButton(val)).toList(),
    );
  }

  Widget _buildKeypadButton(String value) {
    return InkWell(
      onTap: () => _onNumberTap(value),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        child: Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        child: Icon(icon, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade300 : Colors.black54, size: 24),
      ),
    );
  }
}
