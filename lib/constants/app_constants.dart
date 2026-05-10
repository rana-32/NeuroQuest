class AppConstants {
  // App name
  static const String appName = "NeuroQuest";
  
  // Development mode flag
  static const bool isDevelopment = true;
  
  // Default quiz settings
  static const int questionsPerQuiz = 5;
  static const int xpPerCorrectAnswer = 10;
  
  // Badge types
  static const Map<String, String> badgeDescriptions = {
    'Starter Star': 'Complete your first quiz!',
    'Animal Expert': 'Score 80% or higher in the Animals category',
    'Math Wizard': 'Score 80% or higher in the Math category',
    'Science Genius': 'Score 80% or higher in the Science category',
    '100 XP Club': 'Earn 100 XP total',
    '500 XP Club': 'Earn 500 XP total',
  };
  
  // Text sizes
  static const double headingFontSize = 24.0;
  static const double subheadingFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double smallFontSize = 12.0;
  
  // Animation durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration questionAnimationDuration = Duration(milliseconds: 500);
  static const Duration resultAnimationDuration = Duration(seconds: 2);
  
  // Spacings
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  
  // Button sizes
  static const double buttonHeight = 56.0;
  static const double buttonRadius = 16.0;
  
  // App routes
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String categoryRoute = '/category';
  static const String quizRoute = '/quiz';
  static const String resultRoute = '/result';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String devRoute = '/dev';
} 