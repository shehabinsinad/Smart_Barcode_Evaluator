import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_scanner_app/services/auth_service.dart';
import 'package:food_scanner_app/services/user_service.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import 'package:food_scanner_app/components/custom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Map<String, String>? userData;
  bool _isLoading = true;
  String email = "";

  Future<void> _loadUserData() async {
    userData = await UserService().getUserData();
    email = FirebaseAuth.instance.currentUser?.email ?? "";
    setState(() {
      _isLoading = false;
    });
  }

  void _logout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/landing');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = userData?['name'] ?? 'User';

    return Scaffold(
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Premium Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spaceMD),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: theme.textTheme.displayMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Profile Avatar
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/profile'),
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          name[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ).animate().scale(delay: 200.ms, duration: 500.ms),
                                ],
                              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                              
                              const SizedBox(height: AppTheme.spaceLG),
                              
                              // Quick Stats Card
                              CustomCard(
                                padding: const EdgeInsets.all(AppTheme.spaceMD),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      icon: Icons.qr_code_scanner_rounded,
                                      label: 'Scans',
                                      value: '0',
                                      color: AppColors.primary,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: theme.dividerColor,
                                    ),
                                    _buildStatItem(
                                      icon: Icons.history_rounded,
                                      label: 'History',
                                      value: '0',
                                      color: AppColors.secondary,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
                            ],
                          ),
                        ),
                      ),

                      // Quick Actions
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Actions',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).animate().fadeIn(delay: 400.ms),
                              const SizedBox(height: AppTheme.spaceSM),
                            ],
                          ),
                        ),
                      ),

                      // Action Cards
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: AppTheme.spaceSM,
                            mainAxisSpacing: AppTheme.spaceSM,
                            childAspectRatio: 1.1,
                          ),
                          delegate: SliverChildListDelegate([
                            _buildActionCard(
                              context: context,
                              title: 'Scan Product',
                              subtitle: 'Check nutrition',
                              icon: Icons.qr_code_scanner_rounded,
                              gradient: AppColors.primaryGradient,
                              onTap: () => Navigator.pushNamed(context, '/scanner'),
                              delay: 500,
                            ),
                            _buildActionCard(
                              context: context,
                              title: 'View History',
                              subtitle: 'Past scans',
                              icon: Icons.history_rounded,
                              gradient: LinearGradient(
                                colors: [AppColors.secondary, AppColors.secondary.withValues(alpha: 0.7)],
                              ),
                              onTap: () => Navigator.pushNamed(context, '/history'),
                              delay: 600,
                            ),
                            _buildActionCard(
                              context: context,
                              title: 'Profile',
                              subtitle: 'Settings',
                              icon: Icons.person_rounded,
                              gradient: const LinearGradient(
                                colors: [Colors.purple, Colors.deepPurple],
                              ),
                              onTap: () => Navigator.pushNamed(context, '/profile'),
                              delay: 700,
                            ),
                            _buildActionCard(
                              context: context,
                              title: 'Sign Out',
                              subtitle: 'Logout',
                              icon: Icons.logout_rounded,
                              gradient: LinearGradient(
                                colors: [Colors.red.shade400, Colors.red.shade700],
                              ),
                              onTap: _logout,
                              delay: 800,
                            ),
                          ]),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceLG)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLG),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceSM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }
}
