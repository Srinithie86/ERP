import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Widgets/app_status_bar_wrapper.dart';
import '../../core/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class SparePartsTab extends StatefulWidget {
  const SparePartsTab({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<SparePartsTab> createState() => _SparePartsTabState();
}

class _SparePartsTabState extends State<SparePartsTab> {
  List<Map<String, dynamic>> _spareList = [];
  List<Map<String, dynamic>> _usedList = [];
  bool _loadingSpares = false;
  String? _errorSpares;

  @override
  void initState() {
    super.initState();
    _fetchSpares();
  }

  Future<void> _fetchSpares() async {
    setState(() {
      _loadingSpares = true;
      _errorSpares = null;
    });

    try {
      final cid = await StorageService.getCid() ?? "";
      final uid = await StorageService.getUid() ?? "";
      final roleId = await StorageService.getRoleId() ?? "";
      final token = await StorageService.getToken() ?? "";
      final cusId = await StorageService.getCusId() ?? "";

      final detailedRes = await ApiService.getSparesHistory(
        cid: cid,
        uid: uid,
        roleId: roleId,
        token: token,
        engineerId: cusId,
      );

      final resData = await ApiService.getSparesData(
        cid: cid,
        uid: uid,
        roleId: roleId,
        token: token,
        engineerId: cusId,
        lat: "22",
        lon: "22",
      );

      List<Map<String, dynamic>> myParts = [];
      if (detailedRes is Map && detailedRes['error'] == false) {
        final rawData = detailedRes['data'];
        if (rawData is List) {
          myParts = rawData.where((e) => e is Map).map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'spare_name': m['spare_name']?.toString() ?? 'N/A',
              'spare_code': m['id']?.toString() ?? 'N/A',
              'qty': m['qty']?.toString() ?? '0',
              'date': _extractDate(m['dtime'] ?? m['date']),
            };
          }).toList();
        }
      } else if (resData is Map && resData['error'] == false) {
        final rawSpares = resData['spares'];
        if (rawSpares is List) {
          myParts = rawSpares.where((e) => e is Map).map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'spare_name': m['product_name']?.toString() ?? 'N/A',
              'spare_code': m['spare_id']?.toString() ?? 'N/A',
              'qty': m['stock_qty']?.toString() ?? '0',
              'date': _extractDate(m['dtime']),
            };
          }).toList();
        }
      }

      // Parse 'used' list from 5023
      List<Map<String, dynamic>> usedHistory = [];
      if (resData is Map && resData['error'] == false) {
        final rawUsed = resData['used'];
        if (rawUsed is List) {
          usedHistory = rawUsed.where((e) => e is Map).map((e) {
            final m = Map<String, dynamic>.from(e);
            return {
              'spare_name': m['product_name']?.toString() ?? 'N/A',
              'used_by': (m['customer_name']?.toString().isNotEmpty == true)
                  ? m['customer_name']
                  : 'N/A',
              'used_date': _extractDate(m['dtime']),
              'used_qty': m['used_qty']?.toString() ?? '0',
            };
          }).toList();
        }
      }

      if (mounted) {
        setState(() {
          _spareList = myParts;
          _usedList = usedHistory;
          _loadingSpares = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch Spares Error: $e');
      setState(() {
        _errorSpares = 'Network error. Please try again.';
        _loadingSpares = false;
      });
    }
  }

  String _extractDate(dynamic dtime) {
    if (dtime == null || dtime.toString().isEmpty) return 'N/A';
    try {
      String dt = dtime.toString();
      if (dt.contains(' ')) {
        return dt.split(' ')[0]; // Return only the date part
      }
      return dt;
    } catch (_) {
      return 'N/A';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myParts = _spareList;
    final usedParts = _usedList;

    return AppStatusBarWrapper(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () async {
              await _fetchSpares();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (unchanged)
                  Row(
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
                        'Spares',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  // Summary Boxes (unchanged)
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryBox(
                          count: '${myParts.length}',
                          label: 'My Parts',
                          colors: const [Color(0xFF42D74D), Color(0xFF1D8E39)],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _SummaryBox(
                          count: '${usedParts.length}',
                          label: 'Used Parts',
                          colors: const [Color(0xFFF4A33C), Color(0xFFAC6A28)],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // My Parts Section (unchanged)
                  SizedBox(height: 30.h),
                  Text(
                    'My Parts',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (_loadingSpares)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorSpares != null)
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _errorSpares!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed: _fetchSpares,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (myParts.isEmpty)
                    const Center(child: Text('No spare parts found'))
                  else
                    ...myParts.map(
                      (part) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _MyPartCard(part: part),
                      ),
                    ),

                  // Used Parts Section
                  SizedBox(height: 30.h),
                  Text(
                    'Used Parts',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (usedParts.isEmpty)
                    const Center(child: Text('No used parts found'))
                  else
                    ...usedParts.map(
                      (part) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _UsedPartCard(part: part),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.count,
    required this.label,
    required this.colors,
  });

  final String count;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.24),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPartCard extends StatelessWidget {
  const _MyPartCard({required this.part});

  final Map<String, dynamic> part;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD38BFF)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF8854D0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
              ),
            ),
            child: Row(
              children: [
                const _CircleIcon(
                  icon: Icons.build_rounded,
                  color: Color(0xFF4B197E),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part['spare_name'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Code: ${(part['spare_code']?.toString().trim().isEmpty ?? true) ? 'N/A' : part['spare_code']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFFFF1F1),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/quantity_icon.png',
                        width: 18.w,
                        height: 18.h,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'Quantity: ${part['qty']?.toString().isEmpty ?? true ? 'N/A' : part['qty']}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: Colors.grey.shade400,
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/calendar_icon.png',
                        width: 18.w,
                        height: 18.h,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          'Received: ${part['date']?.toString().trim().isEmpty ?? true ? 'N/A' : part['date']}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
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

class _UsedPartCard extends StatelessWidget {
  const _UsedPartCard({required this.part});

  final Map<String, dynamic> part;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFF5D5FEF).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Header (Blue)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFF3889D5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
              ),
            ),
            child: Row(
              children: [
                const _CircleIcon(
                  icon: Icons.build_rounded,
                  color: Color(0xFF0F3A63),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part['spare_name'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
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
          Container(
            color: const Color(0xFFFFF1F1),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 20.sp,
                        color: const Color(0xFF515E72),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          part['used_by'] ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF445B87),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month,
                        size: 20.sp,
                        color: const Color(0xFFE54D4D),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Used Date: ${part['used_date'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF445B87),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Color(0xFFF0D0D0),
                  indent: 10,
                  endIndent: 10,
                ),

                // Row 3: Used Quantity
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 20.sp,
                        color: const Color(0xFFD47C34),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Used Quantity: ${part['used_qty'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF445B87),
                          ),
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

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(icon, size: 17.sp, color: color),
    );
  }
}
