import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../utils/sound_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SoundManager _soundManager = SoundManager();
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _controller.forward();
    
    // Play splash sound
    _soundManager.playIntroSound();
    
    // Check authentication after splash animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _checkAuthAndNavigate();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _checkAuthAndNavigate() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      // User is authenticated, navigate to home
      _soundManager.playBackgroundMusic();
      
      // Use GoRouter for navigation instead of Navigator
      GoRouter.of(context).go(AppConstants.homeRoute);
    } else {
      // User is not authenticated, navigate to login
      GoRouter.of(context).go(AppConstants.loginRoute);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation
            Lottie.asset(
              'assets/animations/splash.json',
              height: 250,
              controller: _controller,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
              },
            ),
            const SizedBox(height: 32),
            
            // App name
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Loading indicator
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
} 