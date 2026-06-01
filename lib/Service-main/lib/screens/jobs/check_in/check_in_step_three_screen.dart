import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../../../data/app_data.dart';
import '../../../services/api_service.dart';
import 'check_in_completed_screen.dart';
import 'check_in_widgets.dart';
import '../../../services/device_service.dart';

const Color _primaryBlue = Color(0xFF2644A6);

class CheckInStepThreeScreen extends StatefulWidget {
  const CheckInStepThreeScreen({super.key});

  @override
  State<CheckInStepThreeScreen> createState() => _CheckInStepThreeScreenState();
}

class _CheckInStepThreeScreenState extends State<CheckInStepThreeScreen> {
  @override
  Widget build(BuildContext context) {
    final flow = AppData.instance;
    final job = flow.job;
    final rows = (job['spareLines'] as List)
        .map((item) => Map<String, String>.from(item as Map))
        .toList();
    final spareRows = rows.map((r) => {
      'name': r['spare_name'] ?? '',
      'quantity': r['qty'] ?? '0'
    }).toList();
    final selectedChannel = flow.otpChannel;

    return CheckInScaffold(
      title: 'Check Out',
      actionLabel: 'Enter Happy Code',
      actionEnabled: true,
      onAction: () => _showHappyCodeBottomSheet(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WorkflowIndicator(currentStep: 4),
          SizedBox(height: 14.h),
          GradientTicketSummary(
            ticketId: '${job['ticketId']}',
            customerName: '${job['customerName']}',
            issue: '${job['issue']}',
            startTime: '${job['startTime']}',
            endTime: '${job['endTime']}',
            duration: '${job['duration']}',
          ),
          SizedBox(height: 16.h),
          SummaryTable(
            rows: spareRows,
            serviceCharge: '${job['serviceCharge']}',
            nextVisitDate: '${job['nextVisitDate'] ?? ''}',
          ),
          SizedBox(height: 16.h),
          Text(
            'Upload  Signature',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          UploadBox(
            caption: 'E-Signature Required',
            isSignature: true,
            fileName: flow.signatureName.isNotEmpty ? flow.signatureName : null,
            imageBytes: flow.signatureBytes,
            onTap: () async {
              final bytes = await Navigator.of(context).push<Uint8List?>(
                MaterialPageRoute(builder: (_) => const SignaturePadScreen()),
              );
              if (bytes != null) {
                setState(() {
                  flow.signatureBytes = bytes;
                  flow.signatureName = 'Signature Captured';
                });
              }
            },
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFF4AC94A),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              children: [
                Text(
                  'Happy Code Required',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'An OTP called the Happy Code is sent in Customer App in My Complaints. The customer needs to share it back, then checkout can complete.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHappyCodeBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => _HappyCodeSheet(
        onVerified: () {
          final appData = AppData.instance;
          final ticketId = appData.job['ticketId'];
          if (ticketId != null) {
            appData.updateTicket(
              '$ticketId',
              status: appData.workStatus.isEmpty
                  ? 'Completed'
                  : appData.workStatus,
            );
          }

          Navigator.of(bottomSheetContext).pop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const CheckInCompletedScreen()),
          );
        },
      ),
    );
  }
}

class _HappyCodeSheet extends StatefulWidget {
  const _HappyCodeSheet({required this.onVerified});

  final VoidCallback onVerified;

