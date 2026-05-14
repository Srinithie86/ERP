import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/lead_service.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/preference_service.dart';

import 'package:erp_smart/CRM-ERP-main/lib/Services/add_lead_service.dart';

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
  final _cityController = TextEditingController();
  final _budgetController = TextEditingController();

  String _selectedLeadSource = 'Select Source';
  String _selectedRequirement = 'Select Requirement';
  String _selectedOccupation = 'Select Occupation';
  String _selectedState = 'Select State';
  List<dynamic> _dynamicLeadSources = [];
  List<dynamic> _dynamicRequirements = [];
  List<dynamic> _dynamicOccupations = [];
  List<dynamic> _dynamicStates = [];
  List<dynamic> _dynamicEnquiryTypes = [];

  @override
  void initState() {
    super.initState();
    _typeController.text =
        widget.isReferral ? 'Referral' : (widget.isEnquiry ? 'Enquiry' : 'Lead');
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final sourcesData = await LeadService.fetchDropdownData(type: '3020');
      final requirementsData = await LeadService.fetchDropdownData(type: '3021');
      final occupationsData = await LeadService.fetchDropdownData(
        type: '2083',
        form: 'sm_main_form_22442',
        select: 'id,name',
      );
      final statesData =
          await LeadService.fetchDropdownData(type: '2084', listId: '1510');
      final enquiryTypesData =
          await LeadService.fetchDropdownData(type: '2084', listId: '210');

      if (mounted) {
        setState(() {
          _dynamicLeadSources = sourcesData;
          _dynamicRequirements = requirementsData;
          _dynamicOccupations = occupationsData;
          _dynamicStates = statesData;
          _dynamicEnquiryTypes = enquiryTypesData;
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
    _cityController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// Extracts value or id from dropdown items based on selected display name.
  String _getDropdownValue(List<dynamic> items, String selectedName, {String? defaultName}) {
    if (selectedName == (defaultName ?? 'Select')) return '';
    try {
      final item = items.firstWhere(
        (e) => (e['name'] ?? e['le_source'] ?? e['source_name'] ?? e['label'] ?? e['occupation_name'] ?? e.values.first).toString() == selectedName,
        orElse: () => null,
      );
      if (item != null) {
        return (item['value'] ?? item['id'] ?? item['name'] ?? '').toString();
      }
    } catch (e) {
      debugPrint('Error finding value for $selectedName: $e');
    }
    return '';
  }

  Future<void> _saveLead() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, String> leadData = {
       
        'cus_name': _nameController.text,
        'comany_name': _companyController.text,
        'mobile_1': _phone1Controller.text,
        'moble_2': _phone2Controller.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'pincode': _pinCodeController.text,
        'city': _cityController.text,
        'budget': _budgetController.text,
        'requirement_notes': _descriptionController.text,
        'enquiry_type': _getDropdownValue(_dynamicEnquiryTypes, widget.isReferral ? 'Referral' : (widget.isEnquiry ? 'Enquiry' : 'Lead')),
        'lead_source': _getDropdownValue(_dynamicLeadSources, _selectedLeadSource, defaultName: 'Select Source'),
        'product_service': _getDropdownValue(_dynamicRequirements, _selectedRequirement, defaultName: 'Select Requirement'),
        'occupation': _getDropdownValue(_dynamicOccupations, _selectedOccupation, defaultName: 'Select Occupation'),
        'state': _getDropdownValue(_dynamicStates, _selectedState, defaultName: 'Select State'),
        'cus_status':'NEW',
      };

      final response = await AddLeadService.submitLead(leadData);

      if (mounted) {
        setState(() => _isSaving = false);

        if (response['error'].toString() == 'false') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lead saved successfully ✅')),
          );
          Navigator.pop(context, true);
        } else {
          final errorMsg = response['message'] ?? response['error_msg'] ?? 'Failed to save lead';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ $errorMsg')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

              // _buildRoundedTextField(
              //   controller: _typeController,
              //   labelText: 'Type',
              //   hintText: '',
              //   readOnly: true,
              // ),
              // const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _addressController,
                labelText: 'Address',
                hintText: 'Enter Address',
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(
                controller: _cityController,
                labelText: 'City',
                hintText: 'Enter City',
              ),
              const SizedBox(height: 16),

              _buildRoundedDropdown(
                value: _selectedState,
                items: [
                  'Select State',
                  ..._dynamicStates.map((e) => (e['label'] ?? e['name'] ?? e.values.first).toString()).toSet(),
                ],
                labelText: 'State',
                onChanged: (val) {
                  setState(() {
                    _selectedState = val ?? 'Select State';
                  });
                },
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
                  ..._dynamicLeadSources.map((e) => (e['label'] ?? e['name'] ?? e['le_source'] ?? e['source_name'] ?? e.values.first).toString()).toSet(),
                ],
                labelText: widget.isReferral
                    ? 'Referral Source'
                    : (widget.isEnquiry ? 'Enquiry Source' : 'Lead Source'),
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
                  ..._dynamicRequirements.map((e) => (e['label'] ?? e['name'] ?? e['required_project'] ?? e['product_service'] ?? e.values.first).toString()).toSet(),
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
                controller: _budgetController,
                labelText: 'Budget',
                hintText: 'Enter Budget',
                keyboardType: TextInputType.number,
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
                  ..._dynamicOccupations.map((e) => (e['label'] ?? e['name'] ?? e['occupation_name'] ?? e.values.first).toString()).toSet(),
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
    // Robustness: ensure value exists in items
    String effectiveValue = value;
    if (!items.contains(effectiveValue)) {
      effectiveValue = items.isNotEmpty ? items.first : value;
    }

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
          value: effectiveValue,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF26A69A)),
          dropdownColor: Colors.white,
          items: items.toSet().toList().map((String item) {
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
