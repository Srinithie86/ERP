import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:service_ticket/core/size_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Widgets/app_status_bar_wrapper.dart';
import '../../../core/app_colors.dart';
import '../../../data/app_data.dart';
import '../../../services/device_service.dart';
import '../Check_in/check_in_step_two_screen.dart';
import '../Check_in/check_in_widgets.dart';

class WorkInProgressScreen extends StatefulWidget {
  const WorkInProgressScreen({super.key, required this.jobData});

  final Map<String, dynamic> jobData;

  @override
  State<WorkInProgressScreen> createState() => _WorkInProgressScreenState();
}

class _WorkInProgressScreenState extends State<WorkInProgressScreen> {
  Timer? _timer;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;
  bool _initializing = true;
  bool _submitted = false;

  String _extractNumericId(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    return RegExp(r'\d+').allMatches(str).map((m) => m.group(0)).join('');
  }

  // ── API submission ────────────────────────────────────────────────────────
  Future<void> _submitToBackend() async {
    final flow = AppData.instance;
    final prefs = await SharedPreferences.getInstance();

    final cid = (prefs.getString('cid') ?? '').trim();
    final token = (prefs.getString('token') ?? '').trim();
    final uid = (prefs.getString('uid') ?? '').trim();
    final roleId = (prefs.getString('role_id') ?? '').trim();
    var engineerId = (prefs.getString('cus_id') ??
                      prefs.getString('engineer_id') ??
                      prefs.getString('engineer') ??
                      '')
        .trim();
    if (engineerId.isEmpty) engineerId = uid;
    final deviceId = await DeviceService.getDeviceId();

    // extract numeric ID
    final ticketId = _extractNumericId(
      widget.jobData['id'] ??
          widget.jobData['ticketId'] ??
          widget.jobData['ticketNo'],
    );

    final lat =
        widget.jobData['jobLatitude']?.toString() ??
        widget.jobData['lt']?.toString() ??
        '11.0';
    final lng =
        widget.jobData['jobLongitude']?.toString() ??
        widget.jobData['ln']?.toString() ??
        '77.0';

    final int wrkTimeSecs = flow.workDuration.inSeconds > 0
        ? flow.workDuration.inSeconds
        : _elapsed.inSeconds;

    final dio = dio_pkg.Dio();

    final formData = dio_pkg.FormData.fromMap({
      'cid': cid,
      'uid': uid.isEmpty ? '33' : uid,
      'type': '5014',
      'ln': lng,
      'lt': lat,
      'device_id': deviceId,
      'id': ticketId,
      'role_id': roleId,
      'token': token,
      'engineer_id': engineerId.isEmpty ? uid : engineerId,
      'wrk_time': '$wrkTimeSecs',
    });

    if (flow.beforeImagePath.isNotEmpty) {
      final file = File(flow.beforeImagePath);
      final exists = await file.exists();
      debugPrint(
        'DEBUG: Before Image Path: ${flow.beforeImagePath}, Exists: $exists',
      );
      if (exists) {
        formData.files.add(
          MapEntry(
            'bf_photo',
            await dio_pkg.MultipartFile.fromFile(
              file.path,
              filename: 'bf_photo.jpg',
            ),
          ),
        );
      }
    }

    try {
      final response = await dio.post(
        'https://erpsmart.in/total/api/m_api/',
        data: formData,
        queryParameters: {'cid': cid, 'id': ticketId, 'type': '5014'},
        options: dio_pkg.Options(validateStatus: (status) => true),
      );
      debugPrint('WorkInProgress API Response: ${response.data}');
    } catch (e) {
      debugPrint('WorkInProgress API Exception: $e');
    }
  }
  // ─────────────────────────────────────────────────────────────────────────