  @override
  State<_HappyCodeSheet> createState() => _HappyCodeSheetState();
}

class _HappyCodeSheetState extends State<_HappyCodeSheet> {
  Future<void> _submitCheckOutToBackend(AppData flow) async {
    final prefs = await SharedPreferences.getInstance();
    final cid = (prefs.getString('cid') ?? '').trim();
    final token = (prefs.getString('token') ?? '').trim();
    final uid = (prefs.getString('uid') ?? '').trim();
    final roleId = (prefs.getString('role_id') ?? '').trim();
    final engineerId = (prefs.getString('engineer_id') ?? '').trim();
    final deviceId = (prefs.getString('device_id') ?? '').trim();

    final ticketId = RegExp(r'\d+')
        .allMatches(flow.job['id'] ?? flow.job['ticketId'] ?? '')
        .map((m) => m.group(0))
        .join('');
    final lat = flow.job['lt']?.toString() ?? '11.0';
    final lng = flow.job['ln']?.toString() ?? '77.0';

    final String workStatusParam =
        flow.workStatus.toLowerCase() == 'completed' ? 'completed' : 'pending';
    final String scheduledDate = flow.nextVisitDate != null
        ? '${flow.nextVisitDate!.year}-${flow.nextVisitDate!.month.toString().padLeft(2, '0')}-${flow.nextVisitDate!.day.toString().padLeft(2, '0')}'
        : '';

    final List<Map<String, dynamic>> spareData =
        (flow.job['spareLines'] as List? ?? [])
            .map((line) =>
                {'spare_name': line['spare_name'], 'qty': line['qty'] ?? '1'})
            .toList();

    final Map<String, dynamic> fields = {
      'cid': cid,
      'uid': uid,
      'type': '5014',
      'ln': lng,
      'lt': lat,
      'device_id': deviceId.isEmpty ? await DeviceService.getDeviceId() : deviceId,
      'id': ticketId,
      'role_id': roleId,
      'token': token,
      'engineer_id': engineerId.isEmpty ? uid : engineerId,
      'wrk_disc': flow.workDescription,
      'charge': flow.serviceChargeInput,
      'work_status': workStatusParam,
      'wrk_time': DateFormat('hh:mma').format(DateTime.now()).toLowerCase(),
      'spares': jsonEncode(spareData),
    };

    if (scheduledDate.isNotEmpty) fields['scheduled_date'] = scheduledDate;

    final formData = dio_pkg.FormData.fromMap(fields);

    if (flow.beforeImageBytes != null) {
      formData.files.add(
        MapEntry(
          'bf_photo',
          dio_pkg.MultipartFile.fromBytes(
            flow.beforeImageBytes!,
            filename: 'bf_photo.jpg',
          ),
        ),
      );
    }
    if (flow.afterImageBytes != null) {
      formData.files.add(
        MapEntry(
          'af_photo',
          dio_pkg.MultipartFile.fromBytes(
            flow.afterImageBytes!,
            filename: 'af_photo.jpg',
          ),
        ),
      );
    }
    if (flow.oldSpareImageBytes != null) {
      formData.files.add(
        MapEntry(
          'old_spare',
          dio_pkg.MultipartFile.fromBytes(
            flow.oldSpareImageBytes!,
            filename: 'old_spare.jpg',
          ),
        ),
      );
    }
    if (flow.signatureBytes != null) {
      formData.files.add(
        MapEntry(
          'sign',
          dio_pkg.MultipartFile.fromBytes(
            flow.signatureBytes!,
            filename: 'signature.png',
          ),
        ),
      );
    }

    try {
      final dio = dio_pkg.Dio();
      await dio.post(await ApiService.getBaseUrl(), data: formData);
    } catch (e) {
      debugPrint('Final submission error: $e');
    }
  }

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _controller.text.trim().length == 6;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        24.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Happy code sent !',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E8D43),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ask customer to share the 6-digit code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF667085)),
            ),
            SizedBox(height: 24.h),
            Text(
              'ENTER HAPPY CODE',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 14.h),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final digits = _controller.text.replaceAll(
                  RegExp(r'[^0-9]'),
                  '',
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    final digit = index < digits.length ? digits[index] : '';
                    return Container(
                      width: 42.w,
                      height: 48.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFF7A92E8),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        digit,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: _primaryBlue,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            SizedBox(height: 10.h),
            SizedBox(
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  counterText: '',
                ),
                style: const TextStyle(fontSize: 1, color: Colors.transparent),
                cursorColor: Colors.transparent,
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resend OTP in ',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF2644A6),
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text(
                  '30 Sec',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2644A6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: (isValid && !_isBusy) ? _handleVerify : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E8D43),
                  disabledBackgroundColor: const Color(0xFFC7D5C8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isBusy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'VERIFY & CHECK OUT',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVerify() async {
    final otp = _controller.text.trim();
    if (otp.length != 6) return;

    setState(() => _isBusy = true);

    try {
      final job = AppData.instance.job;
      // The numeric ID is stored in 'id' according to previous screens
      final complaintId = job['id']?.toString() ?? '';

      if (complaintId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Missing job ID')));
        }
        return;
      }

      final res = await ApiService.verifyHappyCode(
        complaintId: complaintId,
        otp: otp,
      );

      if (res['error'] == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Verified Successfully'),
              backgroundColor: Colors.green,
            ),
          );
          await _submitCheckOutToBackend(AppData.instance);
          widget.onVerified();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Verification Failed'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}

class SignaturePadScreen extends StatefulWidget {
  const SignaturePadScreen({super.key});

  @override
  State<SignaturePadScreen> createState() => _SignaturePadScreenState();
}

class _SignaturePadScreenState extends State<SignaturePadScreen> {
  final GlobalKey _captureKey = GlobalKey();
  final List<Offset?> _points = <Offset?>[];
  bool _hasDrawn = false;

  Future<void> _clear() async {
    setState(() {
      _points.clear();
      _hasDrawn = false;
    });
  }

  Future<void> _save() async {
    final boundary =
        _captureKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    if (!mounted) return;
    Navigator.of(context).pop(data.buffer.asUint8List());
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _points.add(details.localPosition);
      _hasDrawn = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _points.add(null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _primaryBlue,
        elevation: 0,
        title: const Text('Signature'),
        actions: [TextButton(onPressed: _clear, child: const Text('Clear'))],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D9),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFF2C94C)),
                ),
                child: Text(
                  'Sign inside the black area below',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8C5A00),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: const Color(0xFFD9E2F2)),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: RepaintBoundary(
                    key: _captureKey,
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        foregroundPainter: _SignaturePainter(points: _points),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.black,
                          child: Center(
                            child: !_hasDrawn
                                ? Text(
                                    'Draw your signature here',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white70,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _hasDrawn ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    disabledBackgroundColor: const Color(0xFFC8D0E6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Save Signature'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({required this.points});

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final point = points[i];
      final nextPoint = points[i + 1];
      if (point != null && nextPoint != null) {
        canvas.drawLine(point, nextPoint, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
