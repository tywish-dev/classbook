import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/custom_text_field.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_emailController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendPasswordResetEmail(
      _emailController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => VerificationCodeScreen(email: _emailController.text),
        ),
      );
    }
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
                'Şifre Kurtarma',
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
                    "Şifrenizi mi unuttunuz? Endişelenmeyin, mevcut şifrenizi sıfırlamak için e-posta adresinizi girin.",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Email field
                  CustomTextField(
                    hintText: 'E-posta',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _handleSubmit(),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  AuthButton(
                    text: 'Gönder',
                    onPressed: _handleSubmit,
                    isLoading: _isLoading,
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
