import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Models/attendance_api.dart';
import 'office_attendance_detail.dart';

class OfficeAttendanceScreen extends StatefulWidget {
  const OfficeAttendanceScreen({super.key});

  @override
  State<OfficeAttendanceScreen> createState() => _OfficeAttendanceScreenState();
}

class _OfficeAttendanceScreenState extends State<OfficeAttendanceScreen> {
  late Future<AttendanceResponse> _attendanceFuture;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  void _fetchAttendance() {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    _attendanceFuture = AttendanceApi.fetchInOfficeAttendance(date: formattedDate);
  }

  void _refresh() {
    setState(() {
      _fetchAttendance();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF26A69A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fetchAttendance();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          "In-Office Attendance",
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            onPressed: () => _selectDate(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            color: const Color(0xFF26A69A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Date Filter",
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: GoogleFonts.outfit(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 18),
                  label: Text(
                    "Change",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<AttendanceResponse>(
              future: _attendanceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                        SizedBox(height: 16.h),
                        Text("Error: ${snapshot.error}"),
                        ElevatedButton(onPressed: _refresh, child: const Text("Retry")),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy_rounded, size: 64.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(height: 16.h),
                        Text(
                          "No records found for ${DateFormat('dd MMM').format(_selectedDate)}",
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter out records where employee name or code is missing
                final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
                final records = snapshot.data!.data.where((r) => 
                  r.date == formattedDate && ((r.employeeName?.isNotEmpty ?? false) || (r.employeeCode?.isNotEmpty ?? false))
                ).toList();

                if (records.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_rounded, size: 64.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(height: 16.h),
                        Text(
                          "No valid records found for this date",
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => OfficeAttendanceDetailScreen(record: record)),
                      ),
                      child: _buildOfficeAttendanceCard(record),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeAttendanceCard(AttendanceData record) {
    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF26A69A).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OfficeAttendanceDetailScreen(record: record)),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 52.h,
                        width: 52.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF26A69A).withOpacity(0.1), const Color(0xFF26A69A).withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: const Color(0xFF26A69A).withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text(
                            record.employeeName?.isNotEmpty == true ? record.employeeName![0].toUpperCase() : "?", 
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF26A69A), 
                              fontWeight: FontWeight.w800,
                              fontSize: 18.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.employeeName?.isNotEmpty == true ? record.employeeName! : "Unknown Employee", 
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp, 
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                "EMP ID: ${record.employeeCode ?? 'N/A'}", 
                                style: GoogleFonts.outfit(
                                  fontSize: 10.sp, 
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            record.date ?? "N/A", 
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp, 
                              color: const Color(0xFF3B82F6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            height: 6.h,
                            width: 24.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF26A69A).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _miniTimeColumn("IN TIME", record.inTime ?? "--:--", const Color(0xFF10B981)),
                        Container(height: 20.h, width: 1, color: const Color(0xFFE2E8F0)),
                        _miniTimeColumn("OUT TIME", record.outTime ?? "--:--", const Color(0xFFF59E0B)),
                        Container(height: 20.h, width: 1, color: const Color(0xFFE2E8F0)),
                        _miniTimeColumn("TOT HRS", record.totalHours ?? "0", const Color(0xFF3B82F6)),
                      ],
                    ),
                  ),
                  if (record.remarks?.isNotEmpty == true) ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(Icons.notes_rounded, size: 14.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            record.remarks!,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniTimeColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label, 
          style: GoogleFonts.poppins(
            fontSize: 8.sp, 
            fontWeight: FontWeight.w600, 
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value, 
          style: GoogleFonts.outfit(
            fontSize: 15.sp, 
            fontWeight: FontWeight.w700, 
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
