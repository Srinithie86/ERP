import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';

// Module Screens
import '../modules/dashboard/dashboard_screen.dart';
import '../modules/formula/formula_screen.dart';
import '../modules/production_order/production_order_screen.dart';
import '../modules/job_card/job_card_screen.dart';
import '../modules/material_request/material_request_screen.dart';
import '../modules/production/production_screen.dart';
import '../modules/quality/pages/quality_list_screen.dart';

const _teal = Color(0xFF26A69A);

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<_NavItem> _items = [
    const _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      screen: DashboardScreen(),
      showInBottomNav: true,
    ),
    const _NavItem(
      label: 'Formula',
      icon: Icons.account_tree_outlined,
      activeIcon: Icons.account_tree,
      screen: FormulaScreen(),
      showInBottomNav: true,
    ),
    const _NavItem(
      label: 'Production Order',
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      screen: ProductionOrderScreen(),
      showInBottomNav: true,
    ),
    const _NavItem(
      label: 'Job Card',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment,
      screen: JobCardScreen(),
      showInBottomNav: true,
    ),
    const _NavItem(
      label: 'Material Intent',
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      screen: MaterialRequestScreen(),
      showInBottomNav: false,
    ),
    const _NavItem(
      label: 'Productions',
      icon: Icons.output_outlined,
      activeIcon: Icons.output,
      screen: ProductionEntryScreen(),
      showInBottomNav: false,
    ),
    const _NavItem(
      label: 'Quality',
      icon: Icons.precision_manufacturing_outlined,
      activeIcon: Icons.precision_manufacturing,
      screen: QualityListScreen(),
      showInBottomNav: false,
    ),
    const _NavItem(
      label: 'Finished Goods',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      screen: QualityListScreen(),
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

    final currentTitle = _items[_selected].label;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isWide
          ? null
          : _Sidebar(
        items: _items,
        selected: _selected,
        onClose: () => Navigator.pop(context),
        onSelect: (i) {
          setState(() => _selected = i);
          Navigator.pop(context);
        },
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarH),
        child: AppBar(
          backgroundColor: _teal,
          elevation: 0,
          surfaceTintColor: _teal,
          leading: isWide
              ? null
              : IconButton(
            icon: Icon(Icons.menu, color: Colors.white, size: iconSize),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            currentTitle,
            style: TextStyle(
              fontSize: fontTitle,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        //  // actions: [
        //     Stack(children: [
        //       IconButton(
        //         icon: Icon(Icons.notifications_outlined,
        //             color: Colors.white, size: notifSize),
        //         onPressed: () {},
        //       ),
        //       Positioned(
        //         top: sh * 0.012,
        //         right: sw * 0.025,
        //         child: Container(
        //           width: dotSize,
        //           height: dotSize,
        //           decoration: const BoxDecoration(
        //               color: Colors.orange, shape: BoxShape.circle),
        //         ),
        //       ),
        //     ]),
        //     SizedBox(width: sw * 0.03),
        //   ],
       
        ),
      ),
      body: isWide ? _wideLayout() : _items[_selected].screen,
      bottomNavigationBar:
      isWide ? null : _bottomNav(sw, sh, bottomPad, navH, fontNav),
    );
  }

  Widget _wideLayout() => Row(children: [
    _Sidebar(
        items: _items,
        selected: _selected,
        onClose: () {},
        onSelect: (i) => setState(() => _selected = i)),
    Expanded(child: _items[_selected].screen),
  ]);

  Widget _narrowLayout() {
    return _items[_selected].screen;
  }

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
              color: Colors.black.withOpacity(0.06),
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
  final VoidCallback onClose;
  const _Sidebar({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return Container(
      width: sw * 0.85 > 320 ? 320 : sw * 0.85,
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: sh * 0.12,
          padding: EdgeInsets.only(left: sw * 0.05, right: sw * 0.03, top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            color: _teal,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manufacturing',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sw * 0.055,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: onClose,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: items.asMap().entries.map((e) => _SidebarItem(
              icon: e.value.icon,
              activeIcon: e.value.activeIcon,
              label: e.value.label,
              selected: selected == e.key,
              onTap: () => onSelect(e.key),
            )).toList(),
          ),
        ),
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: sw * 0.05, vertical: sw * 0.04),
        child: Row(children: [
          Icon(selected ? activeIcon : icon,
              size: sw * 0.06,
              color: _teal),
          SizedBox(width: sw * 0.05),
          Text(label,
              style: TextStyle(
                fontSize: sw * 0.042,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.black87,
              )),
          if (selected) ...[
            const Spacer(),
            Container(
              width: sw * 0.015,
              height: sw * 0.015,
              decoration:
              const BoxDecoration(color: _teal, shape: BoxShape.circle),
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
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? _teal : AppColors.textHint,
          )),
    ]),
  );
}
