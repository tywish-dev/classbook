import 'package:flutter/material.dart';
import '../constants.dart';

class AuthorAvatar extends StatelessWidget {
  final String name;
  final Color avatarColor;
  final bool isSelected;

  const AuthorAvatar({
    super.key,
    required this.name,
    required this.avatarColor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: avatarColor,
            border: Border.all(
              color: isSelected ? AppColors.primaryGreen : AppColors.darkGrey,
              width: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            name,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
