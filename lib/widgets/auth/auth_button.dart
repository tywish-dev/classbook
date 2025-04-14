import 'package:flutter/material.dart';
import '../../constants.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isOutlined ? Colors.transparent : AppColors.primaryGreen,
          foregroundColor:
              isOutlined ? AppColors.primaryGreen : AppColors.darkGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side:
                isOutlined
                    ? const BorderSide(color: AppColors.primaryGreen, width: 2)
                    : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          disabledBackgroundColor:
              isOutlined
                  ? Colors.transparent
                  : AppColors.primaryGreen.withOpacity(0.5),
          disabledForegroundColor:
              isOutlined
                  ? AppColors.primaryGreen.withOpacity(0.5)
                  : AppColors.darkGrey.withOpacity(0.7),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined ? AppColors.primaryGreen : AppColors.darkGrey,
                    ),
                  ),
                )
                : Text(
                  text,
                  style: AppTextStyles.button.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}
