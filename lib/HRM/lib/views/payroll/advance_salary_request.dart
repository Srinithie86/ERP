import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/advance_salary_api.dart';

class AdvanceSalaryRequestScreen extends StatefulWidget {
  final int initialTabIndex;
  const AdvanceSalaryRequestScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AdvanceSalaryRequestScreen> createState() => _AdvanceSalaryRequestScreenState();
}

class _AdvanceSalaryRequestScreenState extends State<AdvanceSalaryRequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  
  bool _isLoading = false;
  bool _isHistoryLoading = true;
  List<dynamic> _historyList = [];
  final Color _themeColor = const Color(0xFF26A69A);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _fetchHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isHistoryLoading = true);
    try {
      final res = await AdvanceSalaryApi.getAdvanceHistory();
      if (mounted) {
        setState(() {
          _historyList = res['data'] ?? [];
          _isHistoryLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isHistoryLoading = false);
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String deviceId = prefs.getString('device_id') ?? "123456";
      final String lat = (prefs.getDouble('lat') ?? 0.0).toString();
      final String lng = (prefs.getDouble('lng') ?? 0.0).toString();
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String empName = prefs.getString('name') ?? "User";
      final String empCode = prefs.getString('employee_code') ?? "";

      final res = await AdvanceSalaryApi.submitAdvanceRequest(
        amount: _amountController.text,
        reason: _reasonController.text,
        date: today,
        deviceId: deviceId,
        lt: lat,
        ln: lng,
        employeeName: empName,
        employeeCode: empCode,
      );

      if (!mounted) return;

      if (res['error'] == false || res['error'] == "false") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Advance salary request submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        _amountController.clear();
        _reasonController.clear();
        _tabController.animateTo(1);
        _fetchHistory();
      } else {
        throw Exception(res['error_msg'] ?? "Submission failed");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Salary Advance',
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 20),
        ),
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          labelColor: _themeColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _themeColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: "Apply"),
            Tab(text: "History"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Requested Amount (₹)"),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              decoration: _inputDecoration("Enter amount e.g. 5000", Icons.payments_rounded),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please enter amount';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            _buildLabel("Reason for Advance"),
            const SizedBox(height: 10),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              style: GoogleFonts.poppins(),
              decoration: _inputDecoration("Briefly explain your requirement...", Icons.edit_note_rounded),
              validator: (v) => (v == null || v.isEmpty) ? 'Please enter reason' : null,
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _themeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: _themeColor.withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        "Submit Request",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            _buildNoticeCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isHistoryLoading) {
      return Center(child: CircularProgressIndicator(color: _themeColor));
    }
    if (_historyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No previous requests found",
              style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: _themeColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final item = _historyList[index];
          return _buildHistoryCard(item);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    String status = (item['status'] ?? "Pending").toString().toLowerCase();
    Color statusColor = Colors.orange;
    String displayStatus = "Pending";
    
    if (status.contains("accept") || status == "1") {
      statusColor = Colors.green;
      displayStatus = "Approved";
    } else if (status.contains("reject") || status == "2") {
      statusColor = Colors.red;
      displayStatus = "Rejected";
    } else {
      displayStatus = "Pending";
    }

    final String requestedAmount = item['advance_amount'] ?? '0';
    final String? approvedAmount = item['approved_amount'];
    final String? recoveryStart = item['recovery_start_month'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                    "Requested: ₹$requestedAmount",
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                  ),
                  if (approvedAmount != null && approvedAmount != "null")
                    Text(
                      "Approved: ₹$approvedAmount",
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.green.shade700),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayStatus,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['reason'] ?? "No reason provided",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
          if (recoveryStart != null && recoveryStart != "null") ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    "Recovery starts: $recoveryStart",
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    item['request_date'] ?? item['dtime']?.toString().split(' ')[0] ?? "N/A",
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              if (item['id'] != null)
                Text(
                  "Ref: #${item['id']}",
                  style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade400),
                ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Note: Approved advance amounts are typically deducted from your next month's salary.",
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: _themeColor, size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _themeColor, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
