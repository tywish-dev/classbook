import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/custom_text_field.dart';
import 'genre_preferences_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _termsAccepted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleTermsAccepted() {
    setState(() {
      _termsAccepted = !_termsAccepted;
    });
  }

  void _handleSignup() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate inputs
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Lütfen tüm alanları doldurun';
      });
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() {
        _errorMessage = 'Şifre en az 8 karakter olmalıdır';
      });
      return;
    }

    if (!_termsAccepted) {
      setState(() {
        _errorMessage =
            'Kullanım Koşulları ve Gizlilik Politikasını kabul etmeniz gerekiyor';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Navigate to genre preferences screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GenrePreferencesScreen()),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                'Kayıt Ol',
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
                  // Info text
                  Text(
                    "Hesabınız yok gibi görünüyor.\nSizin için yeni bir hesap oluşturalım.",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Name field
                  CustomTextField(hintText: 'Ad', controller: _nameController),

                  const SizedBox(height: 16),

                  // Email field
                  CustomTextField(
                    hintText: 'E-posta',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    hintText: 'Şifre',
                    controller: _passwordController,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: _togglePasswordVisibility,
                  ),

                  const SizedBox(height: 16),

                  // Terms and conditions
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleTermsAccepted,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                _termsAccepted
                                    ? AppColors.primaryGreen
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  _termsAccepted
                                      ? AppColors.primaryGreen
                                      : AppColors.textGrey,
                              width: 1,
                            ),
                          ),
                          child:
                              _termsAccepted
                                  ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: AppColors.darkGrey,
                                  )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hesap Oluştur butonunu seçerek, Kullanım Koşulları ve Gizlilik Politikasını kabul etmiş olursunuz',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: AppTextStyles.caption.copyWith(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Create account button
                  AuthButton(
                    text: 'Hesap Oluştur',
                    onPressed: _handleSignup,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Login link
                  GestureDetector(
                    onTap: _navigateToLogin,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textWhite,
                        ),
                        children: [
                          const TextSpan(text: 'Zaten hesabınız var mı? '),
                          TextSpan(
                            text: 'Giriş Yap',
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
