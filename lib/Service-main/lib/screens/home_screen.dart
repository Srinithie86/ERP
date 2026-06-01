import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/device_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../widgets/common_job_card.dart';
import '../core/app_colors.dart';
import '../data/app_data.dart';
import 'support/notification_screen.dart';
import 'jobs/jobs_screen.dart';
import 'spares/sparetab_screen.dart';
import 'dispatchment/dispatchment_entry.dart';
import 'all_tickets/all_tickets.dart';
import 'all_tickets/raise_complaint.dart';
import 'all_dispatch/all_dispatch_screen.dart';
import 'standby_screen.dart';
import 'spares/toolkit_screen.dart';
import 'eod/eod_report_screen.dart';
import 'evaluation/evaluation_screen.dart';


class HomeTab extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function(BuildContext, String, {String? moduleContext})? onNavigate;
  final List<Map<String, dynamic>>? serviceMenus;

  const HomeTab({
    super.key,
    required this.onOpenTasks,
    required this.onOpenDirectVisit,
    this.isEmbedded = false,
    this.scaffoldKey,
    this.onNavigate,
    this.serviceMenus,
  });

  final VoidCallback onOpenTasks;
  final ValueChanged<Map<String, dynamic>> onOpenDirectVisit;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Map<String, dynamic>> _todayApiTasks = [];
  List<Map<String, dynamic>> _homeSpares = [];
  int _totalTask = 0;
  int _pendingJob = 0;
  int _completedCount = 0;
  List<Map<String, dynamic>> _salesOverview = [];
  List<Map<String, dynamic>> _orderStatus = [];

  @override
  void initState() {
    super.initState();
    _todayApiTasks = AppData.instance.tickets;
    _fetchTodayTasks();
    _fetchSpares();
    _fetchHomeSummary();
  }

  Future<void> _handleRefresh() async {
    await Future.wait([
      _fetchTodayTasks(),
      _fetchSpares(),
      _fetchHomeSummary(),
    ]);
  }

  Future<void> _fetchHomeSummary() async {
    try {
      final cid = await StorageService.getCid() ?? '';
      final uid = await StorageService.getUid() ?? '';
      final roleId = await StorageService.getRoleId() ?? '';
      final token = await StorageService.getToken() ?? '';
      final cusId = await StorageService.getCusId() ?? '';
      final engineerId = await StorageService.getEngineerId() ?? '';
      final deviceId = await DeviceService.getDeviceId();

      final body = {
        "type": "5035",
        "cid": cid.toString(),
        "device_id": deviceId.toString(),
        "lt": "123",
        "ln": "987",
        "cus_id": cusId.toString(),
        "engineer_id": engineerId.toString(),
        "token": token.toString(),
        "role_id": roleId.toString(),
        "uid": uid.toString(),
      };

      debugPrint("HOME TAB FETCH SUMMARY BODY: $body");

      final response = await http
          .post(Uri.parse(await ApiService.getBaseUrl()), body: body)
          .timeout(const Duration(seconds: 15));

      debugPrint(
        "HOME TAB FETCH SUMMARY RESPONSE: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        final dynamic data = await compute(jsonDecode, response.body);
        if (data is Map && data['error'] == false) {
          if (mounted) {
            setState(() {
              final summary = data['summary'];
              if (summary is Map) {
                _totalTask =
                    int.tryParse(summary['total_task']?.toString() ?? '') ?? 0;
                _pendingJob =
                    int.tryParse(summary['pending_job']?.toString() ?? '') ?? 0;
                _completedCount = int.tryParse(
                        summary['completed_task']?.toString() ?? '') ??
                    int.tryParse(summary['completed_job']?.toString() ?? '') ??
                    0;
              }

              final sales = data['sales_overview'];
              if (sales is List) {
                _salesOverview =
                    sales.map((e) => Map<String, dynamic>.from(e)).toList();
              }

              final orders = data['order_status'];
              if (orders is List) {
                _orderStatus =
                    orders.map((e) => Map<String, dynamic>.from(e)).toList();

                // If summary didn't have completed_task, try getting it from order_status
                if (_completedCount == 0) {
                  final completedItem = _orderStatus.firstWhere(
                    (e) => e['label'] == 'Completed',
                    orElse: () => {},
                  );
                  _completedCount =
                      int.tryParse(completedItem['count']?.toString() ?? '0') ??
                          0;
                }
              }
            });
            debugPrint(
              "HOME TAB SUMMARY UPDATED: Total=$_totalTask, Pending=$_pendingJob, Completed=$_completedCount",
            );
          }
        } else {
          debugPrint(
            "HOME TAB SUMMARY ERROR IN RESPONSE: ${data['message'] ?? 'Unknown error'}",
          );
        }
      }
    } catch (e) {
      print("HOME TAB FETCH SUMMARY ERROR: $e");
    }
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
          .post(Uri.parse(await ApiService.getBaseUrl()), body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic data = await compute(jsonDecode, response.body);
        if (data is Map && data['error'] == false) {
          final rawData = data['data'];
          if (rawData is List) {
            final mapped = rawData.where((r) => r is Map).map((r) {
              final dtime = r['dtime']?.toString() ?? '';
              final dateOnly =
                  dtime.contains(' ') ? dtime.split(' ')[0] : dtime;
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

      final prefs = await SharedPreferences.getInstance();
      final ln = prefs.getString('ln') ?? '77.0';
      final lt = prefs.getString('lt') ?? '11.0';

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
          .post(Uri.parse(await ApiService.getBaseUrl()), body: body)
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
            if (uniqueTasks.indexOf(record) == 0) {
              debugPrint("HOME TASK FIRST RECORD: $record");
            }
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
                final displayHour =
                    hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
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
              'dateText': record['request_date']?.toString() ??
                  _formatDateShort(scheduledAt),
              'timeText': timeText,
              'label': record['status']?.toString() ?? 'Today',
              'status': record['status']?.toString() ?? '',
              'product': record['product_id']?.toString() ?? 'N/A',
              'complaint': record['complaint_desc']?.toString() ?? 'N/A',
              'phone': record['pho']?.toString() ?? '',
              'address': record['address']?.toString() ?? 'N/A',
              'priority': record['priority']?.toString() ?? '2',
              'photoUrl': record['photo']?.toString(),
              'audioUrl': record['audio']?.toString(),
              'hasAudio': record['audio']?.toString().isNotEmpty ?? false,
              'lt': record['lt']?.toString(),
              'ln': record['ln']?.toString(),
              'note': (record['warranty_note']?.toString().isNotEmpty ?? false)
                  ? record['warranty_note'].toString()
                  : (record['waranty_note']?.toString().isNotEmpty ?? false)
                      ? record['waranty_note'].toString()
                      : (record['remark']?.toString() ??
                          record['note']?.toString() ??
                          'N/A'),
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
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
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
      'label': (ticket['status']?.toString().isNotEmpty ?? false)
          ? ticket['status'].toString()
          : 'Today',
      'status': ticket['status'] ?? '',
      'product': '${ticket['product'] ?? ticket['device'] ?? ''}',
      'complaint':
          '${ticket['complaint'] ?? ticket['issue'] ?? ticket['title'] ?? ''}',
      'phone': ticket['phone'] ?? '${profile['phone'] ?? ''}',
      'address': location,
      'locationLabel': location,
      'priority': '${ticket['priority'] ?? ''}',
      'jobLatitude': lat,
      'jobLongitude': lng,
      'showAudio': (ticket['hasAudio'] == true) ||
          (ticket['audioUrl'] != null &&
              ticket['audioUrl'].toString().isNotEmpty),
      'audioUrl': ticket['audioUrl'],
      'complaintTranslation':
          '${ticket['complaint'] ?? ticket['issue'] ?? ticket['title'] ?? ''}',
      'note': '${ticket['note'] ?? 'N/A'}',
      'id': ticketId,
    };
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final appData = AppData.instance;
    final profile = appData.profile;

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
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
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
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            count: '$_totalTask',
                            label: "Total Task",
                            color: const Color(0xFFFA1E4E),
                            overlayColor: Colors.white.withOpacity(0.2),
                            icon: Icons.assignment_rounded,
                            onTap: widget.onOpenTasks,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _StatCard(
                            count: '$_pendingJob',
                            label: 'Pending Job',
                            color: const Color(0xFF0F968C),
                            overlayColor: Colors.white.withOpacity(0.2),
                            icon: Icons.pending_actions_rounded,
                            onTap: widget.onOpenTasks,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _StatCard(
                            count: '$_completedCount',
                            label: 'Completed',
                            color: const Color(0xFFB50D70),
                            overlayColor: Colors.white.withOpacity(0.2),
                            icon: Icons.timer_rounded,
                            onTap: widget.onOpenTasks,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    const _SectionHeader(title: "Quick Navigation"),
                    SizedBox(height: 12.h),
                    _buildQuickNavigationGrid(context),
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
                          note: ticket['note'] ?? 'N/A',
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
                    _SalesOverviewCard(data: _salesOverview),
                    _OrderStatusCard(data: _orderStatus),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickNavigationGrid(BuildContext context) {
    final rawSubMenus = widget.serviceMenus ?? [];

    // 2. Deduplicate and filter exactly like DynamicDrawer
    final Map<String, Map<String, dynamic>> uniqueMenus = {};
    for (var i in rawSubMenus) {
      if (i is! Map) continue;
      final Map<String, dynamic> item =
          i is Map<String, dynamic> ? i : Map<String, dynamic>.from(i);
      final name = (item['name'] ?? '').toString().trim().toUpperCase();
      if (name.isEmpty) continue;

      if (uniqueMenus.containsKey(name)) {
        if (item.containsKey('sub_menu') &&
            item['sub_menu'] is List &&
            (item['sub_menu'] as List).isNotEmpty) {
          uniqueMenus[name] = item;
        }
      } else {
        uniqueMenus[name] = item;
      }
    }

    final List<Map<String, dynamic>> filteredSubMenus = uniqueMenus.values.where((item) {
      final name = (item['name'] ?? '').toString().toUpperCase();
      if (name.contains("CREATE") && (name.contains("QC") || name.contains("INSPECTION"))) {
        return false;
      }
      if (name == "DASHBOARD" || name == "MAIN DASHBOARD") {
        return false;
      }
      return true;
    }).toList();

    // 3. Map filtered items to local configuration (screen, icon, color, etc.)
    final List<Map<String, dynamic>> gridItems = [];

    for (var item in filteredSubMenus) {
      final String name = (item['name'] ?? '').toString();
      final String normalized = name.trim().toUpperCase();

      String title = name;
      IconData icon = Icons.circle_outlined;
      Color color = const Color(0xFF00796B);
      Widget? screen;

      switch (normalized) {
        case 'JOBS':
          title = 'Jobs';
          icon = Icons.work_history_outlined;
          color = const Color(0xFF00796B);
          screen = JobsScreen(onBack: () => Navigator.pop(context));
          break;
        case 'SPARES':
          title = 'Spares';
          icon = Icons.inventory_2_outlined;
          color = const Color(0xFFE65100);
          screen = SparePartsTab(onBack: () => Navigator.pop(context));
          break;
        case 'ENGINEER SPARE ENTRY':
          title = 'Spare Entry';
          icon = Icons.edit_document;
          color = const Color(0xFFE65100);
          screen = SparePartsTab(onBack: () => Navigator.pop(context));
          break;
        case 'SPARE DISPATCH':
          title = 'Spare Dispatch';
          icon = Icons.inventory_2_outlined;
          color = const Color(0xFFE65100);
          screen = SparePartsTab(onBack: () => Navigator.pop(context));
          break;
        case 'DISPATCH':
          title = 'Dispatch';
          icon = Icons.local_shipping_outlined;
          color = const Color(0xFF0288D1);
          screen = DispatchmentEntryScreen(onBack: () => Navigator.pop(context));
          break;
        case 'ALL TICKETS':
          title = 'All Tickets';
          icon = Icons.confirmation_number_outlined;
          color = const Color(0xFF6A1B9A);
          screen = const AllTicketsScreen();
          break;
        case 'RAISE COMPLAINT':
          title = 'Raise Complaint';
          icon = Icons.campaign_outlined;
          color = const Color(0xFFD81B60);
          screen = const RaiseComplaintScreen();
          break;
        case 'ALL DISPATCH':
          title = 'All Dispatch';
          icon = Icons.assignment_turned_in_outlined;
          color = const Color(0xFF283593);
          screen = const AllDispatchScreen();
          break;
        case 'STAND BY':
          title = 'Stand By';
          icon = Icons.power_settings_new_rounded;
          color = const Color(0xFFC62828);
          screen = const StandByScreen();
          break;
        case 'STANDBY MANAGE & TRACK':
          title = 'Standby Track';
          icon = Icons.location_on_outlined;
          color = const Color(0xFFC62828);
          screen = const StandByScreen();
          break;
        case 'MY TOOLKIT':
          title = 'My Toolkit';
          icon = Icons.build_outlined;
          color = const Color(0xFF37474F);
          screen = const ToolkitScreen();
          break;
        case 'TOOLKIT MANAGEMENT':
          title = 'Toolkit Manage';
          icon = Icons.handyman_outlined;
          color = const Color(0xFF37474F);
          screen = const ToolkitScreen();
          break;
        case 'EOD':
          title = 'EOD';
          icon = Icons.analytics_outlined;
          color = const Color(0xFFAD1457);
          screen = const EodReportScreen();
          break;
        case 'SERVICE DETAILS':
          title = 'Service Details';
          icon = Icons.analytics_outlined;
          color = const Color(0xFFAD1457);
          screen = const EodReportScreen();
          break;
        case 'SERVICE HISTORY':
          title = 'Service History';
          icon = Icons.history_edu_outlined;
          color = const Color(0xFFAD1457);
          screen = const EodReportScreen();
          break;
        case 'EVOLUTION REPORT':
          title = 'Evolution Report';
          icon = Icons.assignment_ind_outlined;
          color = const Color(0xFF8D6E63);
          screen = const EvaluationScreen();
          break;
        case 'EVALUATION':
          title = 'Evaluation';
          icon = Icons.assignment_ind_outlined;
          color = const Color(0xFF8D6E63);
          screen = const EvaluationScreen();
          break;
        default:
          title = _toTitleCase(name);
          icon = _getAppIcon(name);
          color = const Color(0xFF00796B);
          screen = null;
          break;
      }

      gridItems.add({
        'title': title,
        'icon': icon,
        'color': color,
        'screen': screen,
        'originalName': name,
      });
    }

    if (gridItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        alignment: Alignment.center,
        child: Text(
          "No menus available",
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.92,
      ),
      itemCount: gridItems.length,
      itemBuilder: (context, index) {
        final item = gridItems[index];
        final Color itemColor = item['color'] as Color;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (item['screen'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                );
              } else {
                if (widget.onNavigate != null) {
                  widget.onNavigate!(
                    context,
                    item['originalName'] as String,
                    moduleContext: 'ERP SERVICE',
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: itemColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: itemColor,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    item['title'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
              color: Colors.black.withOpacity(0.15),
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
                        package: 'service_ticket',
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
                        package: 'service_ticket',
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
        ],
      ),
    );
  }
}

class _SalesOverviewCard extends StatelessWidget {
  const _SalesOverviewCard({required this.data});
  final List<Map<String, dynamic>> data;

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
            color: Colors.black.withOpacity(0.04),
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
            'Service Overviewwww',
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: 600.w,
                child: CustomPaint(painter: _BarChartPainter(data: data)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.data});
  final List<Map<String, dynamic>> data;

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

    final List<String> allMonths = [
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
    final Map<String, double> mergedData = {
      for (var month in allMonths) month: 0.0,
    };

    for (var item in data) {
      final month = item['month']?.toString() ?? '';
      if (mergedData.containsKey(month)) {
        mergedData[month] =
            double.tryParse(item['percentage']?.toString() ?? '0') ?? 0.0;
      }
    }

    final List<Map<String, dynamic>> finalData = allMonths
        .map((m) => {'month': m, 'percentage': mergedData[m]})
        .toList();

    _drawDataBars(canvas, size, finalData, chartHeight, endY);
  }

  void _drawDataBars(
    Canvas canvas,
    Size size,
    List<Map<String, dynamic>> barData,
    double chartHeight,
    double endY,
  ) {
    final List<Color> colors = [
      const Color(0xFFFF2A55),
      const Color(0xFFB51065),
      const Color(0xFF4B14C8),
      const Color(0xFF00465A),
      const Color(0xFF28A096),
    ];
    final List<Color> darkColors = [
      const Color(0xFFD9153A),
      const Color(0xFF8A0A4B),
      const Color(0xFF320C8A),
      const Color(0xFF00304F),
      const Color(0xFF1B7A72),
    ];

    final double maxVal = 100.0;
    final double barWidth = size.width / (barData.length * 2.2);
    final double spacing =
        (size.width - (barWidth * barData.length)) / (barData.length + 1);

    double currentX = spacing;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < barData.length; i++) {
      final item = barData[i];
      final value =
          double.tryParse(item['percentage']?.toString() ?? '0') ?? 0.0;
      final color =
          value == 0 ? Colors.grey.shade300 : colors[i % colors.length];
      final darkColor =
          value == 0 ? Colors.grey.shade400 : darkColors[i % darkColors.length];
      final label = item['month']?.toString() ?? '';

      // Ensure min bar height for the pointed tip if value > 0
      final double calculatedHeight = (value / maxVal) * chartHeight;
      final double tipHeight = barWidth / 2.2; // Sharper tip
      final double barHeight =
          value > 0 ? math.max(calculatedHeight, tipHeight + 5) : 0;

      if (barHeight > 0) {
        final leftPath = Path();
        leftPath.moveTo(currentX, endY);
        leftPath.lineTo(currentX, endY - barHeight + tipHeight);
        leftPath.lineTo(currentX + (barWidth / 2), endY - barHeight);
        leftPath.lineTo(currentX + (barWidth / 2), endY);
        leftPath.close();
        canvas.drawPath(leftPath, Paint()..color = color);

        final rightPath = Path();
        rightPath.moveTo(currentX + (barWidth / 2), endY);
        rightPath.lineTo(currentX + (barWidth / 2), endY - barHeight);
        rightPath.lineTo(currentX + barWidth, endY - barHeight + tipHeight);
        rightPath.lineTo(currentX + barWidth, endY);
        rightPath.close();
        canvas.drawPath(rightPath, Paint()..color = darkColor);
      } else {
        // Draw a subtle line for 0%
        canvas.drawLine(
          Offset(currentX, endY),
          Offset(currentX + barWidth, endY),
          Paint()
            ..color = Colors.grey.shade300
            ..strokeWidth = 1.5,
        );
      }

      // Percentage Text
      if (value > 0) {
        textPainter.text = TextSpan(
          text: '${value.toInt()}%',
          style: TextStyle(
            color: color,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            currentX + (barWidth / 2) - (textPainter.width / 2),
            endY - barHeight - 16,
          ),
        );
      }

      // Label Text
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: value == 0 ? Colors.grey : color,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w800,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(currentX + (barWidth / 2) - (textPainter.width / 2), endY + 8),
      );

      currentX += barWidth + spacing;
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const int dashWidth = 4;
    const int dashSpace = 4;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(startX + dashWidth, p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) => true;
}

class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard({required this.data});
  final List<Map<String, dynamic>> data;

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
            color: Colors.black.withOpacity(0.04),
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
            'Service Status',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF222222),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 130.w,
                height: 130.w,
                child: CustomPaint(painter: _PieChartPainter(data: data)),
              ),
              SizedBox(width: 32.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.map((item) {
                  final label = item['label']?.toString() ?? '';
                  Color color = const Color(0xFF00465A);
                  if (label == 'Assigned') color = const Color(0xFF4B14C8);
                  if (label == 'Completed') color = const Color(0xFFB51065);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: _buildLegendItem(color, label),
                  );
                }).toList(),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
  _PieChartPainter({required this.data});
  final List<Map<String, dynamic>> data;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (data.isEmpty) return;

    double startAngle = -math.pi / 2;

    for (var item in data) {
      final value =
          double.tryParse(item['percentage']?.toString() ?? '0') ?? 0.0;
      final labelText = item['label']?.toString() ?? '';

      Color color = const Color(0xFF00465A);
      if (labelText == 'Assigned') color = const Color(0xFF4B14C8);
      if (labelText == 'Completed') color = const Color(0xFFB51065);

      final sweepAngle = (value / 100) * 2 * math.pi;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);

      if (value > 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${value.toInt()}%',
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
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => true;
}

IconData _getAppIcon(String name) {
  final String n = name.toUpperCase();

  // Module Icons
  if (n.contains("PURCHASE")) return Icons.shopping_bag_outlined;
  if (n.contains("SALES")) return Icons.trending_up_rounded;
  if (n.contains("HRM")) return Icons.people_outline_rounded;
  if (n.contains("CRM")) return Icons.contact_mail_outlined;
  if (n.contains("ACCOUNTING")) return Icons.account_balance_wallet_outlined;
  if (n.contains("WAREHOUSE")) return Icons.warehouse_outlined;
  if (n.contains("MANUFACTURING")) return Icons.precision_manufacturing_outlined;
  if (n.contains("SERVICE")) return Icons.home_repair_service_outlined;

  // Action Icons
  if (n.contains("CREATE PR") || n == "PR" || n.contains("PURCHASE REQUEST")) return Icons.add_shopping_cart_rounded;
  if (n.contains("SUPPLIER QUOTATIONS")) return Icons.history_rounded;
  if (n.contains("RFQ")) return Icons.article_outlined;
  if (n.contains("ORDER")) return Icons.local_offer_outlined;
  if (n.contains("GRN") || n.contains("QC")) return Icons.assignment_turned_in_outlined;
  if (n.contains("INVOICE")) return Icons.receipt_long_outlined;
  if (n.contains("APPROVAL")) return Icons.assignment_ind_outlined;
  if (n.contains("COMPARISON")) return Icons.compare_arrows_rounded;
  if (n.contains("CHALLAN")) return Icons.local_shipping_outlined;
  if (n.contains("LEAVE")) return Icons.event_available_outlined;
  if (n.contains("PERMISSION")) return Icons.history_toggle_off_rounded;
  if (n.contains("SETTINGS")) return Icons.settings_outlined;
  if (n.contains("REPORT")) return Icons.analytics_outlined;
  if (n.contains("DASHBOARD")) return Icons.dashboard_customize_outlined;
  if (n.contains("LEAD")) return Icons.person_add_alt_1_rounded;
  if (n.contains("ENQUIRY")) return Icons.headset_mic_rounded;
  if (n.contains("DEAL")) return Icons.handshake_rounded;
  if (n.contains("FOLLOW")) return Icons.event_note_rounded;
  if (n.contains("MEETING")) return Icons.groups_rounded;
  if (n.contains("RECRUITMENT")) return Icons.person_search_outlined;
  if (n.contains("ONBOARDING")) return Icons.how_to_reg_outlined;
  if (n.contains("COMPLAINT")) return Icons.gavel_outlined;
  if (n.contains("PAYROLL")) return Icons.payments_outlined;
  if (n.contains("EXPENSE")) return Icons.account_balance_wallet_outlined;
  if (n.contains("PERFORMANCE")) return Icons.speed_outlined;
  if (n.contains("TRAINING")) return Icons.school_outlined;
  if (n.contains("HEALTH") && n.contains("SAFETY")) return Icons.health_and_safety_outlined;
  if (n.contains("EMPLOYEE DETAILS") || n.contains("STAFF DETAILS")) return Icons.badge_outlined;
  if (n.contains("ATTENDANCE MANAGEMENT") || n.contains("ATTENDANCE ADMIN") || (n.contains("ATTENDANCE") && n.contains("ADMIN"))) return Icons.fact_check_rounded;

  return Icons.circle_outlined;
}
