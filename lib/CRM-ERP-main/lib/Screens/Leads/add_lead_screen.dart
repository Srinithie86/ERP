import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm/Services/lead_service.dart';
import 'package:crm/Services/preference_service.dart';
import 'package:crm/Models/lead_api.dart';
import 'package:crm/Models/enquiry_api.dart';
import 'package:crm/Models/referral_api.dart';

class AddLeadScreen extends StatefulWidget {
  final bool isEnquiry;
  final bool isReferral;
  const AddLeadScreen({super.key, this.isEnquiry = false, this.isReferral = false});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Controllers
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phone1Controller = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();

  String _selectedLeadSource = 'Select Source';
  String _selectedRequirement = 'Select Requirement';
  String _selectedOccupation = 'Select Occupation';
  List<dynamic> _dynamicLeadSources = [];
  List<dynamic> _dynamicRequirements = [];
  List<dynamic> _dynamicOccupations = [];

  @override
  void initState() {
    super.initState();
    _typeController.text = widget.isReferral ? 'Referral' : (widget.isEnquiry ? 'Enquiry' : 'Lead');
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final sources = await LeadService.fetchDropdownData(type: '3020');
      final requirements = await LeadService.fetchDropdownData(type: '3021');
      final occupations = await LeadService.fetchDropdownData(type: '3022');

      if (mounted) {
        setState(() {
          _dynamicLeadSources = sources;
          _dynamicRequirements = requirements;
          _dynamicOccupations = occupations;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dropdown data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _requirementsController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _saveLead() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final String? ledId = await PreferenceService.getUid();
      debugPrint("------------ UID RETRIEVED IN UI: $ledId ------------");

      if (ledId == null || ledId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        debugPrint("CRITICAL: UID NOT FOUND. ALL KEYS: ${prefs.getKeys()}");
        
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error: User ID not found. Please login again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Find IDs for selected items
      final selectedSourceItem = _dynamicLeadSources.firstWhere(
        (e) =>
            (e['name'] ?? e['le_source'] ?? e['source_name'] ?? '')
                .toString() ==
            _selectedLeadSource,
        orElse: () => null,
      );
      final selectedReqItem = _dynamicRequirements.firstWhere(
        (e) =>
            (e['name'] ?? e['required_project'] ?? e['product_service'] ?? '')
                .toString() ==
            _selectedRequirement,
        orElse: () => null,
      );
      final selectedOccItem = _dynamicOccupations.firstWhere(
        (e) =>
            (e['name'] ?? e['occupation_name'] ?? e.values.first).toString() ==
            _selectedOccupation,
        orElse: () => null,
      );

      final String todayDate = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

      final Map<String, String> leadData = {
        'enquiry_date': todayDate,
        'cus_name': _nameController.text.trim(),
        'comany_name': _companyController.text.trim(),
        'contact_person': _nameController.text.trim(), // Mapping name to contact person
        'mobile_1': _phone1Controller.text.trim(),
        'moble_2': _phone2Controller.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'city': '', 
        'state': '', 
        'pincode': _pinCodeController.text.trim(),
        'lead_source': selectedSourceItem != null
            ? selectedSourceItem['id'].toString()
            : '',
        'product_service': selectedReqItem != null
            ? selectedReqItem['id'].toString()
            : '',
        'budget': '', 
        'requirement_notes': _selectedRequirement == 'Select Requirement'
            ? ''
            : _selectedRequirement,
        'enquiry_type': widget.isReferral ? '3' : (widget.isEnquiry ? '2' : '1'),
        'assigned_to': ledId, 
        'remarks': _descriptionController.text.trim(),
        'occupation': selectedOccItem != null
            ? selectedOccItem['id'].toString()
            : '',
      };

      Map<String, dynamic> response;
      if (widget.isReferral) {
        response = await ReferralApi.addReferral(leadData);
      } else if (widget.isEnquiry) {
        response = await EnquiryApi.addEnquiry(leadData);
      } else {
        response = await LeadApi.addLead(leadData);
      }

      debugPrint("------------ ADD RECORD RESPONSE IN UI ------------");
      debugPrint("RESPONSE: $response");

      if (mounted) {
        setState(() => _isSaving = false);

        if (response['error'] == false) {
          String typeDisp = widget.isReferral ? 'Referral' : (widget.isEnquiry ? 'Enquiry' : 'Lead');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? '$typeDisp saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          String typeDisp = widget.isReferral ? 'Referral' : (widget.isEnquiry ? 'Enquiry' : 'Lead');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error_msg'] ?? 'Failed to save $typeDisp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isReferral ? 'Add Referral' : (widget.isEnquiry ? 'Add Enquiry' : 'Add Lead'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF26A69A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRoundedTextField(
                controller: _nameController,
                labelText: 'Name',
                hintText: 'Enter Name',
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

              _buildRoundedTextField(
                controller: _companyController,
                labelText: 'Company Name',
                hintText: 'Enter Company Name',
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _phone1Controller,
                labelText: 'Phone No 1',
                hintText: 'Enter Phone No 1',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _phone2Controller,
                labelText: 'Phone No 2',
                hintText: 'Enter Phone No 2',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Please enter a valid 10-digit number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _emailController,
                labelText: 'Email ID',
                hintText: 'Enter Email ID',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _typeController,
                labelText: 'Type',
                hintText: '',
                readOnly: true,
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _addressController,
                labelText: 'Address',
                hintText: 'Enter Address',
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _pinCodeController,
                labelText: 'Pin code',
                hintText: 'Enter Pin code',
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pincode';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'Please enter a valid 6-digit pincode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildRoundedDropdown(
                value: _selectedLeadSource,
                items: [
                  'Select Source',
                  ..._dynamicLeadSources.map(
                    (e) =>
                        (e['name'] ??
                                e['le_source'] ??
                                e['source_name'] ??
                                e.values.first)
                            .toString(),
                  ),
                ],
                labelText: widget.isReferral ? 'Referral Source' : (widget.isEnquiry ? 'Enquiry Source' : 'Lead Source'),
                onChanged: (val) {
                  setState(() {
                    _selectedLeadSource = val ?? 'Select Source';
                  });
                },
              ),
              const SizedBox(height: 16),

              _buildRoundedDropdown(
                value: _selectedRequirement,
                items: [
                  'Select Requirement',
                  ..._dynamicRequirements.map(
                    (e) =>
                        (e['name'] ??
                                e['required_project'] ??
                                e['product_service'] ??
                                e.values.first)
                            .toString(),
                  ),
                ],
                labelText: 'Product Service requirements',
                onChanged: (val) {
                  setState(() {
                    _selectedRequirement = val ?? 'Select Requirement';
                  });
                },
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter Description',
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              _buildRoundedDropdown(
                value: _selectedOccupation,
                items: [
                  'Select Occupation',
                  ..._dynamicOccupations.map(
                    (e) =>
                        (e['name'] ?? e['occupation_name'] ?? e.values.first)
                            .toString(),
                  ),
                ],
                labelText: 'Occupation',
                onChanged: (val) {
                  setState(() {
                    _selectedOccupation = val ?? 'Select Occupation';
                  });
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      validator: validator,
      decoration: InputDecoration(
        counterText: "",
        alignLabelWithHint: true,
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF26A69A)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildRoundedDropdown({
    required String value,
    required List<String> items,
    required String labelText,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF26A69A)),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF26A69A)),
          dropdownColor: Colors.white,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: item.startsWith('Select')
                      ? Colors.grey
                      : Colors.black87,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
