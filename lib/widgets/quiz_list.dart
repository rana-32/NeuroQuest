import 'package:flutter/material.dart';
import '../models/models.dart';
import 'quiz_card.dart';

class QuizList extends StatelessWidget {
  final List<Quiz> quizzes;
  final Map<String, bool> completedQuizzes;
  final Function(Quiz) onQuizSelected;

  const QuizList({
    super.key,
    required this.quizzes,
    required this.completedQuizzes,
    required this.onQuizSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) {
      return const Center(
        child: Text('No quizzes available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final isCompleted = completedQuizzes[quiz.id] ?? false;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: QuizCard(
            quiz: quiz,
            isCompleted: isCompleted,
            onTap: () => onQuizSelected(quiz),
          ),
        );
      },
    );
  }
} 