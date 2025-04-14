import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/custom_text_field.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _handleResetPassword() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate inputs
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen her iki şifre alanını doldurun';
      });
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() {
        _errorMessage = 'Şifre en az 8 karakter olmalıdır';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Şifreler eşleşmiyor';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(_passwordController.text);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Show success message and navigate back to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre yenileme işlemi başarılı! Lütfen yeni şifrenizle giriş yapın.',
          ),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      // Navigate back to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: null, // No app bar needed for this screen
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
              child: Text(
                'Şifre Belirle',
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
                  // Success icon and message
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryGreen.withOpacity(0.2),
                        ),
                        child: Icon(
                          Icons.check,
                          color: AppColors.primaryGreen,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Kod doğrulandı',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // New password field
                  CustomTextField(
                    hintText: 'Yeni şifre girin',
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    hintText: 'Yeni şifreyi tekrar girin',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: _toggleConfirmPasswordVisibility,
                  ),

                  const SizedBox(height: 8),

                  // Min length requirement
                  Text(
                    'En az 8 karakter',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.caption.copyWith(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Reset button
                  AuthButton(
                    text: 'Şifreyi Belirle',
                    onPressed: _handleResetPassword,
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
