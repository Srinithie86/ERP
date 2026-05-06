import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Models/permission_api.dart';
import '../../../Utils/shared_prefs_util.dart';

class AdminPermissionStatusScreen extends StatefulWidget {
  const AdminPermissionStatusScreen({super.key});

  @override
  State<AdminPermissionStatusScreen> createState() => _AdminPermissionStatusScreenState();
}

class _AdminPermissionStatusScreenState extends State<AdminPermissionStatusScreen> {
  bool _isLoading = true;
  List<PermissionRequestData> _permissionData = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final params = await SharedPrefsUtil.getCommonParams();
      final String reportingManager = params['uid'] ?? "";
      final response = await PermissionApi.fetchPermissionRequests(reportingManager: reportingManager);
      setState(() {
        _permissionData = response.data;
        _isLoading = false;
      });
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
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : _error != null
              ? Center(child: Text(_error!, style: GoogleFonts.poppins(color: Colors.red)))
              : _permissionData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64.sp, color: Colors.grey[400]),
                          SizedBox(height: 16.h),
                          Text("No permission history found",
                              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16.sp)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildSummaryHeader(),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: _permissionData.length,
                            itemBuilder: (context, index) => _buildStatusCard(_permissionData[index]),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSummaryHeader() {
    int approved = _permissionData.where((p) => (p.status ?? "").toLowerCase() == 'approved').length;
    int rejected = _permissionData.where((p) => (p.status ?? "").toLowerCase() == 'rejected').length;
    int pending = _permissionData.where((p) => (p.status ?? "").toLowerCase() == 'pending').length;

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
          _summaryItem("Pending", "$pending", Colors.orange),
          _summaryItem("Approved", "$approved", Colors.green),
          _summaryItem("Rejected", "$rejected", Colors.red),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
          _infoRow(Icons.calendar_today, "Apply Date", permission.appDate ?? "N/A"),
          SizedBox(height: 8.h),
          _infoRow(Icons.access_time, "Time", "${permission.startTime ?? "N/A"} - ${permission.endDate ?? "N/A"}"),
          SizedBox(height: 8.h),
          _infoRow(Icons.notes, "Reason", permission.reason ?? "No reason provided"),
          if (permission.appBy != null) ...[
            SizedBox(height: 8.h),
            _infoRow(Icons.person_outline, "Processed By", permission.appBy!, isBold: true),
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

  Widget _infoRow(IconData icon, String label, String text, {bool isBold = false, Color? color}) {
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
