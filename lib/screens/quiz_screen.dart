import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/sound_manager.dart';
import '../widgets/answer_option.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/question_progress.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;

  const QuizScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final SoundManager _soundManager = SoundManager();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showAnswerFeedback = false;
  bool _isCorrect = false;
  String _selectedAnswer = '';
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.questionAnimationDuration,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isQuizCompleted && quizProvider.latestResult != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(
              AppConstants.resultRoute,
              extra: quizProvider.latestResult,
            );
          });
          return const Center(child: CircularProgressIndicator());
        }
        
        final currentQuestion = quizProvider.currentQuestion;
        
        if (currentQuestion == null) {
          return const Scaffold(
            body: Center(
              child: Text('No questions available'),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text('Quiz: ${widget.categoryId}'),
            actions: [
              // Skip button (for testing)
              TextButton(
                onPressed: () {
                  _showSkipConfirmationDialog(context, quizProvider);
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress bar and timer
              Container(
                padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Row(
                  children: [
                    // Question progress
                    Expanded(
                      child: QuestionProgress(
                        current: quizProvider.currentQuestionIndex + 1,
                        total: quizProvider.questions.length,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Timer
                    CountdownTimer(
                      remainingSeconds: quizProvider.remainingTime,
                      totalSeconds: 30,
                    ),
                  ],
                ),
              ),
              
              // Question card
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  child: FadeTransition(
                    opacity: _animation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text
                        Text(
                          'Question ${quizProvider.currentQuestionIndex + 1}',
                          style: TextStyle(
                            fontSize: AppConstants.bodyFontSize,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentQuestion.question,
                          style: TextStyle(
                            fontSize: AppConstants.subheadingFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Answer options
                        ..._buildAnswerOptions(currentQuestion, quizProvider),
                        
                        const SizedBox(height: 24),
                        
                        // Explanation (shown after answer)
                        if (_showAnswerFeedback)
                          _buildAnswerFeedback(currentQuestion),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom controls
              if (_showAnswerFeedback)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  color: Theme.of(context).colorScheme.surface,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showAnswerFeedback = false;
                        _selectedAnswer = '';
                      });
                      _animationController.reset();
                      quizProvider.nextQuestion();
                      _animationController.forward();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Next Question',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  List<Widget> _buildAnswerOptions(Question question, QuizProvider quizProvider) {
    final options = question.options;
    final correctAnswerIndex = question.correctAnswerIndex;
    
    return List.generate(options.length, (index) {
      final option = options[index];
      final isSelected = _selectedAnswer == option;
      final isDisabled = _showAnswerFeedback;
      final isCorrect = _showAnswerFeedback && index == correctAnswerIndex;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AnswerOption(
          text: option,
          isSelected: isSelected,
          isCorrect: isCorrect,
          isDisabled: isDisabled,
          onTap: () => _handleAnswerSelected(option, index, quizProvider),
        ),
      );
    });
  }
  
  Widget _buildAnswerFeedback(Question question) {
    // Since we don't have an explanation field in our Question model, create a simple explanation
    final correctAnswer = question.correctAnswer;
    final explanation = "The correct answer is: $correctAnswer";
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCorrect 
            ? Colors.green.withOpacity(0.1) 
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                _isCorrect ? 'Correct!' : 'Incorrect!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  void _handleAnswerSelected(String answer, int answerIndex, QuizProvider quizProvider) {
    if (_showAnswerFeedback) return;
    
    _soundManager.playClickSound();
    
    final currentQuestion = quizProvider.currentQuestion;
    if (currentQuestion == null) return;
    
    final correctAnswerIndex = currentQuestion.correctAnswerIndex;
    final isCorrect = answerIndex == correctAnswerIndex;
    
    setState(() {
      _showAnswerFeedback = true;
      _selectedAnswer = answer;
      _isCorrect = isCorrect;
    });
    
    quizProvider.answerQuestion(answerIndex);
  }
  
  void _showSkipConfirmationDialog(BuildContext context, QuizProvider quizProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Question?'),
        content: const Text('Are you sure you want to skip this question? You will not earn points for it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              quizProvider.answerQuestion(-1); // -1 indicates skipped
              quizProvider.nextQuestion(); // Explicitly move to next question after skipping
              setState(() {
                _showAnswerFeedback = false;
                _selectedAnswer = '';
              });
              _animationController.reset();
              _animationController.forward();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
} 