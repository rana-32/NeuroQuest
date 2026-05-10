import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../models/category.dart' as app_category;

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _questionsCollection = 'questions';
  final String _categoriesCollection = 'categories';
  final String _resultsCollection = 'quiz_results';

  // Get all categories
  Future<List<app_category.Category>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return app_category.Category.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  // Get category by ID
  Future<app_category.Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return app_category.Category.fromJson(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting category: $e');
      return null;
    }
  }

  // Get questions for a category
  Future<List<Question>> getQuestions(String categoryId) async {
    try {
      // Get all questions for the category
      final snapshot = await _firestore
          .collection('questions')
          .where('categoryId', isEqualTo: categoryId)
          .get();
      
      // Use Maps to track unique questions both by ID and by content
      final Map<String, Question> uniqueQuestionsMap = {};
      final Map<String, Question> uniqueContentMap = {};
      
      // Convert to Question objects and ensure uniqueness
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final id = doc.id;
        data['id'] = id;
        
        final question = Question.fromJson(data);
        
        // Add to map using ID as key to ensure uniqueness
        uniqueQuestionsMap[id] = question;
        
        // Also track by question content to prevent duplicates with different IDs
        // Create a content key that combines the question text and answers
        final contentKey = '${question.question}_${question.correctAnswer}';
        uniqueContentMap[contentKey] = question;
      }
      
      // Use the content-based map for truly unique questions
      final List<Question> uniqueQuestions = uniqueContentMap.values.toList();
      
      // Log the number of questions found
      debugPrint('Found ${snapshot.docs.length} total questions and ${uniqueQuestions.length} unique questions for category $categoryId');
      
      // Shuffle the unique questions
      uniqueQuestions.shuffle();
      
      // Take only the first 10 questions (or fewer if less are available)
      final questionCount = uniqueQuestions.length > 10 ? 10 : uniqueQuestions.length;
      final result = uniqueQuestions.sublist(0, questionCount);
      
      debugPrint('Returning ${result.length} questions for quiz');
      
      return result;
    } catch (e) {
      debugPrint('Error getting questions: $e');
      return [];
    }
  }

  // Save quiz result
  Future<bool> saveQuizResult(Map<String, dynamic> result, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('results')
          .add(result);
          
      return true;
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
      return false;
    }
  }

  // Get user's quiz results
  Future<List<QuizResult>> getUserQuizResults(String userId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_resultsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizResult.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error getting user quiz results: $e');
      return [];
    }
  }

  // Calculate XP from score
  int calculateXP(int score, [int multiplier = 10]) {
    return score * multiplier;
  }

  // Determine badges earned from quiz result
  List<String> determineBadgesEarned(QuizResult result, UserProfile userProfile) {
    final List<String> newBadges = [];
    
    // Logic for badge determination based on score and category
    if (result.score == result.totalQuestions) {
      newBadges.add('Perfect Score: ${result.categoryId}');
    }
    
    if (result.score >= 3) {
      newBadges.add('${result.categoryId} Expert');
    }
    
    // Check XP milestones
    final totalXP = userProfile.xp + result.xpEarned;
    if (totalXP >= 100 && !userProfile.badges.contains('100 XP Club')) {
      newBadges.add('100 XP Club');
    }
    if (totalXP >= 500 && !userProfile.badges.contains('500 XP Club')) {
      newBadges.add('500 XP Club');
    }
    
    // Filter out badges user already has
    return newBadges.where((badge) => !userProfile.badges.contains(badge)).toList();
  }
} 