import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../core/app_colors.dart';
import '../../data/app_data.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'all_tickets_job_card.dart';
import 'dart:convert';
import 'dart:async';

class AllTicketsScreen extends StatefulWidget {
  const AllTicketsScreen({super.key});

  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  DateTime? _selectedDateFilter;
  List<dynamic> _tickets = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _priorityListCache = [];
  List<Map<String, dynamic>> _engineerListCache = [];
  Timer? _searchDebounce;

  // Pre-computed data to prevent ANR
  List<Map<String, dynamic>> _allProcessedTickets = [];
  Map<String, List<Map<String, dynamic>>> _displayedGroupedTickets = {};
  int _countAll = 0, _countOpened = 0, _countAssigned = 0, _countCompleted = 0;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
    _prefetchDropdownData();
  }

  Future<void> _prefetchDropdownData() async {
    try {
      final resP = await ApiService.getPriorityDropdown();
      if (resP != null && resP['error'] == false) {
        _priorityListCache = List<Map<String, dynamic>>.from(
          resP['dropdown'] ?? [],
        );
      }
      final resE = await ApiService.getEngineerDropdown();
      if (resE != null && resE['error'] == false) {
        _engineerListCache = List<Map<String, dynamic>>.from(
          resE['data'] ?? [],
        );
      }
    } catch (e) {
      debugPrint("Prefetch Error: $e");
    }
  }

  Future<void> _fetchTickets() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = await StorageService.getCid() ?? '';
      final uid = await StorageService.getUid() ?? '';
      final roleId = await StorageService.getRoleId() ?? '';
      final token = await StorageService.getToken() ?? '';
      final lat = prefs.getString('lt') ?? '11.0';
      final lon = prefs.getString('ln') ?? '77.0';

      final res = await ApiService.getTickets(
        cid: cid,
        uid: uid,
        roleId: roleId,
        token: token,
        lat: lat,
        lon: lon,
      );

      if (res != null &&
          (res['error'] == false ||
              res['error'] == 0 ||
              res['error'].toString() == '0')) {
        _tickets = (res['records'] is List) ? res['records'] : [];
        _processAllTicketsData();
        _applyFiltersAndGroup();
        if (mounted) setState(() => _isLoading = false);
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching tickets: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _processAllTicketsData() {
    _allProcessedTickets = _tickets.map((t) {
      final dtimeStr = t['dtime']?.toString() ?? '';
      DateTime createdAt = DateTime.now();
      try {
        if (dtimeStr.isNotEmpty) {
          createdAt = DateTime.parse(dtimeStr);
        }
      } catch (_) {}

      final String rawStatus = (t['status']?.toString() ?? '')
          .toUpperCase()
          .trim();
      String statusLabel = 'Opened';
      String filterCat = 'OPENED';

      if (rawStatus.contains('ASSIGNED') || rawStatus == 'ACCEPTED') {
        statusLabel = 'Assigned';
        filterCat = 'ASSIGNED';
      } else if (rawStatus.contains('COMPLETED') || rawStatus == 'RESOLVED') {
        statusLabel = 'Completed';
        filterCat = 'COMPLETED';
      } else if (rawStatus.contains('PENDING') ||
          rawStatus.contains('OPENED')) {
        statusLabel = 'Opened';
        filterCat = 'OPENED';
      } else {
        // Fallback for safety
        statusLabel = 'Opened';
        filterCat = 'OPENED';
      }

      return {
        'id': t['id'],
        'ticketNo': '#JOB-${t['id']}',
        'name': t['customer_id']?.toString() ?? 'Unknown',
        'issue':
            t['complaint_name']?.toString() ??
            t['complaint_desc']?.toString() ??
            'No Issue',
        'location': t['address']?.toString() ?? 'N/A',
        'dateText': _formatDateShort(createdAt),
        'timeText': _formatTimeShort(createdAt),
        'createdAt': createdAt,
        'status': statusLabel,
        'filterCategory': filterCat,
        'product': t['product_name']?.toString() ?? '',
        'priority': t['priority_name']?.toString() ?? 'LOW',
        'complaint_desc': t['complaint_desc']?.toString() ?? '',
        'photo': t['photo']?.toString(),
        'audio': t['audio']?.toString(),
        'pho': t['pho']?.toString(),
        'note': t['remark']?.toString() ?? t['note']?.toString() ?? 'N/A',
        'cus_id': t['cus_id']?.toString() ?? '',
      };
    }).toList();

    // Sort descending by date once
    _allProcessedTickets.sort(
      (a, b) =>
          (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime),
    );

    // Update counts
    _countAll = _allProcessedTickets.length;
    _countOpened = _allProcessedTickets
        .where((t) => t['filterCategory'] == 'OPENED')
        .length;
    _countAssigned = _allProcessedTickets
        .where((t) => t['filterCategory'] == 'ASSIGNED')
        .length;
    _countCompleted = _allProcessedTickets
        .where((t) => t['filterCategory'] == 'COMPLETED')
        .length;
  }

  void _applyFiltersAndGroup() {
    var filtered = _allProcessedTickets.where((t) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          '${t['ticketNo']}'.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          '${t['name']}'.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFilter =
          _selectedFilter == 'ALL' || t['filterCategory'] == _selectedFilter;

      bool matchesDate = true;
      if (_selectedDateFilter != null) {
        final ticketDate = t['createdAt'] as DateTime;
        matchesDate =
            ticketDate.year == _selectedDateFilter!.year &&
            ticketDate.month == _selectedDateFilter!.month &&
            ticketDate.day == _selectedDateFilter!.day;
      }

      return matchesSearch && matchesFilter && matchesDate;
    }).toList();

    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var ticket in filtered) {
      DateTime dt = ticket['createdAt'] as DateTime;
      String dayKey = _formatDayHeader(dt);
      if (!grouped.containsKey(dayKey)) grouped[dayKey] = [];
      grouped[dayKey]!.add(ticket);
    }

    _displayedGroupedTickets = grouped;
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }

  String _formatTimeShort(DateTime date) {
    String period = date.hour >= 12 ? 'PM' : 'AM';
    int h = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    String m = date.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  String _formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final difference = DateTime(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;

    if (difference == 0) return 'Today, ${_formatDateShort(date)}';
    if (difference == -1) return 'Yesterday, ${_formatDateShort(date)}';
    if (difference == 1) return 'Tomorrow, ${_formatDateShort(date)}';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _mapStatusToFilter(String status) {
    final s = status.toUpperCase();
    if (s == 'PENDING' || s == 'OPENED') return 'OPENED';
    if (s == 'ASSIGNED' || s == 'ACCEPTED' || s == 'IN PROGRESS')
      return 'ASSIGNED';
    if (s == 'COMPLETED') return 'COMPLETED';
    return 'OPENED';
  }

  String _displayTicketNo(String value) {
    return value.replaceFirst(RegExp(r'^#?(TCK|TKT)-'), '#JOB-');
  }

  int _statusStep(String status) {
    final s = status.toLowerCase();
    if (s == 'pending' || s == 'opened') return 1;
    if (s == 'accepted' || s == 'assigned') return 2;
    if (s == 'in progress') return 3;
    if (s == 'completed') return 4;
    return 1;
  }

  String _statusTitle(String status) {
    final s = status.toLowerCase();
    if (s == 'pending' || s == 'opened') return 'Opened';
    if (s == 'accepted' || s == 'assigned') return 'Assigned';
    if (s == 'in progress') return 'Visit in progress';
    if (s == 'completed') return 'Completed';
    return status;
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // Top Bar
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 16.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'All Tickets',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: TextField(
                    onChanged: (val) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 300),
                        () {
                          _searchQuery = val;
                          _applyFiltersAndGroup();
                          if (mounted) setState(() {});
                        },
                      );
                    },
                    onSubmitted: (val) {
                      _searchQuery = val;
                      _applyFiltersAndGroup();
                      setState(() {});
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search Ticket , Customer.',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: const Color(0xFF9E9E9E),
                        size: 22.sp,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: _selectedDateFilter != null
                              ? AppColors.primary
                              : const Color(0xFF9E9E9E),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDateFilter ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppColors.primary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          _selectedDateFilter = date;
                          _applyFiltersAndGroup();
                          setState(() {});
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: 16.w, bottom: 20.h),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'ALL($_countAll)',
                      selected: _selectedFilter == 'ALL',
                      onTap: () {
                        _selectedFilter = 'ALL';
                        _applyFiltersAndGroup();
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 10.w),
                    _FilterChip(
                      label: 'OPENED ($_countOpened)',
                      selected: _selectedFilter == 'OPENED',
                      onTap: () {
                        _selectedFilter = 'OPENED';
                        _applyFiltersAndGroup();
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 10.w),
                    _FilterChip(
                      label: 'ASSIGNED ($_countAssigned)',
                      selected: _selectedFilter == 'ASSIGNED',
                      onTap: () {
                        _selectedFilter = 'ASSIGNED';
                        _applyFiltersAndGroup();
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 10.w),
                    _FilterChip(
                      label: 'COMPLETED ($_countCompleted)',
                      selected: _selectedFilter == 'COMPLETED',
                      onTap: () {
                        _selectedFilter = 'COMPLETED';
                        _applyFiltersAndGroup();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

              // List Area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _displayedGroupedTickets.isEmpty
                    ? Center(
                        child: Text(
                          'No tickets found.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _displayedGroupedTickets.length,
                        itemBuilder: (context, index) {
                          String dayKey = _displayedGroupedTickets.keys
                              .elementAt(index);
                          List<Map<String, dynamic>> dayTickets =
                              _displayedGroupedTickets[dayKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Text(
                                  dayKey,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF445B87),
                                  ),
                                ),
                              ),
                              ...dayTickets.asMap().entries.map((entry) {
                                final t = entry.value;
                                return AllTicketsJobCard(
                                  ticketNo: t['ticketNo'],
                                  name: t['name'],
                                  issue: t['issue'],
                                  dateText: t['dateText'],
                                  timeText: t['timeText'],
                                  label: t['status'],
                                  filterCategory: t['filterCategory'],
                                  address: t['location'],
                                  product: t['product'],
                                  phone: t['pho'] ?? '+91 00000 00000',
                                  complaint: t['complaint_desc'],
                                  photo: t['photo'],
                                  audio: t['audio'],
                                  priorityName: t['priority'],
                                  note: t['note'] ?? 'N/A',
                                  cusId: t['cus_id'] ?? '',
                                  onTap: () async {
                                    if (t['cus_id'] != null &&
                                        t['cus_id'].toString().isNotEmpty) {
                                      await StorageService.saveCusId(
                                        t['cus_id'].toString(),
                                      );
                                    }
                                  },
                                  onAssignTap: () =>
                                      _openAssignBottomSheet(context, t),
                                  onViewStatusTap: () =>
                                      _openStatusDialog(context, t),
                                  onCloseWithReason: (reason) {
                                    // Implementation for closing ticket via API
                                  },
                                );
                              }),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAssignBottomSheet(
    BuildContext context,
    Map<String, dynamic> ticketData,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _AssignBottomSheet(
          ticketData: ticketData,
          cachedPriorities: _priorityListCache,
          cachedEngineers: _engineerListCache,
          onAssign:
              (
                String priority,
                String engineerName,
                String engineerId,
                String locationVerify,
                String warranty,
                String approxCharge,
                String expense,
              ) async {
                try {
                  // Show loading if possible, but for now just call the API
                  final res = await ApiService.assignTicket(
                    ticketId: ticketData['id'].toString(),
                    engineerId: engineerId,
                    priority: priority,
                    locationVerify: locationVerify,
                    warranty: warranty,
                    approxCharge: approxCharge,
                    expense: expense,
                  );

                  if (res != null && res['error'] == false) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ticket ${ticketData['ticketNo']} assigned to $engineerName successfully',
                          ),
                        ),
                      );
                      _fetchTickets(); // Refresh list from backend
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to assign ticket: ${res?['message'] ?? 'Unknown error'}',
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error assigning ticket: $e')),
                    );
                  }
                }
              },
        );
      },
    );
  }

  void _openStatusDialog(
    BuildContext context,
    Map<String, dynamic> ticketData,
  ) {
    final status = '${ticketData['status'] ?? ''}';
    final currentStep = _statusStep(status);
    final ticketNo = '${ticketData['ticketNo'] ?? ''}';
    final name = '${ticketData['name'] ?? ''}';
    final issue = '${ticketData['issue'] ?? ''}';
    final location = '${ticketData['location'] ?? ''}';
    final dateText = '${ticketData['dateText'] ?? ''}';
    final timeText = '${ticketData['timeText'] ?? ''}';
    final priority = '${ticketData['priority'] ?? ''}';
    final product = '${ticketData['product'] ?? ''}';
    final statusLabel = _statusTitle(status);

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 18.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Status Tracking',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20.sp,
                            color: const Color(0xFF667085),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F8FF),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFD9E2FF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ticketNo,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F0FF),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          issue,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF445B87),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '$product - $priority',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF667085),
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '$location - $dateText - $timeText',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: const Color(0xFF667085),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    'Tracking',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _TicketTrackingBar(currentStep: currentStep),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2F4FB4) : const Color(0xFF9EB5FF),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AssignBottomSheet extends StatefulWidget {
  const _AssignBottomSheet({
    required this.ticketData,
    required this.onAssign,
    this.cachedPriorities = const [],
    this.cachedEngineers = const [],
  });

  final Map<String, dynamic> ticketData;
  final void Function(
    String priority,
    String engineerName,
    String engineerId,
    String locationVerify,
    String warranty,
    String approxCharge,
    String expense,
  )
  onAssign;
  final List<Map<String, dynamic>> cachedPriorities;
  final List<Map<String, dynamic>> cachedEngineers;

  @override
  State<_AssignBottomSheet> createState() => _AssignBottomSheetState();
}

