import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final int total;
  final double percentage;
  final String message;
  final bool isSuccess;
  final Color? backgroundColor;
  final Color? textColor;
  
  ScoreCard({
    super.key,
    required this.score,
    required this.total,
    String? message,
    Color? backgroundColor,
    Color? textColor,
  }) : 
    percentage = total > 0 ? (score / total) * 100 : 0,
    isSuccess = total > 0 ? (score / total) >= 0.7 : false,
    message = message ?? _getDefaultMessage(total > 0 ? (score / total) : 0),
    backgroundColor = backgroundColor,
    textColor = textColor;
  
  static String _getDefaultMessage(double ratio) {
    if (ratio >= 0.9) {
      return 'Outstanding! You\'re a genius! 🌟';
    } else if (ratio >= 0.8) {
      return 'Amazing job! You\'re a star! ⭐';
    } else if (ratio >= 0.7) {
      return 'Great work! You\'re doing very well! 👏';
    } else if (ratio >= 0.6) {
      return 'Good effort! Keep practicing! 👍';
    } else if (ratio >= 0.5) {
      return 'Not bad! You\'re on the right track! 🙂';
    } else {
      return 'Keep trying! You\'ll get better! 💪';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? (isSuccess ? colorScheme.primary : colorScheme.error);
    final txtColor = textColor ?? Colors.white;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              child: isSuccess
                ? Lottie.asset(
                    'assets/animations/success.json',
                    repeat: false,
                  )
                : Lottie.asset(
                    'assets/animations/try_again.json',
                    repeat: false,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $score / $total',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: txtColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: txtColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 