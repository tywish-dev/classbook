import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/custom_text_field.dart';
import '../../screens/home_screen.dart';
import 'forgot_password_screen.dart';

class LoginPasswordScreen extends StatefulWidget {
  final String email;

  const LoginPasswordScreen({super.key, required this.email});

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleLogin() async {
    if (_passwordController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      widget.email,
      _passwordController.text,
      context,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    }
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
                  // User info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.darkGrey,
                        child: Icon(
                          Icons.person,
                          color: AppColors.textGrey,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ahmet Yılmaz',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.email,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.check_circle, color: AppColors.primaryGreen),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Password field
                  CustomTextField(
                    hintText: 'Şifre',
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: _togglePasswordVisibility,
                    onSubmitted: (_) => _handleLogin(),
                  ),

                  const SizedBox(height: 16),

                  // Login button
                  AuthButton(
                    text: 'Devam Et',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 16),

                  // Forgot password link
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
