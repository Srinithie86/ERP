import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:service_ticket/services/api_service.dart';
import '../../services/device_service.dart';
import '../../services/storage_service.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../core/app_colors.dart';

class ToolkitScreen extends StatefulWidget {
  const ToolkitScreen({super.key});

  @override
  State<ToolkitScreen> createState() => _ToolkitScreenState();
}

class _ToolkitScreenState extends State<ToolkitScreen> {
  List<Map<String, dynamic>> _toolkitRecords = [];
  String _verifiedDate = 'N/A';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchToolkit();
  }

  Future<void> _fetchToolkit() async {
    try {
      final cid = await StorageService.getCid() ?? '';
      final uid = await StorageService.getUid() ?? '';
      final roleId = await StorageService.getRoleId() ?? '';
      final engineerId = await StorageService.getEngineerId() ?? '';
      final token = await StorageService.getToken() ?? '';
      final deviceId = await DeviceService.getDeviceId();

      const ln = '22';
      const lt = '22';

      final body = {
        "type": "5024",
        "cid": cid,
        "uid": uid,
        "ln": ln,
        "lt": lt,
        "assigned_to": engineerId,
        "device_id": deviceId,
        "role_id": roleId,
        "token": token,
      };

      final response = await http.post(
        Uri.parse(await ApiService.getBaseUrl()),
        body: body,
      );

      print("TOOLKIT 5024 REQUEST BODY: $body");
      print("TOOLKIT 5024 RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['error'] == false) {
          final List<dynamic> records = data['records'] ?? [];
          setState(() {
            _toolkitRecords = records
                .map((r) => Map<String, dynamic>.from(r))
                .toList();
            _verifiedDate = data['last_checked_date']?.toString() ?? 'N/A';
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("TOOLKIT FETCH ERROR: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color headerBg = AppColors.primary;
    const Color borderColor = AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppStatusBarWrapper(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.r),
                        child: Icon(
                          Icons.arrow_back,
                          size: 22.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'My Toolkit',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // table
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _toolkitRecords.isEmpty
                    ? Center(
                        child: Text(
                          'No tools found',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 1.5),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                decoration: BoxDecoration(
                                  color: headerBg,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4.5.r),
                                    topRight: Radius.circular(4.5.r),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _HeaderCell(text: 'S.No', flex: 1),
                                    _HeaderCell(text: 'Name', flex: 3),
                                    _HeaderCell(text: 'Tool Code', flex: 3),
                                    _HeaderCell(text: 'Qt', flex: 2),
                                  ],
                                ),
                              ),

                              // Table Rows
                              ..._toolkitRecords.asMap().entries.map((entry) {
                                final index = entry.key;
                                final tool = entry.value;
                                final isLast =
                                    index == _toolkitRecords.length - 1;
                                return Container(
                                  decoration: BoxDecoration(
                                    border: isLast
                                        ? null
                                        : Border(
                                            bottom: BorderSide(
                                              color: borderColor.withOpacity(
                                                0.3,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                  ),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _DataCell(
                                          text: '${index + 1}',
                                          flex: 1,
                                          isBold: false,
                                          borderColor: borderColor,
                                        ),
                                        _DataCell(
                                          text: '${tool['tool_name'] ?? 'N/A'}',
                                          flex: 3,
                                          isBold: false,
                                          borderColor: borderColor,
                                        ),
                                        _DataCell(
                                          text: '${tool['tool_code'] ?? 'N/A'}',
                                          flex: 3,
                                          isBold: true,
                                          textColor: AppColors.primary,
                                          borderColor: borderColor,
                                        ),
                                        _DataCell(
                                          text: '${tool['quantity'] ?? '0'}',
                                          flex: 2,
                                          isBold: true,
                                          borderColor: borderColor,
                                          showBorder: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              // Verified Date Footer
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                  horizontal: 16.w,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(4.5.r),
                                    bottomRight: Radius.circular(4.5.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/verified_icon.png',
                                      package: 'service_ticket',
                                      width: 18.w,
                                      height: 18.w,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Verified Date : $_verifiedDate',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Header Cell
class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.text, required this.flex});

  final String text;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Data Cell
class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.text,
    required this.flex,
    required this.borderColor,
    this.isBold = false,
    this.textColor,
    this.showBorder = true,
  });

  final String text;
  final int flex;
  final bool isBold;
  final Color? textColor;
  final Color borderColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
        decoration: showBorder
            ? BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: borderColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              )
            : null,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: textColor ?? Colors.black87,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}
