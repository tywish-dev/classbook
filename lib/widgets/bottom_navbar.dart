import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants.dart';

class BookNexusBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // Define a fixed height constant for the navigation bar
  static const double height = 72.0;

  const BookNexusBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.darkGrey, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Ana Sayfa', 'assets/icons/home_icon.svg'),
          _buildNavItem(1, 'Keşfet', 'assets/icons/explore_icon.svg'),
          _buildNavItem(2, 'Kütüphane', 'assets/icons/library_icon.svg'),
          _buildNavItem(3, 'Liderlik', Icons.emoji_events_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, dynamic icon) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is String
                ? SvgPicture.asset(
                  icon,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.primaryGreen : AppColors.textGrey,
                    BlendMode.srcIn,
                  ),
                )
                : Icon(
                  icon as IconData,
                  size: 20,
                  color:
                      isSelected ? AppColors.primaryGreen : AppColors.textGrey,
                ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primaryGreen : AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simpler version for compatibility with existing code
class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onTap;

  const BottomNavbar({super.key, required this.selectedIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BookNexusBottomNavBar(
      currentIndex: selectedIndex,
      onTap: onTap ?? ((_) {}),
    );
  }
}
