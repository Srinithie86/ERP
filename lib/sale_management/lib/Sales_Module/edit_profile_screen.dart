import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _nameController    = TextEditingController(text: 'Rajesh Kumar');
  final _emailController   = TextEditingController(text: 'rajesh.kumar@acmecorp.in');
  final _phoneController   = TextEditingController(text: '+91 98765 43210');
  final _roleController    = TextEditingController(text: 'Sales Manager');
  final _companyController = TextEditingController(text: 'Acme Corp Ltd');
  final _cityController    = TextEditingController(text: 'Chennai');
  final _stateController   = TextEditingController(text: 'Tamil Nadu');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq     = MediaQuery.of(context);
    final sw     = mq.size.width;
    final sh     = mq.size.height;
    final isWide = sw >= 600;

    final avatarR      = isWide ? 52.0 : 44.0;
    final headerPad    = isWide ? 28.0 : 20.0;
    final sectionFs    = isWide ? 13.0 : 12.0;
    final fieldFs      = isWide ? 14.0 : 13.0;
    final hintFs       = isWide ? 13.0 : 12.0;
    final bodyHorizPad = isWide ? sw * 0.06 : 16.0;
    final cardRadius   = isWide ? 20.0 : 16.0;
    final btnHeight    = isWide ? 52.0 : 48.0;
    final btnFs        = isWide ? 15.0 : 14.0;
    final topBarH      = sh * 0.26;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarTeal,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Stack(
          children: [
            // ── Teal header band ──────────────────────────────────────────
            Positioned(
              top: 0, left: 0, right: 0,
              height: topBarH,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ── App Bar ─────────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: headerPad, vertical: 10),
                    child: Row(
                      children: [
                        _CircleBtn(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWide ? 20 : 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        if (_isSaving)
                          const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        else
                          GestureDetector(
                            onTap: _save,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.40),
                                    width: 1),
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWide ? 14 : 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Avatar card ─────────────────────────────────────────
                  SizedBox(height: isWide ? 12 : 8),
                  _AvatarCard(avatarRadius: avatarR, isWide: isWide),

                  SizedBox(height: isWide ? 20 : 16),

                  // ── Form body ───────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                          bodyHorizPad, 0, bodyHorizPad, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(
                                label: 'PERSONAL INFORMATION',
                                fontSize: sectionFs),
                            SizedBox(height: isWide ? 10 : 8),
                            _FormCard(
                              radius: cardRadius,
                              children: [
                                _Field(
                                  controller: _nameController,
                                  label: 'Full Name',
                                  icon: Icons.person_outline_rounded,
                                  fieldFs: fieldFs,
                                  hintFs: hintFs,
                                  validator: (v) => v == null || v.trim().isEmpty
                                      ? 'Name is required' : null,
                                ),
                                _Divider(),
                                _Field(
                                  controller: _emailController,
                                  label: 'Email Address',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  fieldFs: fieldFs,
                                  hintFs: hintFs,
                                  validator: (v) => v != null && v.contains('@')
                                      ? null : 'Enter a valid email',
                                ),
                                _Divider(),
                                _Field(
                                  controller: _phoneController,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  fieldFs: fieldFs,
                                  hintFs: hintFs,
                                ),
                              ],
                            ),

                            SizedBox(height: isWide ? 20 : 16),
                            _SectionLabel(
                                label: 'WORK INFORMATION',
                                fontSize: sectionFs),
                            SizedBox(height: isWide ? 10 : 8),
                            _FormCard(
                              radius: cardRadius,
                              children: [
                                _Field(
                                  controller: _roleController,
                                  label: 'Job Role',
                                  icon: Icons.work_outline_rounded,
                                  fieldFs: fieldFs,
                                  hintFs: hintFs,
                                ),
                                _Divider(),
                                _Field(
                                  controller: _companyController,
                                  label: 'Company',
                                  icon: Icons.business_outlined,
                                  fieldFs: fieldFs,
                                  hintFs: hintFs,
                                ),
                              ],
                            ),

                            SizedBox(height: isWide ? 20 : 16),
                            _SectionLabel(
                                label: 'LOCATION', fontSize: sectionFs),
                            SizedBox(height: isWide ? 10 : 8),
                            _FormCard(
                              radius: cardRadius,
                              children: [
                                _Field(
                                  controller: _cityController,
                                  label: 'City',
                                  icon: Icons.location_city_outlined,
                                  fieldFs: fieldFs,
                                  hintFs: hintFs,
                                ),
                                _Divider(),
                                _Field(
                                  controller: _stateController,
                                  label: 'State',
                                  icon: Icons.map_outlined,
                                  fieldFs: fieldFs,
                                  hintFs: hintFs,
                                ),
                              ],
                            ),

                            SizedBox(height: isWide ? 28 : 24),
                            // Save button
                            SizedBox(
                              width: double.infinity,
                              height: btnHeight,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(cardRadius),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5),
                                )
                                    : Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: btnFs,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar Card ──────────────────────────────────────────────────────────────
class _AvatarCard extends StatelessWidget {
  final double avatarRadius;
  final bool isWide;
  const _AvatarCard({required this.avatarRadius, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: avatarRadius - 3,
                backgroundColor: AppColors.primarySurface,
                child: Text(
                  'RK',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: avatarRadius * 0.55,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: isWide ? 28 : 24,
                height: isWide ? 28 : 24,
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: isWide ? 14 : 12),
              ),
            ),
          ],
        ),
        SizedBox(height: isWide ? 10 : 8),


      ],
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final double fontSize;
  const _SectionLabel({required this.label, required this.fontSize});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: AppColors.textMuted,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      fontFamily: 'Poppins',
    ),
  );
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  final double radius;
  const _FormCard({required this.children, required this.radius});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.divider, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final double fieldFs;
  final double hintFs;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.fieldFs,
    required this.hintFs,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: AppColors.textDark,
        fontSize: fieldFs,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textMuted,
          fontSize: hintFs,
          fontFamily: 'Poppins',
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1, thickness: 1,
    color: AppColors.divider,
    indent: 16, endIndent: 16,
  );
}