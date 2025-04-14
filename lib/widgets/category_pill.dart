import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants.dart';

class CategoryPill extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool isSelected;

  const CategoryPill({
    super.key,
    required this.label,
    required this.iconAsset,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: AppColors.darkGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconAsset,
            height: 16,
            width: 16,
            colorFilter: ColorFilter.mode(
              isSelected ? AppColors.darkGrey : AppColors.textWhite,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: isSelected ? AppColors.darkGrey : AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}
