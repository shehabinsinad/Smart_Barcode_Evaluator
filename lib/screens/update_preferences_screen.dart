import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_scanner_app/utils/validation_helper.dart';
import 'package:food_scanner_app/components/custom_card.dart';
import 'package:food_scanner_app/components/animated_button.dart';
import 'package:food_scanner_app/theme/app_colors.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import '../services/user_service.dart';

class UpdatePreferencesScreen extends StatefulWidget {
  const UpdatePreferencesScreen({super.key});

  @override
  UpdatePreferencesScreenState createState() => UpdatePreferencesScreenState();
}

class UpdatePreferencesScreenState extends State<UpdatePreferencesScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final List<String> allergensList = [
    "Peanuts",
    "Gluten",
    "Soy",
    "Dairy",
    "Eggs",
    "Tree Nuts"
  ];
  Set<String> selectedAllergies = {};

  final List<String> conditionsList = [
    "Diabetes",
    "Hypertension",
    "Gluten Intolerance",
    "Lactose Intolerance"
  ];
  Set<String> selectedConditions = {};

  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final data = await UserService().getUserData();
    setState(() {
      nameController.text = data["name"] ?? "";
      heightController.text = data["height"] ?? "";
      weightController.text = data["weight"] ?? "";
      selectedAllergies = (data["allergies"] ?? "")
          .split(",")
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      selectedConditions = (data["conditions"] ?? "")
          .split(",")
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      _isLoading = false;
    });
  }

  void _updatePreferences() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    String name = nameController.text.trim();
    String height = heightController.text.trim();
    String weight = weightController.text.trim();
    String allergies = selectedAllergies.join(", ");
    String conditions = selectedConditions.join(", ");
    
    await UserService().saveUserData(name, height, weight, allergies, conditions);
    
    setState(() {
      _isLoading = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Preferences Updated")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Update Profile", style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spaceMD),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppTheme.spaceSM),
                        
                        // Personal Information Card
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceSM),
                                  Text(
                                    'Personal Information',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceMD),
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: "Full Name",
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              TextFormField(
                                controller: heightController,
                                decoration: InputDecoration(
                                  labelText: "Height (cm)",
                                  prefixIcon: const Icon(Icons.height_rounded),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: ValidationHelper.validateHeight,
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              TextFormField(
                                controller: weightController,
                                decoration: InputDecoration(
                                  labelText: "Weight (kg)",
                                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: ValidationHelper.validateWeight,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: AppTheme.spaceMD),
                        
                        // Allergens Card
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceSM),
                                  Text(
                                    'Allergens',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              Text(
                                'Select any allergens you have:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              ...allergensList.map((allergen) {
                                return CheckboxListTile(
                                  title: Text(allergen),
                                  value: selectedAllergies.contains(allergen.toLowerCase()),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedAllergies.add(allergen.toLowerCase());
                                      } else {
                                        selectedAllergies.remove(allergen.toLowerCase());
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                  contentPadding: EdgeInsets.zero,
                                );
                              }),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: AppTheme.spaceMD),
                        
                        // Health Conditions Card
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.health_and_safety_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spaceSM),
                                  Text(
                                    'Health Conditions',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              Text(
                                'Select any health conditions you have:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spaceSM),
                              ...conditionsList.map((condition) {
                                return CheckboxListTile(
                                  title: Text(condition),
                                  value: selectedConditions.contains(condition.toLowerCase()),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedConditions.add(condition.toLowerCase());
                                      } else {
                                        selectedConditions.remove(condition.toLowerCase());
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                  contentPadding: EdgeInsets.zero,
                                );
                              }),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                        
                        const SizedBox(height: AppTheme.spaceLG),
                        
                        // Update Button
                        AnimatedButton(
                          text: 'Update Preferences',
                          icon: Icons.save_rounded,
                          gradient: AppColors.primaryGradient,
                          onPressed: _updatePreferences,
                        ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
                        
                        const SizedBox(height: AppTheme.spaceMD),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
