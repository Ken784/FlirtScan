import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/icons/app_icon_widgets.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.s84,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadow.navTop,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: Container()),
          _NavItem(
            isHome: true,
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          Expanded(child: Container()),
          _NavItem(
            isHome: false,
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.isHome,
    required this.isActive,
    required this.onTap,
  });

  final bool isHome;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: isHome
              ? AppIconWidgets.home(
                  size: 32,
                  selected: isActive,
                )
              : AppIconWidgets.inbox(
                  size: 32,
                  selected: isActive,
                ),
        ),
      ),
    );
  }
}






