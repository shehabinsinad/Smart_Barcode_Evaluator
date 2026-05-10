import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/utils/validation_helper.dart';
import 'package:food_scanner_app/components/animated_button.dart';
import 'package:food_scanner_app/components/custom_card.dart';
import 'package:food_scanner_app/components/custom_snackbar.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';

class SignupCredentialsScreen extends StatefulWidget {
  const SignupCredentialsScreen({super.key});

  @override
  SignupCredentialsScreenState createState() => SignupCredentialsScreenState();
}

class SignupCredentialsScreenState extends State<SignupCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _next() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _authService.signUpWithEmail(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      Navigator.pushReplacementNamed(context, '/signup_preferences');
    } else {
      CustomSnackbar.error(context, message: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Create Account', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.pushReplacementNamed(context, '/landing'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 44,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: AppTheme.spaceMD),

                  Text(
                    'Create Account',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Enter your credentials to get started',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppTheme.spaceLG),

                  // Card with form fields
                  CustomCard(
                    glassmorphic: true,
                    color: Colors.white.withValues(alpha: 0.1),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Field
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primary,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 2,
                                ),
                              ),
                              errorStyle: const TextStyle(
                                color: Color(0xFFFFB3B3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            validator: ValidationHelper.validateEmail,
                          ),

                          const SizedBox(height: AppTheme.spaceSM),

                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white70,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                  width: 2,
                                ),
                              ),
                              errorStyle: const TextStyle(
                                color: Color(0xFFFFB3B3),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            validator: ValidationHelper.validatePassword,
                          ),

                          const SizedBox(height: AppTheme.spaceLG),

                          // Next Button
                          AnimatedButton(
                            text: 'Next',
                            icon: Icons.arrow_forward_rounded,
                            gradient: AppColors.primaryGradient,
                            isLoading: _isLoading,
                            onPressed: _next,
                          ),

                          const SizedBox(height: AppTheme.spaceSM),

                          // Login Link
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                                children: const [
                                  TextSpan(text: 'Already have an account? '),
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: AppColors.primary,
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
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
