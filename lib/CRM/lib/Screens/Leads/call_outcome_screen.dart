import 'package:flutter/material.dart';
import '../../Models/follow_up_api.dart';

class CallOutcomeScreen extends StatefulWidget {
  final Map<String, dynamic> lead;
  const CallOutcomeScreen({super.key, required this.lead});

  @override
  State<CallOutcomeScreen> createState() => _CallOutcomeScreenState();
}

class _CallOutcomeScreenState extends State<CallOutcomeScreen> {
  final _nameCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _projectCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
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
    _nameCtrl.text =
        (widget.lead['le_name'] ?? widget.lead['cus_name'])?.toString() ?? '';
    _fetchDropdowns();
  }

  Future<void> _fetchDropdowns() async {
    try {
      final outcomesApi = await FollowUpApi.fetchCallOutcomes();
      List<dynamic> dynamicOutcomes = outcomesApi.map((e) => {'name': e['label'].toString(), 'value': e['value'].toString()}).toList();

      final statusesApi = await FollowUpApi.fetchLeadStatuses();
      List<dynamic> dynamicStatuses = statusesApi.map((e) => {'name': e['label'].toString(), 'value': e['value'].toString()}).toList();

      final modesApi = await FollowUpApi.fetchFollowUpModes();
      List<dynamic> dynamicModes = modesApi.map((e) => {'name': e['label'].toString(), 'value': e['value'].toString()}).toList();

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Lead',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
                _field(_locationCtrl),
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
                  onPressed: () => Navigator.pop(context),
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Lead',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
                _label('Attended by'),
                _field(_attendedByCtrl),
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
                  onPressed: () => Navigator.pop(context),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Lead',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
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
              ignoring: _outcome != 'Connected',
              child: Opacity(
                opacity: _outcome == 'Connected' ? 1.0 : 0.5,
                child: _dropdown('Select Follow-up Mode', _modes, _mode, (v) {
                  setState(() => _mode = v);
                  if (v == 'Direct Meeting') {
                    _showMeetingDetailsPopup();
                  } else if (v == 'Virtual Meeting') {
                    _showVirtualMeetingDetailsPopup();
                  }
                }),
              ),
            ),
            IgnorePointer(
              ignoring: _outcome != 'Connected',
              child: Opacity(
                opacity: _outcome == 'Connected' ? 1.0 : 0.5,
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
                    _field(_projectCtrl),
                    _label('Other Required'),
                    _field(_otherCtrl),
                    _label('Call Summary'),
                    _field(_summaryCtrl),
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
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: val,
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF26A69A)),
        hint: Text(
          hint,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        isExpanded: true,
        items: its
            .map(
              (e) => DropdownMenuItem(
                value: e['name'].toString(),
                child: Text(e['name'].toString()),
              ),
            )
            .toList(),
        onChanged: oC,
      ),
    ),
  );

  Future<void> _save() async {
    if (_outcome == 'Connected' &&
        (_mode == null || _date == null || _time == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      String getDropdownValue(List<dynamic> list, String? selectedName) {
        if (selectedName == null || selectedName.isEmpty) return '';
        try {
          return list.firstWhere((e) => e['name'] == selectedName, orElse: () => {'value': ''})['value'].toString();
        } catch (_) {
          return '';
        }
      }

      final res = await FollowUpApi.submitCallOutcome({
        'uid': widget.lead['id']?.toString() ?? '',
        'cus_name': (widget.lead['le_name'] ?? widget.lead['cus_name'])?.toString() ?? '',
        'Call_Outcome': getDropdownValue(_outcomes, _outcome),
        'Follow_Up_Mode': getDropdownValue(_modes, _mode),
        'Required_Project': _projectCtrl.text,
        'Other_Required': _otherCtrl.text,
        'Customer_Budget': _budgetCtrl.text,
        'Next_Follow_Up_Date': _date != null ? _date!.toString().split(' ')[0] : '',
        'Next_Follow_Up_Time': _time != null ? _time!.format(context) : '',
        'Call_Summary': _summaryCtrl.text,
        'Lead_Status': getDropdownValue(_statuses, _status),
      });

      if (mounted && res['error'].toString() == 'false') {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully')));
      } else if (mounted) {
        String msg = res['message'] ?? 'Failed to save';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint("Error saving follow-up: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
