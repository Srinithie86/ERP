import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'direct_generate_info.dart';
import 'invoice_view_screen.dart';
import 'package:sale_management/core/api_config.dart';

// ─── Theme Constants ──────────────────────────────────────
const kTeal = Color(0xFF26A69A);
const kBg = Color(0xFFF4F6F8);
const kCard = Colors.white;
const kTextPrimary = Color(0xFF1A2332);
const kTextSecondary = Color(0xFF3D5481);
const kBorder = Color(0xFFE0E6ED);

// ─── Status Colors ────────────────────────────────────────
const kPaidBg = Color(0xFF31AA28);
const kPendingBg = Color(0xFFBABD12);
const kDraftBg = Color(0xFF4098FA);

// ─── Data Model ───────────────────────────────────────────
enum InvoiceStatus { paid, pending, draft }

class InvoiceItem {
  final String productName;
  final String amount;
  final String date;
  final String invoiceNo;
  final InvoiceStatus status;

  const InvoiceItem({
    required this.productName,
    required this.amount,
    required this.date,
    required this.invoiceNo,
    required this.status,
  });
}

final List<InvoiceItem> allInvoices = [
  const InvoiceItem(
    productName: 'L2 Managed Switch - 48 Port',
    amount: '₹4,200.00',
    date: '3 Apr 2026',
    invoiceNo: 'INV-2023-0042',
    status: InvoiceStatus.paid,
  ),
  const InvoiceItem(
    productName: 'L2 Managed Switch - 48 Port',
    amount: '₹4,200.00',
    date: '3 Apr 2026',
    invoiceNo: 'INV-2023-0042',
    status: InvoiceStatus.pending,
  ),
  const InvoiceItem(
    productName: 'L2 Managed Switch - 48 Port',
    amount: '₹4,200.00',
    date: '3 Apr 2026',
    invoiceNo: 'INV-2023-0042',
    status: InvoiceStatus.draft,
  ),
  const InvoiceItem(
    productName: 'L2 Managed Switch - 48 Port',
    amount: '₹4,200.00',
    date: '3 Apr 2026',
    invoiceNo: 'INV-2023-0042',
    status: InvoiceStatus.pending,
  ),
  const InvoiceItem(
    productName: 'L2 Managed Switch - 48 Port',
    amount: '₹4,200.00',
    date: '3 Apr 2026',
    invoiceNo: 'INV-2023-0042',
    status: InvoiceStatus.paid,
  ),
];

// ─── Main Page ────────────────────────────────────────────
class AllInvoicePage extends StatefulWidget {
  const AllInvoicePage({super.key});

  @override
  State<AllInvoicePage> createState() => _AllInvoicePageState();
}

class _AllInvoicePageState extends State<AllInvoicePage> {
  int _selectedFilterIndex = 0;
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();
  List<InvoiceItem> _allInvoices = [];
  bool _isLoading = false;

