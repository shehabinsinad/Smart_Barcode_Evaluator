import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/services/history_service.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import 'package:food_scanner_app/components/custom_card.dart';
import 'package:food_scanner_app/components/loading_shimmer.dart';
import 'package:food_scanner_app/components/custom_snackbar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String, dynamic>>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = HistoryService().getHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = HistoryService().getHistory();
    });
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 70) return 'Excellent';
    if (score >= 40) return 'Good';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          child: Column(
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
                      'Scan History',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              ),

              // History List
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                        itemCount: 5,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: AppTheme.spaceSM),
                          child: LoadingShimmer.listItem(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spaceMD),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 64,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              Text(
                                'Error loading history',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.history_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceMD),
                            Text(
                              'No scan history yet',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start scanning products to see your history here',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spaceLG),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/scanner');
                              },
                              icon: const Icon(Icons.qr_code_scanner_rounded),
                              label: const Text('Scan Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceLG,
                                  vertical: AppTheme.spaceSM,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 600.ms,
                        ),
                      );
                    }

                    final history = snapshot.data!.reversed.toList();

                    return RefreshIndicator(
                      onRefresh: () async => _refreshHistory(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spaceMD,
                          0,
                          AppTheme.spaceMD,
                          AppTheme.spaceMD,
                        ),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final scan = history[index];
                          final score = scan['healthScore'] as int? ?? 0;
                          final productName = scan['productName'] as String? ?? 'Unknown Product';
                          final timestamp = scan['timestamp'] as String? ?? '';
                          final date = timestamp.isNotEmpty ? timestamp.substring(0, 10) : 'Unknown';

                          return Dismissible(
                            key: Key(timestamp + productName),
                            background: Container(
                              margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: AppTheme.spaceMD),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              // TODO: Implement delete from Firestore
                              CustomSnackbar.info(
                                context,
                                message: '$productName removed from history',
                                actionLabel: 'Undo',
                                onActionPressed: () => _refreshHistory(),
                                durationSeconds: 4,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
                              child: CustomCard(
                                onTap: () {
                                  // Navigate to results with this product data
                                },
                                child: Row(
                                  children: [
                                    // Score Circle
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _getScoreColor(score),
                                            _getScoreColor(score).withValues(alpha: 0.7),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          score.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: AppTheme.spaceSM),

                                    // Product Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            productName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getScoreColor(score).withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _getScoreLabel(score),
                                                  style: TextStyle(
                                                    color: _getScoreColor(score),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                size: 12,
                                                color: theme.textTheme.bodySmall?.color,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                date,
                                                style: theme.textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Chevron
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.2, end: 0);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
