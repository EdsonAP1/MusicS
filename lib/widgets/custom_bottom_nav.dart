import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';

/// Custom bottom navigation bar with glassmorphism effect
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.accentColor = AppColors.primaryPurple,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkNavBar.withValues(alpha: 0.95)
            : AppColors.lightNavBar.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: '',
            isActive: currentIndex == 0,
            accentColor: accentColor,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.favorite_rounded,
            label: '',
            isActive: currentIndex == 1,
            accentColor: accentColor,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: '',
            isActive: currentIndex == 2,
            accentColor: accentColor,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: '',
            isActive: currentIndex == 3,
            accentColor: accentColor,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isActive ? accentColor : inactiveColor,
                size: isActive ? 26 : 24,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 4 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
