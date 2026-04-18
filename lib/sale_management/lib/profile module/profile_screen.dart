import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'select_language_screen.dart';
import 'edit_profile_screen.dart';
import '../Sales_Module/sale_dashboard.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '...';
  String _userEmail = '...';
  String _userPhone = '...';
  String _userInitial = 'U';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('name') ?? 'User';
      _userEmail = prefs.getString('email') ?? (prefs.getString('username') ?? 'N/A');
      _userPhone = prefs.getString('mobile') ?? (prefs.getString('phone') ?? 'N/A');
      if (_userName.isNotEmpty && _userName != 'User') {
        _userInitial = _userName[0].toUpperCase();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final hp = sw / 390;
    final vp = sh / 844;
    final sp = (sw / 390).clamp(0.8, 1.2);

    const primaryTeal = Color(0xFF26A69A);
    const accentTeal = Color(0xFF4DB6AC);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          // ── DECORATIVE BACKGROUND SHAPE ─────────────────────────
          Positioned(
            top: -100 * vp,
            right: -80 * hp,
            child: Container(
              width: 300 * hp,
              height: 300 * hp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryTeal.withOpacity(0.15),
                    primaryTeal.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          // ── CUSTOM CURVED HEADER ───────────────────────────────
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: 340 * vp,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryTeal,
                    accentTeal,
                    Color(0xFF00796B),
                    Color(0xFF004D40),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // ── APP BAR ──────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * hp, vertical: 8 * vp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _blurButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const DashboardPage()),
                            );
                          },
                        ),
                        Text(
                          'Executive Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17 * sp,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                            letterSpacing: 0.5,
                          ),
                        ),
                        _blurButton(
                          icon: Icons.more_vert_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * vp),

                  // ── AVATAR SECTION WITH GLOW ──────────────────────
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Halo
                        Container(
                          width: 130 * hp,
                          height: 130 * hp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: primaryTeal.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                        // Inner ring
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 52 * hp,
                            backgroundColor: const Color(0xFFE0F2FE),
                            child: Text(
                              _userInitial,
                              style: TextStyle(
                                fontSize: 44 * sp,
                                fontWeight: FontWeight.w900,
                                color: primaryTeal,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5 * vp,
                          right: 5 * hp,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                              ],
                            ),
                            child: const Icon(Icons.edit_rounded, color: primaryTeal, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20 * vp),
                  Text(
                    _userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28 * sp,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Poppins',
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 4 * vp),
                    padding: EdgeInsets.symmetric(horizontal: 12 * hp, vertical: 4 * vp),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ACTIVE MEMBER',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10 * sp,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  SizedBox(height: 48 * vp),

                  // ── GLASSMORPHIC CONTACT INFO ───────────────────
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 24 * hp),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: EdgeInsets.all(24 * hp),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'OFFICIAL INFO',
                                    style: TextStyle(
                                      fontSize: 11 * sp,
                                      fontWeight: FontWeight.w900,
                                      color: primaryTeal.withOpacity(0.6),
                                      letterSpacing: 1.5,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Icon(Icons.info_outline_rounded, color: primaryTeal.withOpacity(0.3), size: 16),
                                ],
                              ),
                              SizedBox(height: 24 * vp),
                              _buildInfoRow(
                                icon: Icons.alternate_email_rounded,
                                label: 'Corporate Email',
                                value: _userEmail,
                                sp: sp,
                                hp: hp,
                                color: primaryTeal,
                              ),
                              _glassDivider(),
                              _buildInfoRow(
                                icon: Icons.phone_android_rounded,
                                label: 'Direct Phone',
                                value: _userPhone,
                                sp: sp,
                                hp: hp,
                                color: primaryTeal,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24 * vp),

                  // ── ACTION MENU ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 24 * hp),
                    padding: EdgeInsets.symmetric(vertical: 8 * vp),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          iconPath: Icons.manage_accounts_rounded,
                          label: 'Account Settings',
                          sp: sp,
                          hp: hp,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          ),
                        ),
                        _buildMenuTile(
                          iconPath: Icons.translate_rounded,
                          label: 'Display Language',
                          sp: sp,
                          hp: hp,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SelectLanguageScreen()),
                          ),
                        ),
                        _buildMenuTile(
                          iconPath: Icons.shield_moon_rounded,
                          label: 'Privacy & Policy',
                          sp: sp,
                          hp: hp,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 48 * vp),
                  Text(
                    'ERP VERSION 2.1.0',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11 * sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 32 * vp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _glassDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 1,
      width: double.infinity,
      color: Colors.grey.withOpacity(0.1),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required double sp,
    required double hp,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20 * sp),
        ),
        SizedBox(width: 16 * hp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11 * sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontSize: 15 * sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData iconPath,
    required String label,
    required double sp,
    required double hp,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24 * hp, vertical: 18),
        child: Row(
          children: [
            Icon(iconPath, color: const Color(0xFF64748B), size: 22 * sp),
            SizedBox(width: 16 * hp),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontSize: 15 * sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 14),
          ],
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
