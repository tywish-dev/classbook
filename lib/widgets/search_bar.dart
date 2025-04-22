import 'package:flutter/material.dart';
import '../constants.dart'; // Assuming constants.dart defines AppColors and AppTextStyles

class SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String hintText;

  const SearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Search books, authors, genres...',
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final Color iconColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final TextStyle? hintStyle = AppTextStyles.body?.copyWith(
      color: iconColor.withOpacity(0.6),
    );
    final TextStyle? textStyle =
        AppTextStyles.body; // Assuming AppTextStyles.body exists

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: cardColor, // Use determined card color
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: (value) => onSubmitted?.call(),
        style: textStyle, // Use text style from constants or default
        decoration: InputDecoration(
          icon: Icon(
            Icons.search,
            color: iconColor,
          ), // Use determined icon color
          hintText: hintText,
          hintStyle: hintStyle,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
          ), // Adjust padding
        ),
      ),
    );
  }
}
