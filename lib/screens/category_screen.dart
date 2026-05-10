import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../models/category.dart' as app_category;
import '../providers/quiz_provider.dart';
import '../utils/sound_manager.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryId;
  final SoundManager _soundManager = SoundManager();
  
  CategoryScreen({
    super.key,
    required this.categoryId,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // Find the category by id
        app_category.Category? category;
        if (quizProvider.categories.isNotEmpty) {
          category = quizProvider.categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => app_category.Category(
              id: categoryId,
              name: 'Unknown Category',
              iconUrl: '',
              description: 'No description available.',
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(category?.name ?? 'Category'),
          ),
          body: Column(
            children: [
              // Header with category image and description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Category image
                        if (category?.iconUrl.isNotEmpty ?? false)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              category!.iconUrl,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120,
                                  width: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, size: 40),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.category,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Category name and description
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              category?.name ?? 'Category',
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category?.description ?? 'No description available.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Information about the quiz
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About this Quiz:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    
                    // Quiz info card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const ListTile(
                              leading: Icon(Icons.question_answer),
                              title: Text('10 Questions'),
                              dense: true,
                            ),
                            const ListTile(
                              leading: Icon(Icons.timer),
                              title: Text('30 seconds per question'),
                              dense: true,
                            ),
                            if (category != null)
                              ListTile(
                                leading: const Icon(Icons.list_alt),
                                title: Text('${category.quizCount} quizzes available'),
                                dense: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Start quiz button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _soundManager.playClickSound();
                      _startQuiz(context, quizProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Start Quiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
  
  void _startQuiz(BuildContext context, QuizProvider quizProvider) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Text('Loading quiz...'),
          ],
        ),
      ),
    );
    
    // Start quiz
    final success = await quizProvider.startQuizWithCategory(categoryId);
    
    // Dismiss loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }
    
    if (success && context.mounted) {
      // Navigate to quiz screen
      context.push(
        AppConstants.quizRoute,
        extra: {
          'categoryId': categoryId,
        },
      );
    } else if (context.mounted) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(quizProvider.error.isNotEmpty
              ? quizProvider.error
              : 'Failed to load quiz questions. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
} 