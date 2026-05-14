import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/lead_service.dart';
import '../../Services/preference_service.dart';
import '../../Models/follow_up_api.dart';
import '../../Models/meeting_api.dart';

class CallOutcomeScreen extends StatefulWidget {
  final Map<String, dynamic> lead;
  final bool autoCall; // Trigger dialer on open?
  final String? selectedPhone; // Specific number to call
  const CallOutcomeScreen({
    super.key,
    required this.lead,
    this.autoCall = false,
    this.selectedPhone,
  });

  @override
  State<CallOutcomeScreen> createState() => _CallOutcomeScreenState();
}

class _CallOutcomeScreenState extends State<CallOutcomeScreen> {
  final _nameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final TextEditingController _projectCtrl = TextEditingController();
  final TextEditingController _otherCtrl = TextEditingController();
  final TextEditingController _summaryCtrl = TextEditingController();
  List<dynamic> _locations = [];
  String? _selectedLocation;
  final _locationCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _attendedByCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String? _outcome, _mode, _status, _virtualMode;
  DateTime? _date;
  TimeOfDay? _time;

  List<dynamic> _outcomes = [], _modes = [], _statuses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill Customer Name from lead data
    _nameCtrl.text =
        (widget.lead['le_name'] ?? widget.lead['cus_name'])?.toString() ?? '';
    // Auto-fill Required Project from lead data
    _projectCtrl.text = (widget.lead['required_project'] ??
            widget.lead['required_project_name'] ??
            widget.lead['product_service'] ??
            widget.lead['project'] ??
            '')
        .toString();
    _fetchDropdowns();
    _fetchLocations();

