import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_ticket/core/size_utils.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../../Widgets/app_status_bar_wrapper.dart';
import '../../../core/app_colors.dart';
import '../../../Widgets/workflow_stepper.dart';
import '../../../data/app_data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/storage_service.dart';
import '../Work_in_progress/work_in_progress.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:http_parser/http_parser.dart';

class DirectVisitCameraScreen extends StatefulWidget {
  const DirectVisitCameraScreen({
    super.key,
    required this.jobData,
    required this.travelDuration,
  });

  final Map<String, dynamic> jobData;
  final String travelDuration;

  @override
  State<DirectVisitCameraScreen> createState() =>
      _DirectVisitCameraScreenState();
}

class _DirectVisitCameraScreenState extends State<DirectVisitCameraScreen> {
  bool _busy = false;
  bool _verified = false;
  bool _hasError = false;
  Uint8List? _selfieBytes;
  String? _capturedFilePath;

  Future<void> _openCamera() async {
    setState(() => _busy = true);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
      );
      if (file == null) {
        if (mounted) setState(() => _busy = false);
        return;
      }

      _capturedFilePath = file.path;
      final bytes = await file.readAsBytes();

      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableContours: false,
          enableClassification: false,
        ),
      );
      final inputImage = InputImage.fromFilePath(file.path);
      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      if (!mounted) return;

      if (faces.isEmpty) {
        setState(() {
          _selfieBytes = bytes;
          _verified = false;
          _hasError = true;
          _busy = false;
        });
        return;
      }

      setState(() {
        _selfieBytes = bytes;
        _verified = true;
        _hasError = false;
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Engineer verified successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open camera: $e')));
    }
  }

  Future<void> _submitVerification() async {
    if (_capturedFilePath == null) return;

    setState(() => _busy = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // DEBUG: Dump all keys to FIND role/engineer ids
      print('--- SharedPreferences Dump ---');
      for (String key in prefs.getKeys()) {
        print('DEBUG: Key: "$key", Value: "${prefs.get(key)}"');
      }
      print('-----------------------------');

      final cid = (prefs.getString('cid') ?? '').trim();
      final token = (prefs.getString('token') ?? '').trim();
      final uid = (prefs.getString('uid') ?? '').trim();
      final deviceId = (prefs.getString('device_id') ?? '').trim();

      // Role and Engineer ID fallbacks + alias checks
      String roleId =
          (prefs.getString('role_id') ?? prefs.getString('role') ?? '').trim();
      if (roleId.isEmpty) roleId = widget.jobData['role_id']?.toString() ?? '';

      String engineerId =
          (prefs.getString('engineer_id') ?? prefs.getString('engineer') ?? '')
              .trim();
      if (engineerId.isEmpty)
        engineerId =
            widget.jobData['engineer_id']?.toString() ??
            uid; // Fallback to UID as many systems use them interchangeably

      // Detailed extraction for ID
      String ticketId = widget.jobData['id']?.toString() ?? '';
      if (ticketId.isEmpty || ticketId == 'null')
        ticketId = widget.jobData['ticketId']?.toString() ?? '';
      if (ticketId.isEmpty || ticketId == 'null')
        ticketId = widget.jobData['ticketNo']?.toString() ?? '';

      if (ticketId.contains('-')) {
        ticketId = ticketId.split('-').last.trim();
      }
      ticketId = ticketId.replaceAll('#', '').trim();

      final lat =
          widget.jobData['jobLatitude']?.toString() ??
          widget.jobData['lt']?.toString() ??
          '11.0';
      final lng =
          widget.jobData['jobLongitude']?.toString() ??
          widget.jobData['ln']?.toString() ??
          '77.0';

      print('DEBUG: cid: "$cid"');
      print('DEBUG: ticketId (id): "$ticketId"');
      print('DEBUG: uid: "$uid"');
      print('DEBUG: roleId: "$roleId"');
      print('DEBUG: engineerId: "$engineerId"');

      if (cid.isEmpty || ticketId.isEmpty) {
        throw 'Missing cid or id in job session. CID: "$cid", ID: "$ticketId"';
      }

      final dio = dio_pkg.Dio();

      final Map<String, dynamic> allFields = {
        'cid': cid,
        'uid': uid,
        'type': '5013',
        'ln': lng,
        'lt': lat,
        'device_id': deviceId.isEmpty ? 'BP2A.250605.031.A3' : deviceId,
        'id': ticketId,
        'role_id': roleId.isEmpty ? '2' : roleId,
        'engineer_id': engineerId.isEmpty ? uid : engineerId,
        'token': token,
        'wrk_time': '1000',
        'tra_time': widget.travelDuration,
      };

      final formData = dio_pkg.FormData.fromMap({
        ...allFields,
        'vrf_photo': await dio_pkg.MultipartFile.fromFile(
          _capturedFilePath!,
          filename: 'vrf_photo.png',
          contentType: MediaType('image', 'png'),
        ),
      });

      print(
        'DEBUG: Final POST QueryParams: {cid: $cid, id: $ticketId, type: 5013}',
      );
      print('DEBUG: Final POST Body Fields: $allFields');

      final response = await dio.post(
        'https://erpsmart.in/total/api/m_api/',
        data: formData,
        queryParameters: {'cid': cid, 'id': ticketId, 'type': '5013'},
        options: dio_pkg.Options(
          headers: {'Accept': '*/*'},
          validateStatus: (status) => true,
        ),
      );

      print('DEBUG: Response Status: ${response.statusCode}');
      print('DEBUG: Response Body: ${response.data}');

      final dynamic responseData = response.data is String
          ? json.decode(response.data)
          : response.data;

      if (responseData['error'] == false) {
        if (!mounted) return;

        final flow = AppData.instance;
        final startedAt = DateTime.now();

        final updatedFields = responseData['updated_fields'] ?? {};

        flow.updateJob({
          ...widget.jobData,
          'vrf_photo_url':
              updatedFields['vrf_photo_url'] ?? responseData['vrf_photo_url'],
          'tra_time': updatedFields['tra_time'] ?? responseData['tra_time'],
        });

        flow.startWorkTimer(startedAt: startedAt);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WorkInProgressScreen(jobData: flow.job),
          ),
        );
      } else {
        final errorMsg =
            responseData['error_msg'] ??
            responseData['message'] ??
            responseData['msg'] ??
            'Server error';
        throw '$errorMsg (Source: ${response.data})';
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.jobData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
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
                      'Engineer Verification',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                const WorkflowStepper(
                  currentStep: 3,
                  labels: [
                    'Ticket\nRaised',
                    'Direct\nVisit',
                    'Selfie\nVerification',
                    'Check In',
                    'Check Out',
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFF4C542)),
                  ),
                  child: Text(
                    'Identity verification required before check-in',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB7791F),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: const Color(0xFFE6EAF4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_selfieBytes == null)
                        Image.asset(
                          'assets/camera_icon.png',
                          width: 140.w,
                          height: 140.w,
                          fit: BoxFit.contain,
                        )
                      else
                        Container(
                          width: 138.w,
                          height: 138.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF3F5F9),
                            border: Border.all(
                              color: _hasError
                                  ? Colors.red
                                  : const Color(0xFFCBD5E1),
                              width: _hasError ? 2.5 : 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.memory(
                              _selfieBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      SizedBox(height: 14.h),
                      if (!_verified) ...[
                        if (_hasError)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              'Verification Failed: No Face Detected',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          )
                        else
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: const Color(0xFF445B87),
                              ),
                              children: const [
                                TextSpan(text: 'Tap '),
                                TextSpan(
                                  text: 'Open Camera',
                                  style: TextStyle(color: Color(0xFF1E8D43)),
                                ),
                                TextSpan(text: ' to begin verification'),
                              ],
                            ),
                          ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          width: double.infinity,
                          height: 42.h,
                          child: OutlinedButton(
                            onPressed: _busy ? null : _openCamera,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF3451B2),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                            ),
                            child: Text(
                              _busy ? 'Opening Camera...' : 'Open Camera',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F7EC),
                                borderRadius: BorderRadius.circular(999.r),
                                border: Border.all(
                                  color: const Color(0xFF3BB54A),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF3BB54A),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Engineer verified',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2E8B3D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Verified with selfie',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E8B3D),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 250.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: (_verified && !_busy)
                        ? () => _submitVerification()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_verified && !_busy)
                          ? AppColors.primary
                          : const Color(0xFFC9CFDD),
                      disabledBackgroundColor: const Color(0xFFC9CFDD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _busy
                          ? 'Uploading...'
                          : 'Completed verification & Check - In',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
}

class MapPreviewScreen extends StatelessWidget {
  const MapPreviewScreen({super.key, required this.locationLabel});

  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 3,
                child: Image.asset('assets/map.png', fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF55C56B),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  locationLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              top: 16.h,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
