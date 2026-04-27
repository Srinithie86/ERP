import 'package:flutter/material.dart';
import 'package:crm/core/theme/app_theme.dart';
import 'package:crm/widgets/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Placeholder (based on Figma)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, color: AppTheme.primaryTeal, size: 40),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMART',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontSize: 32,
                              letterSpacing: 2.0,
                            ),
                      ),
                      Text(
                        'TOTAL ERP',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryTeal,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Create your account',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your customers, sales & business anywhere.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              
              // Auth Tabs (Figma style)
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primaryTeal,
                labelColor: AppTheme.primaryTeal,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                   Tab(icon: Icon(Icons.sms), text: 'via SMS'),
                   Tab(icon: Icon(Icons.mail), text: 'via Mail'),
                   Tab(icon: FaIcon(FontAwesomeIcons.whatsapp), text: 'via WhatsApp'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 120,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    CustomTextField(
                      controller: _mobileController,
                      label: 'Enter Mobile Number',
                      hintText: '+91 XXXXX XXXXX',
                      keyboardType: TextInputType.phone,
                    ),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Enter Email Address',
                      hintText: 'user@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomTextField(
                      controller: _whatsappController,
                      label: 'Enter WhatsApp Number',
                      hintText: '+91 XXXXX XXXXX',
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to OTP or Dashboard
                },
                child: const Text('Next'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Or continue with',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialIcon(FontAwesomeIcons.google, Colors.red),
                  _socialIcon(FontAwesomeIcons.apple, Colors.black),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't Have An Account? "),
                  GestureDetector(
                    onTap: () {
                      // Navigate to Signup
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _socialIcon(dynamic icon, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: icon is IconData 
            ? Icon(icon, color: color, size: 24)
            : FaIcon(icon, color: color, size: 24),
      ),
    );
  }
}
