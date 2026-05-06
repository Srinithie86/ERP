import 'package:flutter/material.dart';
import 'package:purchase_erp/create_pr.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:purchase_erp/Request%20Approvals/approvals.dart';
import 'package:purchase_erp/Supplier%20Quotations/quotation_comparison.dart';
import 'package:purchase_erp/widgets/bottom_nav.dart';
import 'package:purchase_erp/purchase_orders/purchase_orders.dart';
import 'package:purchase_erp/purchase_request.dart';
import 'package:purchase_erp/notification.dart';
import 'package:purchase_erp/widgets/profile_details_sheet.dart';
// import 'package:purchase_erp/Profile/profile.dart';
import 'package:purchase_erp/RFQ/request_for_quotation.dart';
import 'package:purchase_erp/Reports/reports_analytics.dart';
import 'package:purchase_erp/GRN/grn_screen.dart';
import 'package:purchase_erp/Supplier%20Quotations/supplier_quotations.dart';
import 'package:purchase_erp/Profile/settings.dart';
import 'package:purchase_erp/Profile/privacy_policy.dart';
import 'package:purchase_erp/QC/qc_inspections_screen.dart';
import 'package:purchase_erp/purchase_invoice.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:purchase_erp/utils/device_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erp_smart/providers/menu_provider.dart';
import 'package:erp_localization/erp_localization.dart';
import 'package:erp_smart/utils/app_navigation.dart';
import 'package:erp_smart/utils/widgets/dynamic_drawer.dart';
import 'package:hrm/main.dart'; // HRM module entry

import 'package:erp_smart/utils/widgets/language_selector.dart';
import 'package:purchase_erp/core/api_config.dart';

