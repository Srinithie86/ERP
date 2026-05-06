import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_ticket/core/app_colors.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:service_ticket/Widgets/app_status_bar_wrapper.dart';
import 'package:service_ticket/data/app_data.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ProfileTab(onBack: onBack);
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinController;
  late TextEditingController _countryController;

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;

      setState(() => AppData.instance.updateAvatar(bytes));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile photo: $e')),
      );
    }
  }

  Future<void> _showAvatarPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Choose profile photo',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 14.h),
                _AvatarChoiceTile(
                  icon: Icons.photo_library_rounded,
                  label: 'Pick from gallery',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                SizedBox(height: 10.h),
                _AvatarChoiceTile(
                  icon: Icons.photo_camera_rounded,
                  label: 'Open camera',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAvatar(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final profile = AppData.instance.profile;
    _nameController = TextEditingController(text: profile['name']);
    _emailController = TextEditingController(text: profile['email']);
    _phoneController = TextEditingController(text: profile['phone']);
    _addressController = TextEditingController(text: profile['address']);
    _cityController = TextEditingController(text: profile['city']);
    _stateController = TextEditingController(text: profile['state']);
    _pinController = TextEditingController(text: profile['pincode']);
    _countryController = TextEditingController(text: profile['country']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() {
      AppData.instance.updateProfile({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pinController.text,
        'country': _countryController.text,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppData.instance.profile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: widget.onBack ?? () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Center(
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: _showAvatarPicker,
                        borderRadius: BorderRadius.circular(999.r),
                        child: Container(
                          width: 110.w,
                          height: 110.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child:
                                (profile['avatarBytes'] as Uint8List?) != null
                                ? Image.memory(
                                    profile['avatarBytes'] as Uint8List,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF4F72E8),
                                          Color(0xFF2440A2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      _initialsFromName(
                                        '${profile['name'] ?? ''}',
                                      ),
                                      style: TextStyle(
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 34.h),
                _ProfileInputField(
                  label: 'User Name',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  hintText: 'Enter your full name',
                ),
                _ProfileInputField(
                  label: 'Email ID',
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hintText: 'Enter your email address',
                ),
                _ProfileInputField(
                  label: 'Mobile Number',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  hintText: 'Enter your mobile number',
                ),
                _ProfileInputField(
                  label: 'Address',
                  controller: _addressController,
                  icon: Icons.home_work_outlined,
                  hintText: 'Enter your address',
                ),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileInputField(
                        label: 'City',
                        controller: _cityController,
                        noIcon: true,
                        hintText: 'E.g. Coimbatore',
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: _ProfileInputField(
                        label: 'State',
                        controller: _stateController,
                        noIcon: true,
                        hintText: 'E.g. Tamil Nadu',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _ProfileInputField(
                        label: 'Pin code',
                        controller: _pinController,
                        noIcon: true,
                        hintText: 'E.g. 641001',
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: _ProfileInputField(
                        label: 'Country',
                        controller: _countryController,
                        noIcon: true,
                        hintText: 'E.g. India',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _initialsFromName(String name) {
  final clean = name.trim().replaceAll(RegExp(r'\s+'), '');
  if (clean.isEmpty) return '--';
  if (clean.length == 1) return clean.toUpperCase();
  return clean.substring(0, 2).toUpperCase();
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.label,
    required this.controller,
    this.icon,
    this.noIcon = false,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool noIcon;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                if (!noIcon && icon != null) ...[
                  SizedBox(width: 10.w),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(icon, size: 18.sp, color: Colors.grey.shade600),
                  ),
                  SizedBox(width: 12.w),
                ] else if (noIcon) ...[
                  SizedBox(width: 16.w),
                ],
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: noIcon ? TextAlign.center : TextAlign.start,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade400,
                      ),
                    ),
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

class _AvatarChoiceTile extends StatelessWidget {
  const _AvatarChoiceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
