import 'package:flutter/material.dart';
import '../../constants.dart';

enum SocialProvider { google }

class SocialButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    String buttonText;
    Widget providerIcon;

    switch (provider) {
      case SocialProvider.google:
        buttonText = 'Google ile Giriş Yap';
        providerIcon = Image.asset(
          'assets/icons/google_icon.png',
          width: 24,
          height: 24,
        );
        break;
    }

    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGrey,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          disabledBackgroundColor: AppColors.darkGrey.withOpacity(0.5),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.textWhite,
                    ),
                  ),
                )
                : Row(
                  children: [
                    SizedBox(width: 24, height: 24, child: providerIcon),
                    Expanded(
                      child: Center(
                        child: Text(
                          buttonText,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
