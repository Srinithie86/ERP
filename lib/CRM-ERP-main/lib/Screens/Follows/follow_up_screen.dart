import '../Lead_Information/enquiry_tabs_view.dart';
import 'package:flutter/material.dart';
import '../../Models/follow_up_api.dart';
import '../../Widgets/lead_row_card.dart';
import 'package:intl/intl.dart';
import '../Leads/call_outcome_screen.dart';
import '../../widgets/call_confirmation_popup.dart';

class FollowUpScreen extends StatefulWidget {
  final int initialIndex;
  final bool isMissed;
  final VoidCallback? onBack;

  const FollowUpScreen({
    super.key,
    this.initialIndex = 0,
    this.isMissed = false,
    this.onBack,
  });

  @override
  State<FollowUpScreen> createState() => _FollowUpScreenState();
}

class _FollowUpScreenState extends State<FollowUpScreen> {
  late int _selectedIndex;
  bool _isQuickMenuExpanded = false;
  List<dynamic> _allFollowUps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final List<FollowUpModel> models = await FollowUpApi.fetchFollowUpLeads();
      if (mounted) {
        setState(() {
          _allFollowUps = models
              .whereType<FollowUpModel>()
              .map((m) => m.toMap())
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error in FollowUpScreen: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredList {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    
    final List<Map<String, dynamic>> safeList = _allFollowUps
        .where((item) => item != null && item is Map)
        .cast<Map<String, dynamic>>()
        .toList();

    return safeList.where((item) {
      // Filter by type
      final eType = item['enquiry_type']?.toString();
      bool typeMatch = false;
      if (_selectedIndex == 0) {
        typeMatch = (eType == '1' || eType == null || eType == '');
      } else if (_selectedIndex == 1) {
        typeMatch = (eType == '2');
      } else if (_selectedIndex == 2) {
        typeMatch = (eType == '3');
      }

      if (!typeMatch) return false;

      // Filter by date
      final date = item['next_follow_up_date']?.toString() ?? '';
      if (date == '0000-00-00' || date.isEmpty) {
        return !widget.isMissed;
      }

      if (widget.isMissed) {
        return date.compareTo(todayStr) < 0;
      } else {
        return date == todayStr;
      }
    }).toList();
  }

  // Helper to get properties based on selected index
  String get _title {
    String prefix = widget.isMissed ? 'Missed ' : '';
    switch (_selectedIndex) {
      case 0:
        return '${prefix}Lead Follow-ups';
      case 1:
        return '${prefix}Enquiry Follow-ups';
      case 2:
        return '${prefix}Referral Follow-ups';
      default:
        return '${prefix}Follow-up';
    }
  }

  String get _summaryTitle {
    String prefix = widget.isMissed ? 'Missed ' : 'Total ';
    switch (_selectedIndex) {
      case 0:
        return '${prefix}Lead Follow-up';
      case 1:
        return '${prefix}Enquiry Follow-up';
      case 2:
        return '${prefix}Referral Follow-up';
      default:
        return '${prefix}Follow-up';
    }
  }

  String get _summaryCount {
    return _filteredList.length.toString();
  }

  String get _assetIcon {
    switch (_selectedIndex) {
      case 0:
        return 'assets/icons/leads.png';
      case 1:
        return 'assets/icons/enquiry.png';
      case 2:
        return 'assets/icons/re.png';
      default:
        return 'assets/icons/leads.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return Scaffold(
      // backgroundColor: Colors.white, // Removed hardcoded color
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _title,
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () => _selectDate(context),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Buttons Row
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCircleAction(
                          'assets/icons/leads.png',
                          0,
                          screenWidth,
                        ),
                        _buildCircleAction(
                          'assets/icons/enquiry.png',
                          1,
                          screenWidth,
                        ),
                        _buildCircleAction(
                          'assets/icons/re.png',
                          2,
                          screenWidth,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFilterChip('Lead', 0, screenWidth),
                        _buildFilterChip('Enquiry', 1, screenWidth),
                        _buildFilterChip('Referral', 2, screenWidth),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Summary Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dynamic Icon
                        Image.asset(
                          _assetIcon,
                          width: screenWidth * 0.1,
                          height: screenWidth * 0.1,
                          errorBuilder: (c, e, s) {
                            if (_selectedIndex == 0) {
                              return Image.asset(
                                'assets/icons/today.png',
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.1,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.calendar_today,
                                  size: screenWidth * 0.1,
                                  color: Colors.redAccent,
                                ),
                              );
                            }
                            if (_selectedIndex == 1) {
                              return Icon(
                                Icons.group_add_rounded,
                                size: screenWidth * 0.1,
                                color: Colors.orange,
                              );
                            }
                            if (_selectedIndex == 2) {
                              return Icon(
                                Icons.calendar_month_outlined,
                                size: screenWidth * 0.1,
                                color: Colors.cyan,
                              );
                            }
                            return Icon(
                              Icons.ads_click_rounded,
                              size: screenWidth * 0.1,
                              color: Colors.redAccent,
                            );
                          },
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          _summaryTitle,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _summaryCount,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // List Items
              _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
                : _filteredList.isEmpty 
                  ? Center(
                      child: Column(
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No follow-ups found', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredList.length,
                      itemBuilder: (context, index) {
                        return LeadRowCard(
                          lead: _filteredList[index],
                          onCall: () => _confirmCall(_filteredList[index]),
                        );
                      },
                    ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isQuickMenuExpanded) ...[
            _buildQuickActionItem(
              'assets/icons/what.png',
              () {},
            ),
            const SizedBox(height: 12),
            _buildQuickActionItem(Icons.email_outlined, () {}),
            const SizedBox(height: 12),
            _buildQuickActionItem(Icons.phone_outlined, () {
              if (_filteredList.isNotEmpty) {
                _confirmCall(_filteredList.first);
              }
            }),
            const SizedBox(height: 12),
            _buildQuickActionItem(Icons.message_outlined, () {}),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: () {
              setState(() {
                _isQuickMenuExpanded = !_isQuickMenuExpanded;
              });
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isQuickMenuExpanded
                          ? const Color(0xFFD9D9D9)
                          : null,
                      gradient: _isQuickMenuExpanded
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF1B7BBC), Color(0xFF26A69A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    ),
                  ),
                  const Text(
                    'Quick',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCall(Map<String, dynamic> lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => CallConfirmationPopup(
        lead: lead,
        onCancel: () => Navigator.pop(c),
        onConfirm: () async {
          Navigator.pop(c);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CallOutcomeScreen(lead: lead, autoCall: true),
            ),
          ).then((_) => _fetchData());
        },
      ),
    );
  }

  Widget _buildCircleAction(String assetPath, int index, double screenWidth) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF26A69A)
              : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.white),
          shape: BoxShape.circle,
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: screenWidth * 0.06,
            height: screenWidth * 0.06,
            color: isSelected ? Colors.white : const Color(0xFF26A69A),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, double screenWidth) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          height: screenWidth * 0.12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2440)
                      : const Color(0xFFF3F0F5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpCard({
    required String name,
    required String leadNo,
    required String time,
    String? tag,
    Color? tagColor,
    String? reason,
    String? purpose,
    bool hasLeftBorder = false,
    Color borderColor = const Color(0xFF76E888),
    bool showRescheduleButton = false,
    bool showArrow = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasLeftBorder)
            Container(
              width: 4,
              height: reason != null
                  ? 100
                  : 80, // Dynamic height based on fields
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnquiryTabsView(
                      lead: {'cus_name': name, 'enquiry_date': leadNo},
                      status: 'Follow up',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      Theme.of(
                        context,
                      ).cardTheme.color?.withValues(alpha: 0.5) ??
                      const Color(0xFFF7F7F7),
                  borderRadius: hasLeftBorder
                      ? const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        )
                      : BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(Icons.person_outline, 'Name', name),
                              const SizedBox(height: 4),
                              _buildInfoRow(
                                Icons.track_changes,
                                'Lead No',
                                leadNo,
                              ),
                              const SizedBox(height: 4),
                              _buildInfoRow(Icons.calendar_month, 'Time', time),
                              if (reason != null) ...[
                                const SizedBox(height: 4),
                                _buildInfoRow(
                                  Icons.center_focus_weak_sharp,
                                  'Reason',
                                  reason,
                                  valueColor: _selectedIndex == 1
                                      ? const Color(0xFF05660E)
                                      : borderColor,
                                  labelColor: _selectedIndex == 1
                                      ? const Color(0xFF05660E)
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (showArrow)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Image.asset(
                                  'assets/icons/green_next.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            if (tag != null && tagColor != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: tagColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (showRescheduleButton)
                              GestureDetector(
                                onTap: () =>
                                    _showRescheduleBottomSheet(context),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF7B7B),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Reschedule',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (purpose != null) ...[
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.track_changes_outlined,
                        'Purpose',
                        purpose,
                      ),
                    ],
                    // "View Full Detail >>" on the next row bottom right
                    if (_selectedIndex == 0)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EnquiryTabsView(
                                  lead: {},
                                  status: 'Follow up',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'View Full Detail >>',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    Color? labelColor,
  }) {
    final Color effectiveLabelColor =
        labelColor ??
        (Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey);
    final Color effectiveValueColor =
        valueColor ??
        (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: effectiveLabelColor),
        const SizedBox(width: 8),
        Text(
          '$label :',
          style: TextStyle(fontSize: 14, color: effectiveLabelColor),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: effectiveValueColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF26A69A),
              brightness: Theme.of(context).brightness,
              primary: const Color(0xFF26A69A),
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _showRescheduleBottomSheet(BuildContext context) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Select Reschedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color:
                        Theme.of(context).textTheme.titleLarge?.color ??
                        Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildBottomSheetItem(context, 'Today'),
              _buildBottomSheetItem(context, 'Tomorrow'),
              _buildBottomSheetItem(context, '3 Days from Now'),
              _buildBottomSheetItem(context, '1 Week From Now'),
              _buildBottomSheetItem(context, '1 Moths from Now'),
              _buildBottomSheetItem(
                context,
                'Select Custom Date',
                isCustomDate: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetItem(
    BuildContext context,
    String title, {
    bool isCustomDate = false,
  }) {
    return Column(
      children: [
        Divider(color: Theme.of(context).dividerColor, height: 1),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            if (isCustomDate) {
              _selectDate(context);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                  ),
                ),
                if (isCustomDate) const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(
    dynamic iconOrAsset,
    VoidCallback onTap, {
    Color? color,
  }) {
    // If it's an Icon widget, extract its properties or use it directly
    Widget iconWidget;
    if (iconOrAsset is IconData) {
      iconWidget = Icon(iconOrAsset, color: color ?? Colors.white, size: 24);
    } else if (iconOrAsset is String) {
      iconWidget = Image.asset(
        iconOrAsset,
        width: 24,
        height: 24,
        color: color,
      );
    } else if (iconOrAsset is ImageProvider) {
      iconWidget = Image(
        image: iconOrAsset,
        width: 24,
        height: 24,
        color: color,
      );
    } else if (iconOrAsset is Widget) {
      iconWidget = iconOrAsset;
    } else {
      iconWidget = const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: Color(0xFF26A69A),
          shape: BoxShape.circle,
        ),
        child: Center(child: iconWidget),
      ),
    );
  }
}