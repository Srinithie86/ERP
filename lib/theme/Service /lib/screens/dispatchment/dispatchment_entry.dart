import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../core/app_colors.dart';
import '../../data/app_data.dart';
import '../../services/device_service.dart';
import 'dispatchment_history.dart';
import 'package:service_ticket/core/api_config.dart';

class DispatchmentEntryScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const DispatchmentEntryScreen({super.key, this.onBack});

  @override
  State<DispatchmentEntryScreen> createState() =>
      _DispatchmentEntryScreenState();
}

class _DispatchmentEntryScreenState extends State<DispatchmentEntryScreen> {
  List<String> _parcels = [];
  bool _isLoadingParcels = false;
  List<Map<String, dynamic>> _transportModes = [];
  bool _isLoadingModes = false;

  final _parcelCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _parcelFocus = FocusNode();
  final _phoneFocus = FocusNode();

  String? _selectedParcelId;
  Timer? _debounce;

  String? _mode;
  DateTime? _transportDate;
  DateTime? _expectedDate;
  TimeOfDay? _dispatchTime;
  String _period = 'AM';

  bool _showDetails = true;
  bool _submitted = false;
  File? _image;
  String? _imagePath;

  String _apiName = '';
  String _apiPhone = '';
  String _apiAddress = '';
  String _apiCusId = '';

  @override
  void initState() {
    super.initState();
    _dispatchTime = TimeOfDay.now();
    _fetchTransportModes();
    _fetchParcels('');

    _parcelFocus.addListener(() {
      setState(() {});
    });
  }

