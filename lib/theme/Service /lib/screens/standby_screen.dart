import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/app_colors.dart';
import '../core/size_utils.dart';
import '../data/app_data.dart';

class StandByScreen extends StatefulWidget {
  const StandByScreen({super.key});

  @override
  State<StandByScreen> createState() => _StandByScreenState();
}

class _StandByScreenState extends State<StandByScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _available = [];
  List<Map<String, dynamic>> _inUse = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final res = await ApiService.getStandbyScreenData();
      if (res != null && res['error'] == false) {
        if (mounted) {
          setState(() {
            _available = List<Map<String, dynamic>>.from(
              res['available'] ?? [],
            );
            _inUse = List<Map<String, dynamic>>.from(res['used'] ?? []);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _available;
    final inUse = _inUse;
    final total = available.length + inUse.length;
    final availableCount = available.length;
    final inUseCount = inUse.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Stand by',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Section
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Machine Statistics',
                          style: TextStyle(
                            color: const Color(0xFFB71C1C),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 18.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _CircularStat(
                              label: 'Total',
                              value: 1.0,
                              count: total,
                              color: Colors.green,
                            ),
                            _CircularStat(
                              label: 'Available',
                              value: total > 0 ? availableCount / total : 0,
                              count: availableCount,
                              color: Colors.blue,
                            ),
                            _CircularStat(
                              label: 'In Use',
                              value: total > 0 ? inUseCount / total : 0,
                              count: inUseCount,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Machines',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: () => _openAssignBottomSheet(context),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF4776E6,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 16.sp, color: Colors.white),
                              SizedBox(width: 4.w),
                              Text(
                                'Assign',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  if (available.isEmpty)
                    _buildEmptyState('No machines available')
                  else
                    ...available.map<Widget>((m) {
                      final id = m['id']?.toString() ?? 'N/A';
                      final productName =
                          m['product_name']?.toString() ?? 'N/A';
                      final displayId = id.isEmpty || id == 'null' ? 'N/A' : id;
                      final displayProduct =
                          productName.isEmpty || productName == 'null'
                          ? 'N/A'
                          : productName;
                      return _MachineListItem(
                        name: 'Standby -$displayId-$displayProduct',
                        gradientColors: const [
                          Colors.white,
                          Color(0xCC66BB6A),
                          Color(0xFF43A047),
                        ],
                      );
                    }),
                  SizedBox(height: 24.h),
                  Text(
                    'Machines in Use',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (inUse.isEmpty)
                    _buildEmptyState('No machines in use')
                  else
                    ...inUse.map<Widget>((m) => _MachineInUseItem(machine: m)),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
        ),
      ),
    );
  }

  Future<void> _openAssignBottomSheet(BuildContext context) async {
    final assigned = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AssignMachineSheet(),
    );
    if (assigned == true && mounted) {
      _fetchData();
    }
  }
}

class _CircularStat extends StatelessWidget {
  const _CircularStat({
    required this.label,
    required this.value,
    required this.count,
    required this.color,
  });

  final String label;
  final double value;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 58.w,
              height: 58.w,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 5.w,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _MachineListItem extends StatelessWidget {
  const _MachineListItem({required this.name, required this.gradientColors});

  final String name;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          name,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _MachineInUseItem extends StatefulWidget {
  const _MachineInUseItem({required this.machine});
  final Map<String, dynamic> machine;

  @override
  State<_MachineInUseItem> createState() => _MachineInUseItemState();
}

class _MachineInUseItemState extends State<_MachineInUseItem> {
  bool _isExpanded = false;

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty || date.toString() == 'null')
      return 'N/A';
    if (date is DateTime) {
      return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
    }
    if (date is String) {
      try {
        DateTime parsed = DateTime.parse(date);
        return '${parsed.month}/${parsed.day}/${parsed.year.toString().substring(2)}';
      } catch (e) {
        return date;
      }
    }
    return 'N/A';
  }

  String _getMachineName(Map<String, dynamic> m) {
    String id = m['id']?.toString() ?? 'N/A';
    String productName = m['product_name']?.toString() ?? 'N/A';
    if (id.isEmpty || id == 'null') id = 'N/A';
    if (productName.isEmpty || productName == 'null') productName = 'N/A';
    return 'Standby -$id-$productName';
  }

  String _getValue(dynamic val) {
    if (val == null || val.toString().isEmpty || val.toString() == 'null')
      return 'N/A';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.machine;
    final machineName = _getMachineName(m);

    if (!_isExpanded) {
      return InkWell(
        onTap: () => setState(() => _isExpanded = true),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xCCEF5350), Color(0xFFE53935)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '$machineName · In Use',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ),
              Positioned(
                right: 12.w,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 26.sp,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF78FA7), Color(0xFFF14D67)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      '$machineName · In Use',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 26.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // _buildDetailRow(
                //   Icons.settings_suggest_rounded,
                //   const Color(0xFFF06292),
                //   'Machine No',
                //   m['breakerNo'] ?? '--',
                // ),
                // SizedBox(height: 10.h),
                // _buildDetailRow(
                //   Icons.apps_rounded,
                //   const Color(0xFF4CAF50),
                //   'Serial Number',
                //   m['serial'] ?? '--',
                // ),
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.people_alt_rounded,
                  const Color(0xFF5C6BC0),
                  'Customer',
                  _getValue(m['customer_id']),
                ),
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.confirmation_number_rounded,
                  const Color(0xFFFF9800),
                  'Ticket No',
                  _getValue(m['ticket_id']),
                ),
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.currency_rupee_rounded,
                  const Color(0xFF009688),
                  'Charges',
                  _getValue(m['charges']) == 'N/A' ? 'N/A' : '₹${m['charges']}',
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: const Divider(color: Colors.black38, height: 1),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/calendar_icon.png',
                  width: 24.sp,
                  height: 24.sp,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Given Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(m['issue_date']),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Returning Date',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(m['return_date']),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    Color iconColor,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF004D40),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSIGN MACHINE BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _AssignMachineSheet extends StatefulWidget {
  const _AssignMachineSheet();

  @override
  State<_AssignMachineSheet> createState() => _AssignMachineSheetState();
}

class _AssignMachineSheetState extends State<_AssignMachineSheet> {
  final _ticketController = TextEditingController();
  final _customerController = TextEditingController();
  final _chargesController = TextEditingController();

  String? _selectedBreakerName;
  String? _selectedBreakerId;

  // FIX: Keep ticket_no (display) and ticket id (for API) separate and clear
  String? _selectedTicketDisplayNo; // what user sees in dropdown
  String? _selectedTicketId; // the actual id sent to backend
  String? _selectedCustomerId;

  DateTime? _givenDate;
  DateTime? _returnDate;
  bool _submitted = false;
  bool _isAssigning = false;

  List<Map<String, dynamic>> _apiTickets = <Map<String, dynamic>>[];
  bool _isFetchingTickets = true;
  List<Map<String, dynamic>> _apiBreakersList = <Map<String, dynamic>>[];
  bool _isFetchingBreakers = true;
  List<Map<String, dynamic>> _customerSuggestions = <Map<String, dynamic>>[];
  bool _isLoadingSuggestions = false;
  Timer? _debounce;

  // FIX: Track whether customer details are still loading to block premature submit
  bool _isFetchingCustomer = false;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
    _fetchBreakers();
  }

  @override
  void dispose() {
    _ticketController.dispose();
    _customerController.dispose();
    _chargesController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchTickets() async {
    try {
      final data = await ApiService.getStandbyTickets();
      if (data is Map && data['error'] == false) {
        final List<dynamic> records = data['data'] ?? [];
        final List<Map<String, dynamic>> list = records
            .where((r) => r is Map)
            .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r))
            .toList();

        if (mounted) {
          setState(() {
            _apiTickets = list;
            _isFetchingTickets = false;
          });
        }
      } else {
        if (mounted) setState(() => _isFetchingTickets = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingTickets = false);
    }
  }

  Future<void> _fetchBreakers() async {
    try {
      final data = await ApiService.getAvailableBreakers();
      if (data is Map && data['error'] == false) {
        final List<dynamic> records = data['data'] ?? [];
        if (mounted) {
          setState(() {
            _apiBreakersList = records
                .where((r) => r is Map)
                .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r))
                .toList();
            _isFetchingBreakers = false;
          });
        }
      } else {
        if (mounted) setState(() => _isFetchingBreakers = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingBreakers = false);
    }
  }

  Future<void> _fetchCustomerSuggestions(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoadingSuggestions = true);
    try {
      final data = await ApiService.getCustomerSuggestions(query);
      if (data is Map && data['error'] == false) {
        final List<dynamic> records = data['data'] ?? [];
        if (mounted) {
          setState(() {
            _customerSuggestions = records
                .where((r) => r is Map)
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList();
          });
        }
      }
    } catch (e) {
      print("STANDBY FETCH SUGGESTIONS ERROR: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  void _onCustomerSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() => _customerSuggestions = []);
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchCustomerSuggestions(query);
    });
  }

  // FIX: Returns the fetched customer id so caller can use it safely
  Future<String?> _fetchTicketDetails(String ticketNo) async {
    try {
      final searchVal = ticketNo.replaceAll(RegExp(r'[^0-9]'), '');
      final data = await ApiService.getTicketDetails(
        searchVal.isNotEmpty ? searchVal : ticketNo,
      );

      if (data is Map && data['error'] == false) {
        final List<dynamic> records = data['data'] ?? [];
        if (records.isNotEmpty && records.first is Map) {
          final first = records[0] as Map;

          // DEBUG DUMP to find the real customer id field
          print("=== API 5027 RESPONSE FIELD DUMP ===");
          first.forEach((k, v) => print("  $k: $v (${v.runtimeType})"));

          final custName = _extractName(first);
          final custId = _extractId(first);

          if (mounted) {
            setState(() {
              _customerController.text = custName.isNotEmpty
                  ? custName
                  : 'Unknown';
              _selectedCustomerId = custId.isNotEmpty ? custId : null;
              _isFetchingCustomer = false;
            });
          }
          return custId.isNotEmpty ? custId : null;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _customerController.text = 'Error';
          _isFetchingCustomer = false;
        });
      }
    }
    if (mounted) setState(() => _isFetchingCustomer = false);
    return null;
  }

  // FIX: Completely rewritten — all state mutations happen in ONE setState call
  // after async work is done, eliminating the race condition.
  void _applyTicketSelection(
    AppData provider,
    String displayTicketNo,
    String ticketId,
  ) {
    _ticketController.text = displayTicketNo;

    // Try to pre-populate customer from local data for instant feedback
    String prefilledName = '';
    String prefilledId = '';

    final standbyTicket = _apiTickets.firstWhere(
      (item) =>
          '${item['id']}' == ticketId ||
          '${item['ticket_no']}' == displayTicketNo,
      orElse: () => <String, dynamic>{},
    );

    if (standbyTicket.isNotEmpty) {
      prefilledName = _extractName(standbyTicket);
      prefilledId = _extractId(standbyTicket);
    } else {
      final ticket = provider.tickets.firstWhere(
        (item) =>
            '${item['id']}' == ticketId ||
            '${item['ticket_no']}' == displayTicketNo,
        orElse: () => <String, dynamic>{},
      );
      if (ticket.isNotEmpty) {
        prefilledName = _extractName(ticket);
        prefilledId = _extractId(ticket);
      }
    }

    // FIX: Set isFetchingCustomer = true BEFORE the async call,
    // and set prefilled values atomically in one setState
    setState(() {
      _isFetchingCustomer = true;
      _customerController.text = prefilledName.isNotEmpty
          ? prefilledName
          : 'Loading...';
      _selectedCustomerId = prefilledId.isNotEmpty ? prefilledId : null;
    });

    // Always fetch full details from API to ensure customer_id is correct
    _fetchTicketDetails(displayTicketNo);
  }

  void _populateFromMap(Map<String, dynamic> data) {
    final name = _extractName(data);
    final id = _extractId(data);
    if (mounted) {
      setState(() {
        _customerController.text = name.isNotEmpty ? name : 'Unknown';
        _selectedCustomerId = id.isNotEmpty ? id : null;
      });
    }
  }

  String _extractName(Map<dynamic, dynamic> data) {
    return (data['customer_name'] ??
            data['ledger_name'] ??
            data['Ledger_name'] ??
            data['customerName'] ??
            data['CustomerName'] ??
            data['cust_name'] ??
            data['user'] ??
            data['name'] ??
            data['customer'] ??
            data['Customer'] ??
            '')
        .toString()
        .trim();
  }

  String _extractId(Map<dynamic, dynamic> data) {
    // Priority 1: Direct customer id fields
    final cid =
        (data['customer_id'] ??
                data['ledger_id'] ??
                data['Ledger_id'] ??
                data['cus_id'] ??
                data['customerID'] ??
                data['ledgerID'] ??
                data['cid'] ??
                '')
            .toString()
            .trim();

    if (cid.isNotEmpty && cid != 'null') return cid;

    // Priority 2: Generic ID fields
    final id = (data['id'] ?? data['ID'] ?? '').toString().trim();

    // FIX: Removed the regex letter-check that was rejecting valid IDs like "TCK-4"
    if (id.isNotEmpty && id != 'null') return id;

    return '';
  }

  Future<void> _pickDate(BuildContext context, bool isGiven) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isGiven) {
          _givenDate = picked;
        } else {
          _returnDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _handleSubmit() async {
    setState(() => _submitted = true);

    // FIX: Block submission if customer details are still being fetched
    if (_isFetchingCustomer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, loading customer details...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final customerText = _customerController.text.trim();
    final hasCustomer =
        customerText.isNotEmpty &&
        customerText != 'Loading...' &&
        customerText != 'N/A' &&
        customerText != 'Error';

    // FIX: Use _selectedTicketId (not _selectedTicketNo which was renamed)
    final hasTicket =
        _selectedTicketId != null && _selectedTicketId!.trim().isNotEmpty;
    final hasCustomerId =
        _selectedCustomerId != null && _selectedCustomerId!.trim().isNotEmpty;
    final hasGiven = _givenDate != null;
    final hasReturn = _returnDate != null;
    final hasBreaker =
        _selectedBreakerId != null && _selectedBreakerId!.trim().isNotEmpty;

    print(
      "SUBMIT CHECK — ticketId: $_selectedTicketId | customerId: $_selectedCustomerId | "
      "customer: $customerText | breakerId: $_selectedBreakerId | "
      "given: $_givenDate | return: $_returnDate",
    );

    if (!hasTicket ||
        !hasCustomer ||
        !hasCustomerId ||
        !hasGiven ||
        !hasReturn ||
        !hasBreaker) {
      // Show a descriptive snackbar so the user knows exactly what's missing
      final missing = <String>[];
      if (!hasTicket) missing.add('Ticket');
      if (!hasCustomer || !hasCustomerId) missing.add('Customer');
      if (!hasGiven) missing.add('Given Date');
      if (!hasReturn) missing.add('Return Date');
      if (!hasBreaker) missing.add('Breaker');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill: ${missing.join(', ')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isAssigning = true);

    try {
      final formattedGiven =
          "${_givenDate!.year}-${_givenDate!.month.toString().padLeft(2, '0')}-${_givenDate!.day.toString().padLeft(2, '0')}";
      final formattedReturn =
          "${_returnDate!.year}-${_returnDate!.month.toString().padLeft(2, '0')}-${_returnDate!.day.toString().padLeft(2, '0')}";

      print(
        "CALLING assignStandby — ticketId: $_selectedTicketId | customerId: $_selectedCustomerId | "
        "standbyId: $_selectedBreakerId | issueDate: $formattedGiven | returnDate: $formattedReturn",
      );

      final response = await ApiService.assignStandby(
        ticketId: _selectedTicketId!, // FIX: use correct ticket id field
        customerId: _selectedCustomerId!,
        returnDate: formattedReturn,
        issueDate: formattedGiven,
        standbyId: _selectedBreakerId!,
        charges: _chargesController.text.trim(),
      );

      print("assignStandby RESPONSE: $response");

      if (response['error'] == false) {
        final provider = AppData.instance;
        provider.assignMachine(
          breakerNo: _selectedBreakerName ?? _selectedBreakerId!,
          ticketNo: _selectedTicketId!, // FIX: use ticket id consistently
          customerName: _customerController.text.trim(),
          jobNo: _selectedTicketId!,
          givenDate: _givenDate!,
          returnDate: _returnDate!,
          charges: _chargesController.text.trim().isEmpty
              ? null
              : _chargesController.text.trim(),
        );

        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Machine $_selectedBreakerName assigned successfully',
              ),
              backgroundColor: const Color(0xFF45C95A),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response['message'] ?? 'Check input'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAssigning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = AppData.instance;
    final breakersData = _apiBreakersList;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Ticket No', true),
                  SizedBox(height: 6.h),
                  // FIX: Dropdown value bound to _selectedTicketDisplayNo (display value),
                  // while _selectedTicketId stores the actual backend id separately.
                  _buildDropdown(
                    value: _selectedTicketDisplayNo,
                    hint: _isFetchingTickets
                        ? 'Loading...'
                        : 'Select Ticket No',
                    items: _apiTickets
                        .map<String>(
                          (e) => (e['ticket_no'] ?? e['id'])?.toString() ?? '',
                        )
                        .toList(),
                    hasError: _submitted && _selectedTicketId == null,
                    onChanged: (val) {
                      if (val == null) return;

                      // Find the matching ticket record
                      final ticket = _apiTickets.firstWhere(
                        (e) => (e['ticket_no'] ?? e['id'])?.toString() == val,
                        orElse: () => {},
                      );

                      // FIX: Extract id cleanly — prefer 'id', fallback to ticket_no
                      final ticketId =
                          (ticket['id'] ?? ticket['ticket_no'])?.toString() ??
                          val;

                      // FIX: Set BOTH display value and id atomically before async call
                      setState(() {
                        _selectedTicketDisplayNo = val;
                        _selectedTicketId = ticketId;
                      });

                      // Populate customer details using display ticket_no for search
                      _applyTicketSelection(provider, val, ticketId);
                    },
                  ),
                  SizedBox(height: 16.h),
                  _buildLabel('Customer Name', true),
                  SizedBox(height: 6.h),
                  _buildTextField(
                    controller: _customerController,
                    hint: 'Search For Customer Name',
                    hasError:
                        _submitted && _customerController.text.trim().isEmpty,
                    onChanged: _onCustomerSearch,
                  ),
                  if (_customerSuggestions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: BoxConstraints(maxHeight: 200.h),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _customerSuggestions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, index) {
                          final sug = _customerSuggestions[index];
                          final name = _extractName(sug);
                          return ListTile(
                            dense: true,
                            title: Text(name),
                            onTap: () {
                              setState(() {
                                _customerController.text = name;
                                _selectedCustomerId = _extractId(sug);
                                _customerSuggestions = [];
                              });
                            },
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Date of Given', true),
                            SizedBox(height: 6.h),
                            _buildDateField(
                              date: _givenDate,
                              hasError: _submitted && _givenDate == null,
                              onTap: () => _pickDate(context, true),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Return Date', true),
                            SizedBox(height: 6.h),
                            _buildDateField(
                              date: _returnDate,
                              hasError: _submitted && _returnDate == null,
                              onTap: () => _pickDate(context, false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  _buildLabel('Breaker No', true),
                  SizedBox(height: 6.h),
                  _buildDropdown(
                    value: _selectedBreakerName,
                    hint: _isFetchingBreakers ? 'Loading...' : 'Select Breaker',
                    items: breakersData
                        .map<String>(
                          (e) =>
                              (e['product_name'] ?? e['breakerNo'])
                                  ?.toString() ??
                              '',
                        )
                        .toList(),
                    hasError: _submitted && _selectedBreakerId == null,
                    onChanged: (val) {
                      if (val == null) return;
                      final record = breakersData.firstWhere(
                        (e) =>
                            (e['product_name'] ?? e['breakerNo'])?.toString() ==
                            val,
                        orElse: () => {},
                      );
                      if (record.isEmpty) return;
                      setState(() {
                        _selectedBreakerName = val;
                        _selectedBreakerId =
                            (record['id'] ?? record['standby_id'])?.toString();
                      });
                    },
                  ),
                  SizedBox(height: 18.h),
                  _buildLabel('Charges', false),
                  SizedBox(height: 6.h),
                  _buildTextField(
                    controller: _chargesController,
                    hint: 'Enter charges (optional)',
                    hasError: false,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              foregroundColor: AppColors.primary,
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: _isAssigning ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E54E9),
                                    Color(0xFF4776E6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isAssigning
                                    ? SizedBox(
                                        width: 20.w,
                                        height: 20.w,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Assign',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isMandatory) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: isMandatory
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontSize: 13.sp),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool hasError,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: (val) {
        if (onChanged != null) onChanged(val);
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: hasError ? Colors.red : const Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: hasError ? Colors.red : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      ),
    );
  }

  Widget _buildDateField({
    required DateTime? date,
    required bool hasError,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: hasError ? Colors.red : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? _formatDate(date) : 'Select',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: date != null
                      ? Colors.black87
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            Image.asset(
              'assets/calendar_icon.png',
              width: 18.sp,
              height: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required bool hasError,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: hasError ? Colors.red : const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF6B7280),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(fontSize: 14.sp)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
