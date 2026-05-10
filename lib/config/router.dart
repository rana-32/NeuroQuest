import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../screens/screens.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppConstants.categoryRoute:
        final categoryId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CategoryScreen(categoryId: categoryId),
        );

      case AppConstants.quizRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => QuizScreen(categoryId: args['categoryId'] as String),
        );

      case AppConstants.resultRoute:
        final result = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => ResultScreen(result: result));

      case AppConstants.profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppConstants.settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
