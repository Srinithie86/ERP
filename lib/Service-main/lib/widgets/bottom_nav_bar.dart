import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final navHeight = 65.0 + bottomPadding;
    const iconSize = 24.0;
    const textSize = 11.5;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 65,
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
                        size: iconSize,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: textSize,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: isSelected ? 28 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
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
