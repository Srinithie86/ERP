import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/device_service.dart';
import '../services/storage_service.dart';
import '../Widgets/common_job_card.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import 'Support/notification_screen.dart';
import 'package:service_ticket/core/api_config.dart';

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
    _todayApiTasks = AppData.instance.tickets;
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
          .post(Uri.parse(await ApiConfig.getBaseUrl()), body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic data = await compute(jsonDecode, response.body);
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
          .post(Uri.parse(await ApiConfig.getBaseUrl()), body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic data = await compute(jsonDecode, response.body);

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
              'lt': record['lt']?.toString(),
              'ln': record['ln']?.toString(),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _displayTicketNo(String value) {
    return value.replaceFirst(RegExp(r'^#?(TCK|TKT)-'), '#JOB-');
  }

  Map<String, dynamic> _buildDirectVisitJob(
    Map<String, dynamic> ticket,
    Map<String, dynamic> profile,
  ) {
    final createdAt = ticket['scheduledAt'] as DateTime? ?? DateTime.now();
    final ticketId = '${ticket['id'] ?? ticket['ticketId'] ?? ''}';
    final location = '${ticket['address'] ?? ticket['location'] ?? ''}';

    final double? lat = double.tryParse(ticket['lt']?.toString() ?? '');
    final double? lng = double.tryParse(ticket['ln']?.toString() ?? '');

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
      'jobLatitude': lat,
      'jobLongitude': lng,
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
          child: Row(
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
              SizedBox(width: 16.w),
              Text(
                'Service',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationScreen()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                    Positioned(
                      right: 1.w,
                      top: 1.h,
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
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
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          count: '$todayTaskCount',
                          label: "Total Task",
                          color: const Color(0xFFFA1E4E),
                          overlayColor: Colors.white.withValues(alpha: 0.2),
                          icon: Icons.assignment_rounded,
                          onTap: widget.onOpenTasks,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _StatCard(
                          count: '$pendingJobCount',
                          label: 'Pending Job',
                          color: const Color(0xFF0F968C),
                          overlayColor: Colors.white.withValues(alpha: 0.2),
                          icon: Icons.pending_actions_rounded,
                          onTap: widget.onOpenTasks,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _StatCard(
                          count: '$urgentJobCount',
                          label: 'Urgent',
                          color: const Color(0xFFB50D70),
                          overlayColor: Colors.white.withValues(alpha: 0.2),
                          icon: Icons.timer_rounded,
                          onTap: widget.onOpenTasks,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _SectionHeader(
                    title: "Today's Task",
                    trailing: Text(
                      '$todayTaskCount Assigned',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF7A7A7A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
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
                  SizedBox(height: 12.h),
                  const _SalesOverviewCard(),
                  const _OrderStatusCard(),
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
    required this.overlayColor,
    required this.icon,
    this.onTap,
  });

  final String count;
  final String label;
  final Color color;
  final Color overlayColor;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: overlayColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 18.sp),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: const Color(0xFF2C439E),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        if (trailing != null) trailing!,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Code: $code',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ],
                  ),
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
                      Expanded(
                        child: Text(
                          'Quantity: $quantity',
                          style: TextStyle(fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24.h,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/calendar_icon.png',
                        width: 22.w,
                        height: 22.h,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'Received: $receivedDate',
                          style: TextStyle(fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5),
              border: const Border(top: BorderSide(color: Color(0xFFE8D5FA))),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5.r),
                bottomRight: Radius.circular(5.r),
              ),
            ),
            child: Text(
              'Remarks : New stock added to inventory',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF333333)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesOverviewCard extends StatelessWidget {
  const _SalesOverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Overview',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            height: 180.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarChartPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double startY = 24.0;
    final double endY = size.height - 24.0;
    final double chartHeight = endY - startY;

    final steps = 4;
    for (int i = 0; i <= steps; i++) {
      double y = endY - (chartHeight * (i / steps));
      if (i > 0) {
        _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), bgPaint);
      }
    }

    final axisPaint = Paint()
      ..color = const Color(0xFF334A5F)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, endY), Offset(size.width, endY), axisPaint);

    final data = [
      {'label': 'Jan', 'value': 36.0, 'color': const Color(0xFFFF2A55), 'darkColor': const Color(0xFFD9153A)},
      {'label': 'Feb', 'value': 30.0, 'color': const Color(0xFFB51065), 'darkColor': const Color(0xFF8A0A4B)},
      {'label': 'Mar', 'value': 40.0, 'color': const Color(0xFF4B14C8), 'darkColor': const Color(0xFF320C8A)},
      {'label': 'Apr', 'value': 25.0, 'color': const Color(0xFF00465A), 'darkColor': const Color(0xFF00303F)},
      {'label': 'May', 'value': 36.0, 'color': const Color(0xFF28A096), 'darkColor': const Color(0xFF1B7A72)},
    ];

    const double maxVal = 45.0; // Giving a little headroom
    final double barWidth = size.width / (data.length * 2.2);
    final double spacing = (size.width - (barWidth * data.length)) / (data.length + 1);

    double currentX = spacing;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var item in data) {
      final value = item['value'] as double;
      final color = item['color'] as Color;
      final darkColor = item['darkColor'] as Color;
      final label = item['label'] as String;

      final barHeight = (value / maxVal) * chartHeight;

      final leftPath = Path();
      leftPath.moveTo(currentX, endY);
      leftPath.lineTo(currentX, endY - barHeight + (barWidth / 2.5));
      leftPath.lineTo(currentX + (barWidth / 2), endY - barHeight);
      leftPath.lineTo(currentX + (barWidth / 2), endY);
      leftPath.close();
      canvas.drawPath(leftPath, Paint()..color = color);

      final rightPath = Path();
      rightPath.moveTo(currentX + (barWidth / 2), endY);
      rightPath.lineTo(currentX + (barWidth / 2), endY - barHeight);
      rightPath.lineTo(currentX + barWidth, endY - barHeight + (barWidth / 2.5));
      rightPath.lineTo(currentX + barWidth, endY);
      rightPath.close();
      canvas.drawPath(rightPath, Paint()..color = darkColor);

      textPainter.text = TextSpan(
        text: '${value.toInt()}%',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(currentX + (barWidth / 2) - (textPainter.width / 2), endY - barHeight - 18),
      );

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(currentX + (barWidth / 2) - (textPainter.width / 2), endY + 6),
      );

      currentX += barWidth + spacing;
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const int dashWidth = 4;
    const int dashSpace = 4;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(Offset(startX, p1.dy), Offset(startX + dashWidth, p1.dy), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              SizedBox(
                width: 130.w,
                height: 130.w,
                child: CustomPaint(
                  painter: _PieChartPainter(),
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(const Color(0xFF00465A), 'Rejected'),
                    SizedBox(height: 14.h),
                    _buildLegendItem(const Color(0xFF4B14C8), 'Completed'),
                    SizedBox(height: 14.h),
                    _buildLegendItem(const Color(0xFFB51065), 'Pending'),
                    SizedBox(height: 14.h),
                    _buildLegendItem(const Color(0xFFFF2A55), 'Process'),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final data = [
      {'value': 22.0, 'color': const Color(0xFF4B14C8), 'label': '22%'},
      {'value': 20.0, 'color': const Color(0xFFB51065), 'label': '20%'},
      {'value': 18.0, 'color': const Color(0xFFFF2A55), 'label': '18%'},
      {'value': 40.0, 'color': const Color(0xFF00465A), 'label': '40%'},
    ];

    double startAngle = -math.pi / 2;

    for (var item in data) {
      final value = item['value'] as double;
      final sweepAngle = (value / 100) * 2 * math.pi;

      final paint = Paint()
        ..color = item['color'] as Color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: item['label'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelAngle = startAngle + (sweepAngle / 2);
      final radius = size.width / 2;
      final labelRadius = radius * 0.6;
      final cx = radius + labelRadius * math.cos(labelAngle);
      final cy = radius + labelRadius * math.sin(labelAngle);

      textPainter.paint(
        canvas,
        Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
