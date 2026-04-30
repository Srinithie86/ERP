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
    final iconSize = width * 0.056;
    final textSize = width * 0.029;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        color: AppColors.primary,
        child: SizedBox(
          height: 58,
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
                        size: iconSize.clamp(18.0, 22.0),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: textSize.clamp(10.0, 12.0),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: isSelected ? width * 0.08 : 0,
                        height: 2.5,
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
