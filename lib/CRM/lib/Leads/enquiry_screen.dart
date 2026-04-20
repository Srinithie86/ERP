import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../services/lead_service.dart';
import '../services/profile_service.dart';
import '../Models/enquiry_api.dart';
import '../Follows/enquiry_details_screen.dart';
import '../SignIn/splash.dart';
import '../utils/preference_service.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'New',
    'Follow up',
    'Meeting',
    'Negotiation',
  ];
  bool _isLoading = false;
  List<dynamic> _allEnquiries = [];
  List<dynamic> _allFollowUps = [];
  String _employeeName = '';

  List<dynamic> get _filteredEnquiries {
    if (_selectedFilter == 'All') return _allEnquiries;
    if (_selectedFilter == 'Follow up') return _allFollowUps;
    
    if (_selectedFilter == 'New') {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return _allEnquiries.where((e) {
        String status = (e['lead_status'] ?? e['status'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (status == 'follow up' ||
            status == 'interested' ||
            status == 'negotiation' ||
            status == 'meeting') {
          return false;
        }
        final date =
            e['enquiry_date']?.toString() ?? e['entry_date']?.toString() ?? '';
        return date.startsWith(todayStr);
      }).toList();
    }

    return _allEnquiries.where((e) {
      String status = (e['lead_status'] ?? e['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      if (_selectedFilter == 'Meeting') {
        return status.contains('meeting');
      }
      if (_selectedFilter == 'Negotiation') {
        return status.contains('negotiation');
      }
      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
    _fetchProfileName();
  }

  Future<void> _refreshData() async {
    if (_selectedFilter == 'Follow up') {
      await _fetchFollowUps();
    } else {
      await _fetchEnquiries();
    }
  }

  Future<void> _fetchFollowUps() async {
    setState(() => _isLoading = true);
    try {
      final followUps = await LeadService.fetchFollowUpHistoryAll();
      if (mounted) {
        setState(() {
          _allFollowUps = followUps;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching follow-ups: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchProfileName() async {
    final profileData = await ProfileService.fetchProfileData();
    if (mounted && profileData != null) {
      setState(() {
        _employeeName = profileData['name'] ?? 'N/A';
      });
    }
  }

  Future<void> _fetchEnquiries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final enquiries = await EnquiryApi.fetchEnquiries();
      if (mounted) {
        setState(() {
          _allEnquiries = enquiries;
        });
      }
    } catch (e) {
      debugPrint("Error fetching enquiries: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch dialer')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showCallConfirmation(Map<String, dynamic> enquiry) {
    final String name =
        (enquiry['le_name'] ?? enquiry['cus_name'])?.toString() ?? 'N/A';
    final String phone = enquiry['mobile_1']?.toString() ?? 'N/A';
    final double screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirm Call',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: screenWidth * 0.12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+91 $phone',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF448AFF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'New Enquiry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Do you want to call this enquiry?',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _makePhoneCall(phone);
                          Future.delayed(const Duration(seconds: 2), () {
                            if (mounted) {
                              _showEnquiryDetailsPopup(enquiry);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Call Now',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEnquiryDetailsPopup(Map<String, dynamic> enquiry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnquiryDetailsPopupContent(
        lead: enquiry,
        employeeName: _employeeName,
        onRefresh: _refreshData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enquiry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Filters Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filters.map((filter) {
                final bool isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _refreshData();
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF26A69A)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF26A69A),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF26A69A),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedFilter == 'New'
                    ? 'Today Enquiry (${_filteredEnquiries.length})'
                    : 'Total Enquiry (${_allEnquiries.length})',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Enquiry List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF26A69A),
                      ),
                    ),
                  )
                : _filteredEnquiries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No enquiries found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredEnquiries.length,
                    itemBuilder: (context, index) {
                      final enquiry = _filteredEnquiries[index];
                      // Use standard enquiry card, but map fields correctly for follow-up history records
                      return _buildEnquiryCard(
                        enquiry: enquiry,
                        name:
                            (enquiry['le_name'] ??
                                    enquiry['cus_name'] ??
                                    enquiry['contact_person'])
                                ?.toString() ??
                            'N/A',
                        phone1: enquiry['mobile_1']?.toString() ?? 'N/A',
                        phone2:
                            (enquiry['moble_2'] ?? enquiry['mobile_2'])
                                ?.toString() ??
                            'N/A',
                        service:
                            (enquiry['product_service'] ??
                                    enquiry['required_project'])
                                ?.toString() ??
                            'N/A',
                        followUpdate:
                            (enquiry['enquiry_date'] ?? enquiry['call_date'])
                                ?.toString() ??
                            'N/A',
                        email: enquiry['email']?.toString() ?? 'N/A',
                        screenWidth: screenWidth,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnquiryCard({
    required Map<String, dynamic> enquiry,
    required String name,
    required String phone1,
    required String phone2,
    required String service,
    required String followUpdate,
    required String email,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnquiryDetailsScreen(
              lead: enquiry,
              selectedStatus: _selectedFilter,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person_outline, 'Name : $name', screenWidth),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.phone_outlined,
              'Phone No: $phone1',
              screenWidth,
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.phone_outlined,
              'Phone No: $phone2',
              screenWidth,
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.headphones_outlined,
              'Service Required : $service',
              screenWidth,
            ),
            const SizedBox(height: 6),
            _buildInfoRow(
              Icons.person_add_alt_1_outlined,
              'Follow Update : $followUpdate',
              screenWidth,
            ),
            const SizedBox(height: 6),
            _buildInfoRow(Icons.mail_outline, 'Email Id : $email', screenWidth),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCallConfirmation(enquiry),
                icon: const Icon(Icons.phone, color: Colors.white),
                label: const Text(
                  'Call Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4BA751),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, double screenWidth) {
    // Split the text into label and value if it contains a colon
    final parts = text.split(':');
    final String label = parts[0];
    final String value = parts.length > 1 ? parts.sublist(1).join(':') : '';
    final bool isName = label.trim().toLowerCase().contains('name');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: screenWidth * 0.045,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              children: [
                TextSpan(
                  text: '$label:',
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: isName ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Enquiry Details Popup (Same as Lead Details Popup flow) ─────────────────

class _EnquiryDetailsPopupContent extends StatefulWidget {
  final Map<String, dynamic> lead;
  final String employeeName;
  final VoidCallback? onRefresh;

  const _EnquiryDetailsPopupContent({
    required this.lead,
    required this.employeeName,
    this.onRefresh,
  });

  @override
  State<_EnquiryDetailsPopupContent> createState() =>
      _EnquiryDetailsPopupContentState();
}

class _EnquiryDetailsPopupContentState
    extends State<_EnquiryDetailsPopupContent> {
  String selectedOutcome = 'Select Outcome';
  String selectedMode = 'Select Follow-up Mode';
  String selectedStatus = 'Select Lead Status';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  late TextEditingController customerNameController;
  late TextEditingController attendedByController;
  final budgetController = TextEditingController();
  final otherServiceController = TextEditingController();
  final notesController = TextEditingController();

  bool isSubmitting = false;

  List<Map<String, dynamic>> outcomeList = [];
  List<Map<String, dynamic>> modeList = [];
  List<Map<String, dynamic>> statusList = [];

  bool isLoadingDropdowns = true;

  @override
  void initState() {
    super.initState();
    customerNameController = TextEditingController(
      text:
          (widget.lead['le_name'] ?? widget.lead['cus_name'])?.toString() ?? '',
    );
    attendedByController = TextEditingController(text: widget.employeeName);
    budgetController.text =
        (widget.lead['budget'] ?? widget.lead['customer_budget'])?.toString() ??
        '';
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final results = await Future.wait([
        LeadService.fetchDropdownData(type: '3014'), // Call Outcome
        LeadService.fetchDropdownData(type: '3015'), // Follow-up Mode
        LeadService.fetchDropdownData(type: '3009'), // Lead Status
      ]);

      if (mounted) {
        setState(() {
          outcomeList = List<Map<String, dynamic>>.from(results[0]);
          modeList = List<Map<String, dynamic>>.from(results[1]);
          statusList = List<Map<String, dynamic>>.from(results[2]);
          isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading dropdown data: $e");
      if (mounted) {
        setState(() => isLoadingDropdowns = false);
      }
    }
  }

  @override
  void dispose() {
    customerNameController.dispose();
    attendedByController.dispose();
    budgetController.dispose();
    otherServiceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Enquiry details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).dividerColor),
          Expanded(
            child: isLoadingDropdowns
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPopupLabel('Customer Name'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: customerNameController,
                          hint: 'Enter Customer Name',
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Call Outcome', isRequired: true),
                        const SizedBox(height: 8),
                        _buildPopupDropdown(
                          value: selectedOutcome,
                          items: [
                            'Select Outcome',
                            ...outcomeList.map((e) => e['name'].toString()),
                          ],
                          onChanged: (val) => setState(
                            () => selectedOutcome = val ?? 'Select Outcome',
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Follow-Up Mode', isRequired: true),
                        const SizedBox(height: 8),
                        _buildPopupDropdown(
                          value: selectedMode,
                          items: [
                            'Select Follow-up Mode',
                            ...modeList.map((e) => e['name'].toString()),
                          ],
                          onChanged: (val) => setState(
                            () => selectedMode = val ?? 'Select Follow-up Mode',
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Attended By'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: attendedByController,
                          hint: 'Enter Employee Name',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildPopupLabel(
                                    'Next Follow-up Date',
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDatePickerField(
                                    selectedDate != null
                                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                        : '',
                                    () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime(2100),
                                      );
                                      if (date != null) {
                                        setState(() => selectedDate = date);
                                      }
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
                                  _buildPopupLabel(
                                    'Next Follow-up Time',
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTimePickerField(
                                    selectedTime != null
                                        ? selectedTime!.format(context)
                                        : '',
                                    () async {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        setState(() => selectedTime = time);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Customer Budget'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: budgetController,
                          hint: '₹25,000',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Other Service Required'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: otherServiceController,
                          hint: 'Enter Other Services',
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Notes / Call Summary'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: notesController,
                          hint: 'Enter discussion summary..',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Lead Status'),
                        const SizedBox(height: 8),
                        _buildPopupDropdown(
                          value: selectedStatus,
                          items: [
                            'Select Lead Status',
                            ...statusList.map((e) => e['name'].toString()),
                          ],
                          onChanged: (val) => setState(
                            () => selectedStatus = val ?? 'Select Lead Status',
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (selectedOutcome == 'Select Outcome') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select call outcome',
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (selectedMode ==
                                        'Select Follow-up Mode') {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please select follow-up mode',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => isSubmitting = true);

                                    try {
                                      final String dateStr =
                                          selectedDate != null
                                          ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
                                          : "";
                                      final String timeStr =
                                          selectedTime != null
                                          ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00"
                                          : "";

                                      // If it has 'call_by' or 'call_date', it's a history record (API 3016)
                                      final bool isHistoryRecord =
                                          widget.lead.containsKey('call_by') ||
                                          widget.lead.containsKey('call_date');

                                      final dynamic rawId =
                                          widget.lead['id'] ??
                                          widget.lead['no'];
                                      final String? userLedId =
                                          await PreferenceService.getLedId();

                                      final Map<String, dynamic>
                                      followUpData = {
                                        if (!isHistoryRecord && rawId != null)
                                          'no': rawId.toString(),
                                        // For updates (API 3017), 'id' is the unique follow-up ID.
                                        // If missing from 3016 items, we try common keys or fallback to '33'.
                                        if (isHistoryRecord)
                                          'id':
                                              (rawId ??
                                                      widget.lead['cid'] ??
                                                      '')
                                                  .toString(),
                                        'led_id': (userLedId ?? '').toString(),
                                        'call_date': DateTime.now()
                                            .toString()
                                            .split(' ')[0],
                                        'cus_name': customerNameController.text,
                                        'le_name': customerNameController.text,
                                        'call_outcome':
                                            selectedOutcome == 'Select Outcome'
                                            ? ''
                                            : (() {
                                                final idx = outcomeList
                                                    .indexWhere(
                                                      (e) =>
                                                          e['name']
                                                              .toString() ==
                                                          selectedOutcome,
                                                    );
                                                if (idx == -1) return '';
                                                final item = outcomeList[idx];
                                                return (item['value'] ??
                                                        (idx + 1))
                                                    .toString();
                                              })(),
                                        'follow_up_mode':
                                            selectedMode ==
                                                'Select Follow-up Mode'
                                            ? ''
                                            : (() {
                                                final idx = modeList.indexWhere(
                                                  (e) =>
                                                      e['name'].toString() ==
                                                      selectedMode,
                                                );
                                                if (idx == -1) return '';
                                                final item = modeList[idx];
                                                return (item['value'] ??
                                                        (idx + 1))
                                                    .toString();
                                              })(),
                                        'required_project':
                                            (widget.lead['product_service'] ??
                                                    widget
                                                        .lead['required_project'])
                                                ?.toString() ??
                                            '',
                                        'other_required':
                                            otherServiceController.text,
                                        'customer_budget':
                                            budgetController.text,
                                        'next_follow_up_date': dateStr,
                                        'next_follow_up_time': timeStr,
                                        'call_summary': notesController.text,
                                        'lead_status':
                                            selectedStatus ==
                                                'Select Lead Status'
                                            ? ''
                                            : (() {
                                                final idx = statusList
                                                    .indexWhere(
                                                      (e) =>
                                                          e['name']
                                                              .toString() ==
                                                          selectedStatus,
                                                    );
                                                if (idx == -1) return '';
                                                final item = statusList[idx];
                                                return (item['value'] ??
                                                        (idx + 1))
                                                    .toString();
                                              })(),
                                        'type_status':
                                            'enquiry', // Added per user request
                                      };

                                      final response = await () async {
                                        final String deviceId =
                                            SplashScreen.deviceId ?? '1234';
                                        final String ln =
                                            SplashScreen.ln ?? '123';
                                        final String lt =
                                            SplashScreen.lt ?? '456';
                                        final String cid =
                                            await PreferenceService.getCid();
                                        final String? token =
                                            await PreferenceService.getToken();

                                        final String apiCode = isHistoryRecord
                                            ? '3017'
                                            : '3018'; // Changed from 3008 to 3018 for Enquiry insert

                                        final Map<String, String> body = {
                                          'type': apiCode,
                                          'cid': cid,
                                          'device_id': deviceId,
                                          'lt': lt,
                                          'ln': ln,
                                          'token': ?token,
                                          ...followUpData.map(
                                            (k, v) => MapEntry(k, v.toString()),
                                          ),
                                        };

                                        debugPrint(
                                          "------------ DIRECT API REQUEST ($apiCode) ------------",
                                        );
                                        debugPrint(
                                          "URL: https://erpsmart.in/total/api/m_api/",
                                        );
                                        debugPrint("BODY: $body");

                                        final res = await http.post(
                                          Uri.parse(
                                            "https://erpsmart.in/total/api/m_api/",
                                          ),
                                          body: body,
                                        );

                                        debugPrint(
                                          "------------ DIRECT API RESPONSE ($apiCode) ------------",
                                        );
                                        debugPrint("BODY: ${res.body}");

                                        try {
                                          return json.decode(res.body);
                                        } catch (e) {
                                          return {
                                            'error': true,
                                            'error_msg':
                                                'Invalid JSON response',
                                          };
                                        }
                                      }();

                                      debugPrint(
                                        "------------ ENQUIRY FOLLOW-UP SUBMISSION RESPONSE ------------",
                                      );
                                      debugPrint(response.toString());

                                      if (mounted) {
                                        if (response['error'] == false) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response['error_msg'] ??
                                                    'Success',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          if (widget.onRefresh != null) {
                                            widget.onRefresh!();
                                          }
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                response['error_msg'] ??
                                                    'Error',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      debugPrint('Submit error: $e');
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Submission failed. Please try again.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (mounted) {
                                        setState(() => isSubmitting = false);
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26A69A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }

  Widget _buildPopupLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildPopupDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: item.startsWith('Select')
                      ? Colors.grey
                      : Theme.of(context).textTheme.bodyLarge?.color,
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

  Widget _buildDatePickerField(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              size: 20,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
