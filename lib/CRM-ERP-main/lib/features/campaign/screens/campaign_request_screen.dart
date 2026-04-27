import 'package:flutter/material.dart';
import 'package:crm/core/theme/app_theme.dart';

class CampaignRequestScreen extends StatefulWidget {
  const CampaignRequestScreen({super.key});

  @override
  State<CampaignRequestScreen> createState() => _CampaignRequestScreenState();
}

class _CampaignRequestScreenState extends State<CampaignRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isCreativeNeeded = false;
  String _priority = 'Normal';

  // Form Controllers
  final _reqIdController = TextEditingController(text: 'DMC-95659766-620');
  final _reqDateController = TextEditingController(text: '04-04-2026');
  final _reqByController = TextEditingController();
  final _departmentController = TextEditingController(); // Used for dropdown state
  
  final _campaignNameController = TextEditingController();
  final _campaignTypeController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  final _targetLocationController = TextEditingController();
  final _purposeController = TextEditingController();
  
  final _messageController = TextEditingController();
  
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  
  final _expectedLeadsController = TextEditingController();
  final _notesController = TextEditingController();

  final _approvalStatusController = TextEditingController(text: 'Pending');
  final _campaignStatusController = TextEditingController(text: 'Requested');

  @override
  void dispose() {
    // Dispose controllers
    _reqIdController.dispose();
    _reqDateController.dispose();
    _reqByController.dispose();
    _departmentController.dispose();
    _campaignNameController.dispose();
    _campaignTypeController.dispose();
    _targetAudienceController.dispose();
    _targetLocationController.dispose();
    _purposeController.dispose();
    _messageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _expectedLeadsController.dispose();
    _notesController.dispose();
    _approvalStatusController.dispose();
    _campaignStatusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Request Information',
                children: [
                  _buildReadOnlyField('Request ID *', _reqIdController),
                  const SizedBox(height: 16),
                  _buildDateField('Request Date *', _reqDateController),
                  const SizedBox(height: 16),
                  _buildTextField('Requested By *', 'Enter your name', _reqByController),
                  const SizedBox(height: 16),
                  _buildDropdownField('Department *', 'Select Department', ['Marketing', 'Sales', 'IT', 'HR'], _departmentController),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Campaign Details',
                children: [
                  _buildTextField('Campaign Name *', 'Enter campaign name', _campaignNameController),
                  const SizedBox(height: 16),
                  _buildDropdownField('Campaign Type *', 'Select Type', ['Email', 'Social Media', 'SEO', 'PPC', 'Other'], _campaignTypeController),
                  const SizedBox(height: 16),
                  _buildTextField('Target Audience *', 'e.g., Age 25-45, Professionals', _targetAudienceController),
                  const SizedBox(height: 16),
                  _buildTextField('Target Location', 'e.g., Mumbai, Delhi, Pan India', _targetLocationController),
                  const SizedBox(height: 16),
                  _buildTextArea('Purpose of Campaign *', 'Describe the campaign objective and goals', _purposeController),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Content Requirements',
                children: [
                  _buildTextArea('Message / Offer Details *', 'Provide the message content, offer details, or key points', _messageController),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Creative Needed'),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(_isCreativeNeeded ? 'Yes' : 'No', style: const TextStyle(fontWeight: FontWeight.w500)),
                              value: _isCreativeNeeded,
                              activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.5),
                              activeThumbColor: AppTheme.primaryTeal,
                              onChanged: (bool value) {
                                setState(() {
                                  _isCreativeNeeded = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Upload Reference Files'),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.5), style: BorderStyle.solid), // Changed from dashed to solid as flutter core doesn't have dashed
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Choose Files', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(child: Text('No file chosen', style: TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Schedule',
                children: [
                  _buildDateField('Preferred Start Date *', _startDateController, hint: 'dd-mm-yyyy'),
                  const SizedBox(height: 16),
                  _buildDateField('Preferred End Date *', _endDateController, hint: 'dd-mm-yyyy'),
                  const SizedBox(height: 16),
                  _buildLabel('Priority'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Normal',
                        groupValue: _priority,
                        activeColor: AppTheme.primaryTeal,
                        onChanged: (String? value) {
                          setState(() { _priority = value!; });
                        },
                      ),
                      const Text('Normal', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 24),
                      Radio<String>(
                        value: 'Urgent',
                        groupValue: _priority,
                        activeColor: AppTheme.primaryTeal,
                        onChanged: (String? value) {
                          setState(() { _priority = value!; });
                        },
                      ),
                      const Text('Urgent', style: TextStyle(fontSize: 15)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Expected Outcome',
                children: [
                  _buildTextField('Expected Leads / Reach', 'Enter estimated number', _expectedLeadsController),
                  const SizedBox(height: 16),
                  _buildTextArea('Notes / Special Instructions', 'Any additional requirements or special instructions', _notesController),
                ],
              ),
              const SizedBox(height: 16),
              _buildSection(
                title: 'Approval & Status',
                children: [
                  _buildDropdownField('Approval Status', 'Pending', ['Pending', 'Approved', 'Rejected'], _approvalStatusController),
                  const SizedBox(height: 16),
                  _buildDropdownField('Campaign Status', 'Requested', ['Requested', 'In Progress', 'Completed'], _campaignStatusController),
                ],
              ),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                     Icon(Icons.dashboard_customize, color: AppTheme.primaryTeal),
                    const SizedBox(width: 12),
                    Text(
                      'Campaign Management',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                    ),
                  ],
                ),
                Icon(Icons.more_vert, color: Colors.grey[600]), // Options icon instead of buttons to keep UI clean
              ],
            ),
            const Divider(height: 32),
            Icon(Icons.campaign, size: 40, color: AppTheme.primaryDark),
            const SizedBox(height: 12),
            Text(
              'Digital Marketing Campaign Request Form',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit your campaign requirements for review and approval',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                ),
              ],
            ),
            const Divider(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text.replaceAll(' *', ''),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
        children: text.contains('*')
            ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: _inputDecoration('').copyWith(
            fillColor: Colors.grey.shade100,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.primaryTeal, 
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              String formattedDate = "\${pickedDate.day.toString().padLeft(2,'0')}-\${pickedDate.month.toString().padLeft(2,'0')}-\${pickedDate.year}";
              setState(() {
                controller.text = formattedDate;
              });
            }
          },
          decoration: _inputDecoration(hint ?? 'Select date').copyWith(
            suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: _inputDecoration(hint),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          initialValue: controller.text.isNotEmpty && items.contains(controller.text) ? controller.text : null,
          hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              if (newValue != null) controller.text = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextArea(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: _inputDecoration(hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check),
          label: const Text('Submit Request'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal, // App theme color usage
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close, size: 20),
                label: const Text('Cancel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
