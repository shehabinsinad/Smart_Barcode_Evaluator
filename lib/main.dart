import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_scanner_app/firebase_options.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import 'package:food_scanner_app/utils/page_transitions.dart';

// Screens
import 'package:food_scanner_app/screens/landing_screen.dart';
import 'package:food_scanner_app/screens/login_screen.dart';
import 'package:food_scanner_app/screens/signup_credentials_screen.dart';
import 'package:food_scanner_app/screens/signup_preferences_screen.dart';
import 'package:food_scanner_app/screens/home_screen.dart';
import 'package:food_scanner_app/screens/results_screen.dart';
import 'package:food_scanner_app/screens/scanner_screen.dart';
import 'package:food_scanner_app/screens/product_not_found_screen.dart';
import 'package:food_scanner_app/screens/history_screen.dart';
import 'package:food_scanner_app/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Food Scanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const LandingScreen(),
        onGenerateRoute: (settings) {
          // Custom transitions for different routes
          switch (settings.name) {
            case '/login':
              return AppPageRoute.slideFade(const LoginScreen());
            case '/signup_credentials':
              return AppPageRoute.slideRight(const SignupCredentialsScreen());
            case '/signup_preferences':
              return AppPageRoute.slideRight(const SignupPreferencesScreen());
            case '/home':
              return AppPageRoute.fade(const HomeScreen(), durationMs: 400);
            case '/scanner':
              return AppPageRoute.slideUp(const ScannerScreen());
            case '/results':
              return AppPageRoute.scale(const ResultsScreen());
            case '/product_not_found':
              return AppPageRoute.slideFade(const ProductNotFoundScreen());
            case '/history':
              return AppPageRoute.slideRight(const HistoryScreen());
            case '/profile':
              return AppPageRoute.slideRight(const ProfileScreen());
            default:
              return AppPageRoute.fade(const LandingScreen());
          }
        },
      );
  }
}
