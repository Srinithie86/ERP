import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dashboard.dart';
import 'bom_screen.dart';
import 'planning_jobcard.dart';
import 'material_qc.dart';
import 'joborder_screen.dart';
import 'models.dart';

const _teal = Color(0xFF26A69A);

void main() => runApp(const ManufacturingErpApp());

class ManufacturingErpApp extends StatelessWidget {
  const ManufacturingErpApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Manufacturing ERP',
    theme: AppTheme.theme,
    debugShowCheckedModeBanner: false,
    home: const MainShell(),
  );
}

class _NavItem {
  final String label;
  final IconData icon, activeIcon;
  final Widget screen;
  final bool showInBottomNav;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.screen,
    this.showInBottomNav = true,
  });
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selected = 0;
  bool _sidebarOpen = false;

  late final _items = [
    const _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      screen: DashboardScreen(),
      showInBottomNav: true,
    ),
    const _NavItem(
      label: 'BOM',
      icon: Icons.account_tree_outlined,
      activeIcon: Icons.account_tree,
      screen: BomScreen(),
      showInBottomNav: true,
    ),
    const _NavItem(
      label: 'Job Order',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      screen: JobOrderScreen(),
      showInBottomNav: true,
    ),
    _NavItem(
      label: 'Product Planning',
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note,
      // ✅ Fixed: pass orders from SampleData
      screen: ProductionPlanningScreen(orders: SampleData.jobOrders),
      showInBottomNav: false,
    ),
    const _NavItem(
      label: 'Job Card',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      screen: JobCardScreen(),
      showInBottomNav: true,
    ),
    const _NavItem(
      label: 'Material Request',
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      screen: MaterialRequestScreen(),
      showInBottomNav: false,
    ),
    const _NavItem(
      label: 'Material Issue',
      icon: Icons.output_outlined,
      activeIcon: Icons.output,
      screen: MaterialRequestScreen(),
      showInBottomNav: false,
    ),
    const _NavItem(
      label: 'Assembly',
      icon: Icons.precision_manufacturing_outlined,
      activeIcon: Icons.precision_manufacturing,
      screen: QcScreen(),
      showInBottomNav: false,
    ),
    const _NavItem(
      label: 'Finished Goods',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      screen: QcScreen(),
      showInBottomNav: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final bottomPad = mq.padding.bottom;
    final isWide = sw > 720;

    final fontTitle = sw * 0.045;
    final iconSize = sw * 0.055;
    final navH = sh * 0.075 + bottomPad;
    final fontNav = sw * 0.026;
    final appBarH = sh * 0.07;
    final notifSize = sw * 0.06;
    final dotSize = sw * 0.02;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarH),
        child: AppBar(
          backgroundColor: _teal,
          elevation: 0,
          leading: isWide
              ? null
              : IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: iconSize),
            onPressed: () =>
                setState(() => _sidebarOpen = !_sidebarOpen),
          ),
          title: Row(children: [
            Text(
              'Manufacturing',
              style: TextStyle(
                fontSize: fontTitle,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ]),
          actions: [
            Stack(children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: Colors.white, size: notifSize),
                onPressed: () {},
              ),
              Positioned(
                top: sh * 0.012,
                right: sw * 0.025,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
            ]),
            SizedBox(width: sw * 0.03),
          ],
        ),
      ),
      body: isWide ? _wideLayout() : _narrowLayout(),
      bottomNavigationBar:
      isWide ? null : _bottomNav(sw, sh, bottomPad, navH, fontNav),
    );
  }

  Widget _wideLayout() => Row(children: [
    _Sidebar(
        items: _items,
        selected: _selected,
        onSelect: (i) => setState(() => _selected = i)),
    Expanded(child: _items[_selected].screen),
  ]);

  Widget _narrowLayout() => Stack(children: [
    _items[_selected].screen,
    if (_sidebarOpen)
      GestureDetector(
        onTap: () => setState(() => _sidebarOpen = false),
        child: Container(color: Colors.black54),
      ),
    if (_sidebarOpen)
      Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        width: 260,
        child: _Sidebar(
            items: _items,
            selected: _selected,
            onSelect: (i) {
              setState(() {
                _selected = i;
                _sidebarOpen = false;
              });
            }),
      ),
  ]);

  Widget _bottomNav(
      double sw, double sh, double bottomPad, double navH, double fontNav) {
    final bottomItems = _items
        .asMap()
        .entries
        .where((e) => e.value.showInBottomNav)
        .toList();
    return Container(
      height: navH,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: bottomItems
            .map((e) => _BottomNavItem(
          icon: e.value.icon,
          activeIcon: e.value.activeIcon,
          label: e.value.label,
          selected: _selected == e.key,
          onTap: () => setState(() => _selected = e.key),
          sw: sw,
          fontNav: fontNav,
        ))
            .toList(),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  const _Sidebar(
      {required this.items,
        required this.selected,
        required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      width: sw * 0.65 > 260 ? 260 : sw * 0.65,
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        ...items.asMap().entries.map((e) => _SidebarItem(
          icon: e.value.icon,
          activeIcon: e.value.activeIcon,
          label: e.value.label,
          selected: selected == e.key,
          onTap: () => onSelect(e.key),
        )),
        const Spacer(),
      ]),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: sw * 0.025, vertical: sw * 0.005),
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.03, vertical: sw * 0.028),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE0F2F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border:
          selected ? Border.all(color: _teal.withValues(alpha: 0.3)) : null,
        ),
        child: Row(children: [
          Icon(selected ? activeIcon : icon,
              size: sw * 0.045,
              color: selected ? _teal : Colors.grey),
          SizedBox(width: sw * 0.03),
          Text(label,
              style: TextStyle(
                fontSize: sw * 0.035,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? _teal : Colors.grey[700],
              )),
          if (selected) ...[
            const Spacer(),
            Container(
              width: sw * 0.015,
              height: sw * 0.015,
              decoration: const BoxDecoration(
                  color: _teal, shape: BoxShape.circle),
            ),
          ],
        ]),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double sw, fontNav;
  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.sw,
    required this.fontNav,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        selected ? activeIcon : icon,
        size: sw * 0.058,
        color: selected ? _teal : AppColors.textHint,
      ),
      SizedBox(height: sw * 0.008),
      Text(label,
          style: TextStyle(
            fontSize: fontNav,
            fontWeight:
            selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? _teal : AppColors.textHint,
          )),
    ]),
  );
}