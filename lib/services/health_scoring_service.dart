import 'package:food_scanner_app/constants/health_scoring_constants.dart';

/// Shared health scoring logic — used by both ResultsScreen and HistoryScreen.
class HealthScoringService {
  /// Returns `{"score": int, "allergenNote": String}`.
  static Map<String, dynamic> calculateHealthScore({
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
    // Allergen check
    final List<String> detectedAllergens = [];
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
      if ((userAllergen == 'soy' || userAllergen == 'soya') &&
          (productName.toLowerCase().contains('soy') ||
           productName.toLowerCase().contains('soya'))) {
        if (!detectedAllergens.contains(userAllergen)) {
          detectedAllergens.add(userAllergen);
        }
      }
    }
    if (detectedAllergens.isNotEmpty) {
      return {
        'score': 0,
        'allergenNote': 'Allergen present: ${detectedAllergens.join(", ")}',
      };
    }

    int score = HealthScoringConstants.baseScore;

    // Calorie penalty
    if (calories > HealthScoringConstants.calorieThreshold) {
      score -= (((calories - HealthScoringConstants.calorieThreshold) /
              HealthScoringConstants.calorieIncrement)
          .ceil() * HealthScoringConstants.caloriepenalty);
    }

    // Sugar penalty
    if (sugars > HealthScoringConstants.sugarThreshold) {
      score -= (((sugars - HealthScoringConstants.sugarThreshold) /
              HealthScoringConstants.sugarIncrement)
          .ceil() * HealthScoringConstants.sugarPenalty);
    }

    // BMI penalty
    final double heightInMeters = height / 100;
    final double bmi = weight / (heightInMeters * heightInMeters);
    if (bmi > HealthScoringConstants.bmiOverweight) {
      score -= HealthScoringConstants.bmiOverweightPenalty;
    } else if (bmi < HealthScoringConstants.bmiUnderweight) {
      score -= HealthScoringConstants.bmiUnderweightPenalty;
    }

    // Low protein + high carbs penalty
    if (protein < HealthScoringConstants.lowProteinThreshold &&
        carbs > HealthScoringConstants.highCarbsThreshold) {
      score -= HealthScoringConstants.lowProteinHighCarbsPenalty;
    }

    // Health condition penalties
    if (userConditions.contains('diabetes') &&
        sugars > HealthScoringConstants.diabetesSugarThreshold) {
      score -= HealthScoringConstants.diabetesPenalty;
    }
    if (userConditions.contains('hypertension') &&
        fat > HealthScoringConstants.hypertensionFatThreshold) {
      score -= HealthScoringConstants.hypertensionPenalty;
    }

    // Junk food penalty
    if (productName.toLowerCase().contains('snickers') ||
        productName.toLowerCase().contains('peanut')) {
      score -= HealthScoringConstants.junkFoodPenalty;
    }

    if (score < HealthScoringConstants.minimumScore) {
      score = HealthScoringConstants.minimumScore;
    }
    if (score > HealthScoringConstants.maximumScore) {
      score = HealthScoringConstants.maximumScore;
    }

    return {'score': score, 'allergenNote': ''};
  }

  /// Parse allergen string stored in Firestore back to a list.
  static List<String> parseAllergens(String raw) {
    return raw
        .toLowerCase()
        .split(',')
        .map((e) => e.replaceAll('en:', '').replaceAll('-', ' ').trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Parse a comma-separated user preference string to a list.
  static List<String> parsePreferences(String raw) {
    return raw
        .toLowerCase()
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
