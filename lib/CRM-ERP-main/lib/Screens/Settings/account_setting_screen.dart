import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crm/Services/profile_service.dart';
import 'package:crm/Services/preference_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingScreen extends StatefulWidget {
  final bool isEditing;
  const AccountSettingScreen({super.key, this.isEditing = false});

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  bool _isEditing = false;
  bool _isLoading = true;
  File? _image;
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Load from cache first for instant response
    final String? cachedName = await PreferenceService.getName();
    final String? cachedEmail = await PreferenceService.getEmail();
    final String? cachedPhone = await PreferenceService.getMobile();
    final String? cachedUname = await PreferenceService.getUname();

    if (mounted) {
      setState(() {
        _nameController.text = cachedName ?? 'N/A';
        _emailController.text = cachedEmail ?? 'N/A';
        _phoneController.text = cachedPhone ?? 'N/A';
        _userNameController.text = cachedUname ?? 'N/A';
      });
    }

    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        String lt = prefs.getString('lt') ?? '';
        String ln = prefs.getString('ln') ?? '';
        if (lt.isNotEmpty && ln.isNotEmpty) {
          _locationController.text = "$lt, $ln";
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF26A69A)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Detail Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color ?? Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Profile Image
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF871A1A),
                                    width: 2,
                                  ),
                                  image: _image != null
                                      ? DecorationImage(
                                          image: FileImage(_image!),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/user_avatar.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Change Photo Button
                          TextButton(
                            onPressed: _pickImage,
                            child: const Text(
                              'Change Photo',
                              style: TextStyle(
                                color: Color(0xFF26A69A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Basic Details Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Basic Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.color ??
                                      Colors.black,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  if (_isEditing) {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    // Call Update API
                                    setState(() {
                                      _isLoading = true;
                                    });

                                    final response =
                                        await ProfileService.updateProfileData(
                                          name: _nameController.text,
                                          mobile: _phoneController.text,
                                          email: _emailController.text,
                                        );

                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                        if (response != null &&
                                            response['status'] == 'success') {
                                          _isEditing = false;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response['error_msg'] ??
                                                    'Profile updated successfully',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response?['error_msg'] ??
                                                    'Failed to update profile',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _isEditing = true;
                                    });
                                  }
                                },
                                icon: Icon(
                                  _isEditing
                                      ? Icons.save_outlined
                                      : Icons.edit_outlined,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                label: Text(
                                  _isEditing ? 'Save' : 'Edit',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Info Rows
                          _buildDetailItem(
                            'Name',
                            _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter name';
                              }
                              if (!RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                                return 'Please enter only characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                            'Mail Id',
                            _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              }
                              if (!value.endsWith('@gmail.com') &&
                                  !value.endsWith('@appsgs.in')) {
                                return 'Email must end with @gmail.com or @appsgs.in';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                            'Mobile Number',
                            _phoneController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Please enter a valid 10-digit number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem('Location', _locationController),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailItem(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black87,
              ),
            ),
          ),
        ),
        Expanded(
          child: _isEditing
              ? TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLength: maxLength,
                  validator: validator,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    counterText: "",
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    controller.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color:
                          Theme.of(context).textTheme.bodySmall?.color ??
                          Colors.black54,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