  final List<String> _filters = ['ALL', 'SEND', 'PENDING', 'DRAFT'];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final lt = prefs.getString('lt') ?? '145';
      final ln = prefs.getString('ln') ?? '145';
      final deviceId = prefs.getString('device_id') ?? '12345';
      final uid = prefs.getString('uid') ?? '1';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '8012', // Placeholder for Direct Invoice List
          'cid': cid,
          'ln': ln,
          'lt': lt,
          'device_id': deviceId,
          'uid': uid,
          'date': _selectedDate.toIso8601String().split('T')[0],
        },
      );

      final res = json.decode(response.body);
      debugPrint("Direct Invoice Response: $res");
      if (res['error'] == false && res['data'] != null) {
        final List<dynamic> data = res['data'];
        setState(() {
          _allInvoices = data.map((item) {
            final inv = item['invoice'];
            return InvoiceItem(
              productName: inv['customer_name'] ?? 'Unknown Customer',
              amount: "₹${inv['grand_total'] ?? '0'}",
              date: inv['date'] ?? '',
              invoiceNo: inv['invoice_no'] ?? '',
              status: InvoiceStatus.paid, // Defaulting as API sample variant
            );
          }).toList();
        });
      } else {
         // If API fails or return no data, we could fallback to mock data or empty
         // For now, let's keep it empty if API is live but returning error
         setState(() => _allInvoices = []);
      }
    } catch (e) {
      debugPrint("Error fetching direct invoices: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<InvoiceItem> get filteredInvoices {
    List<InvoiceItem> result = _allInvoices.isEmpty && !_isLoading ? allInvoices : _allInvoices;
    if (_selectedFilterIndex == 1) {
      result = result.where((i) => i.status == InvoiceStatus.paid).toList();
    } else if (_selectedFilterIndex == 2) {
      result = result.where((i) => i.status == InvoiceStatus.pending).toList();
    } else if (_selectedFilterIndex == 3) {
      result = result.where((i) => i.status == InvoiceStatus.draft).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((i) {
        return i.productName.toLowerCase().contains(q) ||
            i.invoiceNo.toLowerCase().contains(q);
      }).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // ── Set on every build so hot reload / resume keeps it correct ──
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,  // black icons (Android)
      statusBarBrightness: Brightness.light,      // black icons (iOS)
    ));

    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final topPadding = mq.padding.top;      // status bar height
    final bottomPadding = mq.padding.bottom;

    final isTablet = screenWidth > 600;
    final hPad = isTablet ? screenWidth * 0.06 : screenWidth * 0.04;
    final cardPad = isTablet ? 18.0 : screenWidth * 0.038;
    final productFontSize = isTablet ? 15.0 : screenWidth * 0.036;
    final subFontSize = isTablet ? 13.0 : screenWidth * 0.03;
    final amountFontSize = isTablet ? 16.0 : screenWidth * 0.038;
    final filterFontSize = isTablet ? 13.0 : screenWidth * 0.03;
    final badgeFontSize = isTablet ? 12.0 : screenWidth * 0.028;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(
            topPadding: topPadding,
            screenWidth: screenWidth,
            hPad: hPad,
            isTablet: isTablet,
          ),

          // ── Body ──────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.015),

                _buildSearchBar(hPad: hPad, screenWidth: screenWidth),

                SizedBox(height: screenHeight * 0.012),

                _buildFilterTabs(
                  hPad: hPad,
                  fontSize: filterFontSize,
                  screenWidth: screenWidth,
                ),

                SizedBox(height: screenHeight * 0.012),

                Expanded(
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator(color: kTeal))
                      : filteredInvoices.isEmpty
                          ? _buildEmptyState(screenWidth)
                          : ListView.builder(
                    padding: EdgeInsets.only(
                      left: hPad,
                      right: hPad,
                      bottom: bottomPadding + 16,
                    ),
                    itemCount: filteredInvoices.length,
                    itemBuilder: (ctx, i) => _buildInvoiceCard(
                      filteredInvoices[i],
                      cardPad: cardPad,
                      productFontSize: productFontSize,
                      subFontSize: subFontSize,
                      amountFontSize: amountFontSize,
                      badgeFontSize: badgeFontSize,
                      screenWidth: screenWidth,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required double topPadding,
    required double screenWidth,
    required double hPad,
    required bool isTablet,
  }) {
    final headerContentHeight = isTablet ? 60.0 : screenWidth * 0.145;
    final titleFontSize = isTablet ? 20.0 : screenWidth * 0.048;
    final btnFontSize = isTablet ? 14.0 : screenWidth * 0.033;
    final btnPadH = isTablet ? 16.0 : screenWidth * 0.035;
    final btnPadV = isTablet ? 10.0 : screenWidth * 0.022;
    final iconSize = isTablet ? 22.0 : screenWidth * 0.05;
    final backBtnSize = isTablet ? 36.0 : screenWidth * 0.082;

    return Container(
      color: kTeal,
      // topPadding = status bar height → content starts below it
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox(
        height: headerContentHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Back button ──────────────────────────────
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              SizedBox(width: screenWidth * 0.03),

              // ── Title ────────────────────────────────────
              Expanded(
                child: Text(
                  'All Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // ── Date Picker Button ────────────────────────
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: kTeal,
                            onPrimary: Colors.white,
                            onSurface: kTextPrimary,
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
                    _fetchInvoices();
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 8 : screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.white, size: iconSize * 0.8),
                      SizedBox(width: 4),
                      Text(
                        "${_selectedDate.day}/${_selectedDate.month}",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: btnFontSize * 0.9),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: screenWidth * 0.02),

              // ── + NEW button ─────────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DirectInvoiceGenerateInfoScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: btnPadH,
                    vertical: btnPadV,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+ NEW',
                    style: TextStyle(
                      color: kTeal,
                      fontSize: btnFontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────
  Widget _buildSearchBar({
    required double hPad,
    required double screenWidth,
  }) {
    final searchFontSize = screenWidth > 600 ? 14.0 : screenWidth * 0.034;
    final iconSize = screenWidth > 600 ? 20.0 : screenWidth * 0.045;
    final vertPad = screenWidth > 600 ? 14.0 : screenWidth * 0.03;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: TextStyle(fontSize: searchFontSize, color: kTextPrimary),
          decoration: InputDecoration(
            hintText: 'Search Invoice or Customer...',
            hintStyle:
            TextStyle(fontSize: searchFontSize, color: kTextSecondary),
            prefixIcon:
            Icon(Icons.search_rounded, color: kTeal, size: iconSize),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.clear,
                  size: iconSize * 0.85, color: kTextSecondary),
              onPressed: () => setState(() => _searchQuery = ''),
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: vertPad),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kTeal, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  // ── Filter Tabs ─────────────────────────────────────────
  Widget _buildFilterTabs({
    required double hPad,
    required double fontSize,
    required double screenWidth,
  }) {
    final tabPadH = screenWidth > 600 ? 20.0 : screenWidth * 0.045;
    final tabPadV = screenWidth > 600 ? 10.0 : screenWidth * 0.022;
    final radius = screenWidth > 600 ? 22.0 : screenWidth * 0.05;

    return SizedBox(
      height: screenWidth > 600 ? 44 : screenWidth * 0.1,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: _filters.length,
        itemBuilder: (ctx, i) {
          final isActive = _selectedFilterIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = i),
            child: Container(
              margin: EdgeInsets.only(right: screenWidth * 0.025),
              padding: EdgeInsets.symmetric(
                horizontal: tabPadH,
                vertical: tabPadV,
              ),
              decoration: BoxDecoration(
                color: isActive ? kTeal : Color(0xffA3E6E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? kTeal : kBorder,
                ),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: kTeal.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
                    : [],
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : kTextSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Invoice Card ────────────────────────────────────────
  Widget _buildInvoiceCard(
      InvoiceItem item, {
        required double cardPad,
        required double productFontSize,
        required double subFontSize,
        required double amountFontSize,
        required double badgeFontSize,
        required double screenWidth,
      }) {
    final statusLabel = _statusLabel(item.status);
    final statusColor = _statusColor(item.status);
    final cardRadius = screenWidth > 600 ? 12.0 : screenWidth * 0.028;
    final marginB = screenWidth > 600 ? 12.0 : screenWidth * 0.025;
    final badgeFontSz = screenWidth > 600 ? 12.0 : screenWidth * 0.028;
    final badgeWidth = screenWidth > 600 ? 80.0 : screenWidth * 0.19;
    final badgeHeight = screenWidth > 600 ? 28.0 : screenWidth * 0.065;
    final badgeRadius = screenWidth > 600 ? 12.0 : screenWidth * 0.03;

    return Container(
      margin: EdgeInsets.only(bottom: marginB),
      decoration: BoxDecoration(
        color: Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: TextStyle(
                      fontSize: productFontSize,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  item.amount,
                  style: TextStyle(
                    fontSize: amountFontSize,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff005BBF),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.015),

            SizedBox(height: screenWidth * 0.015),
            Row(
              children: [
                Text(
                  item.date,
                  style: TextStyle(
                    fontSize: subFontSize,
                    color: kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    item.invoiceNo,
                    style: TextStyle(
                      fontSize: subFontSize,
                      color: kTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: badgeWidth,
                  height: badgeHeight,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(badgeRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: badgeFontSz,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────
  Widget _buildEmptyState(double screenWidth) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: screenWidth * 0.15,
              color: kTextSecondary.withOpacity(0.35)),
          SizedBox(height: screenWidth * 0.03),
          Text('No invoices found',
              style: TextStyle(
                  fontSize: screenWidth * 0.038, color: kTextSecondary)),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────
  String _statusLabel(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.draft:
        return 'Draft';
    }
  }

  Color _statusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return kPaidBg;
      case InvoiceStatus.pending:
        return kPendingBg;
      case InvoiceStatus.draft:
        return kDraftBg;
    }
  }
}
