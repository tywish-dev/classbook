import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final Color coverColor;
  final String listenTime;
  final String readTime;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.coverColor,
    required this.listenTime,
    required this.readTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book Cover
        Container(
          width: 140,
          height: 200,
          decoration: BoxDecoration(
            color: coverColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Book Title
        SizedBox(
          width: 140,
          child: Text(
            title,
            style: AppTextStyles.subtitle2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),

        // Author
        Text(
          author,
          style: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
        ),
        const SizedBox(height: 8),

        // Listen and Read Times
        Row(
          children: [
            // Listen Time
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/headphone_icon.svg',
                  height: 12,
                  width: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textGrey,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  listenTime,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Read Time
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/read_icon.svg',
                  height: 12,
                  width: 12,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textGrey,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  readTime,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
