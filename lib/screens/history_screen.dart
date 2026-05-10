import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/services/history_service.dart';
import 'package:food_scanner_app/services/user_service.dart';
import 'package:food_scanner_app/services/health_scoring_service.dart';
import 'package:food_scanner_app/constants/health_scoring_constants.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import 'package:food_scanner_app/components/custom_card.dart';
import 'package:food_scanner_app/components/loading_shimmer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  HistoryScreenState createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>>? _history;
  Map<String, String>? _userData;     // current user profile for recalculation
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Load history and current user profile in parallel
      final results = await Future.wait([
        HistoryService().getHistory(),
        UserService().getUserData(),
      ]);
      if (mounted) {
        setState(() {
          _history = results[0] as List<Map<String, dynamic>>;
          _userData = results[1] as Map<String, String>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Removes the item locally and deletes it from Firestore.
  /// Shows a snackbar with Undo — Undo re-adds the document and reloads.
  Future<void> _deleteItem(int index, Map<String, dynamic> scan) async {
    final docId = scan['id'] as String?;
    final productName = scan['productName'] as String? ?? 'Item';

    // Cache messenger before the await so the context stays valid.
    final messenger = ScaffoldMessenger.of(context);

    // Optimistic removal from local list
    setState(() => _history!.removeAt(index));

    // Delete from Firestore
    if (docId != null) {
      try {
        await HistoryService().deleteScan(docId);
      } catch (_) {
        // If delete failed, restore the item
        if (mounted) {
          setState(() => _history!.insert(index, scan));
          messenger.showSnackBar(
            const SnackBar(content: Text('Could not delete item. Please try again.')),
          );
        }
        return;
      }
    }

    if (!mounted) return;

    messenger.clearSnackBars();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text('$productName removed from history'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            // Dismiss immediately when tapped
            messenger.hideCurrentSnackBar();
            try {
              await HistoryService().addScan({
                'productName': scan['productName'],
                'healthScore': scan['healthScore'],
                'timestamp': scan['timestamp'],
                'calories': scan['calories'],
                'protein': scan['protein'],
                'carbs': scan['carbs'],
                'fat': scan['fat'],
                'sugars': scan['sugars'],
                'allergens': scan['allergens'] ?? '',
              });
              _loadHistory();
            } catch (_) {
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Could not undo. Please rescan the product.')),
                );
              }
            }
          },
        ),
      ),
    );

    // Auto-close after duration as a safety net
    Future.delayed(const Duration(seconds: 4), () => controller.close());
  }

  /// Recalculate a scan's score using the CURRENT user profile.
  /// Falls back to the stored score for old entries without nutritional data.
  int _recalculateScore(Map<String, dynamic> scan) {
    if (_userData == null) return scan['healthScore'] as int? ?? 0;

    // Only recalculate if nutritional data was saved with this scan
    if (scan['calories'] == null) return scan['healthScore'] as int? ?? 0;

    final double height = double.tryParse(_userData!['height'] ?? '') ??
        HealthScoringConstants.defaultHeight;
    final double weight = double.tryParse(_userData!['weight'] ?? '') ??
        HealthScoringConstants.defaultWeight;
    final userAllergies =
        HealthScoringService.parsePreferences(_userData!['allergies'] ?? '');
    final userConditions =
        HealthScoringService.parsePreferences(_userData!['conditions'] ?? '');

    final toDouble = (dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    };

    final productAllergens =
        HealthScoringService.parseAllergens(scan['allergens'] as String? ?? '');

    final result = HealthScoringService.calculateHealthScore(
      height: height,
      weight: weight,
      userAllergies: userAllergies,
      userConditions: userConditions,
      calories: toDouble(scan['calories']),
      protein: toDouble(scan['protein']),
      carbs: toDouble(scan['carbs']),
      fat: toDouble(scan['fat']),
      sugars: toDouble(scan['sugars']),
      productName: scan['productName'] as String? ?? '',
      productAllergens: productAllergens,
    );
    return result['score'] as int;
  }

  Color _getScoreColor(int score) {
    if (score >= 71) return AppColors.scoreExcellent;
    if (score >= 61) return AppColors.scoreGood;
    if (score >= 41) return AppColors.scoreFair;
    if (score >= 31) return AppColors.scorePoor;
    return AppColors.scoreBad;
  }

  String _getScoreLabel(int score) {
    if (score >= 71) return 'Excellent';
    if (score >= 61) return 'Good';
    if (score >= 41) return 'Fair';
    if (score >= 31) return 'Poor';
    return 'Bad';
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
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _loadHistory,
                      tooltip: 'Refresh',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.cardColor,
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              ),

              // Body
              Expanded(child: _buildBody(theme)),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanDetail(BuildContext context, Map<String, dynamic> scan, int index) {
    final theme = Theme.of(context);
    final score = _recalculateScore(scan);
    final productName = scan['productName'] as String? ?? 'Unknown Product';
    final timestamp = scan['timestamp'] as String? ?? '';
    final date = timestamp.length >= 10 ? timestamp.substring(0, 10) : 'Unknown';
    final time = timestamp.length >= 16 ? timestamp.substring(11, 16) : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            // Score circle
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  _getScoreColor(score),
                  _getScoreColor(score).withValues(alpha: 0.7),
                ]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  score.toString(),
                  style: const TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              productName,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getScoreColor(score).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getScoreLabel(score),
                style: TextStyle(
                  color: _getScoreColor(score),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: theme.textTheme.bodySmall?.color),
                const SizedBox(width: 4),
                Text('$date  $time', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLG),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSM),
                  Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Defer to next frame so the bottom sheet is fully closed
                      // before the SnackBar appears — fixes the timer issue.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _deleteItem(index, scan);
                      });
                    },
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + AppTheme.spaceSM),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
        itemCount: 5,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spaceSM),
          child: LoadingShimmer.listItem(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: AppTheme.spaceSM),
              Text(
                'Error loading history',
                style: theme.textTheme.titleLarge?.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceMD),
              ElevatedButton.icon(
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_history == null || _history!.isEmpty) {
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
              child: const Icon(Icons.history_rounded, size: 60, color: Colors.white),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            Text(
              'No scan history yet',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceMD,
          0,
          AppTheme.spaceMD,
          AppTheme.spaceMD,
        ),
        itemCount: _history!.length,
        itemBuilder: (context, index) {
          final scan = _history![index];
          final score = _recalculateScore(scan);
          final productName = scan['productName'] as String? ?? 'Unknown Product';
          final timestamp = scan['timestamp'] as String? ?? '';
          final date = timestamp.length >= 10 ? timestamp.substring(0, 10) : 'Unknown';

          return Dismissible(
            key: Key('${scan['id']}_$index'),
            background: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.spaceSM),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: AppTheme.spaceMD),
              child: const Icon(Icons.delete_rounded, color: Colors.white, size: 32),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteItem(index, scan),
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spaceSM),
              child: CustomCard(
                onTap: () => _showScanDetail(context, scan, index),
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
                              Text(date, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),

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
  }
}
