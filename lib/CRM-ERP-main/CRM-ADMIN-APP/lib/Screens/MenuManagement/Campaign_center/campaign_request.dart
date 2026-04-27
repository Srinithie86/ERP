import 'package:flutter/material.dart';
import 'campaign_requests_store.dart';
import 'view_campaign.dart';

enum CampaignTab { newRequest, viewRequests }

class CampaignRequestScreen extends StatefulWidget {
  final CampaignTab initialTab;

  const CampaignRequestScreen({
    super.key,
    this.initialTab = CampaignTab.newRequest,
  });

  @override
  State<CampaignRequestScreen> createState() => _CampaignRequestScreenState();
}

class _CampaignRequestScreenState extends State<CampaignRequestScreen> {
  late CampaignTab _activeTab;
  late final TextEditingController _requestIdController;
  late final TextEditingController _requestDateController;
  final TextEditingController _requestedByController = TextEditingController();
  final TextEditingController _campaignNameController = TextEditingController();
  final TextEditingController _targetAudienceController = TextEditingController();
  final TextEditingController _targetLocationController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _expectedReachController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedCampaignType;
  String _priority = 'Normal';
  String _approvalStatus = 'Pending';
  String _campaignStatus = 'Requested';
  bool _creativeNeeded = false;

  final List<String> _departments = const ['Sales', 'Marketing', 'Operations', 'Support'];
  final List<String> _campaignTypes = const ['Email Campaign', 'SMS Campaign', 'Social Media', 'Promotional Offer'];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    final now = DateTime.now();
    _requestIdController = TextEditingController(text: _generateRequestId(now));
    _requestDateController = TextEditingController(text: _formatDate(now));
  }

  @override
  void dispose() {
    _requestIdController.dispose();
    _requestDateController.dispose();
    _requestedByController.dispose();
    _campaignNameController.dispose();
    _targetAudienceController.dispose();
    _targetLocationController.dispose();
    _purposeController.dispose();
    _messageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _expectedReachController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _activeTab == CampaignTab.newRequest ? 'Campaign Requests' : 'Campaign Requests',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTopToggleBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _activeTab == CampaignTab.newRequest
                  ? _buildNewRequestContent()
                  : ViewCampaignContent(
                      key: const ValueKey('view-requests'),
                      onSwitchToNewRequest: () {
                        setState(() => _activeTab = CampaignTab.newRequest);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopToggleBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
            border: const Border(bottom: BorderSide(color: Color(0xFFE8EDF6))),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTopActionChip(
                  label: 'New Request',
                  icon: Icons.add_rounded,
                  isActive: _activeTab == CampaignTab.newRequest,
                  onTap: () => setState(() => _activeTab = CampaignTab.newRequest),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTopActionChip(
                  label: 'View Requests',
                  icon: Icons.receipt_long_rounded,
                  isActive: _activeTab == CampaignTab.viewRequests,
                  onTap: () => setState(() => _activeTab = CampaignTab.viewRequests),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopActionChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF7181F8), Color(0xFF8D56B2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? Colors.transparent : const Color(0xFFD8E1EF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isActive ? Colors.white : const Color(0xFF5A6B86)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF334E73),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewRequestContent() {
    return SingleChildScrollView(
      key: const ValueKey('new-request'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 28),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _section(
              'Request Information',
              Column(
                children: [
                  _textField('Request ID', _requestIdController, readOnly: true, filled: true),
                  const SizedBox(height: 14),
                  _dateField('Request Date', _requestDateController),
                  const SizedBox(height: 14),
                  _textField('Requested By', _requestedByController, hintText: 'Enter your name'),
                  const SizedBox(height: 14),
                  _dropdownField('Department', _departments, _selectedDepartment, 'Select Department', (value) {
                    setState(() => _selectedDepartment = value);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _section(
              'Campaign Details',
              Column(
                children: [
                  _textField('Campaign Name', _campaignNameController, hintText: 'Enter campaign name'),
                  const SizedBox(height: 14),
                  _dropdownField('Campaign Type', _campaignTypes, _selectedCampaignType, 'Select Type', (value) {
                    setState(() => _selectedCampaignType = value);
                  }),
                  const SizedBox(height: 14),
                  _textField('Target Audience', _targetAudienceController, hintText: 'e.g., Age 25-45, Professionals'),
                  const SizedBox(height: 14),
                  _textField('Target Location', _targetLocationController, hintText: 'e.g., Mumbai, Delhi, Pan India'),
                  const SizedBox(height: 14),
                  _textField('Purpose of Campaign', _purposeController, hintText: 'Describe the campaign objective and goals', maxLines: 5),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _section(
              'Content Requirements',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textField('Message / Offer Details', _messageController, hintText: 'Provide the message content, offer details, or key points', maxLines: 5),
                  const SizedBox(height: 18),
                  _switchTile(),
                  const SizedBox(height: 18),
                  _uploadTile(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _section(
              'Schedule',
              Column(
                children: [
                  _dateField('Preferred Start Date', _startDateController, hintText: 'dd-mm-yyyy'),
                  const SizedBox(height: 14),
                  _dateField('Preferred End Date', _endDateController, hintText: 'dd-mm-yyyy'),
                  const SizedBox(height: 18),
                  _prioritySelector(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _section(
              'Expected Outcome',
              Column(
                children: [
                  _textField('Expected Leads / Reach', _expectedReachController, hintText: 'Enter estimated number', keyboardType: TextInputType.number),
                  const SizedBox(height: 14),
                  _textField('Notes / Special Instructions', _notesController, hintText: 'Any additional requirements or special instructions', maxLines: 4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _section(
              'Approval & Status',
              Column(
                children: [
                  _dropdownField('Approval Status', const ['Pending', 'Approved', 'Rejected'], _approvalStatus, null, (value) {
                    if (value != null) setState(() => _approvalStatus = value);
                  }),
                  const SizedBox(height: 14),
                  _dropdownField('Campaign Status', const ['Requested', 'In Progress', 'Completed'], _campaignStatus, null, (value) {
                    if (value != null) setState(() => _campaignStatus = value);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _actionButton('Submit Request', Icons.check_rounded, const Color(0xFF6477F2), _submitRequest)),
                const SizedBox(width: 12),
                Expanded(child: _actionButton('Reset', Icons.refresh_rounded, const Color(0xFFFF9B38), _resetForm)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: _actionButton('Cancel', Icons.close_rounded, const Color(0xFF7D8DA6), () => Navigator.pop(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF6477F2),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF5B72F2))),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE7ECF5)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, {String? hintText, int maxLines = 1, bool readOnly = false, bool filled = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: _inputDecoration(hintText: hintText, filled: filled),
        ),
      ],
    );
  }

  Widget _dateField(String label, TextEditingController controller, {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _pickDate(controller),
          decoration: _inputDecoration(
            hintText: hintText,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField(String label, List<String> items, String? value, String? hintText, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          decoration: _inputDecoration(hintText: hintText),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: hintText == null ? null : Text(hintText),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        ),
      ],
    );
  }

  Widget _switchTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE3F1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Creative Needed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF304A6E))),
                const SizedBox(height: 4),
                Text(_creativeNeeded ? 'Yes' : 'No', style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Switch(
            value: _creativeNeeded,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF6477F2),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD6DFEE),
            onChanged: (value) => setState(() => _creativeNeeded = value),
          ),
        ],
      ),
    );
  }

  Widget _uploadTile() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openUploadContent,
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: _DashedBorderPainter(color: const Color(0xFFCBD7EF), radius: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFF9FBFF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Upload Reference Files', requiredMark: false),
                const SizedBox(height: 8),
                Text(
                  'Tap to open upload content and add sample creatives, brief notes, or supporting documents',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cloud_upload_rounded, color: Color(0xFF516CE7)),
                      SizedBox(width: 12),
                      Expanded(child: Text('Choose files or open upload content', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334E73)))),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF8A99B5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _prioritySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE3F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Priority', requiredMark: false),
          const SizedBox(height: 8),
          RadioListTile<String>(
            value: 'Normal',
            groupValue: _priority,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF6477F2),
            title: const Text('Normal'),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
          ),
          RadioListTile<String>(
            value: 'Urgent',
            groupValue: _priority,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF6477F2),
            title: const Text('Urgent'),
            onChanged: (value) {
              if (value != null) setState(() => _priority = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color backgroundColor, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    );
  }

  Widget _label(String text, {bool requiredMark = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF334E73)),
        children: requiredMark ? const [TextSpan(text: ' *', style: TextStyle(color: Color(0xFFF26464)))] : const [],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon, bool filled = false}) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: filled ? const Color(0xFFF0F4FB) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: _border(),
      focusedBorder: _border(const Color(0xFF6477F2), 1.4),
      border: _border(),
    );
  }

  OutlineInputBorder _border([Color color = const Color(0xFFD8E1EF), double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate != null) controller.text = _formatDate(pickedDate);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  String _generateRequestId(DateTime date) {
    return 'DMC-${date.millisecondsSinceEpoch.toString().substring(5)}';
  }

  void _resetForm() {
    setState(() {
      _requestedByController.clear();
      _campaignNameController.clear();
      _targetAudienceController.clear();
      _targetLocationController.clear();
      _purposeController.clear();
      _messageController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _expectedReachController.clear();
      _notesController.clear();
      _selectedDepartment = null;
      _selectedCampaignType = null;
      _priority = 'Normal';
      _approvalStatus = 'Pending';
      _campaignStatus = 'Requested';
      _creativeNeeded = false;
      final now = DateTime.now();
      _requestDateController.text = _formatDate(now);
      _requestIdController.text = _generateRequestId(now);
    });
    _showMessage('Form reset');
  }

  void _submitRequest() {
    if (_requestedByController.text.trim().isEmpty ||
        _campaignNameController.text.trim().isEmpty ||
        _selectedDepartment == null ||
        _selectedCampaignType == null) {
      _showMessage('Fill the required fields before submitting');
      return;
    }

    CampaignRequestsStore.add({
      'requestId': _requestIdController.text.trim(),
      'requestDate': _requestDateController.text.trim(),
      'requestedBy': _requestedByController.text.trim(),
      'department': _selectedDepartment ?? '',
      'campaignName': _campaignNameController.text.trim(),
      'type': _selectedCampaignType ?? '',
      'targetAudience': _targetAudienceController.text.trim(),
      'targetLocation': _targetLocationController.text.trim(),
      'purpose': _purposeController.text.trim(),
      'message': _messageController.text.trim(),
      'startDate': _startDateController.text.trim(),
      'priority': _priority,
      'approvalStatus': _approvalStatus,
    });

    setState(() => _activeTab = CampaignTab.viewRequests);
    _showMessage('Request added for this instance');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openUploadContent() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E1EF),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Upload Content', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1D2B53))),
            const SizedBox(height: 8),
            Text('Add image references, campaign briefs, offer creatives, or supporting files here.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            _uploadOptionTile(Icons.image_outlined, 'Upload Image', 'Add posters, banners, or visual references'),
            const SizedBox(height: 12),
            _uploadOptionTile(Icons.description_outlined, 'Upload Document', 'Add brief notes or requirement files'),
          ],
        ),
      ),
    );
  }

  Widget _uploadOptionTile(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE3F1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF516CE7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF334E73))),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
