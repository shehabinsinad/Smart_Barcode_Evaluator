import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/services/product_service.dart';
import 'package:food_scanner_app/services/user_service.dart';
import 'package:food_scanner_app/services/history_service.dart';
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
          .map((e) => e.replaceAll("en:", "").trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Calculate health score and check allergens.
    Map<String, dynamic> scoreResult = calculateHealthScore(
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

    await HistoryService().addScan({
      "productName": productData["name"],
      "healthScore": healthScore,
      "timestamp": DateTime.now().toIso8601String(),
    });

    return {
      "product": productData,
      "healthScore": healthScore,
      "allergenNote": allergenNote,
      "userConditions": userConditions,
    };
  }

  Map<String, dynamic> calculateHealthScore({
    required double height,
    required double weight,
    required List<String> userAllergies,
    required List<String> userConditions,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double sugars,
    required String productName,
    required List<String> productAllergens,
  }) {
    List<String> detectedAllergens = [];

    // Check product allergens using regex with word boundaries.
    for (var userAllergen in userAllergies) {
      final pattern = r'\b' + RegExp.escape(userAllergen) + r'\b';
      final regex = RegExp(pattern, caseSensitive: false);
      for (var prodAllergen in productAllergens) {
        if (regex.hasMatch(prodAllergen)) {
          if (!detectedAllergens.contains(userAllergen)) {
            detectedAllergens.add(userAllergen);
          }
        }
      }
      // Additional check on product name for soy/soya.
      if ((userAllergen == "soy" || userAllergen == "soya") &&
          (productName.toLowerCase().contains("soy") ||
           productName.toLowerCase().contains("soya"))) {
        if (!detectedAllergens.contains(userAllergen)) {
          detectedAllergens.add(userAllergen);
        }
      }
    }
    if (detectedAllergens.isNotEmpty) {
      String allergenNote = "Allergen present: ${detectedAllergens.join(", ")}";
      return {"score": 0, "allergenNote": allergenNote};
    }

    int score = HealthScoringConstants.baseScore;

    // Adjusted calorie penalty
    if (calories > HealthScoringConstants.calorieThreshold) {
      score -= (((calories - HealthScoringConstants.calorieThreshold) / HealthScoringConstants.calorieIncrement).ceil() * HealthScoringConstants.caloriepenalty);
    }

    // Adjusted sugar penalty
    if (sugars > HealthScoringConstants.sugarThreshold) {
      score -= (((sugars - HealthScoringConstants.sugarThreshold) / HealthScoringConstants.sugarIncrement).ceil() * HealthScoringConstants.sugarPenalty);
    }

    // BMI penalty
    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);
    if (bmi > HealthScoringConstants.bmiOverweight) {
      score -= HealthScoringConstants.bmiOverweightPenalty;
    } else if (bmi < HealthScoringConstants.bmiUnderweight) {
      score -= HealthScoringConstants.bmiUnderweightPenalty;
    }

    // Low protein, high carbs penalty
    if (protein < HealthScoringConstants.lowProteinThreshold && carbs > HealthScoringConstants.highCarbsThreshold) {
      score -= HealthScoringConstants.lowProteinHighCarbsPenalty;
    }

    // Health condition penalties
    if (userConditions.contains("diabetes") && sugars > HealthScoringConstants.diabetesSugarThreshold) {
      score -= HealthScoringConstants.diabetesPenalty;
    }
    if (userConditions.contains("hypertension") && fat > HealthScoringConstants.hypertensionFatThreshold) {
      score -= HealthScoringConstants.hypertensionPenalty;
    }

    // Junk food penalty
    if (productName.toLowerCase().contains("snickers") ||
        productName.toLowerCase().contains("peanut")) {
      score -= HealthScoringConstants.junkFoodPenalty;
    }

    if (score < HealthScoringConstants.minimumScore) score = HealthScoringConstants.minimumScore;
    if (score > HealthScoringConstants.maximumScore) score = HealthScoringConstants.maximumScore;

    return {"score": score, "allergenNote": ""};
  }

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
                              '${product["calories"]} kcal',
                              Icons.local_fire_department_rounded,
                              AppColors.warning,
                            ),
                            _buildNutritionRow(
                              'Protein',
                              '${product["protein"]}g',
                              Icons.fitness_center_rounded,
                              AppColors.success,
                            ),
                            _buildNutritionRow(
                              'Carbs',
                              '${product["carbs"]}g',
                              Icons.grain_rounded,
                              AppColors.secondary,
                            ),
                            _buildNutritionRow(
                              'Fat',
                              '${product["fat"]}g',
                              Icons.water_drop_rounded,
                              AppColors.scoreFair,
                            ),
                            _buildNutritionRow(
                              'Sugars',
                              '${product["sugars"]}g',
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
                            // Share functionality
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