  String _displayTicketNo(String value) {
    return value.replaceFirst(RegExp(r'^#?(TCK|TKT)-'), '#JOB-');
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(DateTime time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void initState() {
    super.initState();
    _syncTimerFromFlow();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncTimerFromFlow() {
    final flow = AppData.instance;
    if (flow.workStartedAt == null) {
      flow.startWorkTimer(startedAt: DateTime.now());
    }

    final start = flow.workStartedAt ?? DateTime.now();
    setState(() {
      _startTime = start;
      _elapsed = flow.workDuration == Duration.zero
          ? DateTime.now().difference(start)
          : flow.workDuration;
      _initializing = false;
    });

    flow.updateJob({
      'ticketId':
          '${widget.jobData['ticketNo'] ?? widget.jobData['ticketId'] ?? ''}',
      'customerName':
          '${widget.jobData['customerName'] ?? widget.jobData['name'] ?? ''}',
      'issue':
          '${widget.jobData['issue'] ?? widget.jobData['complaint'] ?? ''}',
      'complaint':
          '${widget.jobData['complaint'] ?? widget.jobData['issue'] ?? ''}',
      'phone': '${widget.jobData['phone'] ?? ''}',
      'address': '${widget.jobData['address'] ?? ''}',
      'product': '${widget.jobData['product'] ?? ''}',
      'estimatedDuration': '${widget.jobData['estimatedDuration'] ?? ''}',
      'priority': '${widget.jobData['priority'] ?? 'High Priority'}',
      'startTime': flow.workStartTimeText.isNotEmpty
          ? flow.workStartTimeText
          : _formatTimeOfDay(start),
      'checkInTime': flow.workStartTimeText.isNotEmpty
          ? flow.workStartTimeText
          : _formatTimeOfDay(start),
      'dateText': '${widget.jobData['dateText'] ?? ''}',
      'lt':
          '${widget.jobData['jobLatitude'] ?? widget.jobData['lt'] ?? '11.0'}',
      'ln':
          '${widget.jobData['jobLongitude'] ?? widget.jobData['ln'] ?? '77.0'}',
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _startTime == null || !flow.workTimerRunning) return;
      setState(() {
        _elapsed = DateTime.now().difference(_startTime!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.jobData;
    final ticketNo = _displayTicketNo(
      '${job['ticketNo'] ?? job['ticketId'] ?? ''}',
    );
    final customerName = '${job['customerName'] ?? job['name'] ?? ''}';
    final issue = '${job['issue'] ?? job['complaint'] ?? ''}';
    final location =
        '${job['locationLabel'] ?? job['address'] ?? job['location'] ?? ''}';
    final priority = '${job['priority'] ?? 'High Priority'}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: _initializing
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).maybePop(),
                            borderRadius: BorderRadius.circular(20.r),
                            child: Padding(
                              padding: EdgeInsets.all(4.r),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                size: 24.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Work in Progress',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'WORK TIME RUNNING',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.greenAccent.shade100,
                                letterSpacing: 1.1,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              _formatDuration(_elapsed),
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Started at ${_formatTimeOfDay(_startTime ?? DateTime.now())}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStatCard(
                                    title: 'Ticket',
                                    value: ticketNo,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _MiniStatCard(
                                    title: 'Priority',
                                    value: priority,
                                    valueColor: const Color(0xFFFFD54F),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: _MiniStatCard(
                                    title: 'Location',
                                    value: 'Verified',
                                    valueColor: const Color(0xFF7CFF8B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Work Flow',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      const _WorkProgressIndicator(currentStep: 4),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F5F9),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Detail',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _DetailRow(label: 'Name', value: customerName),
                            _DetailRow(
                              label: 'Product',
                              value: '${job['product'] ?? ''}',
                            ),
                            _DetailRow(label: 'Complaint', value: issue),
                            _DetailRow(
                              label: 'Phone',
                              value: '${job['phone'] ?? ''}',
                              valueColor: const Color(0xFF5177F5),
                            ),
                            _DetailRow(label: 'Address', value: location),
                            _DetailRow(
                              label: 'Et . Duration',
                              value: '${job['estimatedDuration'] ?? ''}',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Upload Before Image',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      UploadBox(
                        caption: 'Capturing the initial state of the work area',
                        fileName: AppData.instance.beforeImageName.isNotEmpty
                            ? AppData.instance.beforeImageName
                            : null,
                        imageBytes: AppData.instance.beforeImageBytes,
                        isInvalid:
                            _submitted &&
                            AppData.instance.beforeImageBytes == null,
                        onTap: () async {
                          final file = await UploadBox.pickImage(context);
                          if (file != null) {
                            final bytes = await file.readAsBytes();
                            setState(() {
                              AppData.instance.beforeImageName = file.path
                                  .split('/')
                                  .last;
                              AppData.instance.beforeImagePath = file.path;
                              AppData.instance.beforeImageBytes = bytes;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() => _submitted = true);
                            final flow = AppData.instance;

                            if (flow.beforeImageBytes == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please upload a Before Image before completing work',
                                  ),
                                ),
                              );
                              return;
                            }

                            flow.stopWorkTimer(endedAt: DateTime.now());
                            _timer?.cancel();
                            flow.updateJob({
                              'endTime': flow.workEndTimeText,
                              'duration': flow.workDurationText,
                            });

                            // ── API call ──────────────────────────────────
                            await _submitToBackend();
                            // ─────────────────────────────────────────────

                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CheckInStepTwoScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Complete Work & Fill Service Form',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkProgressIndicator extends StatelessWidget {
  const _WorkProgressIndicator({required this.currentStep});

  final int currentStep;

  static const labels = [
    'Ticket\nRaised',
    'Direct\nVisit',
    'Selfie\nVerification',
    'Check In',
    'Check Out',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(labels.length, (index) {
        final step = index + 1;
        final isActive = step <= currentStep;
        final circleColor = step <= currentStep
            ? const Color(0xFF55C56B)
            : const Color(0xFFD9DEE8);

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: Container(
                        height: 3.h,
                        color: step <= currentStep
                            ? const Color(0xFF55C56B)
                            : const Color(0xFFD9DEE8),
                      ),
                    ),
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: step <= currentStep
                        ? Icon(
                            Icons.check_rounded,
                            size: 14.sp,
                            color: Colors.white,
                          )
                        : Text(
                            '$step',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  if (index < labels.length - 1)
                    Expanded(
                      child: Container(
                        height: 3.h,
                        color: step < currentStep
                            ? const Color(0xFF55C56B)
                            : const Color(0xFFD9DEE8),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.sp,
                  height: 1.1,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF3D9E45)
                      : const Color(0xFF98A2B3),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFD7DCE8))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF5177F5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                color: valueColor ?? const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
