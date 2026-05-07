import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/leave_api.dart';
import 'leave_application.dart';
import 'permission_form.dart';
import '../../models/permission_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_smart/theme/Service /lib/core/size_utils.dart';

enum LeaveManagementMode {
  selection,
  leaveDashboard,
  leaveForm,
  permissionDashboard,
  permissionForm,
}

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  LeaveManagementMode _currentMode = LeaveManagementMode.selection;
  int selectedTab = 0; // 0 = Summary, 1 = History
  List<dynamic> leaveHistoryData = [];
  List<dynamic> permissionHistoryData = [];
  bool isLoading = false;
  bool isBalanceLoading = false;

  final Color appThemeColor = const Color(0xff26A69A); // Main Green Color

  List<Map<String, dynamic>> leaveBalanceData = [];

  final List<Color> _progressColors = [
    const Color(0xff8388FF),
    const Color(0xff59FAFF),
    const Color(0xffD679F8),
    const Color(0xFFFB6065),
    const Color(0xFF26A69A),
    const Color(0xFFFACC15),
    const Color(0xFF6366F1),
  ];

  List<dynamic> apiHolidays = [];
  bool isHolidaysLoading = false;
  DateTime calendarViewDate = DateTime.now(); // Default to current month/year

  @override
  void initState() {
    super.initState();
    _fetchLeaveSummary();
    _fetchHolidays();
  }

  Future<void> _fetchHolidays() async {
    if (!mounted) return;
    setState(() => isHolidaysLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? prefs.getString('cid_str') ?? "99994444";
      final String deviceId = prefs.getString('device_id') ?? "123";
      final String lat = prefs.getString('lt') ?? prefs.getDouble('lat')?.toString() ?? "0.0";
      final String lng = prefs.getString('ln') ?? prefs.getDouble('lng')?.toString() ?? "0.0";

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "3039",
          "cid": cid,
          "device_id": deviceId,
          "lt": lat,
          "ln": lng,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          final hData = data['data'];
          if (mounted) {
            setState(() {
              apiHolidays = hData['holidays'] ?? [];
              isHolidaysLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching holidays: $e");
      if (mounted) setState(() => isHolidaysLoading = false);
    }
  }

  Future<void> _fetchLeaveSummary() async {
    if (!mounted) return;
    setState(() => isBalanceLoading = true);
    try {
      // 1. Try fetching official Leave Summary (Type 2051)
      final summaryRes = await LeaveService.getLeaveSummary();
      List<dynamic> apiSummaryList = [];
      if (summaryRes['error'] == false || summaryRes['error'] == "false") {
        var sData = summaryRes['data'];
        if (sData is List) apiSummaryList = sData;
        else if (sData is Map) apiSummaryList = sData['leave_types'] ?? sData['summary'] ?? [];
      }

      // 2. Fetch Leave Types (Type 2044)
      final types = await LeaveService.getLeaveTypes();

      setState(() {
        leaveBalanceData = types.asMap().entries.map((entry) {
          int index = entry.key;
          var t = entry.value;
          String tid = t['id']?.toString() ?? "";
          
          // Look for this type in the summary list if available
          var summaryItem = apiSummaryList.firstWhere(
            (s) => s['id']?.toString() == tid || s['leave_type_id']?.toString() == tid,
            orElse: () => null
          );

          double taken = 0;
          if (summaryItem != null) {
            taken = double.tryParse(summaryItem['taken']?.toString() ?? summaryItem['leave_taken']?.toString() ?? "0") ?? 0;
          }

          return {
            "id": tid,
            "type": t['name'],
            "taken": taken,
            "total": int.tryParse(t['max_year']?.toString() ?? summaryItem?['total']?.toString() ?? "12") ?? 12,
            "balance": "0/0",
            "progressColor": _progressColors[index % _progressColors.length],
          };
        }).toList();
      });

      // 3. Fetch history for the activity list
      await _fetchLeaveHistory();
    } catch (e) {
      debugPrint("Error fetching leave summary: $e");
    } finally {
      if (mounted) setState(() => isBalanceLoading = false);
    }
  }

  Future<void> _fetchLeaveHistory() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final res = await LeaveService.getLeaveHistory();
      if (res['error'] == false) {
        List<dynamic> fetchedList = res['leave_applications'] ?? res['data'] ?? [];
        // Sort by ID descending — highest ID (latest applied) shows first
        fetchedList.sort((a, b) {
          int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
          int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
          return idB.compareTo(idA);
        });
        setState(() {
          leaveHistoryData = fetchedList.where((item) {
            final String delFlag = item['del']?.toString() ?? "";
            final String isDFlag = item['is_d']?.toString() ?? "";
            return delFlag != "1" && isDFlag != "1";
          }).toList();
          _calculateBalances();
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _calculateBalances() {
    for (var b in leaveBalanceData) b['taken'] = 0;
    for (var h in leaveHistoryData) {
      String status = (h['status'] ?? "0").toString().toLowerCase();
      bool isApproved = (status == "1" ||
          status == "accept" ||
          status == "approved" ||
          status.contains("approv"));
      if (!isApproved) continue;

      num days = 1;
      if (h['leave_taken'] != null &&
          h['leave_taken'].toString().isNotEmpty &&
          h['leave_taken'].toString() != "null") {
        days = num.tryParse(h['leave_taken'].toString()) ?? 1;
      } else if (h['total_days'] != null &&
          h['total_days'].toString().isNotEmpty &&
          h['total_days'].toString() != "null") {
        days = num.tryParse(h['total_days'].toString()) ?? 1;
      }
      String type = (h['leave_type'] ?? "").toString().toLowerCase();

      for (var b in leaveBalanceData) {
        String bType = b['type'].toString().toLowerCase();
        String bId = b['id']?.toString() ?? "";

        bool match = false;
        String hType = (h['leave_type'] ?? "").toString().toLowerCase();
        String hTypeId = (h['leave_type_id'] ?? "").toString();

        if (bId.isNotEmpty && hTypeId == bId) {
          match = true;
        } else if (hType.contains(bType) || bType.contains(hType)) {
          match = true;
        }

        if (match) {
          b['taken'] = (b['taken'] as num) + days;
          break;
        }
      }
    }
    for (var b in leaveBalanceData) {
      num taken = b['taken'];
      if (b['type'].toString().toLowerCase() == "unpaid")
        b['balance'] = "$taken/-";
      else
        b['balance'] = "${(b['total'] ?? 12) - taken}/${b['total'] ?? 12}";
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = "Leave Management";
    if (_currentMode == LeaveManagementMode.leaveDashboard)
      title = "Leave Request";
    if (_currentMode == LeaveManagementMode.leaveForm) title = "Apply Leave";
    if (_currentMode == LeaveManagementMode.permissionDashboard)
      title = "Permission Request";
    if (_currentMode == LeaveManagementMode.permissionForm)
      title = "Apply Permission";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: appThemeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (_currentMode == LeaveManagementMode.selection) {
              Navigator.pop(context);
            } else if (_currentMode == LeaveManagementMode.leaveForm) {
              setState(() => _currentMode = LeaveManagementMode.leaveDashboard);
            } else if (_currentMode == LeaveManagementMode.permissionForm) {
              setState(
                  () => _currentMode = LeaveManagementMode.permissionDashboard);
            } else {
              setState(() => _currentMode = LeaveManagementMode.selection);
            }
          },
        ),
        title: Text(title,
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentMode) {
      case LeaveManagementMode.selection:
        return _buildSelectionMode();
      case LeaveManagementMode.leaveDashboard:
        return RefreshIndicator(
          onRefresh: () async {
            await _fetchLeaveSummary();
            await _fetchLeaveHistory();
          },
          color: appThemeColor,
          child: _buildDashboardMode(),
        );
      case LeaveManagementMode.permissionDashboard:
        return RefreshIndicator(
          onRefresh: () async => await _fetchPermissionHistory(),
          color: appThemeColor,
          child: _buildDashboardMode(),
        );
      case LeaveManagementMode.leaveForm:
        return SingleChildScrollView(
            padding: EdgeInsets.all(20.r), child: const LeaveForm());
      case LeaveManagementMode.permissionForm:
        return SingleChildScrollView(
            padding: EdgeInsets.all(20.r), child: const PermissionForm());
    }
  }

  Widget _buildSelectionMode() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text("Welcome back!",
              style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B2C61))),
          Text("Select a category to manage your requests.",
              style: GoogleFonts.poppins(
                  fontSize: 14.sp, color: const Color(0xFF64748B))),
          const SizedBox(height: 32),
          _selectionCardResponsive(
              "Leave Request",
              "Total Leave: 12 Days Yearly",
              "Manage balance & history",
              Icons.event_note_rounded,
              appThemeColor, () {
            setState(() {
              _currentMode = LeaveManagementMode.leaveDashboard;
              selectedTab = 0;
            });
            _fetchLeaveSummary();
          }),
          const SizedBox(height: 20),
          _selectionCardResponsive(
              "Permission Request",
              "Total Permission: 2/Month",
              "Apply personal permission",
              Icons.more_time_rounded,
              appThemeColor, () {
            setState(() {
              _currentMode = LeaveManagementMode.permissionDashboard;
              selectedTab = 0;
            });
            _fetchPermissionHistory();
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _selectionCardResponsive(String title, String subtitle, String desc,
      IconData icon, Color color, VoidCallback onTap) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 20.r,
                  offset: Offset(0, 10.h))
            ],
            border: Border.all(color: color.withOpacity(0.1), width: 1.5.w),
          ),
          child: Stack(
            children: [
              Positioned(
                  top: -30,
                  right: -30,
                  child: CircleAvatar(
                      radius: 70.r, backgroundColor: color.withOpacity(0.04))),
              Padding(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r)),
                        child: Icon(icon, color: color, size: 28.r)),
                    const Spacer(),
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B2C61))),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color)),
                    Text(desc,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ),
              Positioned(
                  bottom: 20,
                  right: 20.w,
                  child: CircleAvatar(
                      radius: 20.r,
                      backgroundColor: color,
                      child: Icon(Icons.arrow_forward_ios,
                          size: 14.r, color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardMode() {
    return Column(
      children: [
        _buildTabs(appThemeColor),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                (_currentMode == LeaveManagementMode.permissionDashboard ||
                        selectedTab == 1)
                    ? (isLoading
                        ? const Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator()))
                        : _buildHistoryList())
                    : (isBalanceLoading
                        ? const Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator()))
                        : _buildSummaryGrid()),
                if (_currentMode == LeaveManagementMode.leaveDashboard) ...[
                  const SizedBox(height: 20),
                  _buildHolidayListCard(),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildApplyButton(appThemeColor),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTabs(Color themeColor) {
    if (_currentMode == LeaveManagementMode.permissionDashboard)
      return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30)),
        child: Row(children: [
          _tabItem(0, "Summary", themeColor),
          _tabItem(1, "History", themeColor)
        ]),
      ),
    );
  }

  Widget _tabItem(int index, String label, Color themeColor) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected ? themeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(30)),
          child: Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600)),
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    bool isLeave = _currentMode == LeaveManagementMode.leaveDashboard;
    List<Map<String, dynamic>> dataList = isLeave ? leaveBalanceData : [];
    if (!isLeave)
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child:
                  Text("Detailed summaries available in the history list.")));
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1),
      itemCount: dataList.length,
      itemBuilder: (context, index) => _balanceCard(dataList[index]),
    );
  }

  Widget _balanceCard(Map<String, dynamic> data) {
    num taken = data['taken'] ?? 0;
    num total = data['total'] ?? 12;
    double progress = total == 0 ? 0 : (taken / total).clamp(0.0, 1.0);
    String balanceText = data['balance'] ?? "0/0";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                      radius: 4, backgroundColor: data['progressColor']),
                  const SizedBox(width: 8),
                  Text(data['type'],
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B2C61)))
                ]),
                const SizedBox(height: 10),
                _balanceInfoRow("Taken", ": $taken"),
                const SizedBox(height: 4),
                _balanceInfoRow("Balance", ": $balanceText"),
              ],
            ),
          ),
          const Spacer(),
          Container(
            height: 6,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                    decoration: BoxDecoration(
                        color: data['progressColor'],
                        borderRadius: BorderRadius.circular(10)))),
          ),
        ],
      ),
    );
  }

  Widget _balanceInfoRow(String label, String value) {
    return Row(children: [
      SizedBox(
          width: 60,
          child: Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B)))),
      Text(value,
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B2C61)))
    ]);
  }

  Widget _buildHolidayListCard() {
    return InkWell(
      onTap: _showHolidayList,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB7B7).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month,
                color: Color(0xFF1B2C61), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Holiday List 2026",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1B2C61),
                ),
              ),
            ),
            const Icon(Icons.arrow_right, color: Color(0xFF1B2C61)),
          ],
        ),
      ),
    );
  }

  void _showHolidayList() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Helper to get days in month
          int daysInMonth(DateTime date) =>
              DateTime(date.year, date.month + 1, 0).day;
          int firstDayOffset(DateTime date) =>
              DateTime(date.year, date.month, 1).weekday % 7;

          final monthYearStr = DateFormat('MMMM yyyy').format(calendarViewDate);

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.95,
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                children: [
                  // --- HEADER ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appThemeColor, appThemeColor.withOpacity(0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Holiday Calendar",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Official Company Holidays",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  // --- MONTH NAVIGATION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavBtn(Icons.chevron_left_rounded, () {
                          setDialogState(() {
                            calendarViewDate = DateTime(
                                calendarViewDate.year, calendarViewDate.month - 1);
                          });
                        }),
                        Text(
                          monthYearStr,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B2C61),
                          ),
                        ),
                        _buildNavBtn(Icons.chevron_right_rounded, () {
                          setDialogState(() {
                            calendarViewDate = DateTime(
                                calendarViewDate.year, calendarViewDate.month + 1);
                          });
                        }),
                      ],
                    ),
                  ),

                  // --- WEEK DAYS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                          .map((d) => Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(d,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade400)),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- CALENDAR GRID ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        itemCount: daysInMonth(calendarViewDate) +
                            firstDayOffset(calendarViewDate),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          int offset = firstDayOffset(calendarViewDate);
                          if (index < offset) return const SizedBox.shrink();

                          int day = index - offset + 1;
                          DateTime date = DateTime(
                              calendarViewDate.year, calendarViewDate.month, day);
                          String dateStr = DateFormat('yyyy-MM-dd').format(date);

                          var holiday = apiHolidays.firstWhere(
                              (h) => h['date'] == dateStr,
                              orElse: () => null);

                          bool isToday = DateFormat('yyyy-MM-dd')
                                  .format(DateTime.now()) ==
                              dateStr;

                          return Container(
                            decoration: BoxDecoration(
                              color: holiday != null
                                  ? appThemeColor.withOpacity(0.1)
                                  : (isToday
                                      ? Colors.grey.shade100
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(12),
                              border: holiday != null
                                  ? Border.all(
                                      color: appThemeColor.withOpacity(0.3))
                                  : null,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  day.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: holiday != null || isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: holiday != null
                                        ? appThemeColor
                                        : (isToday
                                            ? Colors.black
                                            : Colors.grey.shade700),
                                  ),
                                ),
                                if (holiday != null)
                                  Positioned(
                                    bottom: 4,
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: appThemeColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // --- HOLIDAY DETAILS IN CURRENT MONTH ---
                  Container(
                    height: 180,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: _buildMonthHolidaysList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: appThemeColor, size: 20),
      ),
    );
  }

  Widget _buildMonthHolidaysList() {
    final monthHolidays = apiHolidays.where((h) {
      DateTime dt = DateTime.parse(h['date']);
      return dt.month == calendarViewDate.month &&
          dt.year == calendarViewDate.year;
    }).toList();

    if (monthHolidays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available_rounded,
                color: Colors.grey.shade300, size: 40),
            const SizedBox(height: 8),
            Text("No holidays this month",
                style: GoogleFonts.poppins(
                    color: Colors.grey.shade400, fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: monthHolidays.length,
      itemBuilder: (context, index) {
        final h = monthHolidays[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 45,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: appThemeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(h['date'].split('-')[2],
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, color: appThemeColor)),
                    Text(DateFormat('MMM').format(DateTime.parse(h['date'])),
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: appThemeColor)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h['holiday'] ?? h['name'] ?? "",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF1B2C61))),
                    Text(h['day'] ?? "",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    bool isLeave = _currentMode == LeaveManagementMode.leaveDashboard;
    List<dynamic> dataToUse =
        isLeave ? leaveHistoryData : permissionHistoryData;
    if (dataToUse.isEmpty)
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(40), child: Text("No records found")));
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dataToUse.length,
        itemBuilder: (context, index) => _historyCard(dataToUse[index]));
  }

  Widget _buildApplyButton(Color themeColor) {
    bool isLeave = _currentMode == LeaveManagementMode.leaveDashboard;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () => setState(() => _currentMode = isLeave
              ? LeaveManagementMode.leaveForm
              : LeaveManagementMode.permissionForm),
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Text(
            isLeave ? "Apply for Leave" : "Apply for Permission",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchPermissionHistory() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final res = await PermissionApi.getPermissionHistory();
      debugPrint("PERMISSION HISTORY API RESULT: $res");
      if (res['error'].toString() == "false") {
        List<dynamic> permList = [];
        if (res['data'] is List) {
          permList = res['data'];
        } else if (res['data'] is Map) {
          permList = res['data']['permission_history'] ??
              res['data']['history'] ??
              res['data']['data'] ??
              [];
        } else {
          permList = res['permission_history'] ?? res['data'] ?? [];
        }

        if (permList is! List) permList = [];

        // Sort by ID descending — highest ID (latest applied) shows first
        permList.sort((a, b) {
          int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
          int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
          return idB.compareTo(idA);
        });
        setState(() {
          permissionHistoryData = permList;
        });
      }
    } catch (e) {
      debugPrint("Error fetching permission history: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _historyCard(Map<String, dynamic> item) {
    bool isLeave = _currentMode == LeaveManagementMode.leaveDashboard;
    String status = (item['status'] ?? "Pending").toString().toLowerCase();
    Color statusColor = Colors.orange;

    if (status.contains("approv") ||
        status == "accept" ||
        status == "1" ||
        status == "approved") {
      statusColor = Colors.green;
      status = "Approved";
    } else if (status.contains("reject") ||
        status == "2" ||
        status == "decline" ||
        status == "rejected") {
      statusColor = Colors.red;
      status = "Rejected";
    } else {
      status = "Pending";
    }

    String title = "";
    String subtitle = "";
    String dateRange = "";
    String days = "";

    if (isLeave) {
      title = (item['leave_type'] ?? "Leave Request").toString();
      subtitle = (item['reason'] ?? "").toString();
      dateRange = "${item['leave_start_date']} to ${item['leave_end_date']}";
      days = " (${item['total_days'] ?? '0'} Days)";
    } else {
      // Permission History mapping based on type 2078
      title = (item['permission_type_name'] != null &&
              item['permission_type_name'].toString().trim().isNotEmpty)
          ? item['permission_type_name'].toString()
          : (item['reason'] ?? "Permission Request").toString();

      subtitle = (item['reason'] ?? "").toString();

      String date = item['permission_date'] ??
          item['applied_date'] ??
          item['app_date'] ??
          item['date'] ??
          "-";
      String startTime = item['from_time'] ?? item['start_time'] ?? "";
      String endTime = item['end_time'] ?? item['to_time'] ?? "";

      dateRange = date;
      if (startTime.isNotEmpty && startTime != "-")
        dateRange += " at $startTime";
      if (endTime.isNotEmpty && endTime != "-") dateRange += " - $endTime";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "$title$days",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B2C61),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                dateRange,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty && subtitle != title) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
