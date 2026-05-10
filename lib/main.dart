import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:food_scanner_app/firebase_options.dart';
import 'package:food_scanner_app/theme/app_theme.dart';
import 'package:food_scanner_app/utils/page_transitions.dart';
import 'package:food_scanner_app/providers/theme_provider.dart';

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
import 'package:food_scanner_app/screens/update_preferences_screen.dart';

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
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Food Scanner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const LandingScreen(),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/landing':
                  return AppPageRoute.slideFade(
                    const LandingScreen(),
                    settings: settings,
                  );
                case '/login':
                  return AppPageRoute.slideFade(
                    const LoginScreen(),
                    settings: settings,
                  );
                case '/signup_credentials':
                  return AppPageRoute.slideRight(
                    const SignupCredentialsScreen(),
                    settings: settings,
                  );
                case '/signup_preferences':
                  return AppPageRoute.slideRight(
                    const SignupPreferencesScreen(),
                    settings: settings,
                  );
                case '/home':
                  return AppPageRoute.fade(
                    const HomeScreen(),
                    durationMs: 400,
                    settings: settings,
                  );
                case '/scanner':
                  return AppPageRoute.slideUp(
                    const ScannerScreen(),
                    settings: settings,
                  );
                case '/results':
                  // CRITICAL: must forward `settings` so ModalRoute.of(context)
                  // .settings.arguments is available inside ResultsScreen.
                  return AppPageRoute.scale(
                    const ResultsScreen(),
                    settings: settings,
                  );
                case '/product_not_found':
                  return AppPageRoute.slideFade(
                    const ProductNotFoundScreen(),
                    settings: settings,
                  );
                case '/history':
                  return AppPageRoute.slideRight(
                    const HistoryScreen(),
                    settings: settings,
                  );
                case '/profile':
                  return AppPageRoute.slideRight(
                    const ProfileScreen(),
                    settings: settings,
                  );
                case '/update_preferences':
                  return AppPageRoute.slideRight(
                    const UpdatePreferencesScreen(),
                    settings: settings,
                  );
                default:
                  return AppPageRoute.fade(
                    const LandingScreen(),
                    settings: settings,
                  );
              }
            },
          );
        },
      ),
    );
  }
}
