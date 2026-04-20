import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_activity_detail_screen.dart';
import '../services/lead_service.dart';

class EnquiryDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? lead;
  final String? selectedStatus;
  const EnquiryDetailsScreen({super.key, this.lead, this.selectedStatus});

  @override
  State<EnquiryDetailsScreen> createState() => _EnquiryDetailsScreenState();
}

class _EnquiryDetailsScreenState extends State<EnquiryDetailsScreen> {
  int _selectedTabIndex = 0;
  bool _isQuickMenuExpanded = false;
  bool _isScheduleExpanded = false;
  bool _isStageExpanded = false;
  bool _isTimelineEditMode = false;

  String _selectedSchedule = 'Schedule Follow-up For';
  final String _selectedStage = 'Current Stage';

  List<dynamic> _timelineData = [];
  bool _isLoadingTimeline = false;

  List<dynamic> _callSummaryData = [];
  bool _isLoadingCallSummary = false;

  @override
  void initState() {
    super.initState();
    if (widget.lead != null) {
      _fetchTimelineData();
      _fetchCallSummaryData();
    }
  }

  Future<void> _fetchTimelineData() async {
    setState(() {
      _isLoadingTimeline = true;
    });

    final String leadNo =
        (widget.lead?['id'] ?? widget.lead?['led_id'])?.toString() ?? '';
    if (leadNo.isNotEmpty) {
      final data = await LeadService.fetchFollowUpHistory(leadNo: leadNo);
      if (mounted) {
        setState(() {
          _timelineData = data;
          _isLoadingTimeline = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingTimeline = false;
        });
      }
    }
  }

