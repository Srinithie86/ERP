import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/lead_service.dart';
import '../services/profile_service.dart';
import '../Follows/enquiry_details_screen.dart';
import '../Models/referral_api.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'New',
    'Follow up',
    'Meeting',
    'Negotiation',
  ];
  bool _isLoading = false;
  List<dynamic> _allReferrals = [];
  List<dynamic> _allFollowUps = [];
  String _employeeName = '';

  List<dynamic> get _filteredReferrals {
    if (_selectedFilter == 'All') return _allReferrals;
    if (_selectedFilter == 'Follow up') return _allFollowUps;
    
    if (_selectedFilter == 'New') {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      return _allReferrals.where((e) {
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

    return _allReferrals.where((e) {
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
      await _fetchReferrals();
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

  Future<void> _fetchReferrals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Using 'Referral' as enquiryType.
      final referrals = await ReferralApi.fetchReferrals();
      if (mounted) {
        setState(() {
          _allReferrals = referrals;
        });
      }
    } catch (e) {
      debugPrint("Error fetching referrals: $e");
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

  void _showCallConfirmation(Map<String, dynamic> referral) {
    final String name =
        (referral['le_name'] ?? referral['cus_name'])?.toString() ?? 'N/A';
    final String phone = referral['mobile_1']?.toString() ?? 'N/A';
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
                                'New Referral',
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
                    'Do you want to call this referral?',
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
                              _showReferralDetailsPopup(referral);
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

  void _showReferralDetailsPopup(Map<String, dynamic> referral) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EnquiryDetailsPopupContent(
        lead: referral,
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
          'Referral',
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
                    ? 'Today Referral (${_filteredReferrals.length})'
                    : 'Total Referral (${_allReferrals.length})',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Referral List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF26A69A),
                      ),
                    ),
                  )
                : _filteredReferrals.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No referrals found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredReferrals.length,
                    itemBuilder: (context, index) {
                      final referral = _filteredReferrals[index];
                      return _buildReferralCard(
                        referral: referral,
                        name:
                            (referral['le_name'] ??
                                    referral['cus_name'] ??
                                    referral['contact_person'])
                                ?.toString() ??
                            'N/A',
                        phone1: referral['mobile_1']?.toString() ?? 'N/A',
                        phone2:
                            (referral['moble_2'] ?? referral['mobile_2'])
                                ?.toString() ??
                            'N/A',
                        service:
                            (referral['product_service'] ??
                                    referral['required_project'])
                                ?.toString() ??
                            'N/A',
                        followUpdate:
                            (referral['enquiry_date'] ?? referral['call_date'])
                                ?.toString() ??
                            'N/A',
                        email: referral['email']?.toString() ?? 'N/A',
                        screenWidth: screenWidth,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard({
    required Map<String, dynamic> referral,
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
              lead: referral,
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
                onPressed: () => _showCallConfirmation(referral),
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

// ─── Referral Details Popup (Same as Enquiry Details Popup) ─────────────────
// Reusing _EnquiryDetailsPopupContent logic from enquiry_screen.dart
// Since it's a private class in enquiry_screen.dart, I'll copy the necessary parts or make it public.
// For now, I'll use a placeholder or copy it if needed.
// Given the prompt, I'll copy it but rename it to avoid confusion if it was public.
// Actually, looking at enquiry_screen.dart, its _EnquiryDetailsPopupContent is private.

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
                  'Referral details',
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
                                  _buildDatePickerField(
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
                                    isTime: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Lead Status', isRequired: true),
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
                        const SizedBox(height: 20),
                        _buildPopupLabel('Customer Budget'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: budgetController,
                          hint: 'Enter Budget',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        _buildPopupLabel('Notes'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: notesController,
                          hint: 'Enter notes here...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _submitFollowUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26A69A),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                                    'Save Follow-up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF26A69A)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildPopupDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePickerField(
    String text,
    VoidCallback onTap, {
    bool isTime = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text.isEmpty ? (isTime ? 'Select Time' : 'Select Date') : text,
                style: TextStyle(
                  color: text.isEmpty ? Colors.grey[400] : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              isTime ? Icons.access_time : Icons.calendar_today,
              size: 18,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFollowUp() async {
    if (selectedOutcome == 'Select Outcome' ||
        selectedMode == 'Select Follow-up Mode' ||
        selectedStatus == 'Select Lead Status' ||
        selectedDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final selectedOutcomeId = outcomeList.firstWhere(
        (e) => e['name'] == selectedOutcome,
      )['id'];
      final selectedModeId = modeList.firstWhere(
        (e) => e['name'] == selectedMode,
      )['id'];
      final selectedStatusId = statusList.firstWhere(
        (e) => e['name'] == selectedStatus,
      )['id'];

      final nextFollowUpDate =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
      final nextFollowUpTime =
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00";

      final Map<String, dynamic> followUpData = {
        'led_id': widget.lead['no'] ?? widget.lead['id'],
        'cus_name': customerNameController.text,
        'call_outcome': selectedOutcomeId,
        'followup_mode': selectedModeId,
        'next_followup_date': nextFollowUpDate,
        'next_followup_time': nextFollowUpTime,
        'lead_status': selectedStatusId,
        'budget': budgetController.text,
        'notes': notesController.text,
      };

      final response = await LeadService.addFollowUp(followUpData);

      if (mounted) {
        if (response['error'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Follow-up saved successfully')),
          );
          Navigator.pop(context); // Close popup
          widget.onRefresh?.call();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['error_msg'] ?? 'Failed to save follow-up',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error submitting follow-up: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('An error occurred')));
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }
}