class Dashboard extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const Dashboard({
    super.key,
    this.isEmbedded = false,
    this.scaffoldKey,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _purchaseMenus = [];

  String purchaseTotal = "0";
  String prTotal = "0";
  String poTotal = "0";
  String pendingApproval = "0";

  List<FlSpot> analyticsSpots = [];
  List<String> analyticsMonths = [];
  double maxYValue = 5.0;
  bool isLoadingAnalytics = true;

  List<Map<String, dynamic>> orderStatuses = [];
  bool isLoadingStatuses = true;

  @override
  void initState() {
    super.initState();
    _loadMenuData();
    _fetchMenuData(); // Fetch fresh menu data from API
    _fetchDashboardMetrics();
    _fetchPurchaseAnalytics();
    _fetchOrderStatus();
    // Pre-fetch Approvals data to make the screen transition "instant"
    RequestApprovals.preFetch();

    // Ensure MenuProvider has data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().loadFromPrefs();
    });
  }

  Future<void> _fetchMenuData() async {
    // This is now redundant as we use MenuProvider, but we keep it for fresh updates
    try {
      final menuProvider = context.read<MenuProvider>();
      await menuProvider.fetchMenuFromServer();
    } catch (e) {
      debugPrint("Error refreshing menu in dashboard: $e");
    }
  }

  Future<void> _fetchDashboardMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('id') ?? prefs.getString('uid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "4022",
          "cid": cid,
          "device_id": deviceId,
          "uid": uid,
          "ln": ln,
          "lt": lt,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false && data['data'] != null) {
          if (mounted) {
            setState(() {
              final d = data['data'];
              purchaseTotal =
                  _formatCurrencyAmount(d['purchase_total']?.toString() ?? "0");
              prTotal = _formatCount(d['pr_total']?.toString() ?? "0");
              poTotal = _formatCount(d['po_total']?.toString() ?? "0");
              pendingApproval =
                  _formatCount(d['pending_approval']?.toString() ?? "0");
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Dashboard Metrics Error: $e");
    }
  }

  Future<void> _fetchPurchaseAnalytics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('id') ?? prefs.getString('uid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "4040",
          "cid": cid,
          "device_id": deviceId,
          "uid": uid,
          "ln": ln,
          "lt": lt,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false &&
            data['data'] != null &&
            data['data'] is List) {
          final List rawData = data['data'];
          List<FlSpot> spots = [];
          List<String> months = [];
          double maxVal = 0;

          int index = 0;
          for (var item in rawData) {
            if (item['month_name'] != null && item['total_amount'] != null) {
              double amount =
                  double.tryParse(item['total_amount'].toString()) ?? 0;
              // Convert to Lakhs for display (divide by 100,000)
              double amountInLakhs = amount / 100000;
              spots.add(FlSpot(index.toDouble(), amountInLakhs));
              months.add(item['month_name'].toString().substring(0, 3));
              if (amountInLakhs > maxVal) maxVal = amountInLakhs;
              index++;
            }
          }

          if (mounted) {
            setState(() {
              analyticsSpots = spots;
              analyticsMonths = months;
              // Set maxY to slightly above max data point, or at least 5
              maxYValue = maxVal > 0 ? (maxVal * 1.2).ceilToDouble() : 5.0;
              isLoadingAnalytics = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Purchase Analytics Error: $e");
      if (mounted) {
        setState(() {
          isLoadingAnalytics = false;
        });
      }
    }
  }

  Future<void> _fetchOrderStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '';
      final uid = prefs.getString('id') ?? prefs.getString('uid') ?? '';
      final deviceData = await DeviceServices.getAndStoreDeviceInfo();
      final ln = deviceData['ln'] ?? '0.0';
      final lt = deviceData['lt'] ?? '0.0';
      final deviceId = deviceData['device_id'] ?? 'Unknown';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          "type": "4041",
          "cid": cid,
          "device_id": deviceId,
          "uid": uid,
          "ln": ln,
          "lt": lt,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false &&
            data['data'] != null &&
            data['data'] is List) {
          final List rawData = data['data'];

          List<Map<String, dynamic>> processedStatuses = [];
          for (var item in rawData) {
            String name = (item['status_name'] ?? '').toString();
            Color color;
            int priority;

            // Map colors and set order priority (Outermost to Innermost)
            if (name.toLowerCase().contains("rejected")) {
              color = const Color(0xffDE318A); // Pink (Outermost)
              priority = 1;
            } else if (name.toLowerCase().contains("approved") ||
                name.toLowerCase().contains("completed")) {
              color = const Color(0xff26A69A); // Teal (Secondary)
              priority = 2;
            } else if (name.toLowerCase().contains("process")) {
              color = const Color(0xff9139ED); // Purple (Tertiary)
              priority = 3;
            } else if (name.toLowerCase().contains("pending")) {
              color = const Color(0xffD3A422); // Gold (Innermost)
              priority = 4;
            } else {
              color = const Color(0xff2A4FD3); // Default Blue
              priority = 5;
            }

            processedStatuses.add({
              "name": name,
              "count": item['total_count'],
              "percentage": item['percentage'],
              "color": color,
              "priority": priority,
            });
          }

          // Sort by priority to ensure consistent concentric ring order
          processedStatuses
              .sort((a, b) => a['priority'].compareTo(b['priority']));

          if (mounted) {
            setState(() {
              orderStatuses = processedStatuses;
              isLoadingStatuses = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Fetch Order Status Error: $e");
      if (mounted) {
        setState(() {
          isLoadingStatuses = false;
        });
      }
    }
  }

  String _formatCurrencyAmount(String value) {
    double amt = double.tryParse(value) ?? 0;
    if (amt >= 10000000) {
      return "${(amt / 10000000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}Cr";
    } else if (amt >= 100000) {
      return "${(amt / 100000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}L";
    } else if (amt >= 1000) {
      return "${(amt / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k";
    } else {
      return amt.toStringAsFixed(0);
    }
  }

  String _formatCount(String value) {
    double amt = double.tryParse(value) ?? 0;
    if (amt >= 1000) {
      return "${(amt / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k";
    } else {
      return amt.toStringAsFixed(0);
    }
  }

  Future<void> _loadMenuData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('user_menu_data');
      if (saved != null) {
        final decoded = json.decode(saved);
        Map<String, dynamic> menuData = {};

        // Handle both wrapped { "menu": { ... } } and direct { "PURCHASE": [...] }
        if (decoded is Map && decoded.containsKey('menu')) {
          menuData = Map<String, dynamic>.from(decoded['menu']);
        } else if (decoded is Map) {
          menuData = Map<String, dynamic>.from(decoded);
        }

        String? purKey;
        for (final key in menuData.keys) {
          if (key.trim().toUpperCase() == "PURCHASE") purKey = key;
        }
        if (purKey != null && menuData[purKey] is List) {
          if (mounted) {
            setState(() {
              _purchaseMenus =
                  List<Map<String, dynamic>>.from(menuData[purKey]);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Purchase Dashboard => Load Error: $e");
    }
  }

  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 1:
        return PurchaseRequestScreen(isEmbedded: widget.isEmbedded);
      case 2:
        return RequestApprovals(isEmbedded: widget.isEmbedded);
      case 3:
        return PurchaseOrdersScreen(isEmbedded: widget.isEmbedded);
      case 4:
        return const QCInspectionsScreen();
      case 0:
      default:
        return _buildDashboardBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return PopScope(
        canPop: _currentIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;
            });
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _currentIndex != 0
              ? null
              : AppBar(
                  backgroundColor: const Color(0xff26A69A),
                  elevation: 0,
                  centerTitle: false,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  title: const Text(
                    "Purchase Management",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  actions: const [],
                ),
          drawer: const DynamicDrawer(moduleName: "PURCHASE"),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          body: _getCurrentScreen(),
        ));
  }

  Widget _buildDashboardBody() {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),

          /// ROW 1 CARDS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: gradientCard(
                    "Total Purchase",
                    "₹ $purchaseTotal",
                    "",
                    const [Color(0xffF70E37), Color(0xffFF869B)],
                    Icons.receipt,
                  ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: gradientCard(
                      "Pending Approvals",
                      pendingApproval,
                      "",
                      const [
                        Color(0xff3A00CA),
                        Color(0xff8E60FF),
                      ],
                      Icons.access_time_filled),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// TOTAL PR + TOTAL PO
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: gradientCard(
                      "Total PR",
                      prTotal,
                      "",
                      const [
                        Color(0xff018477),
                        Color(0xff15F3DD),
                      ],
                      Icons.campaign),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: gradientCard(
                      "Total PO",
                      poTotal,
                      "",
                      const [
                        Color(0xffA8076A),
                        Color(0xffFF7CCD),
                      ],
                      Icons.list_alt),
                ),
              ],
            ),
          ),

          SizedBox(height: height * 0.02),

          /// QUICK ACTIONS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Dynamically choose column count based on width to prevent overflow
                      final cols = constraints.maxWidth > 350 ? 4 : 3;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 8,
                        childAspectRatio: cols == 4 ? 0.72 : 0.85,
                        children:
                            _buildDynamicQuickActions(context, "PURCHASE"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: height * 0.02),

          /// REPORTS & ANALYTICS BUTTON
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsAnalyticsScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xff26A69A),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Reports & Analytics",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: height * 0.03),

          /// ANALYTICS CARD
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Purchase Analytics",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffF0F0FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Text(
                              "This Month",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B4EE0),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: Color(0xFF6B4EE0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  isLoadingAnalytics
                      ? const SizedBox(
                          height: 190,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF26A69A))),
                        )
                      : analyticsSpots.isEmpty
                          ? const SizedBox(
                              height: 190,
                              child: Center(
                                  child: Text("No analytics data available")),
                            )
                          : SizedBox(
                              height: 190,
                              child: BarChart(
                                BarChartData(
                                  maxY: maxYValue,
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (group) =>
                                          const Color(0xff2D237A),
                                      tooltipBorderRadius:
                                          BorderRadius.circular(8),
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          "₹${rod.toY.toStringAsFixed(2)}L",
                                          const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          int idx = value.toInt();
                                          if (idx >= 0 &&
                                              idx < analyticsMonths.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                analyticsMonths[idx],
                                                style: GoogleFonts.outfit(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: const Color(
                                                        0xFF6B4EE0)),
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                        reservedSize: 28,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 32,
                                        interval: (maxYValue / 3)
                                            .clamp(0.1, double.infinity),
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value == 0
                                                ? "0"
                                                : "${value.toStringAsFixed(1)}L",
                                            style: const TextStyle(
                                                color: Color(0xff9E9E9E),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: maxYValue / 4,
                                    getDrawingHorizontalLine: (value) => FlLine(
                                        color: Colors.grey.withOpacity(0.1),
                                        strokeWidth: 1,
                                        dashArray: [5, 5]),
                                  ),
                                  barGroups: List.generate(
                                      analyticsSpots.length, (index) {
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: analyticsSpots[index].y,
                                          color: const Color(0xFF6B4EE0),
                                          width: 16,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(4)),
                                          backDrawRodData:
                                              BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxYValue,
                                            color: const Color(0xFF6B4EE0)
                                                .withOpacity(0.05),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ),

          SizedBox(height: height * 0.03),

          /// ORDER STATUS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Status",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  isLoadingStatuses
                      ? const SizedBox(
                          height: 180,
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF26A69A))),
                        )
                      : orderStatuses.isEmpty
                          ? const SizedBox(
                              height: 180,
                              child: Center(child: Text("No status data")),
                            )
                          : SizedBox(
                              height: 180,
                              child: Stack(
                                children: [
                                  // Concentric Circles
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: width * 0.45,
                                    child: Center(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: List.generate(
                                            orderStatuses.length, (index) {
                                          double size = 140 - (index * 35.0);
                                          if (size < 40) size = 40;

                                          return Container(
                                            width: size,
                                            height: size,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: orderStatuses[index]
                                                  ['color'],
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                          );
                                        }), // No reverse - largest first (bottom), smallest last (top)
                                      ),
                                    ),
                                  ),

                                  // Indicator Lines and Labels (Static-like dynamic layout)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    width: width * 0.45,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: List.generate(
                                          orderStatuses.length, (idx) {
                                        final status = orderStatuses[idx];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6.0),
                                          child: Row(
                                            children: [
                                              // Minimalist line representation
                                              Container(
                                                width: 25 -
                                                    (idx * 4.0).clamp(0, 15),
                                                height: 1.5,
                                                color: status['color'],
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  "${status['name']} (${status['count']})",
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: status['color'],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ],
              ),
            ),
          ),

          SizedBox(height: height * 0.03),
        ],
      ),
    );
  }

  Widget gradientCard(
    String title,
    String value,
    String percent,
    List<Color> colors,
    IconData icon,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final titleFontSize = (cardWidth * 0.11).clamp(12.0, 17.0);
        final valueFontSize = (cardWidth * 0.18).clamp(18.0, 30.0);

        return Container(
          height: 125,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors[0].withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, top: 16.0, bottom: 16.0, right: 46.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Icon Positioning: Top-right if percentage exists, otherwise bottom-right
              Positioned(
                top: percent.isNotEmpty ? 12 : null,
                bottom: percent.isEmpty ? 35 : null,
                right: 8,
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 26, color: Colors.white),
                ),
              ),

              // Percent at bottom-right (only for Total Purchase)
              if (percent.isNotEmpty)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Text(
                    percent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDynamicQuickActions(
      BuildContext context, String moduleName) {
    final menuProvider = context.read<MenuProvider>();
    final subMenus = menuProvider.getSubMenus(moduleName).where((item) {
      final name = (item['name'] ?? '').toString().toUpperCase();
      // Exclude menu items specifically for "Create QC" to satisfy user request
      if (name.contains("CREATE") &&
          (name.contains("QC") || name.contains("INSPECTION"))) {
        return false;
      }
      return true;
    }).toList();

    return subMenus.map((item) {
      final String name = (item['name'] ?? '').toString();
      final String trimmedName = name.trim();

      return ActionItem(
        _getActionIcon(trimmedName),
        trimmedName,
        _getActionGradient(trimmedName),
        onTap: () => AppNavigation.handleNavigation(context, trimmedName,
            moduleContext: "PURCHASE"),
      );
    }).toList();
  }

  IconData _getActionIcon(String name) {
    final String n = name.toUpperCase();
    if (n.contains("PURCHASE REQUEST") || n == "PR") return Icons.add_rounded;
    if (n.contains("QUOTATION")) return Icons.cached_rounded;
    if (n.contains("RFQ")) return Icons.description_rounded;
    if (n.contains("PURCHASE ORDER") || n == "PO")
      return Icons.local_offer_rounded;
    if (n.contains("GRN")) return Icons.add_rounded;
    if (n.contains("QC")) return Icons.cached_rounded;
    if (n.contains("APPROVAL")) return Icons.description_rounded;
    if (n.contains("COMPARISON")) return Icons.local_offer_rounded;
    return AppNavigation.getIcon(name);
  }

  List<Color> _getActionGradient(String name) {
    final String n = name.toUpperCase();
    // Matching the image colors precisely
    if (n.contains("PURCHASE REQUEST") || n == "PR")
      return [const Color(0xFFFF547A), const Color(0xFFFF85A1)];
    if (n.contains("QUOTATION"))
      return [const Color(0xFF6B38FB), const Color(0xFFAB8BFF)];
    if (n.contains("RFQ"))
      return [const Color(0xFF13D3C8), const Color(0xFF4EE8E0)];
    if (n.contains("PURCHASE ORDER") || n == "PO")
      return [const Color(0xFFD81B60), const Color(0xFFFF4081)];
    if (n.contains("GRN"))
      return [const Color(0xFF1B9B4B), const Color(0xFF4CAF50)];
    if (n.contains("QC"))
      return [const Color(0xFF26A69A), const Color(0xFF4DB6AC)];
    if (n.contains("APPROVAL"))
      return [const Color(0xFFD4AF37), const Color(0xFFFFD54F)];
    if (n.contains("COMPARISON"))
      return [const Color(0xFFBF360C), const Color(0xFFFF7043)];
    return [const Color(0xff22A79A), const Color(0xff4DB6AC)];
  }
}

class ActionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const ActionItem(
    this.icon,
    this.text,
    this.gradient, {
    super.key,
    this.onTap,
  });

  String _getShortLabel(String label) {
    final String n = label.toUpperCase();
    if (n.contains("PURCHASE REQUEST") || n == "PR") return "Create PR";
    if (n.contains("PURCHASE ORDER")) return "PO";
    if (n.contains("RFQ")) return "RFQ";
    if (n.contains("QC") || n.contains("INSPECTION")) return "QC/Inspect";
    if (n.contains("GRN")) return "GRN";
    if (n.contains("APPROVAL")) return "PR Approval";
    if (n.contains("COMPARISON")) return "Compare";
    if (n.contains("QUOTATION")) return "SQ";
    if (n.contains("INVOICE")) return "Invoice";
    if (label.length > 10) return label.substring(0, 8) + "..";
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final iconSize = (constraints.maxWidth * 0.75).clamp(45.0, 62.0);
              return Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: iconSize * 0.45),
              );
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _getShortLabel(text),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xff1E293B),
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final String text;
  final Color color;

  const LegendItem(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}