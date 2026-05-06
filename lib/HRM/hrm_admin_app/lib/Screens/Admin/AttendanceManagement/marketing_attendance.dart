import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../Models/marketing_api.dart';

class MarketingAttendanceScreen extends StatefulWidget {
  const MarketingAttendanceScreen({super.key});

  @override
  State<MarketingAttendanceScreen> createState() => _MarketingAttendanceScreenState();
}

class _MarketingAttendanceScreenState extends State<MarketingAttendanceScreen> {
  List<MarketingAttendanceData>? _attendanceList;
  bool _isLoading = true;
  String _error = "";
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = "";
    });
    try {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await MarketingApi.fetchMarketingAttendance(date: formattedDate);
      setState(() {
        _attendanceList = response.data;
        // Sort by ID descending (latest first)
        _attendanceList?.sort((a, b) => b.id.compareTo(a.id));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
        _fetchData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Marketing Attendance",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
          IconButton(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : _error.isNotEmpty
              ? _buildErrorWidget()
              : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            "Something went wrong",
            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _fetchData,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
            child: const Text("Retry", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final filteredList = _attendanceList?.where((e) => e.date == formattedDate).toList();

    if (filteredList == null || filteredList.isEmpty) {
      return Column(
        children: [
          _buildFilterBanner(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_pin_circle_outlined, size: 80.sp, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text(
                    "No records found for ${DateFormat('dd MMM').format(_selectedDate)}",
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _fetchData,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                    child: const Text("Refresh", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildFilterBanner(),
        _buildSummaryHeader(filteredList),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchData,
            color: const Color(0xFF26A69A),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return _buildAttendanceCard(filteredList[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBanner() {
    return Container(
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
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(_selectedDate),
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 16),
            label: Text(
              "Change",
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(List<MarketingAttendanceData> list) {
    int totalVisits = list.length;

    return Container(
      padding: EdgeInsets.all(16.w),
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
          _summaryItem("Total Visits", "$totalVisits", Icons.location_on, Colors.blue),
          _summaryItem("Today", "${_getCountToday(list)}", Icons.today, Colors.green),
        ],
      ),
    );
  }

  int _getCountToday(List<MarketingAttendanceData> list) {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    return list.where((e) => e.date == todayStr).length;
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(MarketingAttendanceData data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: const Color(0xFFE0F2F1),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: const Color(0xFF26A69A),
                    child: Text(
                      data.employeeName.isNotEmpty ? data.employeeName[0].toUpperCase() : "?",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.employeeName,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          data.employeeId.isEmpty ? "ID: N/A" : "ID: ${data.employeeId}",
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      _formatDate(data.date),
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF26A69A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _infoRow(Icons.business, "Client", data.clientName.isEmpty ? "N/A" : data.clientName)),
                      Expanded(child: _infoRow(Icons.history_toggle_off, "Applied Time", _formatTime(data.dtime))),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _infoRow(Icons.place, "Location", data.location.isEmpty ? "N/A" : data.location),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _timeRow(Icons.login, "In", data.checkInTime.isEmpty ? "--:--" : data.checkInTime, Colors.green),
                      ),
                      Expanded(
                        child: _timeRow(Icons.logout, "Out", data.checkOutTime.isEmpty ? "--:--" : data.checkOutTime, Colors.red),
                      ),
                    ],
                  ),
                  if (data.purposeOfVisit.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      "Purpose",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      data.purposeOfVisit,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  if (data.remarks.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      "Remarks",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      data.remarks,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Colors.grey.shade400),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeRow(IconData icon, String label, String time, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color.withOpacity(0.7)),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                color: Colors.grey,
              ),
            ),
            Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String dtimeStr) {
    try {
      DateTime dt = DateTime.parse(dtimeStr);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      if (dtimeStr.contains(" ")) {
        return dtimeStr.split(" ").last;
      }
      return dtimeStr;
    }
  }
}
