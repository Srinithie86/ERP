import 'package:flutter/material.dart';

import '../core/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.work_outline_rounded, Icons.work_rounded, 'Jobs'),
    (Icons.build_outlined, Icons.build_rounded, 'Spares'),
    (Icons.local_shipping_outlined, Icons.local_shipping_rounded, 'Dispatch'),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final bottomPadding = media.padding.bottom;
    final navHeight = 66.0 + bottomPadding;
    final iconSize = width * 0.06;
    final textSize = width * 0.03;

    return Container(
      width: double.infinity,
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
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 8),
      child: SizedBox(
        height: navHeight,
        width: double.infinity,
        child: Row(
          children: List.generate(_items.length, (index) {
            final (icon, activeIcon, label) = _items[index];
            final isSelected = currentIndex == index;
            final activeColor = AppColors.primary;
            final inactiveColor = Colors.grey;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      color: isSelected ? activeColor : inactiveColor,
                      size: iconSize.clamp(20.0, 26.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? activeColor : inactiveColor,
                        fontSize: textSize.clamp(11.0, 13.0),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: isSelected ? width * 0.1 : 0,
                      height: 3,
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
