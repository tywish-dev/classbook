import 'package:flutter/material.dart';
import '../constants.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get unlimited access to books in just',
                style: AppTextStyles.body.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text('\$9.99', style: AppTextStyles.price),
              const SizedBox(height: 4),
              Text('*Terms & conditions apply', style: AppTextStyles.caption),
            ],
          ),
          Positioned(right: 0, bottom: 0, child: _buildBookCovers()),
        ],
      ),
    );
  }

  Widget _buildBookCovers() {
    // Simulating different colored book covers from the design
    return SizedBox(
      height: 100,
      width: 150,
      child: Stack(
        children: [
          for (int i = 0; i < 5; i++)
            Positioned(
              right: i * 20.0,
              child: Transform.rotate(
                angle: (i - 2) * 0.1,
                child: Container(
                  width: 56,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getBookColor(i),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBookColor(int index) {
    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
    ];
    return colors[index % colors.length];
  }
}
