import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/sound_manager.dart';
import '../services/user_service.dart';
import '../services/quiz_service.dart';
import '../models/quiz_result.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  final SoundManager _soundManager = SoundManager();
  final UserService _userService = UserService();
  final QuizService _quizService = QuizService();
  
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _xpUpdated = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
    
    // Play victory sound
    _soundManager.playVictorySound();
    
    // Save results and update XP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveResultsAndUpdateXP();
    });
  }
  
  Future<void> _saveResultsAndUpdateXP() async {
    if (_xpUpdated) return; // Prevent duplicate updates
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final quizProvider = Provider.of<QuizProvider>(context, listen: false);
      
      if (authProvider.user == null) return;
      
      final userId = authProvider.user!.uid;
      final score = widget.result['score'] as int;
      final categoryId = widget.result['categoryId'] as String;
      
      // Calculate XP earned (10 points per correct answer)
      final xpEarned = _quizService.calculateXP(score);
      
      // Save quiz result using the quiz provider
      final resultSaved = await quizProvider.saveQuizResults(userId);
      
      if (resultSaved) {
        // Get current user profile
        final userProfile = authProvider.userProfile;
        if (userProfile == null) return;
        
        // Update user XP
        await _userService.updateUserXP(userId, xpEarned);
        
        // Update category progress
        await _userService.updateCategoryProgress(userId, categoryId, score);
        
        // Create a QuizResult object to determine badges
        final quizResult = QuizResult(
          id: 'temp-id',
          userId: userId,
          categoryId: categoryId,
          score: score,
          totalQuestions: widget.result['total'] as int,
          percentage: widget.result['percentage'] as double,
          xpEarned: xpEarned,
          completedAt: DateTime.now().millisecondsSinceEpoch,
        );
        
        // Determine which badges should be awarded
        final newBadges = _quizService.determineBadgesEarned(quizResult, userProfile);
        
        // Award each new badge
        for (final badge in newBadges) {
          debugPrint('Awarding badge: $badge');
          await _userService.addUserBadge(userId, badge);
        }
        
        // Refresh user profile in auth provider to reflect new badges
        await authProvider.refreshUserProfile();
        
        // Check if widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            _xpUpdated = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error saving results: $e');
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract result data
    final score = widget.result['score'] as int;
    final total = widget.result['total'] as int;
    final percentage = widget.result['percentage'] as double;
    final categoryId = widget.result['categoryId'] as String;
    
    // Calculate stars based on percentage
    int stars = 0;
    if (percentage >= 80) {
      stars = 3;
    } else if (percentage >= 60) {
      stars = 2;
    } else if (percentage >= 40) {
      stars = 1;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false, // Disable back button
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result header
              FadeTransition(
                opacity: _animation,
                child: Text(
                  percentage >= 60 ? 'Great Job!' : 'Nice Try!',
                  style: TextStyle(
                    fontSize: AppConstants.headingFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              
              // Score animation
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score/$total',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: index < stars ? Colors.amber : Colors.grey,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              
              // Quiz details
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  child: Column(
                    children: [
                      _buildDetailRow('Category', categoryId),
                      const Divider(),
                      _buildDetailRow('Score', '$score out of $total correct'),
                      const Divider(),
                      _buildDetailRow('Percentage', '${percentage.toStringAsFixed(0)}%'),
                      const Divider(),
                      _buildDetailRow(
                        'XP Earned', 
                        '+${_quizService.calculateXP(score)} XP'
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.largeSpacing),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Restart the quiz with same parameters
                      _restartQuiz(context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Go back to category selection
                      context.go(AppConstants.homeRoute);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  void _restartQuiz(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    quizProvider.resetQuiz();
    
    // Navigate back to quiz screen with same parameters
    context.go(
      AppConstants.quizRoute,
      extra: {
        'categoryId': widget.result['categoryId'],
      },
    );
  }
} 