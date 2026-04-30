import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../Widgets/common_job_card.dart';
import '../../core/app_colors.dart';
import '../../data/app_data.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import 'Check_in/direct_visit.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  DateTime? _selectedDateFilter;

  bool _isLoading = true;
  String _errorMessage = '';

  List<Map<String, dynamic>> _apiJobs = [];

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
  }

  String _formatTimeShort(DateTime date) {
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _displayTicketNo(String value) {
    return value.replaceFirst(RegExp(r'^#?(TCK|TKT)-'), '#JOB-');
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Map<String, dynamic> _buildJob({
    required String id,
    required String ticketNo,
    required String name,
    required String issue,
    required DateTime scheduledAt,
    required String status,
    required bool showAudio,
    String customerName = 'N/A',
    String priority = 'N/A',
    String product = 'N/A',
    String complaint = 'N/A',
    String phone = 'N/A',
    String address = 'N/A',
    String estimatedDuration = 'N/A',
    String complaintTranslation = 'N/A',
    double? jobLatitude,
    double? jobLongitude,
    String? photoUrl,
    String? audioUrl,
  }) {
    final today = _startOfDay(DateTime.now());
    final jobDay = _startOfDay(scheduledAt);
    final location = address.isEmpty ? issue : address;
    final effectiveLabel = status == 'Completed'
        ? 'Completed'
        : (status == 'On the Way'
              ? 'On the Way'
              : (status == 'Pending' || jobDay.isBefore(today)
                    ? 'Pending'
                    : 'Assigned'));

    return {
      'ticketNo': ticketNo,
      'ticketId': ticketNo,
      'name': name,
      'customerName': customerName.isEmpty ? name : customerName,
      'issue': issue,
      'scheduledAt': scheduledAt,
      'dateText': _formatDateShort(scheduledAt),
      'timeText': _formatTimeShort(scheduledAt),
      'label': effectiveLabel,
      'product': product,
      'complaint': complaint,
      'phone': phone,
      'address': location,
      'locationLabel': location,
      'priority': priority,
      'estimatedDuration': estimatedDuration,
      'jobLatitude': jobLatitude,
      'jobLongitude': jobLongitude,
      'showAudio': showAudio,
      'complaintTranslation': complaintTranslation,
      'photoUrl': photoUrl,
      'audioUrl': audioUrl,
      'id': id,
    };
  }

  // Fetch jobs from API
  Future<void> _fetchJobs({bool ignoreCache = false}) async {
    // Only show full-screen loader if we have no data and are not doing a background refresh
    if (_apiJobs.isEmpty && !ignoreCache) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final cid = await StorageService.getCid() ?? '';
      final uid = await StorageService.getUid() ?? '';
      final engineerId = await StorageService.getCusId() ?? '';
      final roleId = await StorageService.getRoleId() ?? '';
      final token = await StorageService.getToken() ?? '';

      final prefs = await SharedPreferences.getInstance();
      final ln = prefs.getString('ln') ?? '77.0';
      final lt = prefs.getString('lt') ?? '11.0';

      if (cid.isEmpty || engineerId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please login again.';
        });
        return;
      }

      final data = await ApiService.getJobs(
        cid: cid,
        uid: uid,
        engineerId: engineerId,
        roleId: roleId,
        token: token,
        lat: lt,
        lon: ln,
        ignoreCache: ignoreCache,
      );

      if (data['error'] == false && data['records'] != null) {
        final List<dynamic> records = data['records'];

        if (mounted) {
          setState(() {
            _apiJobs = records.map((record) {
              final id = record['id']?.toString() ?? '';
              final scheduledStr =
                  record['dtime']?.toString() ??
                  record['scheduled_date']?.toString() ??
                  '';
              DateTime scheduledAt;
              try {
                scheduledAt = DateTime.parse(scheduledStr);
              } catch (_) {
                scheduledAt = DateTime.now();
              }

              // Status Mapping
              final rawStatus =
                  record['status']?.toString().toUpperCase() ?? '';
              String statusLabel;
              if (rawStatus == 'COMPLETED' || rawStatus == '4') {
                statusLabel = 'Completed';
              } else if (rawStatus == 'ASSIGNED' || rawStatus == '2') {
                statusLabel = 'Assigned';
              } else if (rawStatus == 'ON THE WAY' || rawStatus == '3') {
                statusLabel = 'On the Way';
              } else {
                statusLabel = rawStatus.isEmpty
                    ? 'Pending'
                    : rawStatus[0] + rawStatus.substring(1).toLowerCase();
              }

              // Priority Mapping
              final rawPriority =
                  record['priority']?.toString().toUpperCase() ?? '';
              String priorityLabel;
              if (rawPriority == 'HIGH') {
                priorityLabel = 'High Priority';
              } else if (rawPriority.isNotEmpty) {
                priorityLabel =
                    rawPriority[0] +
                    rawPriority.substring(1).toLowerCase() +
                    ' Priority';
              } else {
                priorityLabel = 'N/A';
              }

              final addressVal = record['address']?.toString();
              final address = (addressVal == null || addressVal.isEmpty)
                  ? 'N/A'
                  : addressVal;
              final lat = double.tryParse(record['lt']?.toString() ?? '');
              final lng = double.tryParse(record['ln']?.toString() ?? '');

              return _buildJob(
                id: id,
                ticketNo: '#JOB ID-$id',
                name: (record['customer_id']?.toString().isEmpty ?? true)
                    ? 'N/A'
                    : record['customer_id'].toString(),
                issue: (record['complaint_title']?.toString().isEmpty ?? true)
                    ? 'N/A'
                    : record['complaint_title'].toString(),
                scheduledAt: scheduledAt,
                status: statusLabel,
                showAudio:
                    record['audio'] != null &&
                    record['audio'].toString().isNotEmpty,
                customerName:
                    (record['customer_id']?.toString().isEmpty ?? true)
                    ? 'N/A'
                    : record['customer_id'].toString(),
                priority: priorityLabel,
                product: (record['product_id']?.toString().isEmpty ?? true)
                    ? 'N/A'
                    : record['product_id'].toString(),
                complaint:
                    (record['complaint_title']?.toString().isEmpty ?? true)
                    ? 'N/A'
                    : record['complaint_title'].toString(),
                phone: (record['pho']?.toString().isEmpty ?? true)
                    ? 'N/A'
                    : record['pho'].toString(),
                address: address,
                complaintTranslation:
                    (record['complaint_title']?.toString().isEmpty ?? true)
                    ? 'N/A'
                    : record['complaint_title'].toString(),
                jobLatitude: lat,
                jobLongitude: lng,
                photoUrl: record['photo']?.toString(),
                audioUrl: record['audio']?.toString(),
              );
            }).toList();
            _isLoading = false;
          });

          if (data['isCache'] == true) {
            _fetchJobs(ignoreCache: true);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = data['message']?.toString() ?? 'No records found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load jobs: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> jobs = [..._apiJobs];

    jobs.sort(
      (a, b) => (b['scheduledAt'] as DateTime).compareTo(
        a['scheduledAt'] as DateTime,
      ),
    );

    final todayJobs = jobs
        .where(
          (job) => _isSameDay(job['scheduledAt'] as DateTime, DateTime.now()),
        )
        .toList();
    final pendingJobs = jobs.where((job) => job['label'] == 'Pending').toList();
    final completedJobs = jobs
        .where((job) => job['label'] == 'Completed')
        .toList();
    final onTheWayJobs = jobs
        .where((job) => job['label'] == 'On the Way')
        .toList();

    final filteredJobs =
        (switch (_selectedFilter) {
          'TODAY' => todayJobs,
          'PENDING' => pendingJobs,
          'COMPLETED' => completedJobs,
          'ON THE WAY' => onTheWayJobs,
          _ => jobs,
        }).where((job) {
          final matchesSearch =
              _searchQuery.isEmpty ||
              '${job['ticketNo']}'.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              '${job['name']}'.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              '${job['issue']}'.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          final matchesDate =
              _selectedDateFilter == null ||
              _isSameDay(job['scheduledAt'] as DateTime, _selectedDateFilter!);

          return matchesSearch && matchesDate;
        }).toList();

    final groupedJobs = <String, List<Map<String, dynamic>>>{};
    for (final job in filteredJobs) {
      final dayKey = _formatDayHeader(job['scheduledAt'] as DateTime);
      groupedJobs.putIfAbsent(dayKey, () => []);
      groupedJobs[dayKey]!.add(job);
    }

    return AppStatusBarWrapper(
      child: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 16.h),
                child: Row(
                  children: [
                    InkWell(
                      onTap: widget.onBack,
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
                      'My Jobs',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _fetchJobs(ignoreCache: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 18.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search + Date filter
                        TextField(
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                          onSubmitted: (value) {
                            setState(() => _searchQuery = value);
                            FocusScope.of(context).unfocus();
                          },
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search Ticket, Customer...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF8C96B5),
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_selectedDateFilter != null)
                                  IconButton(
                                    tooltip: 'Clear date filter',
                                    onPressed: () => setState(
                                      () => _selectedDateFilter = null,
                                    ),
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF8C96B5),
                                    ),
                                  ),
                                IconButton(
                                  tooltip: 'Pick date',
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _selectedDateFilter ?? DateTime.now(),
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

                                    if (picked == null) return;
                                    setState(
                                      () => _selectedDateFilter = picked,
                                    );
                                  },
                                  icon: Image.asset(
                                    'assets/calendar_icon.png',
                                    width: 24.sp,
                                    height: 24.sp,
                                  ),
                                ),
                              ],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFE9ECF7),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12.w,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),

                        // Filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'ALL (${jobs.length})',
                                selected: _selectedFilter == 'ALL',
                                onTap: () =>
                                    setState(() => _selectedFilter = 'ALL'),
                              ),
                              SizedBox(width: 10.w),
                              _FilterChip(
                                label: 'TODAY (${todayJobs.length})',
                                selected: _selectedFilter == 'TODAY',
                                onTap: () =>
                                    setState(() => _selectedFilter = 'TODAY'),
                              ),
                              SizedBox(width: 10.w),
                              _FilterChip(
                                label: 'PENDING (${pendingJobs.length})',
                                selected: _selectedFilter == 'PENDING',
                                onTap: () =>
                                    setState(() => _selectedFilter = 'PENDING'),
                              ),
                              SizedBox(width: 10.w),
                              _FilterChip(
                                label: 'COMPLETED (${completedJobs.length})',
                                selected: _selectedFilter == 'COMPLETED',
                                onTap: () => setState(
                                  () => _selectedFilter = 'COMPLETED',
                                ),
                              ),
                              SizedBox(width: 10.w),
                              _FilterChip(
                                label: 'ON THE WAY (${onTheWayJobs.length})',
                                selected: _selectedFilter == 'ON THE WAY',
                                selectedColor: const Color(0xFF6922DC),
                                onTap: () => setState(
                                  () => _selectedFilter = 'ON THE WAY',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.h),

                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_errorMessage.isNotEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 28.h),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.redAccent,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else if (filteredJobs.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 28.h),
                            child: Center(
                              child: Text(
                                'No jobs found.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF9E9E9E),
                                ),
                              ),
                            ),
                          )
                        else
                          ...groupedJobs.entries.map((entry) {
                            final dayKey = entry.key;
                            final dayJobs = entry.value;

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
                                ...dayJobs.map((job) {
                                  final label = '${job['label']}';
                                  return CommonJobCard(
                                    ticketNo: '${job['ticketNo']}',
                                    name: '${job['name']}',
                                    issue: '${job['issue']}',
                                    dateText: '${job['dateText']}',
                                    timeText: '${job['timeText']}',
                                    label: label,
                                    primaryActionLabel: label == 'On the Way'
                                        ? 'Check In'
                                        : 'Start',
                                    product: '${job['product']}',
                                    complaint: '${job['complaint']}',
                                    phone: '${job['phone']}',
                                    address: '${job['address']}',
                                    showComplaintAudio:
                                        (job['showAudio'] as bool?) ?? false,
                                    complaintTranslation:
                                        '${job['complaintTranslation']}',
                                    priority: '${job['priority'] ?? ''}',
                                    photoUrl: job['photoUrl'],
                                    audioUrl: job['audioUrl'],
                                    onPrimaryTap: label == 'Completed'
                                        ? () {}
                                        : () => _handleJobAction(context, job),
                                  );
                                }),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleJobAction(
    BuildContext context,
    Map<String, dynamic> job,
  ) async {
    final label = '${job['label']}';

    if (label == 'On the Way') {
      _openDirectVisit(context, job);
      return;
    }
    try {
      final res = await ApiService.updateJobStatus(
        jobId: '${job['id']}',
        status: '3',
      );

      if (res['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status updated to On the Way'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchJobs(ignoreCache: true);
          _openDirectVisit(context, job);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to update status'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _openDirectVisit(BuildContext context, Map<String, dynamic> job) {
    AppData.instance.updateJob({
      'ticketId': '${job['ticketNo']}',
      'customerName': '${job['customerName'] ?? job['name'] ?? ''}',
      'complaint': '${job['complaint'] ?? job['issue'] ?? ''}',
      'phone': '${job['phone'] ?? ''}',
      'address': '${job['address'] ?? ''}',
      'locationLabel': '${job['locationLabel'] ?? job['address'] ?? ''}',
      'jobLatitude': job['jobLatitude'],
      'jobLongitude': job['jobLongitude'],
      'dateText': '${job['dateText'] ?? ''}',
      'issue': '${job['issue'] ?? ''}',
      'product': '${job['product'] ?? ''}',
      'id': job['id'],
    });
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => DirectVisitScreen(jobData: job)),
        )
        .then((_) {
          _fetchJobs();
        });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected
              ? (selectedColor ?? AppColors.primary)
              : const Color(0xFF7D98F1),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
