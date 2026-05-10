import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:food_scanner_app/services/product_service.dart';
import 'package:food_scanner_app/services/user_service.dart';
import 'package:food_scanner_app/services/history_service.dart';
import 'package:food_scanner_app/services/health_scoring_service.dart';
import 'package:food_scanner_app/constants/health_scoring_constants.dart';
import 'package:food_scanner_app/components/score_gauge.dart';
import 'package:food_scanner_app/components/custom_card.dart';
import 'package:food_scanner_app/components/animated_button.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  ResultsScreenState createState() => ResultsScreenState();
}

class ResultsScreenState extends State<ResultsScreen> {
  late Future<Map<String, dynamic>> _resultFuture;
  bool _isInitialized = false;
  bool _nutritionExpanded = false;
  bool _scoreExplanationExpanded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _resultFuture = _loadResult();
      _isInitialized = true;
    }
  }

  Future<Map<String, dynamic>> _loadResult() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null || args is! String) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/product_not_found');
      });
      return {};
    }
    final barcodeData = args;

    final productData = await ProductService().getProductDetails(barcodeData);
    final userData = await UserService().getUserData();

    double height = double.tryParse(userData["height"] ?? "") ?? HealthScoringConstants.defaultHeight;
    double weight = double.tryParse(userData["weight"] ?? "") ?? HealthScoringConstants.defaultWeight;
    List<String> userAllergies = (userData["allergies"] ?? "")
        .toString()
        .toLowerCase()
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    List<String> userConditions = (userData["conditions"] ?? "")
        .toString()
        .toLowerCase()
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // If nutrient values are zero, navigate to Product Not Found.
    if (productData["calories"] == 0 &&
        productData["protein"] == 0 &&
        productData["carbs"] == 0 &&
        productData["fat"] == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/product_not_found');
      });
      return {};
    }

    // Process product allergens.
    List<String> productAllergens = [];
    if (productData["allergens"] != null &&
        productData["allergens"].toString().isNotEmpty) {
      productAllergens = productData["allergens"]
          .toString()
          .toLowerCase()
          .split(",")
          .map((e) => e.replaceAll("en:", "").replaceAll("-", " ").trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Calculate health score using shared service
    Map<String, dynamic> scoreResult = HealthScoringService.calculateHealthScore(
      height: height,
      weight: weight,
      userAllergies: userAllergies,
      userConditions: userConditions,
      calories: productData["calories"],
      protein: productData["protein"],
      carbs: productData["carbs"],
      fat: productData["fat"],
      sugars: productData["sugars"],
      productName: productData["name"],
      productAllergens: productAllergens,
    );

    // Extract values from scoreResult
    int healthScore = scoreResult["score"];
    String allergenNote = scoreResult["allergenNote"];

    // Save scan — include nutritional data so history can recalculate with current profile
    await HistoryService().addScan({
      "productName": productData["name"],
      "healthScore": healthScore,
      "timestamp": DateTime.now().toIso8601String(),
      "calories": productData["calories"],
      "protein": productData["protein"],
      "carbs": productData["carbs"],
      "fat": productData["fat"],
      "sugars": productData["sugars"],
      "allergens": (productData["allergens"] ?? "").toString(),
    });

    return {
      "product": productData,
      "healthScore": healthScore,
      "allergenNote": allergenNote,
      "userConditions": userConditions,
    };
  }

  // calculateHealthScore is now in HealthScoringService — see lib/services/health_scoring_service.dart
  String _getScoreDescription(int score) {
    if (score >= 71) return "This product is an excellent choice for your health!";
    if (score >= 61) return "This is a good choice with minor concerns.";
    if (score >= 41) return "Fair choice. Consider healthier alternatives.";
    if (score >= 31) return "Poor nutritional value. Limited consumption recommended.";
    return "Avoid this product. Seek healthier alternatives.";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Product Analysis', style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _resultFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Could not load product',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString().replaceFirst('Exception: ', ''),
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface,
                    theme.scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }

          final product = snapshot.data!["product"];
          final healthScore = snapshot.data!["healthScore"] as int;
          final allergenNote = snapshot.data!["allergenNote"] as String;
          final hasAllergens = allergenNote.isNotEmpty;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface,
                  theme.scaffoldBackgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  
                  // Product Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                    child: Text(
                      product["name"],
                      style: theme.textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: AppTheme.spaceLG),
                  
                  // Allergen Warning (if present)
                  if (hasAllergens)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                      child: CustomCard(
                        color: AppColors.error.withValues(alpha: 0.15),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spaceSM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚠️ ALLERGEN ALERT',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    allergenNote,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake(duration: 500.ms).fadeIn(),
                    ),
                  
                  if (hasAllergens) const SizedBox(height: AppTheme.spaceMD),
                  
                  // Animated Score Gauge
                  Hero(
                    tag: 'score_gauge',
                    child: ScoreGauge(
                      score: healthScore,
                      size: 220,
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spaceSM),
                  
                  // Score Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                    child: Text(
                      _getScoreDescription(healthScore),
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: AppTheme.spaceLG),
                  
                  // Nutrition Facts Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                    child: CustomCard(
                      onTap: () => setState(() => _nutritionExpanded = !_nutritionExpanded),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.restaurant_menu_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceSM),
                                  Text(
                                    'Nutrition Facts',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              Icon(
                                _nutritionExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          if (_nutritionExpanded) ...[
                            const SizedBox(height: AppTheme.spaceSM),
                            const Divider(),
                            const SizedBox(height: AppTheme.spaceSM),
                            _buildNutritionRow(
                              'Calories',
                              '${(product["calories"] as double).toStringAsFixed(1)} kcal',
                              Icons.local_fire_department_rounded,
                              AppColors.warning,
                            ),
                            _buildNutritionRow(
                              'Protein',
                              '${(product["protein"] as double).toStringAsFixed(1)}g',
                              Icons.fitness_center_rounded,
                              AppColors.success,
                            ),
                            _buildNutritionRow(
                              'Carbs',
                              '${(product["carbs"] as double).toStringAsFixed(1)}g',
                              Icons.grain_rounded,
                              AppColors.secondary,
                            ),
                            _buildNutritionRow(
                              'Fat',
                              '${(product["fat"] as double).toStringAsFixed(1)}g',
                              Icons.water_drop_rounded,
                              AppColors.scoreFair,
                            ),
                            _buildNutritionRow(
                              'Sugars',
                              '${(product["sugars"] as double).toStringAsFixed(1)}g',
                              Icons.cake_rounded,
                              AppColors.error,
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2, end: 0),
                  ),
                  
                  const SizedBox(height: AppTheme.spaceSM),
                  
                  // Why This Score? Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                    child: CustomCard(
                      onTap: () => setState(() => _scoreExplanationExpanded = !_scoreExplanationExpanded),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.secondaryGradient,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceSM),
                                  Text(
                                    'Why This Score?',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              Icon(
                                _scoreExplanationExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.secondary,
                              ),
                            ],
                          ),
                          if (_scoreExplanationExpanded) ...[
                            const SizedBox(height: AppTheme.spaceSM),
                            const Divider(),
                            const SizedBox(height: AppTheme.spaceSM),
                            Text(
                              'Your score is calculated based on:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildScoreFactorRow('✓', 'Calorie content'),
                            _buildScoreFactorRow('✓', 'Sugar levels'),
                            _buildScoreFactorRow('✓', 'Your BMI'),
                            _buildScoreFactorRow('✓', 'Macro balance'),
                            _buildScoreFactorRow('✓', 'Your health conditions'),
                            _buildScoreFactorRow('✓', 'Your allergies'),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2, end: 0),
                  ),
                  
                  const SizedBox(height: AppTheme.spaceLG),
                  
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMD),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedButton(
                            text: 'Scan Another',
                            icon: Icons.qr_code_scanner_rounded,
                            gradient: AppColors.primaryGradient,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSM),
                        AnimatedButton(
                          text: '',
                          icon: Icons.share_rounded,
                          width: 50,
                          height: 50,
                          backgroundColor: theme.colorScheme.surface,
                          textColor: AppColors.primary,
                          onPressed: () {
                            final name = product['name'] ?? 'Unknown Product';
                            Share.share(
                              '🔍 I scanned "$name" with Food Scanner!\n'
                              '📊 Health Score: $healthScore/100\n'
                              '🔥 Calories: ${(product["calories"] as double).toStringAsFixed(1)} kcal\n'
                              '💪 Protein: ${(product["protein"] as double).toStringAsFixed(1)}g\n'
                              '🍞 Carbs: ${(product["carbs"] as double).toStringAsFixed(1)}g\n'
                              '💧 Fat: ${(product["fat"] as double).toStringAsFixed(1)}g',
                              subject: 'Food Scanner Result',
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: AppTheme.spaceLG),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreFactorRow(String icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(color: AppColors.success, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
