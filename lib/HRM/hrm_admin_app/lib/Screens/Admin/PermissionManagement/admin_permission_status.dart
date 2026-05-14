import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Models/permission_api.dart';
import '../../../Utils/shared_prefs_util.dart';

class AdminPermissionStatusScreen extends StatefulWidget {
  const AdminPermissionStatusScreen({super.key});

  @override
  State<AdminPermissionStatusScreen> createState() =>
      _AdminPermissionStatusScreenState();
}

class _AdminPermissionStatusScreenState
    extends State<AdminPermissionStatusScreen> {
  bool _isLoading = true;
  List<PermissionRequestData> _permissionData = [];
  String? _error;
  DateTime _selectedDate = DateTime.now();
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF26A69A),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final params = await SharedPrefsUtil.getCommonParams();

      final Map<String, String> body = {
        'type': '2083',
        'cid': '99994444',
        'lt': '123',
        'ln': '123',
        'device_id': '1237',
        'form': 'sm_main_form_16143',
        'select': '*',
        'token': params['token'] ?? "",
        'uid': params['uid'] ?? "",
      };

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: body,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final permResponse = PermissionRequestResponse.fromJson(decodedData);
        setState(() {
          _permissionData = permResponse.data;
          _isLoading = false;
        });
      } else {
        throw Exception(
            "Failed to load permission history: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text(
          "Permission Status History",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: GoogleFonts.poppins(color: Colors.red)))
              : Column(
                  children: [
                    _buildSummaryHeader(),
                    _buildDateDisplay(),
                    Expanded(
                      child: _buildFilteredList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDateDisplay() {
    String dateStr = DateFormat('dd MMMM yyyy').format(_selectedDate);
    bool isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isToday ? "Today's Permissions" : "Permissions for $dateStr",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[700],
            ),
          ),
          if (_statusFilter != 'All')
            GestureDetector(
              onTap: () => setState(() => _statusFilter = 'All'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Text(
                      _statusFilter,
                      style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: const Color(0xFF26A69A),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.close,
                        size: 12.sp, color: const Color(0xFF26A69A)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilteredList() {
    String formattedSelectedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate);

    final filtered = _permissionData.where((p) {
      // Filter by Date
      bool dateMatch = (p.appDate == formattedSelectedDate);

      // Filter by Status
      bool statusMatch = true;
      if (_statusFilter != 'All') {
        String s = (p.status ?? "").toLowerCase();
        if (_statusFilter == 'Pending') {
          statusMatch = (s == 'pending' || s == '0' || s == '');
        } else {
          statusMatch = (s == _statusFilter.toLowerCase());
        }
      }

      return dateMatch && statusMatch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text("No data found for this selection",
                style:
                    GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp)),
            if (_statusFilter != 'All' ||
                !DateFormat('yyyy-MM-dd')
                    .format(_selectedDate)
                    .contains(DateFormat('yyyy-MM-dd').format(DateTime.now())))
              TextButton(
                onPressed: () => setState(() {
                  _selectedDate = DateTime.now();
                  _statusFilter = 'All';
                }),
                child: Text("Reset Filters",
                    style: TextStyle(color: Color(0xFF26A69A))),
              )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildStatusCard(filtered[index]),
    );
  }

  Widget _buildSummaryHeader() {
    String formattedSelectedDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate);
    final dateData = _permissionData
        .where((p) => p.appDate == formattedSelectedDate)
        .toList();

    int approved = dateData
        .where((p) => (p.status ?? "").toLowerCase() == 'approved')
        .length;
    int rejected = dateData
        .where((p) => (p.status ?? "").toLowerCase() == 'rejected')
        .length;
    int pending = dateData.where((p) {
      String s = (p.status ?? "").toLowerCase();
      return s == 'pending' || s == '0' || s == '';
    }).length;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem(
              "Pending", "$pending", Colors.orange, _statusFilter == 'Pending'),
          _summaryItem("Approved", "$approved", Colors.green,
              _statusFilter == 'Approved'),
          _summaryItem(
              "Rejected", "$rejected", Colors.red, _statusFilter == 'Rejected'),
        ],
      ),
    );
  }

  Widget _summaryItem(
      String label, String value, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _statusFilter = isSelected ? 'All' : label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(PermissionRequestData permission) {
    final String status = (permission.status ?? "Pending").toLowerCase();
    final Color statusColor = status == 'approved'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.1),
                child: Icon(
                  status == 'approved'
                      ? Icons.check_circle_outline
                      : status == 'rejected'
                          ? Icons.cancel_outlined
                          : Icons.hourglass_empty_rounded,
                  color: statusColor,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.employeeName,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      permission.permissionType ?? "General Permission",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow(
              Icons.calendar_today, "Apply Date", permission.appDate ?? "N/A"),
          SizedBox(height: 8.h),
          _infoRow(Icons.access_time, "Time",
              "${permission.startTime ?? "N/A"} - ${permission.endDate ?? "N/A"}"),
          SizedBox(height: 8.h),
          _infoRow(
              Icons.notes, "Reason", permission.reason ?? "No reason provided"),
          if (permission.appBy != null) ...[
            SizedBox(height: 8.h),
            _infoRow(Icons.person_outline, "Processed By", permission.appBy!,
                isBold: true),
          ],
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Processed on: ${permission.approvalDate ?? "Pending"}",
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String text,
      {bool isBold = false, Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: color ?? Colors.blueGrey[400]),
        SizedBox(width: 8.w),
        Text(
          "$label: ",
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