  Future<void> _fetchCallSummaryData() async {
    setState(() {
      _isLoadingCallSummary = true;
    });

    final String uid =
        (widget.lead?['uid'] ?? widget.lead?['id'])?.toString() ?? '';

    // Fallback logic for uid if necessary, but ideally it should come from the lead object.
    // If uid isn't directly available under 'uid', we might need to rely on the backend expecting a specific parameter,
    // or we use a default/extracted id. The API response showed uid: "52", led_id: "33".

    if (uid.isNotEmpty) {
      final data = await LeadService.fetchCallSummary(uid);
      if (mounted) {
        setState(() {
          _callSummaryData = data;
          _isLoadingCallSummary = false;
        });
      }
    } else {
      // If no UID is found, we can try to fetch with a fallback or just stop loading
      if (mounted) {
        setState(() {
          _isLoadingCallSummary = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF26A69A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enquiry Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Custom Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        _buildTabItem('Over View', 0),
                        const SizedBox(width: 8),
                        _buildTabItem(_getDynamicTabLabel(), 1),
                        const SizedBox(width: 8),
                        _buildTabItem('Timeline', 3),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (_selectedTabIndex == 0) ...[
                  // Over View Tab Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Schedule Follow-up Custom Dropdown
                        _buildCustomExpandable(
                          title: _selectedSchedule,
                          isExpanded: _isScheduleExpanded,
                          onToggle: () {
                            setState(() {
                              _isScheduleExpanded = !_isScheduleExpanded;
                              if (_isScheduleExpanded) _isStageExpanded = false;
                            });
                          },
                          children: [
                            _buildExpandedItem('Today', () {
                              setState(() {
                                _selectedSchedule = 'Today';
                                _isScheduleExpanded = false;
                              });
                            }),
                            _buildExpandedItem('Tomorrow', () {
                              setState(() {
                                _selectedSchedule = 'Tomorrow';
                                _isScheduleExpanded = false;
                              });
                            }),
                            _buildExpandedItem('3 Days From Now', () {
                              setState(() {
                                _selectedSchedule = '3 Days From Now';
                                _isScheduleExpanded = false;
                              });
                            }),
                            _buildExpandedItem('1 Week From Now', () {
                              setState(() {
                                _selectedSchedule = '1 Week From Now';
                                _isScheduleExpanded = false;
                              });
                            }),
                            _buildExpandedItem('1 Month From Now', () {
                              setState(() {
                                _selectedSchedule = '1 Month From Now';
                                _isScheduleExpanded = false;
                              });
                            }),
                            _buildExpandedItem(
                              'Select Custom Date and Time',
                              () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedSchedule =
                                        '${date.day}/${date.month}/${date.year}';
                                    _isScheduleExpanded = false;
                                  });
                                }
                              },
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            _buildExpandedItem('No Follow-Up', () {
                              setState(() {
                                _selectedSchedule = 'No Follow-Up';
                                _isScheduleExpanded = false;
                              });
                            }),
                          ],
                        ),

                        // const SizedBox(height: 16),
                        // Text(
                        //   'Lead Stage',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w700,
                        //     color: Theme.of(
                        //       context,
                        //     ).textTheme.titleSmall?.color,
                        //   ),
                        // ),
                        // const SizedBox(height: 8),

                        // Current Stage Custom Dropdown
                        // _buildCustomExpandable(
                        //   title: _selectedStage,
                        //   isExpanded: _isStageExpanded,
                        //   onToggle: () {
                        //     setState(() {
                        //       _isStageExpanded = !_isStageExpanded;
                        //       if (_isStageExpanded) _isScheduleExpanded = false;
                        //     });
                        //   },
                        //   children: [
                        //     _buildExpandedItem('Intrested', () {
                        //       setState(() {
                        //         _selectedStage = 'Intrested';
                        //         _isStageExpanded = false;
                        //       });
                        //     }),
                        //     _buildExpandedItem('Meeting Booked', () {
                        //       setState(() {
                        //         _selectedStage = 'Meeting Booked';
                        //         _isStageExpanded = false;
                        //       });
                        //     }),
                        //     _buildExpandedItem('Proposal', () {
                        //       setState(() {
                        //         _selectedStage = 'Proposal';
                        //         _isStageExpanded = false;
                        //       });
                        //     }),
                        //     _buildExpandedItem('Negotiating', () {
                        //       setState(() {
                        //         _selectedStage = 'Negotiating';
                        //         _isStageExpanded = false;
                        //       });
                        //     }),
                        //     _buildExpandedItem('Close - Won', () {
                        //       setState(() {
                        //         _selectedStage = 'Close - Won';
                        //         _isStageExpanded = false;
                        //       });
                        //     }),
                        //     _buildExpandedItem('Close - Lost', () {
                        //       setState(() {
                        //         _selectedStage = 'Close - Lost';
                        //         _isStageExpanded = false;
                        //       });
                        //     }),
                        //     _buildExpandedItem('Uncontactable', () {
                        //       setState(() {
                        //         _selectedStage = 'Uncontactable';
                        //         _isStageExpanded = false;
                        //       });
                        //     }),
                        //   ],
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detail Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildDetailField(
                        //   'Project Value',
                        //   widget.lead?['budget']?.toString() ?? 'N/A',
                        // ),
                        _buildDetailField(
                          'Name',
                          (widget.lead?['le_name'] ??
                                  widget.lead?['cus_name'] ??
                                  widget.lead?['contact_person'])
                              ?.toString() ??
                          'N/A',
                        ),
                        _buildDetailField(
                          'Company Name',
                          widget.lead?['comany_name']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Contact person',
                          widget.lead?['contact_person']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Contact No 1',
                          widget.lead?['mobile_1']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Contact No 2',
                          widget.lead?['moble_2']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Email ID',
                          widget.lead?['email']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Lead Source',
                          widget.lead?['lead_source']?.toString() ?? 'N/A',
                          isLast: true,
                        ),
                        _buildDetailField(
                          'Service Required',
                          (widget.lead?['product_service'] ??
                                      widget.lead?['required_project'])
                                  ?.toString() ??
                              'N/A',
                        ),
                        _buildDetailField(
                          'Budget',
                          (widget.lead?['budget'] ??
                                      widget.lead?['customer_budget'])
                                  ?.toString() ??
                              'N/A',
                        ),
                        _buildDetailField(
                          'Urgercy Level',
                          widget.lead?['urgency_level']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Assigned By',
                          widget.lead?['assigned_by']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Follow Up Date',
                          (widget.lead?['next_follow_up_date'] ??
                                      widget.lead?['followup_date'])
                                  ?.toString() ??
                              'N/A',
                        ),
                        _buildDetailField(
                          'Notes',
                          widget.lead?['remarks']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Address',
                          widget.lead?['address']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'City',
                          widget.lead?['city']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'State',
                          widget.lead?['state']?.toString() ?? 'N/A',
                        ),
                        _buildDetailField(
                          'Pincode',
                          widget.lead?['pincode']?.toString() ?? 'N/A',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ] else if (_selectedTabIndex == 1) ...[
                  // Dynamic Summary Tab Content
                  _buildDynamicTabContent(),
                ] else ...[
                  // Timeline Tab Content (index 3)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Add Activity Section with Line
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _showAddActivityBottomSheet(
                                                context,
                                              ),
                                          child: Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: 1,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 24.0,
                                        ),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              child: Text(
                                                'Add Activity',
                                                style: TextStyle(
                                                  color: Color(0xFF39EF4B),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isTimelineEditMode =
                                                      !_isTimelineEditMode;
                                                });
                                              },
                                              child: Image.asset(
                                                'assets/images/edit_icon.png',
                                                width: 28,
                                                height: 28,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Connecting line between sections
                              SizedBox(
                                height: 24,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      child: Center(
                                        child: Container(
                                          width: 1,
                                          color: const Color(0xFF26A69A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),

                              // Timeline Items
                              if (_isLoadingTimeline)
                                const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF26A69A),
                                    ),
                                  ),
                                )
                              else if (_timelineData.isEmpty)
                                const Center(child: Text("No timeline data"))
                              else
                                ..._timelineData.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  var item = entry.value;
                                  bool isLast = idx == _timelineData.length - 1;

                                  // Extract date and time
                                  String dateTimeStr =
                                      item['created_date']?.toString() ?? 'N/A';
                                  String comments =
                                      item['discussion_summery']?.toString() ??
                                      '';

                                  return _buildTimelineItem(
                                    title: Text(
                                      item['call_outcome']?.toString() ??
                                          'Update',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    dateTime: dateTimeStr,
                                    actor: 'User',
                                    comment: comments,
                                    isLast: isLast,
                                  );
                                }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Save Button
                        if (_isTimelineEditMode)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isTimelineEditMode = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),

          // Custom FAB
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_isQuickMenuExpanded) ...[
                  _buildQuickActionItem(
                    Image.asset(
                      'assets/icons/what.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    () => _launchWhatsApp(widget.lead?['mobile_1']?.toString()),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionItem(
                    const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    () => _launchEmail(widget.lead?['email']?.toString()),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionItem(
                    const Icon(
                      Icons.phone_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    () => _launchCall(widget.lead?['mobile_1']?.toString()),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionItem(
                    const Icon(
                      Icons.message_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    () => _launchSMS(widget.lead?['mobile_1']?.toString()),
                  ),
                  const SizedBox(height: 12),
                ],
                _buildQuickActionButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty || phone == 'N/A') {
      _showErrorSnackBar('WhatsApp number not exists');
      return;
    }

    _showPermissionDialog(
      title: 'WhatsApp Confirmation',
      message: 'Do you want to open WhatsApp chat with this lead?',
      actionLabel: 'WhatsApp Now',
      actionColor: const Color(0xFF25D366),
      actionIcon: Image.asset('assets/icons/what.png', width: 48, height: 48),
      onConfirm: () async {
        String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanPhone.startsWith('0')) {
          cleanPhone = cleanPhone.substring(1);
        }
        if (cleanPhone.length == 10) {
          cleanPhone = '91$cleanPhone';
        }

        // Try native whatsapp scheme first
        final whatsappUrl = "whatsapp://send?phone=$cleanPhone";
        final whatsappUri = Uri.parse(whatsappUrl);

        try {
          if (await canLaunchUrl(whatsappUri)) {
            await launchUrl(whatsappUri);
          } else {
            // Fallback to web link which usually redirects to the app
            final webUrl = "https://wa.me/$cleanPhone";
            final webUri = Uri.parse(webUrl);
            // Using externalApplication mode for web link to force opening the app
            await launchUrl(webUri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          _showErrorSnackBar('Error opening WhatsApp: $e');
        }
      },
    );
  }

  Future<void> _launchEmail(String? email) async {
    if (email == null || email.isEmpty || email == 'N/A') {
      _showErrorSnackBar('Email not exists');
      return;
    }

    _showPermissionDialog(
      title: 'Email Confirmation',
      message: 'Do you want to send an email to this lead?',
      actionLabel: 'Email Now',
      actionColor: const Color(0xFF26A69A),
      actionIcon: const Icon(
        Icons.email_outlined,
        size: 48,
        color: Colors.grey,
      ),
      onConfirm: () async {
        final Uri uri = Uri(scheme: 'mailto', path: email);
        try {
          // Some devices are strict with canLaunchUrl for mailto
          // We'll try to launch directly and catch if it fails
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
            _showErrorSnackBar('Could not launch Email app');
          }
        } catch (e) {
          _showErrorSnackBar('Error opening Email: $e');
        }
      },
    );
  }

  Future<void> _launchCall(String? phone) async {
    if (phone == null || phone.isEmpty || phone == 'N/A') {
      _showErrorSnackBar('Phone number not exists');
      return;
    }

    _showPermissionDialog(
      title: 'Call Confirmation',
      message: 'Do you want to call this lead?',
      actionLabel: 'Call Now',
      actionColor: const Color(0xFF4CAF50),
      actionIcon: const Icon(
        Icons.phone_outlined,
        size: 48,
        color: Colors.grey,
      ),
      onConfirm: () async {
        final Uri uri = Uri(
          scheme: 'tel',
          path: phone.replaceAll(RegExp(r'[^\d+]'), ''),
        );
        try {
          final launched = await launchUrl(uri);
          if (!launched) {
            _showErrorSnackBar('Could not launch Dialer');
          }
        } catch (e) {
          _showErrorSnackBar('Error opening Dialer: $e');
        }
      },
    );
  }

  Future<void> _launchSMS(String? phone) async {
    if (phone == null || phone.isEmpty || phone == 'N/A') {
      _showErrorSnackBar('Phone number not exists');
      return;
    }

    _showPermissionDialog(
      title: 'SMS Confirmation',
      message: 'Do you want to send a message to this lead?',
      actionLabel: 'Message Now',
      actionColor: const Color(0xFF2196F3),
      actionIcon: const Icon(
        Icons.message_outlined,
        size: 48,
        color: Colors.grey,
      ),
      onConfirm: () async {
        final Uri uri = Uri(
          scheme: 'sms',
          path: phone.replaceAll(RegExp(r'[^\d+]'), ''),
        );
        try {
          final launched = await launchUrl(uri);
          if (!launched) {
            _showErrorSnackBar('Could not launch SMS app');
          }
        } catch (e) {
          _showErrorSnackBar('Error opening SMS: $e');
        }
      },
    );
  }

  void _showPermissionDialog({
    required String title,
    required String message,
    required String actionLabel,
    required Color actionColor,
    required Widget actionIcon,
    required VoidCallback onConfirm,
  }) {
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
                  title,
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
                    actionIcon is Icon
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: actionIcon,
                          )
                        : actionIcon,
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lead?['cus_name']?.toString() ?? 'Lead',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title.contains('Email')
                                ? (widget.lead?['email']?.toString() ?? 'N/A')
                                : (widget.lead?['mobile_1']?.toString() ??
                                      'N/A'),
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message,
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
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: actionColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(color: Colors.white),
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

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildProfileInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(Widget icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF1B7BBC), Color(0xFF26A69A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isSelected
                ? null
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : const Color(0xFFDEDEDE)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).textTheme.bodyLarge?.color
                  : Theme.of(context).primaryColor.withValues(alpha: 0.6),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomExpandable({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2A2D3E)
                  : const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 4),
          Column(children: children),
        ],
      ],
    );
  }