    if (widget.autoCall) {
      _launchDialer();
    }
  }

  Future<void> _launchDialer() async {
    final String phone = widget.selectedPhone ??
        (widget.lead['mobile_1'] ??
                widget.lead['mobile_2'] ??
                widget.lead['mobile'] ??
                widget.lead['phone'] ??
                widget.lead['mobile_no'] ??
                widget.lead['cus_mobile'] ??
                widget.lead['contact_no'] ??
                '')
            .toString();
    if (phone.isNotEmpty && phone != 'null') {
      final Uri launchUri =
          Uri.parse('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}');
      try {
        // Direct launch is often more reliable for system dialers than canLaunchUrl
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint("Error launching dialer: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open dialer for $phone')),
          );
        }
      }
    }
  }

  Future<void> _fetchDropdowns() async {
    try {
      final outcomesApi = await FollowUpApi.fetchCallOutcomes();
      List<dynamic> dynamicOutcomes = outcomesApi
          .map((e) =>
              {'name': e['label'].toString(), 'value': e['value'].toString()})
          .toList();

      final statusesApi = await FollowUpApi.fetchLeadStatuses();
      List<dynamic> dynamicStatuses = statusesApi
          .map((e) =>
              {'name': e['label'].toString(), 'value': e['value'].toString()})
          .toList();

      final modesApi = await FollowUpApi.fetchFollowUpModes();
      List<dynamic> dynamicModes = modesApi
          .map((e) =>
              {'name': e['label'].toString(), 'value': e['value'].toString()})
          .toList();

      if (mounted) {
        setState(() {
          _outcomes = dynamicOutcomes;
          _modes = dynamicModes;
          _statuses = dynamicStatuses;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dropdowns: $e");
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final data = await LeadService.fetchDropdownData(
        type: '2083',
        form: 'sm_main_form_18021',
        select: 'id,name',
      );
      if (mounted) {
        setState(() {
          _locations = data
              .map((e) => {
                    'name': e['name'].toString(),
                    'value': e['id'].toString(), // Use ID as the value
                    'id': e['id'].toString(),
                  })
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching locations: $e");
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _time = t);
  }

  void _showMeetingDetailsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (context, setPopupState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Direct meeting details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                _label('Customer Name'),
                _field(_nameCtrl, readOnly: true),
                _label('Mobile 1'),
                _field(
                  TextEditingController(
                    text: widget.lead['mobile_1']?.toString() ?? '',
                  ),
                  readOnly: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Meeting Date *', isRequired: true),
                          GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _date ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (d != null) {
                                setPopupState(() => _date = d);
                                setState(() => _date = d);
                              }
                            },
                            child: _iconField(
                              _date == null
                                  ? ''
                                  : _date!.toString().split(' ')[0],
                              Icons.calendar_month_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Meeting Time *', isRequired: true),
                          GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: _time ?? TimeOfDay.now(),
                              );
                              if (t != null) {
                                setPopupState(() => _time = t);
                                setState(() => _time = t);
                              }
                            },
                            child: _iconField(
                              _time == null ? '' : _time!.format(context),
                              Icons.access_time,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _label('Location'),
                _dropdown(
                  'Select Location',
                  _locations,
                  _selectedLocation,
                  (v) {
                    setPopupState(() => _selectedLocation = v);
                    setState(() => _selectedLocation = v);
                    _locationCtrl.text = v ?? '';
                  },
                ),
                _label('Address'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _addressCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (_date == null || _time == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Date and time are required')));
                      return;
                    }
                    // Capture context-dependent values BEFORE any await
                    final String timeStr = _time!.format(context);
                    final BuildContext popupCtx = context;

                    final uid = await PreferenceService.getUid();
                    final cid = await PreferenceService.getCid();
                    final token = await PreferenceService.getToken();
                    final String leadId = widget.lead['id']?.toString() ??
                        widget.lead['uid']?.toString() ??
                        '';
                    final String eTypeId =
                        (widget.lead['enquiry_type'] ?? '1').toString();
                    final String enquiryType = eTypeId == '1'
                        ? 'Lead'
                        : (eTypeId == '2' ? 'Enquiry' : 'Referral');

                    // DEBUG: verify values before sending
                    debugPrint(
                        '>>> DIRECT MEETING leadId=$leadId, enquiryType=$enquiryType');
                    debugPrint(
                        '>>> widget.lead[id]=${widget.lead['id']}, widget.lead[enquiry_type]=${widget.lead['enquiry_type']}');

                    final Map<String, String> meetFormData = {
                      'uid': uid ?? '',
                      'cid': cid,
                      'aid': leadId, // link to lead
                      // NOTE: enquiry_type NOT sent — sm_main_form_21003 has no such column
                      'cus_name': _nameCtrl.text,
                      'mobile_1': (widget.lead['mobile_1'] ?? '').toString(),
                      'meet_date':
                          '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
                      'time': timeStr,
                      'loc': _selectedLocation ?? '',
                      'address': _addressCtrl.text,
                      'enquiry_type': enquiryType,

                      'le_code': (widget.lead['le_code'] ??
                              widget.lead['lead_code'] ??
                              widget.lead['le_no'] ??
                              widget.lead['le_no_'] ??
                              widget.lead['led_no'] ??
                              widget.lead['enquiry_no'] ??
                              widget.lead['id'] ??
                              '')
                          .toString(),
                      'mode_of_meet': 'Direct Meeting',
                      if (token != null) 'token': token,
                    };
                    debugPrint('>>> meetFormData: $meetFormData');

                    final meetRes =
                        await MeetingApi.submitMeetingDetails(meetFormData);
                    debugPrint('Meeting save result: $meetRes');

                    if (!mounted) return;
                    if (meetRes['error'].toString() == 'false') {
                      Navigator.pop(popupCtx);
                      if (mounted) Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Meeting saved successfully ✅')),
                      );
                    } else {
                      final errMsg = meetRes['message'] ??
                          meetRes['error_msg'] ??
                          'Failed to save meeting';
                      ScaffoldMessenger.of(popupCtx).showSnackBar(
                        SnackBar(content: Text('❌ $errMsg')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showVirtualMeetingDetailsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => StatefulBuilder(
        builder: (context, setPopupState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Virtual meeting details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                _label('Mobile 1'),
                _field(
                  TextEditingController(
                    text: widget.lead['mobile_1']?.toString() ?? '',
                  ),
                  readOnly: true,
                ),
                _label('Mode of meeting'),
                _dropdown(
                  'Select mode of meeting',
                  const [
                    {'name': 'Zoom'},
                    {'name': 'Microsoft Teams'},
                    {'name': 'Google Meet'},
                    {'name': 'Ulter viewer'},
                  ],
                  _virtualMode,
                  (v) => setPopupState(() => _virtualMode = v),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Meeting Date *', isRequired: true),
                          GestureDetector(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _date ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (d != null) {
                                setPopupState(() => _date = d);
                                setState(() => _date = d);
                              }
                            },
                            child: _iconField(
                              _date == null
                                  ? ''
                                  : _date!.toString().split(' ')[0],
                              Icons.calendar_month_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Meeting Time *', isRequired: true),
                          GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(
                                context: context,
                                initialTime: _time ?? TimeOfDay.now(),
                              );
                              if (t != null) {
                                setPopupState(() => _time = t);
                                setState(() => _time = t);
                              }
                            },
                            child: _iconField(
                              _time == null ? '' : _time!.format(context),
                              Icons.access_time,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _label('Description'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Description',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (_date == null ||
                        _time == null ||
                        _virtualMode == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('All fields are required')));
                      return;
                    }
                    // Capture context-dependent values BEFORE any await
                    final String timeStr = _time!.format(context);
                    final String modeStr = _virtualMode ?? '';
                    final BuildContext popupCtx = context;

                    final uid = await PreferenceService.getUid();
                    final cid = await PreferenceService.getCid();
                    final token = await PreferenceService.getToken();
                    final String leadId = widget.lead['id']?.toString() ??
                        widget.lead['uid']?.toString() ??
                        '';
                    final String eTypeId =
                        (widget.lead['enquiry_type'] ?? '1').toString();
                    final String enquiryType = eTypeId == '1'
                        ? 'Lead'
                        : (eTypeId == '2' ? 'Enquiry' : 'Referral');

                    // DEBUG: verify values before sending
                    debugPrint(
                        '>>> VIRTUAL MEETING leadId=$leadId, enquiryType=$enquiryType');
                    debugPrint(
                        '>>> widget.lead[id]=${widget.lead['id']}, widget.lead[enquiry_type]=${widget.lead['enquiry_type']}');

                    final Map<String, String> meetFormData = {
                      'uid': uid ?? '',
                      'cid': cid,
                      'aid': leadId, // link to lead
                      // NOTE: enquiry_type NOT sent — sm_main_form_21003 has no such column
                      'cus_name': _nameCtrl.text,
                      'mobile_1': (widget.lead['mobile_1'] ?? '').toString(),
                      'meet_date':
                          '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
                      'time': timeStr,
                      'attended_by': uid ?? '',
                      'enquiry_type': enquiryType,
                      'le_code': (widget.lead['le_code'] ??
                              widget.lead['lead_code'] ??
                              widget.lead['le_no'] ??
                              widget.lead['le_no_'] ??
                              widget.lead['led_no'] ??
                              widget.lead['enquiry_no'] ??
                              widget.lead['id'] ??
                              '')
                          .toString(),
                      'mode_of_meet': modeStr,
                      if (token != null) 'token': token,
                    };
                    debugPrint('>>> meetFormData: $meetFormData');

                    final meetRes =
                        await MeetingApi.submitMeetingDetails(meetFormData);
                    debugPrint('Virtual meeting save result: $meetRes');

                    if (!mounted) return;
                    if (meetRes['error'].toString() == 'false') {
                      Navigator.pop(popupCtx);
                      if (mounted) Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Virtual meeting saved successfully ✅')),
                      );
                    } else {
                      final errMsg = meetRes['message'] ??
                          meetRes['error_msg'] ??
                          'Failed to save meeting';
                      ScaffoldMessenger.of(popupCtx).showSnackBar(
                        SnackBar(content: Text('❌ $errMsg')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26A69A),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String selectedOutcomeName = _outcomes
        .firstWhere((e) => e['value'].toString() == _outcome,
            orElse: () => {'name': ''})['name']
        .toString();
    final bool isConnected = selectedOutcomeName == 'Connected';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        title: const Text(
          'Call end details',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _label('Customer Name'),
            _field(_nameCtrl, readOnly: true),
            _label('Select Call outcome'),
            _dropdown(
              'Select Outcome',
              _outcomes,
              _outcome,
              (v) => setState(() {
                _outcome = v;
                // Reset mode if outcome is not connected
                if (v != 'Connected') {
                  _mode = null;
                }
              }),
            ),
            _label('Follow-Up Mode *', isRequired: true),
            IgnorePointer(
              ignoring: !isConnected,
              child: Opacity(
                opacity: isConnected ? 1.0 : 0.5,
                child: _dropdown('Select Follow-up Mode', _modes, _mode, (v) {
                  setState(() => _mode = v);
                  final selectedMode = _modes
                      .firstWhere((e) => e['value'].toString() == v,
                          orElse: () => {'name': ''})['name']
                      .toString();
                  if (selectedMode == 'Direct Meeting') {
                    _showMeetingDetailsPopup();
                  } else if (selectedMode == 'Virtual Meeting') {
                    _showVirtualMeetingDetailsPopup();
                  }
                }),
              ),
            ),
            _label('Call Summary'),
            _field(_summaryCtrl),
            IgnorePointer(
              ignoring: !isConnected,
              child: Opacity(
                opacity: isConnected ? 1.0 : 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Follow-up Date *', isRequired: true),
                              GestureDetector(
                                onTap: _pickDate,
                                child: _iconField(
                                  _date == null
                                      ? ''
                                      : _date!.toString().split(' ')[0],
                                  Icons.calendar_month_outlined,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Follow-up Time *', isRequired: true),
                              GestureDetector(
                                onTap: _pickTime,
                                child: _iconField(
                                  _time == null ? '' : _time!.format(context),
                                  Icons.access_time,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _label('Budget'),
                    _field(_budgetCtrl),
                    _label('Required Project'),
                    _field(_projectCtrl,
                        readOnly: _projectCtrl.text.isNotEmpty),
                    _label('Other Required'),
                    _field(_otherCtrl),
                    _label('Select lead status'),
                    _dropdown(
                      'Select lead status',
                      _statuses,
                      _status,
                      (v) => setState(() => _status = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26A69A),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
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

  Widget _field(TextEditingController c, {bool readOnly = false}) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: c,
          readOnly: readOnly,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      );

  Widget _iconField(String t, IconData i) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(i, size: 20, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(t, style: const TextStyle(fontSize: 14)),
          ],
        ),
      );

  Widget _dropdown(
    String hint,
    List<dynamic> its,
    String? val,
    ValueChanged<String?> oC,
  ) {
    // Robust validation: Ensure the current value exists in the list to prevent crashes
    String? effectiveValue = val;
    if (effectiveValue != null) {
      bool exists = its
          .any((e) => (e['value'] ?? e['name']).toString() == effectiveValue);
      if (!exists) effectiveValue = null;
    }

    // Deduplicate items to prevent "duplicate value" crash
    final seen = <String>{};
    final uniqueItems = its.where((e) {
      final val = (e['value'] ?? e['name']).toString();
      if (seen.contains(val)) return false;
      seen.add(val);
      return true;
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF26A69A)),
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          isExpanded: true,
          items: uniqueItems
              .map(
                (e) => DropdownMenuItem(
                  value: (e['value'] ?? e['name']).toString(),
                  child: Text(e['name'].toString()),
                ),
              )
              .toList(),
          onChanged: oC,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_outcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a call outcome')),
      );
      return;
    }

    final selectedOutcomeName = _outcomes
        .firstWhere((e) => e['value'].toString() == _outcome,
            orElse: () => {'name': ''})['name']
        .toString();

    // If Connected, require Follow-up details
    if (selectedOutcomeName == 'Connected') {
      if (_mode == null || _date == null || _time == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all follow-up details')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final String uid = await PreferenceService.getUid() ?? '';
      final String leCode = (widget.lead['le_code'] ??
              widget.lead['lead_code'] ??
              widget.lead['le_no'] ??
              widget.lead['le_no_'] ??
              widget.lead['led_no'] ??
              widget.lead['enquiry_no'] ??
              widget.lead['id'] ??
              '')
          .toString();

      final Map<String, String> data = {
        'uid': uid,
        'cus_name': _nameCtrl.text,
        'call_outcome': _outcome!,
        'le_code': leCode,
        'call_summary': _summaryCtrl.text,
        'enquiry_type': (widget.lead['enquiry_type'] ?? '1').toString(),
        'call_by': uid,
        'cus_status': 'follow_up',
        'aid': (widget.lead['id'] ?? widget.lead['aid'] ?? '').toString(),
        'mobile_1': (widget.lead['mobile_1'] ?? '').toString(),
        'moble_2': (widget.lead['moble_2'] ?? '').toString(),
      };

      if (selectedOutcomeName == 'Connected') {
        data['follow_up_mode'] = _mode!;
        data['next_follow_up_date'] =
            '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}';
        data['next_follow_up_time'] = _time!.format(context);
        data['customer_budget'] = _budgetCtrl.text;
        data['required_project'] = _projectCtrl.text;
        data['other_required'] = _otherCtrl.text;
        data['lead_status'] = _status ?? '';
      }

      final response = await FollowUpApi.followupInsert(data);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Call outcome saved successfully ✅')),
          );
          Navigator.pop(context, true);
        } else {
          final msg = response['message'] ??
              response['error_msg'] ??
              'Error saving details';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ $msg')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving call outcome: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Connection error')),
        );
      }
    }
  }
}