class _AssignBottomSheetState extends State<_AssignBottomSheet> {
  List<Map<String, dynamic>> _priorityList = [];
  List<Map<String, dynamic>> _engineerList = [];

  String? _selectedPriority;
  String? _selectedEngineer;
  bool _submitted = false;
  bool _isLoadingPriorities = true;
  bool _isLoadingEngineers = true;

  bool _locationVerified = false;
  bool _warrantyAvailable = false;
  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cachedPriorities.isNotEmpty) {
      _priorityList = List<Map<String, dynamic>>.from(widget.cachedPriorities);
      _isLoadingPriorities = false;
      _preselectPriority();
    } else {
      _fetchPriorities();
    }

    if (widget.cachedEngineers.isNotEmpty) {
      _engineerList = List<Map<String, dynamic>>.from(widget.cachedEngineers);
      _isLoadingEngineers = false;
      _preselectEngineer();
    } else {
      _fetchEngineers();
    }
  }

  @override
  void dispose() {
    _chargeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  void _preselectPriority() {
    String p = widget.ticketData['priority'] ?? 'LOW';
    final found = _priorityList.firstWhere(
      (item) => item['label'].toString().toUpperCase() == p.toUpperCase(),
      orElse: () => {},
    );
    if (found.isNotEmpty) {
      _selectedPriority = found['label'];
    }
  }

  void _preselectEngineer() {
    String? engName = widget.ticketData['assignedTo'];
    if (engName != null) {
      final found = _engineerList.firstWhere(
        (e) => e['Ledger_Name'].toString() == engName,
        orElse: () => {},
      );
      if (found.isNotEmpty) {
        _selectedEngineer = engName;
      }
    }
  }

  Future<void> _fetchPriorities() async {
    try {
      final res = await ApiService.getPriorityDropdown();
      if (res != null && res['error'] == false) {
        setState(() {
          _priorityList = List<Map<String, dynamic>>.from(
            res['dropdown'] ?? [],
          );
          _isLoadingPriorities = false;
          _preselectPriority();
        });
      } else {
        setState(() => _isLoadingPriorities = false);
      }
    } catch (e) {
      debugPrint("Error fetching priorities: $e");
      setState(() => _isLoadingPriorities = false);
    }
  }

  Future<void> _fetchEngineers() async {
    try {
      final res = await ApiService.getEngineerDropdown();
      if (res != null && res['error'] == false) {
        setState(() {
          _engineerList = List<Map<String, dynamic>>.from(res['data'] ?? []);
          _isLoadingEngineers = false;
          _preselectEngineer();
        });
      } else {
        setState(() => _isLoadingEngineers = false);
      }
    } catch (e) {
      debugPrint("Error fetching engineers: $e");
      setState(() => _isLoadingEngineers = false);
    }
  }

  bool _isDropdownError(String? value) =>
      _submitted && (value == null || value.isEmpty);

  void _handleSubmit() {
    setState(() => _submitted = true);

    if (_selectedPriority == null || _selectedEngineer == null) {
      return;
    }

    // Find the engineer ID from the name
    final engineer = _engineerList.firstWhere(
      (e) => e['Ledger_Name'].toString() == _selectedEngineer,
      orElse: () => {},
    );

    // Find the priority value (ID) from the label
    final priorityItem = _priorityList.firstWhere(
      (p) => p['label'].toString() == _selectedPriority,
      orElse: () => {},
    );

    if (engineer.isEmpty) {
      return;
    }

    final priorityValue =
        priorityItem['value']?.toString() ?? (_selectedPriority ?? 'Low');

    widget.onAssign(
      priorityValue,
      _selectedEngineer!,
      engineer['id'].toString(),
      _locationVerified ? "Yes" : "No",
      _warrantyAvailable ? "Yes" : "No",
      _chargeController.text,
      _expensesController.text,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assign Ticket',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 24.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Ticket No', false),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                widget.ticketData['ticketNo'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Customer Name', false),
                            SizedBox(height: 6.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 12.h,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                widget.ticketData['name'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  _buildLabel('Priority Type', true),
                  SizedBox(height: 6.h),
                  _isLoadingPriorities
                      ? SizedBox(
                          height: 48.h,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.r),
                          ),
                        )
                      : _buildDropdown(
                          value: _selectedPriority,
                          hint: 'Select Priority Type',
                          items: _priorityList
                              .map((e) => e['label'].toString())
                              .where((label) => label.isNotEmpty)
                              .toSet() // Ensure uniqueness
                              .toList(),
                          hasError: _isDropdownError(_selectedPriority),
                          onChanged: (val) =>
                              setState(() => _selectedPriority = val),
                        ),
                  SizedBox(height: 16.h),

                  _buildLabel('Service Engineer', true),
                  SizedBox(height: 6.h),
                  _isLoadingEngineers
                      ? SizedBox(
                          height: 48.h,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.r),
                          ),
                        )
                      : _buildDropdown(
                          value: _selectedEngineer,
                          hint: 'Select Engineer',
                          items: _engineerList
                              .map((e) => e['Ledger_Name']?.toString() ?? '')
                              .where((name) => name.isNotEmpty)
                              .toSet() // Ensure uniqueness to prevent "exactly one item" crash
                              .toList(),
                          hasError: _isDropdownError(_selectedEngineer),
                          onChanged: (val) =>
                              setState(() => _selectedEngineer = val),
                        ),
                  SizedBox(height: 16.h),

                  SizedBox(height: 12.h),
                  _buildCheckbox(
                    label: 'Location Verified',
                    value: _locationVerified,
                    onChanged: (val) =>
                        setState(() => _locationVerified = val ?? false),
                  ),
                  _buildCheckbox(
                    label: 'Warranty item Available',
                    value: _warrantyAvailable,
                    onChanged: (val) =>
                        setState(() => _warrantyAvailable = val ?? false),
                  ),
                  SizedBox(height: 16.h),

                  _buildLabel('Approximate Charge', false),
                  SizedBox(height: 6.h),
                  _buildTextField(_chargeController, 'Enter Charge'),
                  SizedBox(height: 16.h),

                  _buildLabel('Expenses', false),
                  SizedBox(height: 6.h),
                  _buildTextField(_expensesController, 'Enter Expenses'),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF3F51B5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF3F51B5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF283593),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Assign',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            SizedBox(
              height: 24.h,
              width: 24.w,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF3F51B5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isMandatory) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: isMandatory
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 13.sp),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required bool hasError,
    required ValueChanged<String?> onChanged,
  }) {
    // Safety check: ensure the value is present in items to prevent DropdownButton crash
    final String? effectiveValue = (value != null && items.contains(value))
        ? value
        : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: hasError ? Colors.red : const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF6B7280),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14.sp)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TicketTrackingBar extends StatelessWidget {
  const _TicketTrackingBar({required this.currentStep});

  final int currentStep;

  static const _steps = [
    ('Call', Icons.call_rounded),
    ('Assigned', Icons.assignment_turned_in_rounded),
    ('Visit', Icons.location_on_rounded),
    ('Completed', Icons.check_circle_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length, (index) {
        final stepNumber = index + 1;
        final isDone = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;
        final isPending = stepNumber > currentStep;

        final Color activeColor = isDone
            ? const Color(0xFF2FB344)
            : isCurrent
            ? AppColors.primary
            : const Color(0xFFD0D7E2);
        final Color textColor = isPending
            ? const Color(0xFF8A94A6)
            : AppColors.textDark;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 4.h,
                        color: stepNumber <= currentStep
                            ? const Color(0xFF2FB344)
                            : const Color(0xFFD9E1EC),
                      ),
                    ),
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor,
                    ),
                    alignment: Alignment.center,
                    child: isDone
                        ? Icon(
                            Icons.check_rounded,
                            size: 16.sp,
                            color: Colors.white,
                          )
                        : Text(
                            '$stepNumber',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (index < _steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 4.h,
                        color: stepNumber < currentStep
                            ? const Color(0xFF2FB344)
                            : const Color(0xFFD9E1EC),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                _steps[index].$1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
