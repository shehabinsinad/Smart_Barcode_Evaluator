import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/components/animated_button.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/home_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.7),
                AppColors.primaryDark.withValues(alpha: 0.8),
                AppColors.primary.withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // App Logo with Shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/logo.png",
                    height: 120,
                  ),
                ).animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: AppTheme.spaceLG),
                
                // App Name with Gradient
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceLG,
                    vertical: AppTheme.spaceSM,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Food Scanner App",
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Scan. Analyze. Eat Smart.",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                
                const Spacer(flex: 3),
                
                // Call to Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
                  child: Column(
                    children: [
                      // Sign Up Button
                      AnimatedButton(
                        text: 'Sign Up',
                        icon: Icons.person_add_rounded,
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade200],
                        ),
                        textColor: AppColors.primaryDark,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup_credentials');
                        },
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: AppTheme.spaceMD),
                      
                      // Login Button
                      AnimatedButton(
                        text: 'Login',
                        icon: Icons.login_rounded,
                        gradient: AppColors.primaryGradient,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, end: 0),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spaceXL),
                
                // Features Highlight
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLG),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeature(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Quick Scan',
                      ),
                      _buildFeature(
                        icon: Icons.analytics_rounded,
                        label: 'Health Score',
                      ),
                      _buildFeature(
                        icon: Icons.shield_rounded,
                        label: 'Allergen Alert',
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1200.ms),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
