import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_smart/theme/Service /lib/core/size_utils.dart';

import '../../models/permission_api.dart';

extension TimeOfDayExtension on TimeOfDay {
  String format12Hour() {
    final hour = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final minute = this.minute.toString().padLeft(2, '0');
    final period = this.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class PermissionForm extends StatefulWidget {
  const PermissionForm({super.key});

  @override
  State<PermissionForm> createState() => _PermissionFormState();
}

class _PermissionFormState extends State<PermissionForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();

  String? employeeName;
  String? employeeId;
  String? uid;
  bool isLoading = false;

  DateTime? selectedDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  String? reason;
  final Color themeGreen = const Color(0xff26A69A);

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _dateController.text =
        "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
    _fetchUserData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        employeeName = prefs.getString('name');
        uid = prefs.get('uid')?.toString() ?? "";
        employeeId = uid;
      });
    }
  }


  Future<void> _applyPermission() async {
    if (!_formKey.currentState!.validate() ||
        selectedDate == null ||
        fromTime == null ||
        toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      String deviceId = prefs.getString('device_id') ?? "";
      String lat = (prefs.getDouble('lat') ?? 0.0).toString();
      String lng = (prefs.getDouble('lng') ?? 0.0).toString();

      String fromTimeStr =
          "${fromTime!.hour.toString().padLeft(2, '0')}:${fromTime!.minute.toString().padLeft(2, '0')}";
      String toTimeStr =
          "${toTime!.hour.toString().padLeft(2, '0')}:${toTime!.minute.toString().padLeft(2, '0')}";

      String dateStr =
          "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

      final res = await PermissionApi.submitPermission(
        date: dateStr,
        fromTime: fromTimeStr,
        toTime: toTimeStr,
        reason: reason ?? "",
        deviceId: deviceId,
        lt: lat,
        ln: lng,
      );

      if (res['error'].toString() == "false") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res['error_msg'] ?? "Permission request submitted successfully",
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Redirect to Dashboard after 1 second delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).maybePop();
            }
          });
        }
      } else {
        throw Exception(res['error_msg'] ?? "Submission Failed");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: themeGreen),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromTime = picked;
          _fromTimeController.text = picked.format12Hour();
        } else {
          toTime = picked;
          _toTimeController.text = picked.format12Hour();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormCard(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeGreen, themeGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Request Permission",
                    style: GoogleFonts.outfit(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Short duration leave request",
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoLabel(Icons.person, "Employee: ${employeeName ?? 'Loading...'}"),
          const SizedBox(height: 8),
          _infoLabel(Icons.badge, "ID: ${employeeId ?? 'Loading...'}"),
        ],
      ),
    );
  }

  Widget _infoLabel(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.calendar_today_rounded, "Application Date"),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(14),
            child: TextFormField(
              controller: _dateController,
              enabled: false,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              decoration: _inputDecoration("Select Date", icon: Icons.event),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.login_rounded, "From"),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fromTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(context, true),
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: _inputDecoration("Start Time"),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.logout_rounded, "To"),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _toTimeController,
                      readOnly: true,
                      onTap: () => _selectTime(context, false),
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: _inputDecoration("End Time"),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionHeader(Icons.edit_note_rounded, "Reason for Permission"),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 3,
            onChanged: (val) => reason = val,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _inputDecoration("Please describe your reason clearly..."),
            validator: (v) => (v == null || v.isEmpty) ? "Reason is required" : null,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: themeGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 58.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: themeGreen.withOpacity(0.3),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _applyPermission,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                "Submit Request",
                style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: themeGreen),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: themeGreen, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: themeGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}
