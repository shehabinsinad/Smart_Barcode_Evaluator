class ValidationHelper {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  /// Validates numeric input with optional range
  static String? validateNumber(
    String? value, {
    required String fieldName,
    double? min,
    double? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return '$fieldName must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$fieldName must be at most $max';
    }
    
    return null;
  }

  /// Validates height (in cm)
  static String? validateHeight(String? value) {
    return validateNumber(
      value,
      fieldName: 'Height',
      min: 50,
      max: 300,
    );
  }

  /// Validates weight (in kg)
  static String? validateWeight(String? value) {
    return validateNumber(
      value,
      fieldName: 'Weight',
      min: 10,
      max: 500,
    );
  }
}
