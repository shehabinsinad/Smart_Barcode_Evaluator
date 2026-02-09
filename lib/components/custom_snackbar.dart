import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';

/// Premium custom snackbar component
class CustomSnackbar {
  // Prevent instantiation
  CustomSnackbar._();

  /// Show success snackbar
  static void success(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    int durationSeconds = 3,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: AppColors.success,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      durationSeconds: durationSeconds,
    );
  }

  /// Show error snackbar
  static void error(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    int durationSeconds = 4,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: AppColors.error,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      durationSeconds: durationSeconds,
    );
  }

  /// Show warning snackbar
  static void warning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    int durationSeconds = 3,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: AppColors.warning,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      durationSeconds: durationSeconds,
    );
  }

  /// Show info snackbar
  static void info(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    int durationSeconds = 3,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: AppColors.primary,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      durationSeconds: durationSeconds,
    );
  }

  /// Internal method to show snackbar
  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    String? actionLabel,
    VoidCallback? onActionPressed,
    required int durationSeconds,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spaceSM),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      margin: const EdgeInsets.all(AppTheme.spaceSM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSM,
        vertical: AppTheme.spaceSM,
      ),
      duration: Duration(seconds: durationSeconds),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed ?? () {},
            )
          : null,
    ).animate().slideY(
      begin: 1.0,
      end: 0.0,
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar as SnackBar);
  }
}
