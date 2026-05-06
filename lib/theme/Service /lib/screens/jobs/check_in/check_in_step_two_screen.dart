import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:service_ticket/core/size_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_colors.dart';
import '../../../data/app_data.dart';
import 'check_in_step_three_screen.dart';
import 'check_in_widgets.dart';
import 'package:service_ticket/core/api_config.dart';

class CheckInStepTwoScreen extends StatefulWidget {
  const CheckInStepTwoScreen({super.key});

  @override
  State<CheckInStepTwoScreen> createState() => _CheckInStepTwoScreenState();
}

class _CheckInStepTwoScreenState extends State<CheckInStepTwoScreen> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _chargeController;
  late final TextEditingController _partController;
  late final TextEditingController _quantityController;
  String _selectedSpareId = '';

  final List<Map<String, String>> _spareLines = [];
  bool _showSpareDetails = false;
  bool _submitted = false;
  String _workStatus = 'Completed';
  DateTime? _nextVisitDate;

  List<Map<String, dynamic>> _sparesList = [];
  bool _isLoadingSpares = false;

  @override
  void initState() {
    super.initState();
    final flow = AppData.instance;
    _descriptionController = TextEditingController(text: flow.workDescription);
    _chargeController = TextEditingController(text: flow.serviceChargeInput);
    _nextVisitDate = flow.nextVisitDate;

    final existingLines = (flow.job['spareLines'] as List? ?? [])
        .map((item) => Map<String, String>.from(item as Map))
        .toList();
    if (existingLines.isNotEmpty) {
      _spareLines.addAll(existingLines);
    }

    _partController = TextEditingController();
    _quantityController = TextEditingController(text: '1');

    _fetchSpares();
  }

  Future<void> _fetchSpares() async {
    setState(() => _isLoadingSpares = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = (prefs.getString('cid') ?? '').trim();
      final token = (prefs.getString('token') ?? '').trim();
      final uid = (prefs.getString('uid') ?? '').trim();
      final roleId = (prefs.getString('role_id') ?? '').trim();
      final engineerId = (prefs.getString('engineer_id') ?? '').trim();
      final deviceId = (prefs.getString('device_id') ?? '').trim();

      final Map<String, dynamic> body = {
        'type': '5018',
        'cid': cid,
        'device_id': deviceId.isEmpty ? '123' : deviceId,
        'lt': '11.0',
        'ln': '77.0',
        'engineer_id': engineerId.isEmpty ? uid : engineerId,
        'role_id': roleId.isEmpty ? '2' : roleId,
        'token': token,
      };

      final dio = dio_pkg.Dio();
      final response = await dio.post(
        await ApiConfig.getBaseUrl(),
        data: dio_pkg.FormData.fromMap(body),
      );

      dynamic resData = response.data;
      if (resData is String) resData = jsonDecode(resData);

      if (resData != null && resData['error'] == false) {
        final data = resData['data'];
        if (data is List) {
          setState(() {
            final allSpares = data
                .map((e) => Map<String, dynamic>.from(e))
                .toList();

            // Deduplicate by spare_id to prevent DropdownButton crashes
            final Map<String, Map<String, dynamic>> uniqueSpares = {};
            for (var spare in allSpares) {
              final sid = spare['spare_id']?.toString();
              if (sid != null && !uniqueSpares.containsKey(sid)) {
                uniqueSpares[sid] = spare;
              }
            }

            _sparesList = uniqueSpares.values.toList();

            if (_sparesList.isNotEmpty) {
              _partController.text = _sparesList.first['spare_name'] ?? '';
              _selectedSpareId =
                  _sparesList.first['spare_id']?.toString() ?? '';
            }
            _isLoadingSpares = false;
          });
        }
      } else {
        setState(() => _isLoadingSpares = false);
      }
    } catch (e) {
      debugPrint('Fetch Spares Error: $e');
      setState(() => _isLoadingSpares = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _chargeController.dispose();
    _partController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _persistSpareLines(AppData flow) {
    flow.setSpareLines(List<Map<String, String>>.from(_spareLines));
  }

  void _addSpareLine(AppData flow) {
    final name = _partController.text.trim();
    final quantity = _quantityController.text.trim();
    final partCode = _selectedSpareId;
    if (name.isEmpty || quantity.isEmpty || partCode.isEmpty) return;

    setState(() {
      _spareLines.add({
        'name': name,
        'quantity': quantity,
        'partCode': partCode,
      });
      _showSpareDetails = false;
      _quantityController.text = '1';
    });
    _persistSpareLines(flow);
  }

  void _removeSpareLine(int index) {
    final flow = AppData.instance;
    setState(() {
      _spareLines.removeAt(index);
    });
    _persistSpareLines(flow);
  }

  String _formatNextVisitDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatApiDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickNextVisitDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextVisitDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _nextVisitDate = picked);
  }

  String _extractNumericId(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    return RegExp(r'\d+').allMatches(str).map((m) => m.group(0)).join('');
  }

  // API submission
  Future<void> _submitCheckOutToBackend(AppData flow) async {
    final prefs = await SharedPreferences.getInstance();

    final cid = (prefs.getString('cid') ?? '').trim();
    final token = (prefs.getString('token') ?? '').trim();
    final uid = (prefs.getString('uid') ?? '').trim();
    final roleId = (prefs.getString('role_id') ?? '').trim();
    final engineerId = (prefs.getString('engineer_id') ?? '').trim();
    final deviceId = (prefs.getString('device_id') ?? '').trim();

    // Extract numeric ID
    final ticketId = _extractNumericId(
      flow.job['id'] ?? flow.job['ticketId'] ?? flow.job['ticketNo'],
    );

    final lat = flow.job['lt']?.toString() ?? '11.0';
    final lng = flow.job['ln']?.toString() ?? '77.0';

    final String workStatusParam = flow.workStatus.toLowerCase() == 'completed'
        ? 'completed'
        : 'pending';

    final String scheduledDate = flow.nextVisitDate != null
        ? _formatApiDate(flow.nextVisitDate!)
        : '';

    final dio = dio_pkg.Dio();

    final List<Map<String, dynamic>> spareData = _spareLines
        .map(
          (line) => {
            'spare_name': line['name'],
            'qty': int.tryParse(line['quantity'] ?? '0') ?? 1,
          },
        )
        .toList();

    final Map<String, dynamic> fields = {
      'cid': cid,
      'uid': uid.isEmpty ? '33' : uid,
      'type': '5014',
      'ln': lng,
      'lt': lat,
      'device_id': deviceId.isEmpty ? '12345' : deviceId,
      'id': ticketId,
      'role_id': roleId.isEmpty ? '2' : roleId,
      'token': token,
      'engineer_id': engineerId.isEmpty ? uid : engineerId,
      'wrk_disc': flow.workDescription,
      'charge': flow.serviceChargeInput,
      'work_status': workStatusParam,
      'wrk_time': DateFormat('hh:mma').format(DateTime.now()).toLowerCase(),
      'spares': jsonEncode(spareData),
    };

    if (scheduledDate.isNotEmpty) {
      fields['scheduled_date'] = scheduledDate;
    }

    // DEBUG: Print exactly what we are sending
    debugPrint('DEBUG: Calling 5014 with Fields: $fields');

    final formData = dio_pkg.FormData.fromMap(fields);

    if (flow.afterImagePath.isNotEmpty) {
      final file = File(flow.afterImagePath);
      final exists = await file.exists();
      debugPrint(
        'DEBUG: After Image Path: ${flow.afterImagePath}, Exists: $exists',
      );
      if (exists) {
        formData.files.add(
          MapEntry(
            'af_photo',
            await dio_pkg.MultipartFile.fromFile(
              file.path,
              filename: 'af_photo.jpg',
            ),
          ),
        );
      }
    }

    try {
      final response = await dio.post(
        await ApiConfig.getBaseUrl(),
        data: formData,
        queryParameters: {'cid': cid, 'id': ticketId, 'type': '5014'},
        options: dio_pkg.Options(validateStatus: (status) => true),
      );

      final resData = response.data;
      debugPrint('DEBUG: 5014 Response: $resData');

      if (resData is Map && resData['error'] == false) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Service completed successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Update failed: ${resData['error_msg'] ?? 'Server error'}',
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('DEBUG: 5014 Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network error. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = AppData.instance;
    final chargeInvalid = _submitted && _chargeController.text.trim().isEmpty;
    final afterInvalid = _submitted && flow.afterImageBytes == null;
    final nextVisitInvalid =
        _submitted && _workStatus == 'Pending' && _nextVisitDate == null;

    return CheckInScaffold(
      title: 'Service Form',
      actionLabel: 'Save & Check Out',
      onAction: () async {
        setState(() => _submitted = true);
        flow.serviceChargeInput = _chargeController.text.trim();
        flow.workStatus = _workStatus;
        flow.nextVisitDate = _workStatus == 'Pending' ? _nextVisitDate : null;
        flow.updateJob({
          'serviceCharge': flow.serviceChargeInput,
          'nextVisitDate': flow.nextVisitDate == null
              ? ''
              : _formatNextVisitDate(flow.nextVisitDate!),
        });
        _persistSpareLines(flow);
        final hasError =
            _chargeController.text.trim().isEmpty ||
            flow.afterImageBytes == null ||
            (_workStatus == 'Pending' && _nextVisitDate == null);
        if (hasError) {
          return;
        }

        // ── API call ────────────────────────
        await _submitCheckOutToBackend(flow);
        // ────────────────────────────────────

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CheckInStepThreeScreen()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WorkflowIndicator(currentStep: 3),
          SizedBox(height: 16.h),
          Text(
            'Work Description',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 4,
            onChanged: (value) => flow.workDescription = value,
            decoration: InputDecoration(
              hintText: 'Describe the work you performed',
              hintStyle: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF98A2B3),
              ),
              filled: true,
              fillColor: const Color(0xFFF1F4F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () => setState(() => _showSpareDetails = !_showSpareDetails),
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Spare Parts Used',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Leave empty if none',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: const Color(0xFF667085),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    _showSpareDetails
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22.sp,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _showSpareDetails
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE6EAF2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Part',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF445B87),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F4F9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: _isLoadingSpares
                              ? Padding(
                                  padding: EdgeInsets.all(12.r),
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value:
                                        _sparesList.any(
                                          (s) =>
                                              s['spare_id']?.toString() ==
                                              _selectedSpareId,
                                        )
                                        ? _selectedSpareId
                                        : null,
                                    isExpanded: true,
                                    hint: Text(
                                      'Select part',
                                      style: TextStyle(fontSize: 13.sp),
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                    items:
                                        {
                                          for (var spare in _sparesList)
                                            if (spare['spare_id'] != null)
                                              spare['spare_id'].toString():
                                                  spare,
                                        }.values.map((spare) {
                                          final id = spare['spare_id']
                                              .toString();
                                          final name =
                                              spare['spare_name']?.toString() ??
                                              '';
                                          return DropdownMenuItem<String>(
                                            value: id,
                                            child: Text(
                                              name,
                                              style: TextStyle(fontSize: 13.sp),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      final selectedSpare = _sparesList
                                          .firstWhere(
                                            (s) =>
                                                s['spare_id']?.toString() ==
                                                value,
                                            orElse: () => {},
                                          );
                                      setState(() {
                                        _selectedSpareId = value;
                                        _partController.text =
                                            selectedSpare['spare_name']
                                                ?.toString() ??
                                            '';
                                      });
                                    },
                                  ),
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 6.h, left: 2.w),
                          child: Text(
                            'Select spare part from your available stock',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF667085),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _SpareField(
                          label: 'Quantity',
                          controller: _quantityController,
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          height: 44.h,
                          child: ElevatedButton(
                            onPressed: () => _addSpareLine(flow),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Add Spare',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_spareLines.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ..._spareLines.asMap().entries.map((entry) {
              final index = entry.key;
              final line = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFDCE3F7)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${index + 1}. ${line['name']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF445B87),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Qty ${line['quantity']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2F4FB4),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      InkWell(
                        onTap: () => _removeSpareLine(index),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18.sp,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          SizedBox(height: 16.h),

          Text(
            'Upload  After Image',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          UploadBox(
            caption: 'JPG, PNG or PDF (Max 5MB)',
            fileName: flow.afterImageName.isNotEmpty
                ? flow.afterImageName
                : null,
            imageBytes: flow.afterImageBytes,
            isInvalid: afterInvalid,
            onTap: () async {
              final file = await UploadBox.pickImage(context);
              if (file != null) {
                final bytes = await file.readAsBytes();
                setState(() {
                  flow.afterImageName = file.path.split('/').last;
                  flow.afterImagePath = file.path;
                  flow.afterImageBytes = bytes;
                });
              }
            },
          ),
          SizedBox(height: 16.h),
          Text(
            'Service charge',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _chargeController,
            keyboardType: TextInputType.number,
            onChanged: (value) => flow.serviceChargeInput = value,
            decoration: InputDecoration(
              hintText: '1',
              filled: true,
              fillColor: const Color(0xFFF1F4F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: chargeInvalid
                      ? const Color(0xFFD92D20)
                      : Colors.transparent,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: chargeInvalid
                      ? const Color(0xFFD92D20)
                      : Colors.transparent,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: chargeInvalid
                      ? const Color(0xFFD92D20)
                      : AppColors.primary,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Work Status',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE6EAF2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _workStatus,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Completed',
                    child: Text('Completed'),
                  ),
                  DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _workStatus = value;
                    if (value == 'Completed') {
                      _nextVisitDate = null;
                    }
                  });
                  flow.workStatus = value;
                },
              ),
            ),
          ),
          if (_workStatus == 'Pending') ...[
            SizedBox(height: 16.h),
            Text(
              'Next Visit Date',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            InkWell(
              onTap: _pickNextVisitDate,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: nextVisitInvalid
                        ? const Color(0xFFD92D20)
                        : const Color(0xFFE6EAF2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _nextVisitDate == null
                            ? 'Select next visit date'
                            : _formatNextVisitDate(_nextVisitDate!),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _nextVisitDate == null
                              ? const Color(0xFF98A2B3)
                              : const Color(0xFF445B87),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/calendar_icon.png',
                      width: 20.sp,
                      height: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _SpareField extends StatelessWidget {
  const _SpareField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF445B87),
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F4F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }
}