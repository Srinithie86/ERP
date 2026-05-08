import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp_smart/theme/Service /lib/core/size_utils.dart';

import '../../models/permission_api.dart';
import '../../utils/background_fetch_service.dart';

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
              // Trigger a check to record the new pending status locally
              BackgroundFetchService.checkNow();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildFormCard(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [themeGreen, const Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: themeGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            right: -30,
            top: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Request Permission",
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Submit your short duration leave request",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      _infoTile(Icons.person_rounded, "Employee", employeeName ?? "Loading..."),
                      Container(
                        height: 30,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      _infoTile(Icons.badge_rounded, "ID", employeeId ?? "---"),
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

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
            borderRadius: BorderRadius.circular(16),
            child: IgnorePointer(
              child: TextFormField(
                controller: _dateController,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                decoration: _inputDecoration("Select Date", icon: Icons.event_note_rounded),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.more_time_rounded, "From"),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectTime(context, true),
                      borderRadius: BorderRadius.circular(16),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _fromTimeController,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: _inputDecoration("Start Time"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(Icons.history_toggle_off_rounded, "To"),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _selectTime(context, false),
                      borderRadius: BorderRadius.circular(16),
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _toTimeController,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
                          decoration: _inputDecoration("End Time"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _sectionHeader(Icons.edit_note_rounded, "Reason for Permission"),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 4,
            onChanged: (val) => reason = val,
            style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: themeGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: themeGreen),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeGreen.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _applyPermission,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeGreen, const Color(0xFF00897B)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : Text(
                    "Submit Request",
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
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
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: themeGreen.withOpacity(0.7), size: 20) : null,
      filled: true,
      fillColor: const Color(0xFFF1F5F9).withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: themeGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}

