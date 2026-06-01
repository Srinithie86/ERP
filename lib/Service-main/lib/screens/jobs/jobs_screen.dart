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

  String _resolveUrl(String? raw, String baseUrl) {
    if (raw == null || raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final cleaned = raw.replaceAll(RegExp(r'^(\.\.\/)+'), '');

    // Ensure baseUrl ends with total/ if it's the default
    String effectiveBase = baseUrl;
    if (effectiveBase.endsWith('api/m_api/')) {
      effectiveBase = effectiveBase.replaceAll('api/m_api/', '');
    }

    return '$effectiveBase$cleaned';
  }

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

  String _mapStatus(String raw) {
    switch (raw) {
      case 'COMPLETED':
      case 'RESOLVED':
      case '4':
        return 'Completed';
      case 'ASSIGNED':
      case 'ACCEPTED':
      case '2':
        return 'Assigned';
      case 'ON THE WAY':
      case 'ON_THE_WAY':
      case '3':
        return 'On the Way';
      case 'LONG PENDING':
      case 'LONG_PENDING':
        return 'Long Pending';
      case 'PAYMENT PENDING':
      case 'PAYMENT_PENDING':
        return 'Payment Pending';
      case 'SPARE REQUESTED':
      case 'SPARE_REQUESTED':
        return 'Spare Requested';
      case 'TODAY':
        return 'Today';
      case 'PENDING':
      case 'OPENED':
      case '1':
        return 'Pending';
      default:
        if (raw.isEmpty) return 'Pending';
        // Handle CamelCase or other formats
        return raw[0].toUpperCase() + raw.substring(1).toLowerCase();
    }
  }

  DateTime _parseBestDate(Map<String, dynamic> record) {
    final candidates = [
      record['visit_date'],
      record['scheduled_date'],
      record['assign_date'],
      record['request_date'],
      record['dtime'],
    ];
    for (final raw in candidates) {
      if (raw != null && raw.toString().isNotEmpty) {
        try {
          return DateTime.parse(raw.toString());
        } catch (_) {}
      }
    }
    return DateTime.now();
  }

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
    String note = 'N/A',
  }) {
    final today = _startOfDay(DateTime.now());
    final jobDay = _startOfDay(scheduledAt);
    final location = address.isEmpty ? issue : address;

    // Determine the effective display label
    String effectiveLabel;
    switch (status) {
      case 'Completed':
        effectiveLabel = 'Completed';
        break;
      case 'On the Way':
        effectiveLabel = 'On the Way';
        break;
      case 'Long Pending':
        effectiveLabel = 'Long Pending';
        break;
      case 'Assigned':
        effectiveLabel = 'Assigned';
        break;
      case 'Today':
        effectiveLabel = 'Assigned';
        break;
      default:
        // 'Pending' or jobs whose scheduled day has passed
        effectiveLabel = (status == 'Pending' || jobDay.isBefore(today))
            ? 'Pending'
            : 'Assigned';
    }

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
      'note': note,
      'id': id,
    };
  }

  // ─── Fetch jobs from API
  Future<void> _fetchJobs({bool ignoreCache = false}) async {
    if (_apiJobs.isEmpty && !ignoreCache) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final cid = await StorageService.getCid() ?? '';
      final uid = await StorageService.getUid() ?? '';
      final engineerId = await StorageService.getEngineerId() ?? '';
      final roleId = await StorageService.getRoleId() ?? '';
      final token = await StorageService.getToken() ?? '';
      final baseUrl = await ApiService.getBaseUrl();

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

      final isSuccess =
          data != null &&
          (data['error'] == false ||
              data['error'] == 0 ||
              data['error'].toString() == '0');

      if (isSuccess) {
        List<dynamic> records = [];
        if (data['records'] is List) {
          records = data['records'];
        } else {
          final assignInfo = data['assign_date_info'] is List
              ? data['assign_date_info']
              : [];
          final scheduledInfo = data['scheduled_date_info'] is List
              ? data['scheduled_date_info']
              : [];
          records = [...assignInfo, ...scheduledInfo];
        }

        if (mounted) {
          setState(() {
            if (records.isNotEmpty) {
              _apiJobs = records.map((record) {
                final id =
                    (record['id'] ?? record[' id'])?.toString().trim() ?? '';
                final scheduledAt = _parseBestDate(
                  record as Map<String, dynamic>,
                );
                final rawStatus =
                    record['status']?.toString().toUpperCase().trim() ?? '';
                final statusLabel = _mapStatus(rawStatus);
                final rawPriority =
                    record['priority']?.toString().toUpperCase().trim() ?? '';
                String priorityLabel;
                if (rawPriority == 'HIGH') {
                  priorityLabel = 'High Priority';
                } else if (rawPriority == 'MEDIUM' || rawPriority == 'MED') {
                  priorityLabel = 'Medium Priority';
                } else if (rawPriority == 'LOW') {
                  priorityLabel = 'Low Priority';
                } else if (rawPriority.isNotEmpty) {
                  priorityLabel =
                      rawPriority[0] +
                      rawPriority.substring(1).toLowerCase() +
                      ' Priority';
                } else {
                  priorityLabel = 'N/A';
                }

                final addressVal = record['address']?.toString();
                final address =
                    (addressVal == null || addressVal.trim().isEmpty)
                    ? 'N/A'
                    : addressVal.trim();

                final lat = double.tryParse(record['lt']?.toString() ?? '');
                final lng = double.tryParse(record['ln']?.toString() ?? '');
                final photoUrl = _resolveUrl(
                  record['photo']?.toString(),
                  baseUrl,
                );
                final audioUrl = _resolveUrl(
                  record['audio']?.toString(),
                  baseUrl,
                );
                final hasAudio = audioUrl.isNotEmpty;

                // ── Customer name
                final customerName =
                    (record['customer_id']?.toString().trim().isEmpty ?? true)
                    ? 'N/A'
                    : record['customer_id'].toString().trim();

                // ── Product
                final product =
                    (record['product_id']?.toString().trim().isEmpty ?? true)
                    ? 'N/A'
                    : record['product_id'].toString().trim();

                // ── Complaint title
                final complaintTitle =
                    (record['complaint_title']?.toString().trim().isEmpty ??
                        true)
                    ? 'N/A'
                    : record['complaint_title'].toString().trim();

                final phone = (record['pho']?.toString().trim().isEmpty ?? true)
                    ? 'N/A'
                    : record['pho'].toString().trim();

                final note =
                    (record['warranty_note']?.toString().trim().isNotEmpty ??
                        false)
                    ? record['warranty_note'].toString().trim()
                    : ((record['remarks']?.toString().trim().isNotEmpty ??
                              false)
                          ? record['remarks'].toString().trim()
                          : (record['remark']?.toString().trim().isNotEmpty ??
                                false)
                          ? record['remark'].toString().trim()
                          : (record['note']?.toString().trim().isNotEmpty ??
                                false)
                          ? record['note'].toString().trim()
                          : 'N/A');

                return _buildJob(
                  id: id,
                  ticketNo: '#JOB-$id',
                  name: customerName,
                  issue: complaintTitle,
                  scheduledAt: scheduledAt,
                  status: statusLabel,
                  showAudio: hasAudio,
                  customerName: customerName,
                  priority: priorityLabel,
                  product: product,
                  complaint: complaintTitle,
                  phone: phone,
                  address: address,
                  complaintTranslation: complaintTitle,
                  jobLatitude: lat,
                  jobLongitude: lng,
                  photoUrl: photoUrl.isEmpty ? null : photoUrl,
                  audioUrl: audioUrl.isEmpty ? null : audioUrl,
                  note: note,
                );
              }).toList();
              _errorMessage = '';
            } else {
              _apiJobs = [];
              _errorMessage = 'No jobs found.';
            }
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
    SizeConfig.init(context);
    final now = DateTime.now();
    final List<Map<String, dynamic>> jobs = [..._apiJobs];

    debugPrint("JOBS PROCESSING => Total: ${jobs.length}");

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
    debugPrint("JOBS PROCESSING => Today: ${todayJobs.length}");

    final pendingJobs = jobs
        .where(
          (job) =>
              job['label'] == 'Pending' ||
              job['label'] == 'Assigned' ||
              job['label'] == 'Long Pending' ||
              job['label'] == 'Payment Pending' ||
              job['label'] == 'Spare Requested',
        )
        .toList();
    debugPrint("JOBS PROCESSING => Pending: ${pendingJobs.length}");

    final completedJobs = jobs
        .where((job) => job['label'] == 'Completed')
        .toList();
    debugPrint("JOBS PROCESSING => Completed: ${completedJobs.length}");

    final onTheWayJobs = jobs
        .where((job) => job['label'] == 'On the Way')
        .toList();
    debugPrint("JOBS PROCESSING => On the Way: ${onTheWayJobs.length}");

    final longPendingJobs = jobs
        .where((job) => job['label'] == 'Long Pending')
        .toList();

    final filteredJobs = (switch (_selectedFilter) {
      'TODAY' => todayJobs,
      'PENDING' => pendingJobs,
      'COMPLETED' => completedJobs,
      'ON THE WAY' => onTheWayJobs,
      'LONG PENDING' => longPendingJobs,
      _ => jobs,
    });
    debugPrint(
      "JOBS PROCESSING => Selected Filter ($_selectedFilter) Result: ${filteredJobs.length}",
    );

    final finalJobs = filteredJobs.where((job) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          '${job['ticketNo']}'.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          '${job['name']}'.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          '${job['issue']}'.toLowerCase().contains(_searchQuery.toLowerCase());

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

    return Material(
      color: Colors.white,
      child: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────────
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
  
                // ── Body ─────────────────────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _fetchJobs(ignoreCache: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 18.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Search + Date filter ────────────────────────────
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
                                      package: 'service_ticket',
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
  
                          // ── Filter chips ────────────────────────────────────
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
                                SizedBox(width: 10.w),
                                _FilterChip(
                                  label:
                                      'LONG PENDING (${longPendingJobs.length})',
                                  selected: _selectedFilter == 'LONG PENDING',
                                  selectedColor: const Color(0xFFFF5252),
                                  onTap: () => setState(
                                    () => _selectedFilter = 'LONG PENDING',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 18.h),
  
                          // ── Content area ────────────────────────────────────
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
                                      showTranslation: false,
                                      priority: '${job['priority'] ?? ''}',
                                      photoUrl: job['photoUrl'],
                                      audioUrl: job['audioUrl'],
                                      note: job['note'] ?? 'N/A',
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
      'note': '${job['note'] ?? 'N/A'}',
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

// ─── Filter Chip Widget ────────────────────────────────────────────────────────

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
