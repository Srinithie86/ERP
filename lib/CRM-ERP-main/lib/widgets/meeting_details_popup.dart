import 'package:erp_smart/CRM-ERP-main/lib/Services/preference_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Models/meeting_api.dart';
import '../Models/follow_up_api.dart';
import '../Services/lead_service.dart';

class MeetingDetailsPopup extends StatefulWidget {
  final Map<String, dynamic> lead;
  final String enquiryType; // Lead, Enquiry, Referral

  const MeetingDetailsPopup({
    super.key,
    required this.lead,
    required this.enquiryType,
  });

  @override
  State<MeetingDetailsPopup> createState() => _MeetingDetailsPopupState();
}

class _MeetingDetailsPopupState extends State<MeetingDetailsPopup> {
  final Color tealColor = const Color(0xFF26A69A);

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _mobile1Controller;
  late TextEditingController _mobile2Controller;
  late TextEditingController _attendedByController;
  late TextEditingController _productController;
  late TextEditingController _otherRequiredController;
  late TextEditingController _addressController;
  late TextEditingController _summaryController;

  String? _selectedMode;
  String? _selectedLocation;
  String? _selectedStatus;

  List<dynamic> _modes = [];
  List<dynamic> _locations = [];
  List<dynamic> _statuses = [];

  bool _isLoadingDropdowns = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController = TextEditingController(text: "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}");
    _timeController = TextEditingController(text: "");
    _nameController = TextEditingController(text: (widget.lead['cus_name'] ?? widget.lead['le_name'] ?? widget.lead['contact_person'] ?? '').toString());
    _typeController = TextEditingController(text: widget.enquiryType);
    _mobile1Controller = TextEditingController(text: (widget.lead['mobile_1'] ?? widget.lead['mobile'] ?? '').toString());
    _mobile2Controller = TextEditingController(text: (widget.lead['mobile_2'] ?? '').toString());
    _attendedByController = TextEditingController(text: 'Auto-filled');
    _productController = TextEditingController(text: (widget.lead['required_project'] ?? widget.lead['project'] ?? '').toString());
    _otherRequiredController = TextEditingController();
    _addressController = TextEditingController(text: (widget.lead['address'] ?? '').toString());
    _summaryController = TextEditingController();

    _loadDropdowns();
  }

  Future<void> _loadDropdowns() async {
    try {
      final modesApi = await FollowUpApi.fetchFollowUpModes();
      final statusesApi = await FollowUpApi.fetchLeadStatuses();
      final locationsApi = await LeadService.fetchDropdownData(
        type: '2083',
        form: 'sm_main_form_18021',
        select: 'id,name',
      );

      if (mounted) {
        setState(() {
          _modes = modesApi.map((e) => {'name': e['label'].toString(), 'value': e['value'].toString()}).toList();
          _statuses = statusesApi.map((e) => {'name': e['label'].toString(), 'value': e['value'].toString()}).toList();
          _locations = locationsApi.map((e) => {'name': e['name'].toString(), 'value': e['id'].toString()}).toList();
          _isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDropdowns = false);
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _mobile1Controller.dispose();
    _mobile2Controller.dispose();
    _attendedByController.dispose();
    _productController.dispose();
    _otherRequiredController.dispose();
    _addressController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveMeeting() async {
    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Date and Time')));
      return;
    }
    if (_selectedMode == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Mode of Meeting')));
      return;
    }

    setState(() => _isSaving = true);
    try {
        final uid = await PreferenceService.getUid();
      final Map<String, String> data = {
        'date': _dateController.text,
        'time': _timeController.text,
        'mode_of_meet': _modes.firstWhere((e) => e['value'] == _selectedMode)['name'].toString(),
        'location': _selectedLocation != null ? _locations.firstWhere((e) => e['value'] == _selectedLocation)['name'].toString() : '',
        'other_required': _otherRequiredController.text,
        'address': _addressController.text,
        'status': _selectedStatus != null ? _statuses.firstWhere((e) => e['value'] == _selectedStatus)['name'].toString() :"",
        'feedback': _summaryController.text,
        'aid': (widget.lead['id'] ?? widget.lead['uid'] ?? '').toString(),
        //'required_project': _productController.text,
        'enquiry_type': widget.enquiryType.toString(),
        'attended_by': uid ?? "",
        'name': _nameController.text,
        'mobile_1': _mobile1Controller.text,
        'mobile_2': _mobile2Controller.text,
        'summary': _summaryController.text, 
        'uid':uid ?? "",
        'le_code':widget.lead['le_code']?.toString() ?? "",
        'cus_status':"Meeting",
        
        
        
      };

      final response = await MeetingApi.submitMeetingDetails(data, form: 'sm_main_form_21005');
      if (response['error'].toString() == 'false') {
       
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meeting details saved successfully ✅')));
        }
      } else {
        final errMsg = response['message'] ?? response['error_msg'] ?? 'Failed to save meeting';
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $errMsg')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600.w,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: tealColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Meeting Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Meeting Date', isRequired: true),
                              GestureDetector(
                                onTap: _selectDate,
                                child: _iconField(_dateController.text, Icons.calendar_month_outlined),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Meeting Time', isRequired: true),
                              GestureDetector(
                                onTap: _selectTime,
                                child: _iconField(_timeController.text.isEmpty ? '-- : --' : _timeController.text, Icons.access_time),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Customer Name'),
                              _field(_nameController, readOnly: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Type'),
                              _field(_typeController, readOnly: true),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Mobile 1'),
                              _field(_mobile1Controller, readOnly: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Mobile 2'),
                              _field(_mobile2Controller, readOnly: true),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Attended By'),
                              _field(_attendedByController, readOnly: true),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Mode of Meeting', isRequired: true),
                              _dropdown('Select Mode', _modes, _selectedMode, (v) => setState(() => _selectedMode = v)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Location'),
                              _dropdown('Select Location', _locations, _selectedLocation, (v) => setState(() => _selectedLocation = v)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Product Required'),
                              _field(_productController, readOnly: true),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Other Required'),
                              _field(_otherRequiredController, hint: 'Enter requirements'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Address'),
                              _field(_addressController, maxLines: 3, hint: 'Enter Address'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Status'),
                              _dropdown('Select Status', _statuses, _selectedStatus, (v) => setState(() => _selectedStatus = v)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Summary'),
                              _field(_summaryController, maxLines: 3, hint: 'Enter Summary'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveMeeting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save Meeting', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t, {bool isRequired = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 16),
        child: RichText(
          text: TextSpan(
            text: t,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            children: isRequired
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
      );

  Widget _field(TextEditingController c, {bool readOnly = false, int maxLines = 1, String? hint}) => Container(
        decoration: BoxDecoration(
          color: readOnly ? Colors.grey.shade100 : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: c,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ),
      );

  Widget _iconField(String t, IconData i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                t,
                style: TextStyle(fontSize: 15, color: t.isEmpty ? Colors.grey.shade400 : Colors.black),
              ),
            ),
            Icon(i, color: tealColor, size: 20),
          ],
        ),
      );

  Widget _dropdown(String hint, List<dynamic> items, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          value: value,
          items: items.map((e) {
            return DropdownMenuItem<String>(
              value: e['value'].toString(),
              child: Text(e['name'].toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
