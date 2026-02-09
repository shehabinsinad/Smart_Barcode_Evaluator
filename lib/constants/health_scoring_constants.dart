/// Health scoring constants for the Food Scanner App
class HealthScoringConstants {
  // Base score
  static const int baseScore = 100;
  static const int minimumScore = 1;
  static const int maximumScore = 100;

  // Calorie thresholds and penalties
  static const double calorieThreshold = 200.0; // kcal per 100g
  static const double calorieIncrement = 50.0;  // Every 50 kcal above threshold
  static const int caloriepenalty = 5;          // Subtract 5 points per increment

  // Sugar thresholds and penalties
  static const double sugarThreshold = 10.0;    // grams per 100g
  static const double sugarIncrement = 5.0;     // Every 5g above threshold
  static const int sugarPenalty = 3;            // Subtract 3 points per increment

  // BMI thresholds and penalties
  static const double bmiOverweight = 25.0;
  static const double bmiUnderweight = 18.5;
  static const int bmiOverweightPenalty = 5;
  static const int bmiUnderweightPenalty = 3;

  // Macronutrient thresholds
  static const double lowProteinThreshold = 10.0;  // grams per 100g
  static const double highCarbsThreshold = 30.0;   // grams per 100g
  static const int lowProteinHighCarbsPenalty = 3;

  // Health condition penalties
  static const double diabetesSugarThreshold = 15.0; // grams per 100g
  static const int diabetesPenalty = 10;
  
  static const double hypertensionFatThreshold = 10.0; // grams per 100g
  static const int hypertensionPenalty = 5;

  // Product-specific penalties
  static const int junkFoodPenalty = 5;

  // Default user metrics
  static const double defaultHeight = 170.0; // cm
  static const double defaultWeight = 70.0;  // kg
}
