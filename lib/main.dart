import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'constants/app_constants.dart';
import 'providers/providers.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'utils/database_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add error handling for Firebase initialization
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully");
    
    // In debug mode, try to seed initial data if needed
    if (kDebugMode) {
      _checkAndSeedDatabase();
    }
  } catch (e) {
    print("Failed to initialize Firebase: $e");
    // Continue with the app, but Firebase functionality will be disabled
  }
  
  runApp(const MyApp());
}

// Function to check if the database needs initial seeding
// This runs in the background and doesn't block app startup
Future<void> _checkAndSeedDatabase() async {
  try {
    // Create a database seeder and attempt to seed the database
    // This will only add data if the database is empty
    final seeder = DatabaseSeeder();
    await seeder.seedQuizData();
  } catch (e) {
    debugPrint('Error checking/seeding database: $e');
    // Don't stop app startup for seeding errors
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          final authProvider = Provider.of<AuthProvider>(context);
          
          // Create the router with the auth provider
          final appRouter = AppRouter(authProvider);
          
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: AppConstants.isDevelopment,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: appRouter.router,
          );
        }
      ),
    );
  }
}
