import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({super.key, this.selectedIndex = 0, this.onTap});

  void onItemTapped(BuildContext context, int index) {
    if (index == selectedIndex) { return; }
    if (onTap != null) {
      onTap!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.black12, width: 1.0)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: navItem(context, Icons.dashboard, "Dashboard", 0)),
            Expanded(child: navItem(context, Icons.assignment_add, "PR", 1)),
            Expanded(child: navItem(context, Icons.check_circle, "PR Approvals", 2)),
            Expanded(child: navItem(context, Icons.shopping_cart, "PO", 3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? const Color(0xFF26A69A) : Colors.grey;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onItemTapped(context, index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
