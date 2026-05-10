import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/result_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/error_screen.dart';
import '../screens/dev_screen.dart';

class AppRouter {
  final AuthProvider authProvider;
  
  AppRouter(this.authProvider);
  
  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    debugLogDiagnostics: AppConstants.isDevelopment,
    initialLocation: AppConstants.splashRoute,
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        redirect: _guardRoute,
      ),
      GoRoute(
        path: AppConstants.categoryRoute,
        name: 'category',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: CategoryScreen(
            categoryId: state.extra != null 
                ? (state.extra as Map<String, dynamic>)['id']?.toString() ?? ''
                : '',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
        redirect: _guardRoute,
      ),
      GoRoute(
        path: AppConstants.quizRoute,
        name: 'quiz',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: QuizScreen(
            categoryId: state.extra != null 
                ? (state.extra as Map<String, dynamic>)['categoryId']?.toString() ?? '' 
                : '',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
        redirect: _guardRoute,
      ),
      GoRoute(
        path: AppConstants.resultRoute,
        name: 'result',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ResultScreen(
            result: state.extra as Map<String, dynamic>? ?? {},
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        redirect: _guardRoute,
      ),
      GoRoute(
        path: AppConstants.profileRoute,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
        redirect: _guardRoute,
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
        redirect: _guardRoute,
      ),
      // Dev tools route - only available in debug mode
      if (kDebugMode)
        GoRoute(
          path: AppConstants.devRoute,
          name: 'dev',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const DevScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
          redirect: _guardRoute,
        ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error.toString()),
  );
  
  String? _guardRoute(BuildContext context, GoRouterState state) {
    final isAuthenticated = authProvider.isAuthenticated;
    final isGoingToLogin = state.uri.path == AppConstants.loginRoute;
    final isGoingToRegister = state.uri.path == AppConstants.registerRoute;
    final isGoingToSplash = state.uri.path == AppConstants.splashRoute;
    
    // If not authenticated and trying to access a protected route
    if (!isAuthenticated && 
        !isGoingToLogin && 
        !isGoingToRegister && 
        !isGoingToSplash) {
      return AppConstants.loginRoute;
    }
    
    // If authenticated and trying to access login or register
    if (isAuthenticated && (isGoingToLogin || isGoingToRegister)) {
      return AppConstants.homeRoute;
    }
    
    // No redirection needed
    return null;
  }
} 