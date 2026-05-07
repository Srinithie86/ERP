import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hrm/models/payroll_api.dart';
import '../../views/payroll/advance_salary_request.dart';
import '../main_root.dart';
import 'package:intl/intl.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> with SingleTickerProviderStateMixin {
  static const Color primaryColor = Color(0xFF26A69A);
  
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _payrollData;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _isFabOpen = false;
  late AnimationController _fabController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
    _fetchPayroll();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  Future<void> _fetchPayroll() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String uid = prefs.getString('login_cus_id') ?? 
                         prefs.getString('uid') ?? "";
      final String cid = prefs.getString('cid') ?? "";
      final String deviceId = prefs.getString('device_id') ?? "";

      final position = await _determinePosition();
      final month = _selectedMonth.toString().padLeft(2, '0');
      final year = _selectedYear.toString();

      final response = await PayrollRepo.getPayroll(
        cid: cid,
        uid: uid,
        month: month,
        year: year,
        deviceId: deviceId,
        lat: position?.latitude.toString() ?? "0.0",
        lng: position?.longitude.toString() ?? "0.0",
      );

      if (!mounted) return;

      if (response["error"] == false || response["error"] == "false") {
        setState(() {
          _payrollData = response["data"] ?? response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _payrollData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _payrollData = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<Position?> _determinePosition() async {
    try {
      Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 2),
      );
    } catch (e) {
      return null;
    }
  }

  String _getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(0, month));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainRoot()),
            (route) => false,
          ),
        ),
        title: Text(
          "Payroll",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMonthYearPicker,
          ),
        ],
      ),
      floatingActionButton: _buildExpandableFab(),
      body: RefreshIndicator(
        onRefresh: _fetchPayroll,
        color: primaryColor,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOldHeader(),
                  const SizedBox(height: 20),
                  _buildEarningsSection(),
                  const SizedBox(height: 20),
                  _buildBreakdownSection(),
                  const SizedBox(height: 20),
                  _buildBottomButtons(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildOldHeader() {
    final earnings = _payrollData?['earnings'] ?? {};
    final attendance = _payrollData?['attendance'] ?? {};
    final monthName = _getMonthName(_selectedMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$monthName Month Salary Details",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _headerBox("Monthly", "₹${earnings['basic_salary'] ?? '0'}"),
              _headerBox("Per Day", "₹${earnings['per_day_salary'] ?? '0'}"),
              _headerBox("Days Worked", "${attendance['no_of_present'] ?? '0'} Days"),
              _headerBox("Leave days", "${attendance['absent'] ?? '0'} Days"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBox(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.poppins(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(color: primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEarningsSection() {
    final e = _payrollData?['earnings'] ?? {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Earnings", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _earningsField("Bonus", "₹${e['bonus'] ?? '0'}"),
          _earningsField("Allowance", "₹${e['allowance'] ?? '0'}"),
          _earningsField("Incentive", "₹${e['incentives'] ?? '0'}"),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.yellow, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "You Got Incentive Because You Achieved You Target",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _earningsField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection() {
    final e = _payrollData?['earnings'] ?? {};
    final d = _payrollData?['deductions'] ?? {};
    final net = _payrollData?['net_pay'] ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Breakdown", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _breakdownRow("Monthly salary", "₹${e['basic_salary'] ?? '0'}", valueColor: Colors.green),
          _breakdownRow("Per Day Salary", "₹${e['per_day_salary'] ?? '0'}", valueColor: Colors.black87),
          _breakdownRow("Days Worked", "${_payrollData?['attendance']?['no_of_present'] ?? '0'}", valueColor: Colors.black87),
          const Divider(),
          _breakdownRow("Bonus", e['bonus'] != null ? "₹${e['bonus']}" : "-", valueColor: Colors.black54),
          _breakdownRow("Allowance", e['allowance'] != null ? "₹${e['allowance']}" : "-", valueColor: Colors.black54),
          _breakdownRow("Incentive", "₹${e['incentives'] ?? '0'}", valueColor: Colors.orange),
          _breakdownRow("Gross", "₹${e['gross_salary'] ?? '0'}", isBold: true),
          const Divider(),
          _breakdownRow("Per Day leave deduction", d['loss_of_pay'] != null ? "₹${d['loss_of_pay']}" : "-", valueColor: Colors.black54),
          _breakdownRow("Total Deduction", "₹${d['total_deduction'] ?? net['total_deduction'] ?? '0'}", valueColor: Colors.red),
          const Divider(),
          _breakdownRow("Gross Pay", "₹${net['net_paid'] ?? '0'}", isBold: true, valueColor: Colors.green, fontSize: 16),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool isBold = false, Color? valueColor, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _downloadPDF,
            icon: const Icon(Icons.description, size: 18),
            label: const Text("Download"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _sharePDF,
            icon: const Icon(Icons.share, size: 18),
            label: const Text("Share"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFabOption(
          label: "History",
          icon: Icons.history_rounded,
          onTap: () {
            _toggleFab();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvanceSalaryRequestScreen(initialTabIndex: 1)),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildFabOption(
          label: "Request",
          icon: Icons.add_card_rounded,
          onTap: () {
            _toggleFab();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvanceSalaryRequestScreen(initialTabIndex: 0)),
            );
          },
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: _toggleFab,
          backgroundColor: primaryColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _expandAnimation,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 16),
              FloatingActionButton.small(
                onPressed: onTap,
                backgroundColor: primaryColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMonthYearPicker() async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => _MonthYearPickerDialog(
        initialMonth: _selectedMonth,
        initialYear: _selectedYear,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMonth = result['month']!;
        _selectedYear = result['year']!;
      });
      _fetchPayroll();
    }
  }

  Future<void> _downloadPDF() async {}
  Future<void> _sharePDF() async {}
}

class _MonthYearPickerDialog extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  const _MonthYearPickerDialog({required this.initialMonth, required this.initialYear});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Month & Year"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: selectedMonth,
            isExpanded: true,
            items: List.generate(12, (index) => index + 1).map((m) {
              return DropdownMenuItem(value: m, child: Text(DateFormat('MMMM').format(DateTime(0, m))));
            }).toList(),
            onChanged: (v) => setState(() => selectedMonth = v!),
          ),
          const SizedBox(height: 16),
          DropdownButton<int>(
            value: selectedYear,
            isExpanded: true,
            items: List.generate(5, (index) => DateTime.now().year - index).map((y) {
              return DropdownMenuItem(value: y, child: Text(y.toString()));
            }).toList(),
            onChanged: (v) => setState(() => selectedYear = v!),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {'month': selectedMonth, 'year': selectedYear}),
          child: const Text("Select"),
        ),
      ],
    );
  }
}
