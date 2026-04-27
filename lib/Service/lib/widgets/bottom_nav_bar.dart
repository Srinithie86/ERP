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
    final navHeight = 52.0 + (bottomPadding > 0 ? bottomPadding * 0.6 : 0);
    final iconSize = width * 0.052;
    final textSize = width * 0.026;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding * 0.3 : 2),
        child: SizedBox(
          height: navHeight,
          width: double.infinity,
          child: Row(
          children: List.generate(_items.length, (index) {
            final (icon, activeIcon, label) = _items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? activeIcon : icon,
                      color: Colors.white,
                      size: iconSize.clamp(20.0, 26.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
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
                        color: Colors.white,
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
    ),
  );
}
}
