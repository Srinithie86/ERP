import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/device_service.dart';
import '../services/storage_service.dart';
import '../Widgets/common_job_card.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import 'Support/notification_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.onOpenTasks,
    required this.onOpenDirectVisit,
  });

  final VoidCallback onOpenTasks;
  final ValueChanged<Map<String, dynamic>> onOpenDirectVisit;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Map<String, dynamic>> _todayApiTasks = [];
  List<Map<String, dynamic>> _homeSpares = [];

  @override
  void initState() {
    super.initState();
    _fetchTodayTasks();
    _fetchSpares();
  }

  Future<void> _fetchSpares() async {
    try {
      final cid = await StorageService.getCid() ?? '';
      final uid = await StorageService.getUid() ?? '';
      final roleId = await StorageService.getRoleId() ?? '';
      final token = await StorageService.getToken() ?? '';
      final engineerId = await StorageService.getCusId() ?? '';
      final deviceId = await DeviceService.getDeviceId();

      final body = {
        "type": "5017",
        "cid": cid,
        "device_id": deviceId,
        "lt": "123",
        "ln": "987",
        "engineer_id": engineerId,
        "role_id": roleId,
        "uid": uid,
        "token": token,
      };

      final response = await http
          .post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is Map && data['error'] == false) {
          final rawData = data['data'];
          if (rawData is List) {
            final mapped = rawData.where((r) => r is Map).map((r) {
              final dtime = r['dtime']?.toString() ?? '';
              final dateOnly = dtime.contains(' ')
                  ? dtime.split(' ')[0]
                  : dtime;
              return {
                'name': r['spare_name']?.toString() ?? 'N/A',
                'id': r['id']?.toString() ?? 'N/A',
                'qty': r['qty']?.toString() ?? '0',
                'date': dateOnly.isNotEmpty ? dateOnly : 'N/A',
              };
            }).toList();

            if (mounted) {
              setState(() => _homeSpares = mapped);
            }
          }
        }
      }
    } catch (e) {
      print("HOME TAB FETCH SPARES ERROR: $e");
    }
  }

  Future<void> _fetchTodayTasks() async {
    try {
      final cid = await StorageService.getCid() ?? '';
      final engineerId = await StorageService.getEngineerId() ?? '';
      final roleId = await StorageService.getRoleId() ?? '';

      final token = await StorageService.getToken() ?? '';
      final deviceId = await DeviceService.getDeviceId();

      const ln = '123';
      const lt = '21';

      final body = {
        "type": "5009",
        "cid": cid,
        "uid": engineerId,
        "ln": ln,
        "lt": lt,
        "device_id": deviceId,
        "engineer_id": engineerId,
        "role_id": roleId,
        "token": token,
        "cus_id": engineerId,
      };

      final response = await http
          .post(Uri.parse("https://erpsmart.in/total/api/m_api/"), body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is Map && data['error'] == false) {
          final List<dynamic> assignInfo = (data['assign_date_info'] is List)
              ? data['assign_date_info']
              : [];
          final List<dynamic> scheduledInfo =
              (data['scheduled_date_info'] is List)
              ? data['scheduled_date_info']
              : [];
          final combined = [...assignInfo, ...scheduledInfo];

          final seenIds = <String>{};
          final uniqueTasks = combined.where((item) {
            if (item is! Map) return false;
            final id = (item[' id'] ?? item['id'])?.toString().trim() ?? '';
            if (id.isEmpty || seenIds.contains(id)) return false;
            seenIds.add(id);
            return true;
          }).toList();

          final mapped = uniqueTasks.map((record) {
            final id = (record[' id'] ?? record['id'])?.toString().trim() ?? '';
            final requestDate = record['request_date']?.toString() ?? '';
            final dtimeStr = record['dtime']?.toString() ?? '';

            DateTime scheduledAt;
            try {
              scheduledAt = DateTime.parse(
                dtimeStr.isNotEmpty ? dtimeStr : requestDate,
              );
            } catch (_) {
              scheduledAt = DateTime.now();
            }

            String timeText = '';
            if (dtimeStr.contains(' ')) {
              try {
                final timePart = dtimeStr.split(' ')[1];
                final timeParts = timePart.split(':');
                final hour = int.tryParse(timeParts[0]) ?? 0;
                final minute = timeParts.length > 1 ? timeParts[1] : '00';
                final period = hour >= 12 ? 'PM' : 'AM';
                final displayHour = hour > 12
                    ? hour - 12
                    : (hour == 0 ? 12 : hour);
                timeText = '$displayHour:$minute $period';
              } catch (_) {
                timeText = _formatTimeShort(scheduledAt);
              }
            } else {
              timeText = _formatTimeShort(scheduledAt);
            }

            return {
              'id': id,
              'ticketNo': '#JOB-$id',
              'name': record['customer_id']?.toString() ?? 'N/A',
              'issue': record['complaint_title']?.toString() == '0'
                  ? 'No Title'
                  : record['complaint_title']?.toString() ?? 'N/A',
              'scheduledAt': scheduledAt,
              'dateText':
                  record['request_date']?.toString() ??
                  _formatDateShort(scheduledAt),
              'timeText': timeText,
              'label': 'Today',
              'product': record['product_id']?.toString() ?? 'N/A',
              'complaint': record['complaint_desc']?.toString() ?? 'N/A',
              'phone': '',
              'address': record['address']?.toString() ?? 'N/A',
              'priority': record['priority']?.toString() ?? '2',
              'photoUrl': record['photo']?.toString(),
              'audioUrl': record['audio']?.toString(),
              'hasAudio': record['audio']?.toString().isNotEmpty ?? false,
            };
          }).toList();

          if (mounted) {
            setState(() => _todayApiTasks = mapped);
            AppData.instance.setTickets(mapped);
          }
        } else {
          if (mounted) {
            _todayApiTasks = [];
            AppData.instance.setTickets([]);
            setState(() {});
          }
        }
      } else {
        AppData.instance.setTickets([]);
        if (mounted) setState(() => _todayApiTasks = []);
      }
    } catch (e) {
      print("HOME TAB FETCH ERROR: $e");
      AppData.instance.setTickets([]);
      if (mounted) setState(() => _todayApiTasks = []);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

  String _displayTicketNo(String value) {
    return value.replaceFirst(RegExp(r'^#?(TCK|TKT)-'), '#JOB-');
  }

  Map<String, double> _jobCoordinatesForLocation(String location) {
    final normalized = location.toLowerCase();
    if (normalized.contains('finance')) {
      return {'lat': 11.0169, 'lng': 76.9561};
    }
    if (normalized.contains('hr')) {
      return {'lat': 11.0172, 'lng': 76.9555};
    }
    if (normalized.contains('admin')) {
      return {'lat': 11.0175, 'lng': 76.9564};
    }
    if (normalized.contains('floor 1')) {
      return {'lat': 11.0178, 'lng': 76.9552};
    }
    return {'lat': 11.0168, 'lng': 76.9558};
  }

  Map<String, dynamic> _buildDirectVisitJob(
    Map<String, dynamic> ticket,
    Map<String, dynamic> profile,
  ) {
    final createdAt = ticket['scheduledAt'] as DateTime? ?? DateTime.now();
    final ticketId = '${ticket['id'] ?? ticket['ticketId'] ?? ''}';
    final location = '${ticket['address'] ?? ticket['location'] ?? ''}';
    final coords = _jobCoordinatesForLocation(location);

    return {
      'ticketNo': ticketId.startsWith('TCK')
          ? _displayTicketNo('#$ticketId')
          : (ticketId.startsWith('#') ? ticketId : '#JOB-$ticketId'),
      'ticketId': ticketId,
      'name': '${ticket['name'] ?? ticket['user'] ?? profile['name'] ?? ''}',
      'customerName':
          '${ticket['name'] ?? ticket['user'] ?? profile['name'] ?? ''}',
      'issue': '${ticket['issue'] ?? ticket['title'] ?? ''}',
      'scheduledAt': createdAt,
      'dateText': ticket['dateText'] ?? _formatDateShort(createdAt),
      'timeText': ticket['timeText'] ?? _formatTimeShort(createdAt),
      'label': '${ticket['status']}' == 'Completed' ? 'Completed' : 'Today',
      'product': '${ticket['product'] ?? ticket['device'] ?? ''}',
      'complaint':
          '${ticket['complaint'] ?? ticket['issue'] ?? ticket['title'] ?? ''}',
      'phone': ticket['phone'] ?? '${profile['phone'] ?? ''}',
      'address': location,
      'locationLabel': location,
      'priority': '${ticket['priority'] ?? ''}',
      'jobLatitude': coords['lat'],
      'jobLongitude': coords['lng'],
      'showAudio':
          (ticket['hasAudio'] == true) ||
          (ticket['audioUrl'] != null &&
              ticket['audioUrl'].toString().isNotEmpty),
      'audioUrl': ticket['audioUrl'],
      'complaintTranslation':
          '${ticket['complaint'] ?? ticket['issue'] ?? ticket['title'] ?? ''}',
      'id': ticketId,
    };
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final topInset = MediaQuery.of(context).padding.top;
    final appData = AppData.instance;
    final profile = appData.profile;
    final today = DateTime.now();

    final pendingJobCount = appData.pendingCount;
    final urgentJobCount = appData.tickets.where((ticket) {
      final priority = '${ticket['priority']}'.toLowerCase();
      return priority == 'urgent' || priority == 'high' || priority == '1';
    }).length;

    final displayedTasks = _todayApiTasks.take(3).toList();
    final todayTaskCount = _todayApiTasks.length;
    final spareItems = _homeSpares.take(5).toList();

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: AppColors.primary,
          padding: EdgeInsets.fromLTRB(16.w, topInset + 10.h, 16.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Service ERP',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      count: '$todayTaskCount',
                      label: "Today's Task",
                      color: const Color(0xFF4CAF50),
                      onTap: widget.onOpenTasks,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _StatCard(
                      count: '$pendingJobCount',
                      label: 'Pending Job',
                      color: const Color(0xFFFDD835),
                      darkText: true,
                      onTap: widget.onOpenTasks,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _StatCard(
                      count: '$urgentJobCount',
                      label: 'Urgent',
                      color: const Color(0xFFE53935),
                      onTap: widget.onOpenTasks,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: "Today's Task"),
                  SizedBox(height: 14.h),
                  if (displayedTasks.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'No task today',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF667085),
                        ),
                      ),
                    )
                  else
                    ...displayedTasks.map((ticket) {
                      final directVisitJob = _buildDirectVisitJob(
                        ticket,
                        profile,
                      );
                      return CommonJobCard(
                        ticketNo: ticket['ticketNo'] ?? '',
                        name: '${ticket['name'] ?? ''}',
                        issue: '${ticket['issue'] ?? ''}',
                        dateText: ticket['dateText'] ?? '',
                        timeText: ticket['timeText'] ?? '',
                        label: ticket['label'] ?? 'Today',
                        product: '${ticket['product'] ?? ''}',
                        complaint: '${ticket['complaint'] ?? ''}',
                        phone: ticket['phone'] ?? '',
                        address: '${ticket['address'] ?? ''}',
                        showComplaintAudio: (ticket['hasAudio'] == true),
                        complaintTranslation: '${ticket['complaint'] ?? ''}',
                        priority: '${ticket['priority'] ?? ''}',
                        primaryActionLabel: 'Start',
                        photoUrl: ticket['photoUrl'],
                        audioUrl: ticket['audioUrl'],
                        onPrimaryTap: () =>
                            widget.onOpenDirectVisit(directVisitJob),
                      );
                    }),
                  SizedBox(height: 24.h),
                  const _SectionHeader(title: 'Spares'),
                  SizedBox(height: 14.h),
                  ...spareItems.map(
                    (part) => _SpareCard(
                      name: '${part['name']}',
                      code: '${part['id']}',
                      quantity: '${part['qty']}',
                      receivedDate: '${part['date']}',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
    this.darkText = false,
    this.onTap,
  });

  final String count;
  final String label;
  final Color color;
  final bool darkText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: darkText ? Colors.black87 : Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: darkText ? Colors.black87 : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _SpareCard extends StatelessWidget {
  const _SpareCard({
    required this.name,
    required this.code,
    required this.quantity,
    required this.receivedDate,
  });

  final String name;
  final String code;
  final String quantity;
  final String receivedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF9155FD)),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            color: const Color(0xFF9155FD),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    color: Color(0xFF322748),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.build_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Code: $code',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/quantity_icon.png',
                        width: 22.w,
                        height: 22.h,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Quantity: $quantity',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 24.h, color: Colors.grey.shade300),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/calendar_icon.png',
                        width: 22.w,
                        height: 22.h,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Received: $receivedDate',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
