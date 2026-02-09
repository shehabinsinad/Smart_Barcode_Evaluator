import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/components/custom_card.dart';
import 'package:food_scanner_app/components/animated_button.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import 'package:food_scanner_app/components/custom_snackbar.dart';
import 'package:food_scanner_app/utils/validation_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      // Shake animation on validation error
      _shakeController.forward(from: 0);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      String? result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
      if (result == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
          CustomSnackbar.success(context, message: 'Welcome back!');
        }
      } else {
        if (mounted) {
          _shakeController.forward(from: 0);
          CustomSnackbar.error(context, message: result);
        }
      }
    } on Exception catch (e) {
      _shakeController.forward(from: 0);
      if (mounted) {
        CustomSnackbar.error(
          context,
          message: 'Login failed: ${e.toString()}',
          durationSeconds: 4,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final size = MediaQuery.of(context).size; // Unused

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceMD),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
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
                      Icons.qr_code_scanner_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: AppTheme.spaceLG),

                  // Title
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3, end: 0),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: AppTheme.spaceLG),

                  // Glassmorphic Card
                  AnimatedBuilder(
                    animation: _shakeController,
                    builder: (context, child) {
                      final offset = 10 * (_shakeController.value * 2 - 1).abs() * 
                                     (1 - _shakeController.value);
                      return Transform.translate(
                        offset: Offset(offset * (_shakeController.value < 0.5 ? 1 : -1), 0),
                        child: child,
                      );
                    },
                    child: CustomCard(
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
                              ),
                              validator: (value) => ValidationHelper.validateEmail(value),
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
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
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
                              ),
                              validator: (value) => ValidationHelper.validatePassword(value),
                            ),

                            const SizedBox(height: AppTheme.spaceLG),

                            // Login Button
                            AnimatedButton(
                              text: 'Sign In',
                              icon: Icons.login_rounded,
                              gradient: AppColors.primaryGradient,
                              isLoading: _isLoading,
                              onPressed: _login,
                            ),

                            const SizedBox(height: AppTheme.spaceSM),

                            // Sign Up Link
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/signup_credentials');
                              },
                              child: RichText(
                                text: TextSpan(
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                  children: const [
                                    TextSpan(text: "Don't have an account? "),
                                    TextSpan(
                                      text: 'Sign Up',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
