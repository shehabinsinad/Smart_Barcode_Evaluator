import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_scanner_app/providers/theme_provider.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/services/user_service.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import 'package:food_scanner_app/components/custom_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, String>? userData;
  bool _isLoading = true;
  bool _darkMode = false;
  bool _notifications = true;
  bool _hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPreferences();
  }

  Future<void> _loadUserData() async {
    final data = await UserService().getUserData();
    if (mounted) setState(() { userData = data; _isLoading = false; });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _darkMode = prefs.getBool('dark_mode') ?? false;
        _notifications = prefs.getBool('notifications') ?? true;
        _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
      });
    }
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }


  void _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFaqItem(
                'How does the health score work?',
                'Your score (0–100) is calculated using the product\'s calorie, sugar, fat, and protein content — personalised to your BMI, allergies, and health conditions.',
              ),
              _buildFaqItem(
                'Why is my score different for the same product?',
                'Scores are personalised. If you update your profile (weight, height, or conditions), future scans of the same product will reflect those changes.',
              ),
              _buildFaqItem(
                'How do I add allergies?',
                'Go to Profile → Allergies & Preferences to set your dietary restrictions and health conditions.',
              ),
              _buildFaqItem(
                'Can I delete scan history?',
                'Yes! Tap any item in Scan History to view details and delete it, or swipe left on a card to remove it quickly.',
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Still need help? Contact us at:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {},
                child: const SelectableText(
                  'support@foodscanner.app',
                  style: TextStyle(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q: $question',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Food Scanner App is committed to protecting your privacy.\n\n'
            '• Your profile data (name, weight, height, allergies) is stored securely in Firebase Firestore, accessible only to you.\n\n'
            '• Scan history is stored in your personal Firestore account and is never shared with third parties.\n\n'
            '• Product data is fetched from the Open Food Facts public database.\n\n'
            '• Profile photos are stored locally on your device only.\n\n'
            '• We do not sell, share, or monetise your personal data in any way.\n\n'
            '• You may delete your account and all associated data at any time by contacting support.\n\n'
            'Last updated: May 2026',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final name = userData?['name'] ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.3),
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceMD),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.cardColor,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSM),
                          Text(
                            'Profile',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),

                            const SizedBox(height: AppTheme.spaceSM),

                            Text(
                              name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ).animate().fadeIn(delay: 300.ms),

                            const SizedBox(height: 4),

                            Text(
                              email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ).animate().fadeIn(delay: 350.ms),

                            const SizedBox(height: AppTheme.spaceLG),

                            // Account Settings — single entry to preferences
                            CustomCard(
                              padding: const EdgeInsets.all(0),
                              child: _buildSettingsTile(
                                icon: Icons.health_and_safety_outlined,
                                title: 'Allergies & Preferences',
                                subtitle: 'Manage profile, diet & health conditions',
                                onTap: () {
                                  Navigator.pushNamed(context, '/update_preferences')
                                      .then((_) => _loadUserData());
                                },
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                            const SizedBox(height: AppTheme.spaceSM),

                            // App Settings
                            CustomCard(
                              padding: const EdgeInsets.all(0),
                              child: Column(
                                children: [
                                  _buildToggleTile(
                                    icon: Icons.dark_mode_outlined,
                                    title: 'Dark Mode',
                                    subtitle: 'Switch theme',
                                    value: _darkMode,
                                    onChanged: (value) {
                                      setState(() => _darkMode = value);
                                      _savePref('dark_mode', value);
                                      context.read<ThemeProvider>().toggleTheme(isDark: value);
                                    },
                                  ),
                                  const Divider(height: 1),
                                  _buildToggleTile(
                                    icon: Icons.notifications_outlined,
                                    title: 'Notifications',
                                    subtitle: 'Push notifications',
                                    value: _notifications,
                                    onChanged: (value) {
                                      setState(() => _notifications = value);
                                      _savePref('notifications', value);
                                    },
                                  ),
                                  const Divider(height: 1),
                                  _buildToggleTile(
                                    icon: Icons.vibration_rounded,
                                    title: 'Haptic Feedback',
                                    subtitle: 'Vibration on scan',
                                    value: _hapticFeedback,
                                    onChanged: (value) {
                                      setState(() => _hapticFeedback = value);
                                      _savePref('haptic_feedback', value);
                                    },
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                            const SizedBox(height: AppTheme.spaceSM),

                            // About & Support
                            CustomCard(
                              padding: const EdgeInsets.all(0),
                              child: Column(
                                children: [
                                  _buildSettingsTile(
                                    icon: Icons.info_outline_rounded,
                                    title: 'About',
                                    subtitle: 'App version & info',
                                    onTap: () {
                                      showAboutDialog(
                                        context: context,
                                        applicationName: 'Food Scanner',
                                        applicationVersion: '1.0.0',
                                        applicationLegalese: '© 2026 Food Scanner. All rights reserved.',
                                        applicationIcon: Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.qr_code_scanner_rounded,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(height: 1),
                                  _buildSettingsTile(
                                    icon: Icons.help_outline_rounded,
                                    title: 'Help & Support',
                                    subtitle: 'FAQs and contact',
                                    onTap: _showHelpDialog,
                                  ),
                                  const Divider(height: 1),
                                  _buildSettingsTile(
                                    icon: Icons.privacy_tip_outlined,
                                    title: 'Privacy Policy',
                                    subtitle: 'Read our terms',
                                    onTap: _showPrivacyDialog,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                            const SizedBox(height: AppTheme.spaceLG),

                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Sign Out'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSM),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

                            const SizedBox(height: AppTheme.spaceLG),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
