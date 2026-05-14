import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../../Utils/shared_prefs_util.dart';

class AdminLeaveStatusScreen extends StatefulWidget {
  const AdminLeaveStatusScreen({super.key});

  @override
  State<AdminLeaveStatusScreen> createState() => _AdminLeaveStatusScreenState();
}

class _AdminLeaveStatusScreenState extends State<AdminLeaveStatusScreen> {
  bool _isLoading = true;
  List<dynamic> _allLeaveData = [];
  List<dynamic> _filteredLeaveData = [];
  String? _error;
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = "all";

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
        _applyFilter();
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
      final String cid = params['cid'] ?? "99994444";
      final String uid = params['uid'] ?? "";
      final String deviceId = params['device_id'] ?? "1237";
      final String lat = params['lt'] ?? "123";
      final String lng = params['ln'] ?? "123";

      final response = await http.post(
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
        body: {
          "type": "2083",
          "cid": cid,
          "uid": uid,
          "device_id": deviceId,
          "lt": lat,
          "ln": lng,
          "form": "sm_main_form_16112",
          "select": "*",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          setState(() {
            _allLeaveData = data['data'] ?? [];
            _applyFilter();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? "Failed to fetch data";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = "Server error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    List<dynamic> tempList = [];
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // Filter by Date
    tempList = _allLeaveData.where((l) {
      final appliedDate = l['applied_date']?.toString() ?? "";
      return appliedDate == formattedDate;
    }).toList();

    // Then apply Status Filter
    if (_selectedStatus != "all") {
      tempList = tempList
          .where(
              (l) => l['status']?.toString().toLowerCase() == _selectedStatus)
          .toList();
    }

    setState(() {
      _filteredLeaveData = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text(
          "Leave Status History",
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
                    _buildFilterBadge(),
                    Expanded(
                      child: _filteredLeaveData.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy,
                                      size: 64.sp, color: Colors.grey[400]),
                                  SizedBox(height: 16.h),
                                  Text(
                                      _selectedStatus != "all"
                                          ? "No ${_selectedStatus.toUpperCase()} requests found"
                                          : "No leave requests for this date",
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey, fontSize: 16.sp)),
                                  if (_selectedStatus != "all" ||
                                      DateFormat('yyyy-MM-dd')
                                              .format(_selectedDate) !=
                                          DateFormat('yyyy-MM-dd')
                                              .format(DateTime.now()))
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedDate = DateTime.now();
                                          _selectedStatus = "all";
                                          _applyFilter();
                                        });
                                      },
                                      child: const Text("Reset Filters"),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredLeaveData.length,
                              itemBuilder: (context, index) =>
                                  _buildStatusCard(_filteredLeaveData[index]),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterBadge() {
    String dateStr = DateFormat('dd MMMM yyyy').format(_selectedDate);
    bool isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              border:
                  Border.all(color: const Color(0xFF26A69A).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isToday ? Icons.today : Icons.calendar_month,
                    size: 14.sp, color: const Color(0xFF26A69A)),
                SizedBox(width: 6.w),
                Text(
                  isToday ? "Today's Leaves" : dateStr,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF26A69A),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedStatus != "all") ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStatus = "all";
                  _applyFilter();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedStatus.toUpperCase(),
                      style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700]),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.close, size: 12.sp, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            "Count: ${_filteredLeaveData.length}",
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final baseList = _allLeaveData
        .where((l) => l['applied_date']?.toString() == formattedDate)
        .toList();

    int approved = baseList
        .where((l) => l['status']?.toString().toLowerCase() == 'approved')
        .length;
    int rejected = baseList
        .where((l) => l['status']?.toString().toLowerCase() == 'rejected')
        .length;
    int pending = baseList
        .where((l) => l['status']?.toString().toLowerCase() == 'pending')
        .length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _summaryItem("Pending", "$pending", Colors.orange, "pending"),
          _summaryItem("Approved", "$approved", Colors.green, "approved"),
          _summaryItem("Rejected", "$rejected", Colors.red, "rejected"),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = "all";
                _applyFilter();
              });
            },
            child: Column(
              children: [
                Icon(Icons.clear_all,
                    color: _selectedStatus == "all"
                        ? Colors.blueGrey
                        : Colors.grey.shade300),
                Text("Clear",
                    style: GoogleFonts.poppins(
                        fontSize: 11.sp, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
      String label, String value, Color color, String statusKey) {
    bool isSelected = _selectedStatus == statusKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = isSelected ? "all" : statusKey;
          _applyFilter();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
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
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(dynamic leave) {
    final String status =
        (leave['status']?.toString() ?? "Pending").toLowerCase();
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
                      leave['employee_name']?.toString() ?? "Unknown",
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      leave['leave_type']?.toString() ?? "Leave",
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
          _infoRow(Icons.event_note, "Duration",
              "${leave['leave_start_date'] ?? "N/A"} to ${leave['leave_end_date'] ?? "N/A"}"),
          SizedBox(height: 8.h),
          _infoRow(Icons.calendar_today_outlined, "Total Days",
              "${leave['total_days'] ?? "0"} Day(s)"),
          SizedBox(height: 8.h),
          _infoRow(Icons.notes, "Reason",
              leave['reason']?.toString() ?? "No reason provided"),
          if (status == 'rejected' && leave['reject_reason'] != null) ...[
            SizedBox(height: 8.h),
            _infoRow(Icons.warning_amber_rounded, "Reject Reason",
                leave['reject_reason']?.toString() ?? "",
                color: Colors.red),
          ],
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Applied on: ${leave['applied_date'] ?? leave['dtime'] ?? 'N/A'}",
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
