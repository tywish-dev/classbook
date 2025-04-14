import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../widgets/auth/social_button.dart';
import 'forgot_password_screen.dart';
import 'login_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleContinue() async {
    if (_emailController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    // Navigate to password screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPasswordScreen(email: _emailController.text),
      ),
    );
  }

  void _handleSocialLogin(SocialProvider provider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String providerName;

    switch (provider) {
      case SocialProvider.google:
        providerName = 'google';
        break;
    }

    final success = await authProvider.socialLogin(providerName);
    if (success && mounted) {
      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background image or gradient (not implemented yet)

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
              child: Text(
                'Giriş Yap',
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
                  // Email field
                  CustomTextField(
                    hintText: 'E-posta',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => _handleContinue(),
                  ),

                  const SizedBox(height: 16),

                  // Continue button
                  AuthButton(
                    text: 'Devam Et',
                    onPressed: _handleContinue,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Forgot password
                  GestureDetector(
                    onTap: _navigateToForgotPassword,
                    child: Text(
                      'Şifremi unuttum?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.darkGrey, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Veya',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.darkGrey, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Social logins
                  SocialButton(
                    provider: SocialProvider.google,
                    onPressed: () => _handleSocialLogin(SocialProvider.google),
                  ),

                  const SizedBox(height: 24),

                  // Sign up link
                  GestureDetector(
                    onTap: _navigateToSignUp,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textWhite,
                        ),
                        children: [
                          const TextSpan(text: 'Hesabınız yok mu? '),
                          TextSpan(
                            text: 'Kayıt Ol',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
