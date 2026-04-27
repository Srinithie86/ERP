import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/warehouse_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/common_widgets.dart';
import '../entry/inward_entry_screen.dart';
import 'material_req_view_screen.dart';
import 'stock_view_screen.dart';
import 'reports_screen.dart';
import '../../widgets/dashboard_drawer.dart';

class DashboardScreen extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DashboardScreen({
    super.key,
    this.isEmbedded = false,
    this.scaffoldKey,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedFilter = 'Monthly';
  List<Map<String, dynamic>> _warehouseMenus = [];

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('user_menu_data');
      if (saved != null) {
        final Map<String, dynamic> fullMenu = json.decode(saved);
        String? whKey;
        for (final key in fullMenu.keys) {
          if (key.trim().toUpperCase() == "WAREHOUSE") whKey = key;
        }
        if (whKey != null && fullMenu[whKey] is List) {
          setState(() {
            _warehouseMenus = List<Map<String, dynamic>>.from(fullMenu[whKey]);
          });
        }
      }
    } catch (e) {
      debugPrint("Warehouse Dashboard => Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double multiplier = 1.0;
    if (_selectedFilter == 'Weekly') multiplier = 0.25;
    if (_selectedFilter == 'Yearly') multiplier = 12.0;

    final provider = context.watch<WarehouseProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: widget.isEmbedded ? null : const DashboardDrawer(),
        appBar: AppBar(
          backgroundColor: const Color(0xFF26A69A),
          elevation: 0,
          centerTitle: false,
          leading: widget.isEmbedded
              ? Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                    onPressed: () {
                      if (widget.scaffoldKey?.currentState != null) {
                        widget.scaffoldKey!.currentState!.openDrawer();
                      } else {
                        Scaffold.of(ctx).openDrawer();
                      }
                    },
                  ),
                )
              : Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
        title: const Text(
          'Warehouse',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Text(
                'S',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF26A69A)),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black87),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list, color: Color(0xFF26A69A)),
                      tooltip: 'Filter Dashboard Data',
                      padding: EdgeInsets.zero,
                      onSelected: (val) {
                        setState(() {
                          _selectedFilter = val;
                        });
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'Weekly', child: Text('Weekly')),
                        PopupMenuItem(value: 'Monthly', child: Text('Monthly')),
                        PopupMenuItem(value: 'Yearly', child: Text('Yearly')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _GradientStatCard(
                          title: 'Total Raw Material',
                          value: (provider.totalRawMaterialStock * multiplier).toStringAsFixed(0),
                          percent: _selectedFilter == 'Weekly' ? '+2%' : (_selectedFilter == 'Yearly' ? '+45%' : '+12%'),
                          icon: Icons.category,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5252), Color(0xFFFF8A80)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GradientStatCard(
                          title: 'Pending Indents',
                          value: '${(provider.pendingRequestCount * multiplier).ceil()}',
                          percent: null,
                          icon: Icons.pending_actions,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GradientStatCard(
                          title: 'Total FG Stock',
                          value: (provider.totalFGStock * multiplier).toStringAsFixed(0),
                          percent: null,
                          icon: Icons.inventory_2,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GradientStatCard(
                          title: 'Low Stock Alerts',
                          value: '${(provider.lowStockCount * (multiplier > 1 ? multiplier * 0.5 : 1)).ceil()}',
                          percent: null,
                          icon: Icons.warning_amber_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC2185B), Color(0xFFE91E63)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const SizedBox(height: 20),
                  Builder(
                    builder: (context) {
                      final actions = [
                        _buildConditionalQuickAction(
                          context: context,
                          menus: _warehouseMenus,
                          apiKey: 'Inward Entry',
                          label: 'Inward',
                          icon: Icons.add,
                          gradient: const LinearGradient(colors: [Color(0xFFFF5252), Color(0xFFFF8A80)]),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InwardEntryScreen())),
                        ),
                        _buildConditionalQuickAction(
                          context: context,
                          menus: _warehouseMenus,
                          apiKey: 'Outward Entry',
                          label: 'Outward',
                          icon: Icons.swap_horiz,
                          gradient: const LinearGradient(colors: [Color(0xFF512DA8), Color(0xFF7E57C2)]),
                          onTap: () {},
                        ),
                        _buildConditionalQuickAction(
                          context: context,
                          menus: _warehouseMenus,
                          apiKey: 'Stock View',
                          label: 'Stock View',
                          icon: Icons.inventory_2_rounded,
                          gradient: const LinearGradient(colors: [Color(0xFFC2185B), Color(0xFFE91E63)]),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockViewScreen())),
                        ),
                        _buildConditionalQuickAction(
                          context: context,
                          menus: _warehouseMenus,
                          apiKey: 'Material Requisition',
                          label: 'Req & Issue',
                          icon: Icons.assignment_rounded,
                          gradient: const LinearGradient(colors: [Color(0xFF009688), Color(0xFF4DB6AC)]),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialReqViewScreen())),
                        ),
                        _buildConditionalQuickAction(
                          context: context,
                          menus: _warehouseMenus,
                          apiKey: 'Reports',
                          label: 'Reports',
                          icon: Icons.bar_chart_rounded,
                          gradient: const LinearGradient(colors: [Color(0xFFFFA000), Color(0xFFFFC107)]),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                        ),
                      ].whereType<Widget>().toList();

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: actions.map((a) => Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: a,
                          )).toList(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A69A),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF26A69A).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Reports & Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Inventory Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Text(_selectedFilter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    const Icon(Icons.keyboard_arrow_down, size: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 180,
                            child: _buildChart(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (provider.lowStockCount > 0) ...[
                    const SizedBox(height: 24),
                    const Text('Low Stock Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                    const SizedBox(height: 8),
                    SectionCard(
                      padding: EdgeInsets.zero,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.lowStockItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = provider.lowStockItems[index];
                          return ListTile(
                            title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text('Qty: ${item.quantity} ${item.unit} (Min: ${item.minStock})'),
                            trailing: const Icon(Icons.warning, color: Colors.red, size: 20),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget? _buildConditionalQuickAction({
    required BuildContext context,
    required List<Map<String, dynamic>> menus,
    required String apiKey,
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final exists = menus.any((item) => item['name'].toString().trim().toUpperCase() == apiKey.trim().toUpperCase());
    if (!exists) return null;

    return _QuickActionCircle(
      label: label,
      icon: icon,
      gradient: gradient,
      onTap: onTap,
    );
  }

  Widget _buildChart() {
    List<FlSpot> spots;
    List<String> titles;
    double maxX = 5;
    double maxY = 30;

    if (_selectedFilter == 'Weekly') {
      titles = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      spots = const [FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 3), FlSpot(3, 8), FlSpot(4, 5), FlSpot(5, 7)];
      maxY = 10;
    } else if (_selectedFilter == 'Yearly') {
      titles = ['2020', '2021', '2022', '2023', '2024'];
      maxX = 4;
      spots = const [FlSpot(0, 20), FlSpot(1, 35), FlSpot(2, 45), FlSpot(3, 30), FlSpot(4, 60)];
      maxY = 70;
    } else {
      titles = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
      spots = const [FlSpot(0, 5), FlSpot(1, 15), FlSpot(2, 10), FlSpot(3, 22), FlSpot(4, 14), FlSpot(5, 25)];
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < titles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 10, color: Colors.black54)),
                  );
                }
                return const Text('');
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}k', style: const TextStyle(fontSize: 10, color: Colors.black54));
              },
              reservedSize: 30,
              interval: maxY / 3,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: Colors.black12, style: BorderStyle.solid),
            left: BorderSide.none, right: BorderSide.none, top: BorderSide.none,
          ),
        ),
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF512DA8),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF512DA8).withValues(alpha: 0.3),
                  const Color(0xFF512DA8).withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? percent;
  final IconData icon;
  final Gradient gradient;

  const _GradientStatCard({
    required this.title,
    required this.value,
    this.percent,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (percent != null) ...[
                const SizedBox(width: 4),
                Text(
                  percent!,
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCircle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCircle({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (gradient as LinearGradient).colors.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
