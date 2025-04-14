import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/custom_text_field.dart';
import 'reset_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleVerify() async {
    if (_codeController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyResetCode(_codeController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to reset password screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
      );
    }
  }

  void _handleResend() async {
    setState(() {
      _isResending = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.sendPasswordResetEmail(widget.email);

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: _navigateBack,
        ),
        title: Text(
          'Giriş Yap',
          style: AppTextStyles.heading2.copyWith(fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Text(
                'Kodu Doğrula',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Main content container
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instruction text
                  Text(
                    "E-posta adresinize bir doğrulama kodu gönderildi.",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Code field
                  CustomTextField(
                    hintText: 'Kodu Girin',
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _handleVerify(),
                  ),

                  const SizedBox(height: 24),

                  // Verify button
                  AuthButton(
                    text: 'Doğrula',
                    onPressed: _handleVerify,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Resend code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kod almadınız mı?",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isResending ? null : _handleResend,
                        child: Row(
                          children: [
                            if (_isResending)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryGreen,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.refresh,
                                color: AppColors.primaryGreen,
                                size: 16,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              'Yeniden Gönder',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
