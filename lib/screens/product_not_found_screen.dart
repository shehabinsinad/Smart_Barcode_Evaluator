import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/components/custom_card.dart';
import 'package:food_scanner_app/components/animated_button.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';

class ProductNotFoundScreen extends StatelessWidget {
  const ProductNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Product Not Found", style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large Icon with Gradient
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.error.withValues(alpha: 0.2),
                          AppColors.error.withValues(alpha: 0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 80,
                      color: AppColors.error,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: AppTheme.spaceLG),
                  
                  // Message Card
                  CustomCard(
                    child: Column(
                      children: [
                        Text(
                          'Product Not Found',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spaceSM),
                        Text(
                          'We couldn\'t find nutritional information for this product in our database.',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spaceSM),
                        Text(
                          'Please try scanning another product or check if the barcode is clear and visible.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: AppTheme.spaceLG),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedButton(
                          text: 'Scan Again',
                          icon: Icons.qr_code_scanner_rounded,
                          gradient: AppColors.primaryGradient,
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/scanner');
                          },
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceSM),
                      AnimatedButton(
                        text: '',
                        icon: Icons.home_rounded,
                        width: 56,
                        height: 56,
                        backgroundColor: theme.colorScheme.surface,
                        textColor: AppColors.primary,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
