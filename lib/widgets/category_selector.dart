import 'package:flutter/material.dart';
import '../constants.dart'; // Assuming constants define AppColors etc.

class CategorySelector extends StatefulWidget {
  final List<String> categories;
  final Function(String) onCategorySelected;
  final String initialCategory;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.onCategorySelected,
    required this.initialCategory,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    // Determine default colors based on theme
    final Color defaultTextColor = isDark ? Colors.grey[300]! : Colors.black87;
    final Color defaultPrimaryColor = Theme.of(context).colorScheme.primary;
    final Color defaultCardColor =
        isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return SizedBox(
      height: 40, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = category == _selectedCategory;
          // Use theme colors for consistent appearance
          final Color textColor =
              isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge?.color ??
                      defaultTextColor;
          final Color bgColor =
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface;
          final TextStyle? textStyle =
              Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: textColor) ??
              TextStyle(color: textColor);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              widget.onCategorySelected(category);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(20.0), // Pill shape
              ),
              child: Text(category, style: textStyle),
            ),
          );
        },
      ),
    );
  }
}