  Future<void> _fetchParcels([String query = '']) async {
    if (mounted) setState(() => _isLoadingParcels = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = (prefs.getString('cid') ?? '').trim();
      final uid = (prefs.getString('uid') ?? '').trim();
      final roleId = (prefs.getString('role_id') ?? '').trim();
      final token = (prefs.getString('token') ?? '').trim();
      final cusId = (prefs.getString('cus_id') ?? '').trim();
      final engineerIdFromPref = (prefs.getString('engineer_id') ?? '').trim();

      final engineerId = engineerIdFromPref.isNotEmpty
          ? engineerIdFromPref
          : (cusId.isNotEmpty ? cusId : uid);

      final deviceId = await DeviceService.getDeviceId();

      final Map<String, dynamic> body = {
        'type': '5019',
        'cid': cid,
        'device_id': deviceId,
        'lt': '123',
        'ln': '987',
        'uid': uid,
        'role_id': roleId,
        'token': token,
        'engineer_id': engineerId,
        'search': query,
      };

      final dio = dio_pkg.Dio(
        dio_pkg.BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final response = await dio.post(
        await ApiConfig.getBaseUrl(),
        data: body,
        options: dio_pkg.Options(
          contentType: dio_pkg.Headers.formUrlEncodedContentType,
        ),
      );

      dynamic resData = response.data;
      if (resData is String) resData = jsonDecode(resData);

      if (resData is Map &&
          (resData['error'] == false ||
              resData['error'] == 0 ||
              resData['error']?.toString() == '0')) {
        final rawData = resData['data'];
        if (rawData is List) {
          final List<String> list = rawData
              .where((e) => e != null)
              .map((e) => e is Map ? (e['id']?.toString() ?? '') : e.toString())
              .where((s) => s.isNotEmpty)
              .toList();
          if (mounted) {
            setState(() {
              _parcels = list;
              _isLoadingParcels = false;
              if (list.isNotEmpty && _selectedParcelId == null) {
                _selectedParcelId = list.first;
                _fetchParcelDetails(list.first);
              }
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingParcels = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingParcels = false);
      }
    } catch (e) {
      debugPrint('DEBUG: fetchParcels Exception: $e');
      if (mounted) setState(() => _isLoadingParcels = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchParcels(query);
    });
  }

  Future<void> _fetchTransportModes() async {
    if (mounted) setState(() => _isLoadingModes = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = (prefs.getString('cid') ?? '').trim();
      final deviceId = await DeviceService.getDeviceId();

      final Map<String, dynamic> body = {
        'type': '2084',
        'cid': cid,
        'device_id': deviceId,
        'lt': '11.0',
        'ln': '77.0',
        'list_id': '10105',
      };

      final dio = dio_pkg.Dio(
        dio_pkg.BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final response = await dio.post(
        await ApiConfig.getBaseUrl(),
        data: body,
        options: dio_pkg.Options(
          contentType: dio_pkg.Headers.formUrlEncodedContentType,
        ),
      );

      dynamic resData = response.data;
      if (resData is String) resData = jsonDecode(resData);

      if (resData is Map &&
          (resData['error'] == false ||
              resData['error'] == 0 ||
              resData['error']?.toString() == '0')) {
        final rawModes = resData['dropdown'] ?? resData['data'];
        if (rawModes is List) {
          final List<Map<String, dynamic>> mapped = [];
          final Set<String> seenValues = {};

          for (var e in rawModes) {
            if (e is Map) {
              final val = (e['value'] ?? e['id'])?.toString() ?? '';
              final lab =
                  (e['label'] ?? e['name'] ?? e['value'] ?? e['id'])
                      ?.toString() ??
                  'Unknown';

              if (val.isNotEmpty && !seenValues.contains(val)) {
                mapped.add({'label': lab, 'value': val});
                seenValues.add(val);
              }
            }
          }

          if (mounted) {
            setState(() {
              _transportModes = mapped;
              if (mapped.isNotEmpty && _mode == null) {
                _mode = mapped.first['value'];
              }
              _isLoadingModes = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingModes = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingModes = false);
      }
    } catch (e) {
      debugPrint('DEBUG: fetchTransportModes Exception: $e');
      if (mounted) setState(() => _isLoadingModes = false);
    }
  }

  Future<void> _fetchParcelDetails(String parcelId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = (prefs.getString('cid') ?? '').trim();
      final uid = (prefs.getString('uid') ?? '').trim();
      final roleId = (prefs.getString('role_id') ?? '').trim();
      final token = (prefs.getString('token') ?? '').trim();
      final cusId = (prefs.getString('cus_id') ?? '').trim();
      final engineerIdFromPref = (prefs.getString('engineer_id') ?? '').trim();

      final engineerId = engineerIdFromPref.isNotEmpty
          ? engineerIdFromPref
          : (cusId.isNotEmpty ? cusId : uid);

      final deviceId = await DeviceService.getDeviceId();

      String cleanId = parcelId;
      final match = RegExp(r'\d+').firstMatch(parcelId);
      if (match != null) {
        cleanId = match.group(0)!;
      }

      setState(() {
        _nameCtrl.clear();
        _phoneCtrl.clear();
        _placeCtrl.clear();
      });

      final Map<String, dynamic> body = {
        'type': '5016',
        'cid': cid,
        'device_id': deviceId,
        'lt': '123',
        'ln': '987',
        'search': cleanId,
        'uid': uid,
        'role_id': roleId,
        'token': token,
        'engineer_id': engineerId,
      };

      final dio = dio_pkg.Dio();
      final response = await dio.post(
        await ApiConfig.getBaseUrl(),
        data: body,
        options: dio_pkg.Options(
          contentType: dio_pkg.Headers.formUrlEncodedContentType,
        ),
      );

      dynamic resData = response.data;
      if (resData is String) resData = jsonDecode(resData);

      if (resData is Map &&
          (resData['error'] == false ||
              resData['error'] == 0 ||
              resData['error'].toString() == '0')) {
        final rawData = resData['data'];
        Map<String, dynamic>? p;
        if (rawData is List && rawData.isNotEmpty) {
          if (rawData.first is Map) {
            p = Map<String, dynamic>.from(rawData.first);
          }
        } else if (rawData is Map) {
          p = Map<String, dynamic>.from(rawData);
        }

        if (p != null && mounted) {
          setState(() {
            _apiName = p?['b_name']?.toString() ?? '';
            _apiPhone = p?['mobile']?.toString() ?? '';
            _apiAddress = p?['b_add1']?.toString() ?? '';
            _apiCusId = p?['cus_id']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('DEBUG: fetchParcelDetails Exception: $e');
    }
  }

  @override
  void dispose() {
    _parcelCtrl.dispose();
    _parcelFocus.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _placeCtrl.dispose();
    _notesCtrl.dispose();
    _phoneFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return '$hour:${time.minute.toString().padLeft(2, '0')}';
  }

  String _buildDisTime(TimeOfDay time) {
    final timeStr = _formatTime(time);
    final periodStr = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$timeStr $periodStr';
  }

  bool get _phoneValid => _phoneCtrl.text.trim().length == 10;

  bool get _hasErrors =>
      _selectedParcelId == null ||
      _mode == null ||
      _transportDate == null ||
      _expectedDate == null ||
      _dispatchTime == null ||
      _nameCtrl.text.trim().isEmpty ||
      !_phoneValid ||
      _placeCtrl.text.trim().isEmpty ||
      _image == null;

  Color _border(bool invalid) =>
      invalid && _submitted ? const Color(0xFFD92D20) : const Color(0xFFDDE3EF);

  Future<void> _pickDate({required bool expected}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expected
          ? (_expectedDate ?? _transportDate ?? DateTime.now())
          : (_transportDate ?? DateTime.now()),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() => expected ? _expectedDate = picked : _transportDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dispatchTime ?? TimeOfDay.now(),
    );
    if (picked == null) return;
    setState(() {
      _dispatchTime = picked;
      _period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    });
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _imagePath = picked.path;
    });
  }

  // ==================== DIRECT SUBMISSION (No Happy Code) ====================
  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (_hasErrors) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = (prefs.getString('cid') ?? '').trim();
      final uid = (prefs.getString('uid') ?? '').trim();
      final roleId = (prefs.getString('role_id') ?? '').trim();
      final token = (prefs.getString('token') ?? '').trim();
      final cusIdPref = (prefs.getString('cus_id') ?? '').trim();
      final engineerId =
          (cusIdPref.isNotEmpty ? cusIdPref : (prefs.getString('engineer_id') ?? ''))
              .trim();
      final deviceId = await DeviceService.getDeviceId();

      String cleanParcelId = _selectedParcelId ?? '';
      final match = RegExp(r'\d+').firstMatch(cleanParcelId);
      if (match != null) cleanParcelId = match.group(0)!;

      final String cleanPhone = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

      final int hour24 = _dispatchTime!.hour;
      final int minute = _dispatchTime!.minute;
      final String disTimeFormatted =
          '${_formatDate(_transportDate!)} ${hour24.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';

      final Map<String, String> bodyFields = {
        'type': '5015',
        'cid': cid,
        'device_id': deviceId,
        'uid': uid,
        'role_id': roleId,
        'token': token,
        'engineer_id': engineerId.isEmpty ? uid : engineerId,
        'lt': '145',
        'ln': '145',
        'inv_id': cleanParcelId,
        'cus_id': cusIdPref.isNotEmpty ? cusIdPref : _apiCusId,
        'mobile_no': cleanPhone,
        'contact_person_name': _nameCtrl.text.trim(),
        'contact_person_mobile': cleanPhone,
        'date_of_tran': _formatDate(_transportDate!),
        'exp_delivery': _formatDate(_expectedDate!),
        'place': _placeCtrl.text.trim(),
        'deli_addrs': _apiAddress,
        'tran_mode': _mode ?? '',
        'dis_time': disTimeFormatted,
        'notes': _notesCtrl.text.trim(),
      };

      final dio = dio_pkg.Dio(
        dio_pkg.BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final formData = dio_pkg.FormData();
      bodyFields.forEach((k, v) {
        formData.fields.add(MapEntry(k, v));
      });

      if (_image != null && await _image!.exists()) {
        formData.files.add(
          MapEntry(
            'image',
            await dio_pkg.MultipartFile.fromFile(
              _image!.path,
              filename: 'dispatch_proof.jpg',
            ),
          ),
        );
      }

      final response = await dio.post(
        await ApiConfig.getBaseUrl(),
        data: formData,
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Close loader

      dynamic res = response.data;
      if (res is String) res = jsonDecode(res);

      if (res != null &&
          (res['error'] == false ||
              res['error'] == 0 ||
              res['error'].toString() == '0')) {
        // Save to local history
        final appData = AppData.instance;
        String modeLabel = _mode ?? '';
        try {
          final found = _transportModes.firstWhere(
            (e) => e['value']?.toString() == _mode,
            orElse: () => <String, dynamic>{},
          );
          if (found.containsKey('label')) {
            modeLabel = found['label'].toString();
          }
        } catch (_) {}

        appData.confirmDispatch(
          DispatchmentRecord(
            dispatchId: appData.nextDispatchId(),
            parcelNo: _selectedParcelId ?? '',
            transferMode: modeLabel,
            transportDate: _formatDate(_transportDate!),
            expectedDelivery: _formatDate(_expectedDate!),
            dispatchTime: disTimeFormatted,
            contactName: _nameCtrl.text.trim(),
            phone: '+91 ${_phoneCtrl.text.trim()}',
            address: _placeCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty
                ? 'No special instructions'
                : _notesCtrl.text.trim(),
            status: 'Dispatched',
            attachmentPath: _imagePath,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dispatch Confirmed Successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DispatchmentHistoryScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res?['error_msg'] ?? 'Failed to confirm dispatch'),
          ),
        );
      }
    } catch (e) {
      debugPrint('DEBUG: 5015 Exception: $e');
      if (!mounted) return;
      try {
        Navigator.of(context, rootNavigator: true).pop();
      } catch (_) {}
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ====================== UI Decorations ======================
  InputDecoration _decoration({
    required String hint,
    bool invalid = false,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    final color = _border(invalid);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 12.5.sp, color: const Color(0xFFA3A8B7)),
      prefixText: prefixText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF3F5F9),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: BorderSide(color: color),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: BorderSide(color: color),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6.r),
        borderSide: BorderSide(
          color: invalid && _submitted
              ? const Color(0xFFD92D20)
              : AppColors.primary,
          width: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parcelErr = _submitted && _selectedParcelId == null;
    final modeErr = _submitted && _mode == null;
    final dateErr = _submitted && _transportDate == null;
    final expErr = _submitted && _expectedDate == null;
    final timeErr = _submitted && _dispatchTime == null;
    final nameErr = _submitted && _nameCtrl.text.trim().isEmpty;
    final phoneErr = _submitted && !_phoneValid;
    final placeErr = _submitted && _placeCtrl.text.trim().isEmpty;
    final imageErr = _submitted && _image == null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 22.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Dispatch',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),
                _miniLabel('Parcel No'),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: _border(parcelErr)),
                  ),
                  child: TextField(
                    controller: _parcelCtrl,
                    focusNode: _parcelFocus,
                    onChanged: _onSearchChanged,
                    decoration: _decoration(
                      hint: 'Search Parcel No',
                      invalid: parcelErr,
                      suffixIcon: _isLoadingParcels
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.search_rounded,
                                size: 20.sp,
                                color: AppColors.primary,
                              ),
                              onPressed: () => _fetchParcels(_parcelCtrl.text),
                            ),
                    ),
                    style: TextStyle(fontSize: 13.sp),
                  ),
                ),
                if (_parcelFocus.hasFocus && _parcels.isNotEmpty) ...[
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    constraints: BoxConstraints(maxHeight: 200.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE4E8F1)),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _parcels.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFF1F4F9)),
                      itemBuilder: (context, index) {
                        final p = _parcels[index];
                        return ListTile(
                          title: Text(p, style: TextStyle(fontSize: 13.sp)),
                          onTap: () {
                            _parcelCtrl.text = p;
                            setState(() {
                              _selectedParcelId = p;
                              _parcels = [];
                            });
                            _parcelFocus.unfocus();
                            _fetchParcelDetails(p);
                          },
                        );
                      },
                    ),
                  ),
                ],

                SizedBox(height: 20.h),
                // Customer Details Section (unchanged)
                Row(
                  children: [
                    Text(
                      'Customer Detail',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => setState(() => _showDetails = !_showDetails),
                      child: Icon(
                        _showDetails
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFE4E8F1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _miniLabel('Customer Name'),
                        SizedBox(height: 6.h),
                        _valueBox(
                          _apiName.isEmpty ? 'Select a parcel' : _apiName,
                        ),
                        SizedBox(height: 12.h),
                        _miniLabel('Phone'),
                        SizedBox(height: 6.h),
                        _valueBox(_apiPhone.isEmpty ? 'N/A' : '+91 $_apiPhone'),
                        SizedBox(height: 12.h),
                        _miniLabel('Address'),
                        SizedBox(height: 6.h),
                        _valueBox(_apiAddress.isEmpty ? 'N/A' : _apiAddress),
                      ],
                    ),
                  ),
                  crossFadeState: _showDetails
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 220),
                ),

                // Rest of the UI remains exactly the same...
                SizedBox(height: 18.h),
                Text(
                  'Mode Of Transfer',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F9),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: _border(modeErr)),
                  ),
                  child: _isLoadingModes
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14.r,
                                height: 14.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'Loading modes...',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:
                                _transportModes.any(
                                  (e) => e['value'].toString() == _mode,
                                )
                                ? _mode
                                : null,
                            isExpanded: true,
                            hint: Text(
                              _transportModes.isEmpty && !_isLoadingModes
                                  ? 'No modes available'
                                  : 'Select Mode',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            items: _transportModes.map((e) {
                              return DropdownMenuItem(
                                value: e['value'].toString(),
                                child: Text(
                                  e['label'].toString(),
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _mode = v),
                          ),
                        ),
                ),

                SizedBox(height: 18.h),
                Text(
                  'Transport Schedule',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _miniLabel('Date of Transport'),
                          SizedBox(height: 6.h),
                          _dateBox(
                            hint: 'Select Date',
                            value: _transportDate,
                            invalid: dateErr,
                            onTap: () => _pickDate(expected: false),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _miniLabel('Expected Delivery'),
                          SizedBox(height: 6.h),
                          _dateBox(
                            hint: 'Select Date',
                            value: _expectedDate,
                            invalid: expErr,
                            onTap: () => _pickDate(expected: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _miniLabel('Dispatch Time'),
                SizedBox(height: 6.h),
                _timeBox(invalid: timeErr),

                SizedBox(height: 18.h),
                Text(
                  'Contact Person',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                _miniLabel('Full Name'),
                SizedBox(height: 6.h),
                TextField(
                  controller: _nameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: _decoration(
                    hint: 'Enter full name',
                    invalid: nameErr,
                  ),
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 12.h),
                _miniLabel('Phone'),
                SizedBox(height: 6.h),
                TextField(
                  controller: _phoneCtrl,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _decoration(
                    hint: 'Enter phone number',
                    prefixText: '+91  ',
                    invalid: phoneErr,
                  ),
                  style: TextStyle(fontSize: 13.sp),
                ),
                SizedBox(height: 12.h),
                _miniLabel('Place'),
                SizedBox(height: 6.h),
                TextField(
                  controller: _placeCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: _decoration(
                    hint: 'Enter place',
                    invalid: placeErr,
                  ),
                  style: TextStyle(fontSize: 13.sp),
                ),

                SizedBox(height: 18.h),
                Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                _miniLabel('Upload Image'),
                SizedBox(height: 6.h),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 118.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: _border(imageErr)),
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_upload_outlined,
                                size: 26.sp,
                                color: const Color(0xFF67758E),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Click to Image',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF8B95A8),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'JPG, PNG or PDF (Max 5MB)',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: const Color(0xFFA6AFC0),
                                ),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              margin: EdgeInsets.all(10.r),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'Image selected',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 12.h),
                _miniLabel('Dispatch Notes'),
                SizedBox(height: 6.h),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: _decoration(hint: 'Optional'),
                  style: TextStyle(fontSize: 13.sp),
                ),

                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 42.h,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text(
                      'Confirm Dispatch',
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
        ),
      ),
    );
  }

  Widget _miniLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12.5.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    ),
  );

  Widget _valueBox(String text, {bool invalid = false}) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F5F9),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: _border(invalid)),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.5.sp,
        color: const Color(0xFF445B87),
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  Widget _dateBox({
    required String hint,
    required DateTime? value,
    required bool invalid,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: _border(invalid)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value == null ? hint : _formatDate(value),
              style: TextStyle(
                fontSize: 12.5.sp,
                color: value == null
                    ? const Color(0xFFA3A8B7)
                    : const Color(0xFF445B87),
              ),
            ),
          ),
          Image.asset(
            'assets/calendar_icon.png',
            width: 18.w,
            height: 18.w,
            fit: BoxFit.contain,
          ),
        ],
      ),
    ),
  );

  Widget _timeBox({required bool invalid}) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F5F9),
      borderRadius: BorderRadius.circular(6.r),
      border: Border.all(color: _border(invalid)),
    ),
    child: Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickTime,
            child: Text(
              _dispatchTime == null
                  ? 'Select Dispatch Time'
                  : _buildDisTime(_dispatchTime!),
              style: TextStyle(
                fontSize: 12.5.sp,
                color: _dispatchTime == null
                    ? const Color(0xFFA3A8B7)
                    : const Color(0xFF445B87),
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFDDE3EF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _period,
              isDense: true,
              items: const [
                DropdownMenuItem(value: 'AM', child: Text('AM')),
                DropdownMenuItem(value: 'PM', child: Text('PM')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _period = v);
              },
            ),
          ),
        ),
      ],
    ),
  );
}