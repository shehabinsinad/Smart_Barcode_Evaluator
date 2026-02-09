import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  }

  Future<void> _loadUserData() async {
    userData = await UserService().getUserData();
    setState(() => _isLoading = false);
  }

  void _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
    }
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
                            // Avatar Section
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
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),

                            const SizedBox(height: AppTheme.spaceSM),

                            // Name & Email
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

                            // Account Settings
                            CustomCard(
                              padding: const EdgeInsets.all(0),
                              child: Column(
                                children: [
                                  _buildSettingsTile(
                                    icon: Icons.person_outline_rounded,
                                    title: 'Edit Profile',
                                    subtitle: 'Update your information',
                                    onTap: () {
                                      // Navigate to edit profile
                                    },
                                  ),
                                  const Divider(height: 1),
                                  _buildSettingsTile(
                                    icon: Icons.notifications_outlined,
                                    title: 'Allergies & Preferences',
                                    subtitle: 'Manage dietary restrictions',
                                    onTap: () {
                                      Navigator.pushNamed(context, '/signup_preferences');
                                    },
                                  ),
                                ],
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
                                      // TODO: Implement theme switching
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
                                    subtitle: 'Get assistance',
                                    onTap: () {},
                                  ),
                                  const Divider(height: 1),
                                  _buildSettingsTile(
                                    icon: Icons.privacy_tip_outlined,
                                    title: 'Privacy Policy',
                                    subtitle: 'Read our terms',
                                    onTap: () {},
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
      title: Text(
        title,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.textTheme.bodySmall?.color,
      ),
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
      title: Text(
        title,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