  Widget _buildExpandedItem(
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required Widget title,
    required String dateTime,
    required String actor,
    String? comment,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot and Line
          Column(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.access_time_filled,
                  color: Theme.of(context).primaryColor,
                  size: 26,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 4),
                  Text(
                    dateTime,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    actor,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  if (comment != null) ...[
                    const SizedBox(height: 2),
                    _isTimelineEditMode
                        ? TextField(
                            controller: TextEditingController(text: comment),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: UnderlineInputBorder(),
                            ),
                          )
                        : Text(
                            comment,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(String label, String value, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleSmall?.color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        if (!isLast) const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuickActionButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isQuickMenuExpanded = !_isQuickMenuExpanded;
        });
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isQuickMenuExpanded ? const Color(0xFFD9D9D9) : null,
          gradient: _isQuickMenuExpanded
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF1B7BBC), Color(0xFF26A69A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Quick',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAddActivityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Add Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildBottomSheetItem(context, 'Phone Call'),
              _buildBottomSheetItem(context, 'Message'),
              _buildBottomSheetItem(context, 'Meeting'),
              _buildBottomSheetItem(context, 'Note'),
              _buildBottomSheetItem(context, 'Attachments'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem(BuildContext context, String title) {
    return Column(
      children: [
        Divider(color: Theme.of(context).dividerColor, height: 1),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AddActivityDetailScreen(activityType: title),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCallSummaryTab() {
    final String customerName =
        (widget.lead?['le_name'] ?? widget.lead?['cus_name'])?.toString() ??
        'Customer';

    if (_isLoadingCallSummary || _isLoadingTimeline) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF26A69A)),
          ),
        ),
      );
    }

    // Use placeholder items if no live data yet
    final List<Map<String, String>> placeholderItems = [
      {
        'call_date': '2026-03-10',
        'call_time': '10:30 AM',
        'duration': '12 min',
        'outcome': 'Interested',
        'required_project': 'Web Development',
        'other_required': 'SEO Package',
        'budget': '₹50,000',
        'summary':
            'Customer showed strong interest. Requested a demo next week.',
        'followup_mode': 'Phone Call',
      },
      {
        'call_date': '2026-03-08',
        'call_time': '2:00 PM',
        'duration': '8 min',
        'outcome': 'Follow up',
        'required_project': 'Mobile App',
        'other_required': '-',
        'budget': '₹1,20,000',
        'summary': 'Initial call. Customer asked for pricing and brochure.',
        'followup_mode': 'WhatsApp',
      },
      {
        'call_date': '2026-03-05',
        'call_time': '11:00 AM',
        'duration': '20 min',
        'outcome': 'Negotiation',
        'required_project': 'ERP Software',
        'other_required': 'Annual Maintenance',
        'budget': '₹2,50,000',
        'summary': 'Discussed pricing. Customer requested 10% discount.',
        'followup_mode': 'Meeting',
      },
    ];

    final isPlaceholder = _callSummaryData.isEmpty;
    final displayData = isPlaceholder
        ? placeholderItems
        : _callSummaryData.map<Map<String, String>>((item) {
            // Map follow_up_mode ID to string if needed, or just use it directly if it's string.
            // Example response: "follow_up_mode": "1"
            String fMode = item['follow_up_mode']?.toString() ?? '-';
            if (fMode == '1') fMode = 'Phone Call';
            if (fMode == '2') fMode = 'Direct Meet';

            // Map call_outcome ID to string
            // Example response: "call_outcome": "2"
            String outcomeStr = item['call_outcome']?.toString() ?? 'Update';
            if (outcomeStr == '1') outcomeStr = 'Interested';
            if (outcomeStr == '2') outcomeStr = 'Follow up';
            if (outcomeStr == '3') outcomeStr = 'Negotiation';
            if (outcomeStr == '4') outcomeStr = 'Lost';

            return {
              'call_date': item['call_date']?.toString() ?? 'N/A',
              'call_time': item['call_time']?.toString() ?? '',
              'duration':
                  item['duration']?.toString() ??
                  item['call_duration']?.toString() ??
                  '-',
              'outcome': outcomeStr,
              'required_project': item['required_project']?.toString() ?? '-',
              'other_required': item['other_required']?.toString() ?? '-',
              'budget': item['customer_budget']?.toString() ?? '-',
              'summary': item['call_summary']?.toString() ?? '',
              'followup_mode': fMode,
            };
          }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer name in large bold at top
          Text(
            customerName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${displayData.length} Call${displayData.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isPlaceholder) ...[
                const SizedBox(width: 8),
                const Text(
                  '(Sample data)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          ...displayData.map((item) => _buildCallCard(item: item)),
        ],
      ),
    );
  }

  Widget _buildCallCard({required Map<String, String> item}) {
    final String outcome = item['outcome'] ?? 'Update';
    final String callDate = item['call_date'] ?? 'N/A';
    final String callTime = item['call_time'] ?? '';
    final String duration = item['duration'] ?? '-';
    final String requiredProject = item['required_project'] ?? '-';
    final String otherRequired = item['other_required'] ?? '-';
    final String budget = item['budget'] ?? '-';
    final String summary = item['summary'] ?? '-';
    final String followupMode = item['followup_mode'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header – outcome badge + date & time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getOutcomeColor(outcome).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getOutcomeColor(outcome).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    outcome,
                    style: TextStyle(
                      color: _getOutcomeColor(outcome),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          callDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (callTime.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 13,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            callTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Card Body – all fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoItem(Icons.timer_outlined, 'Duration', duration),
                _buildInfoItem(
                  Icons.work_outline,
                  'Required Project',
                  requiredProject,
                ),
                _buildInfoItem(
                  Icons.add_circle_outline,
                  'Other Required',
                  otherRequired,
                ),
                _buildInfoItem(Icons.currency_rupee_outlined, 'Budget', budget),
                _buildInfoItem(
                  Icons.phone_callback_outlined,
                  'Follow-up Mode',
                  followupMode,
                ),
                const Divider(height: 20),
                const Text(
                  'Call Summary',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF26A69A)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getDynamicTabLabel() {
    String? statusContext = widget.selectedStatus;
    if (statusContext != null && statusContext.toLowerCase() == 'all') {
      statusContext =
          null; // Treat 'all' as no specific context to allow fallback
    }

    final String status =
        (statusContext ??
                widget.lead?['lead_status'] ??
                widget.lead?['status'] ??
                '')
            .toString()
            .toLowerCase();

    if (status.contains('negotiation')) {
      return 'Negotiation Summary';
    } else if (status.contains('meeting')) {
      return 'Meeting Summary';
    } else if (status.contains('follow_up') ||
        status.contains('follow up') ||
        status.contains('followup') ||
        status == 'new') {
      return 'Call Summary';
    } else {
      // Default to Call Summary for any other statuses (like 'Interested', 'New Lead', etc.)
      return 'Call Summary';
    }
  }

  Widget _buildDynamicTabContent() {
    final String label = _getDynamicTabLabel();
    if (label == 'Negotiation Summary') {
      return _buildNegotiationSummaryTab();
    } else if (label == 'Meeting Summary') {
      return _buildMeetingSummaryTab();
    } else {
      return _buildCallSummaryTab();
    }
  }

  Widget _buildMeetingSummaryTab() {
    final String customerName =
        (widget.lead?['le_name'] ?? widget.lead?['cus_name'])?.toString() ??
        'Customer';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader(customerName, 'Meeting Summary'),
          const SizedBox(height: 16),
          _buildSummaryPlaceholder(
            Icons.calendar_month_outlined,
            'Meeting data will appear here',
          ),
        ],
      ),
    );
  }

  Widget _buildNegotiationSummaryTab() {
    final String customerName =
        (widget.lead?['le_name'] ?? widget.lead?['cus_name'])?.toString() ??
        'Customer';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryHeader(customerName, 'Negotiation Summary'),
          const SizedBox(height: 16),
          _buildSummaryPlaceholder(
            Icons.handshake_outlined,
            'Negotiation data will appear here',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(String name, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSummaryPlaceholder(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            'Details will be populated after API binding',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Color _getOutcomeColor(String outcome) {
    switch (outcome.toLowerCase()) {
      case 'interested':
      case 'won':
        return Colors.green;
      case 'follow up':
      case 'callback':
        return Colors.blue;
      case 'negotiation':
      case 'proposal':
        return Colors.orange;
      case 'lost':
      case 'not interested':
        return Colors.red;
      case 'uncontactable':
        return Colors.purple;
      default:
        return const Color(0xFF26A69A);
    }
  }
}
