import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF26A69A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: 'assets/icons/home.png',
                label: 'Home',
                index: 0,
                screenWidth: screenWidth,
              ),
              _buildNavItem(
                icon: 'assets/icons/follows.png',
                label: 'Follows',
                index: 1,
                screenWidth: screenWidth,
              ),
              _buildNavItem(
                icon: 'assets/icons/meetings.png',
                label: 'Meeting',
                index: 2,
                screenWidth: screenWidth,
              ),
              _buildNavItem(
                icon: 'assets/icons/deals.png',
                label: 'Deals',
                index: 3,
                screenWidth: screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String label,
    required int index,
    required double screenWidth,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
              width: screenWidth * 0.06,
              height: screenWidth * 0.06,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
