import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A utility class for seeding quiz data into Firestore.
/// This class handles safe initialization of sample data for development and testing.
class DatabaseSeeder {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  static const String _seedCompletedKey = 'database_seed_completed';
  
  DatabaseSeeder({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance;
  
  /// Checks if data seeding has already been performed
  Future<bool> _hasSeedingBeenDone() async {
    try {
      // Check local preference first
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_seedCompletedKey) == true) {
        debugPrint('Seeding already completed according to local preferences');
        return true;
      }
      
      // Double-check by looking for existing data
      final categoriesSnapshot = await _firestore.collection('categories').limit(1).get();
      return categoriesSnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if seeding was done: $e');
      return false;
    }
  }
  
  /// Seeds the database with initial quiz data if it hasn't been done yet
  Future<void> seedQuizData() async {
    // Skip in production unless explicitly forced
    if (!kDebugMode) {
      debugPrint('Skipping data seeding in production');
      return;
    }
    
    try {
      // Check if already seeded
      if (await _hasSeedingBeenDone()) {
        debugPrint('Database already contains data, skipping seeding');
        return;
      }
      
      debugPrint('Starting database seeding process...');
      
      // Make sure we have an authenticated user for Firestore writes
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        // Sign in anonymously just for seeding (development only)
        try {
          final userCredential = await _auth.signInAnonymously();
          currentUser = userCredential.user;
          debugPrint('Signed in anonymously for database seeding');
        } catch (e) {
          debugPrint('Error signing in anonymously: $e');
          rethrow;
        }
      }
      
      // Use a batch for atomic operations
      final batch = _firestore.batch();
      
      // Seed categories
      _seedCategories(batch);
      
      // Seed questions
      _seedQuestions(batch);
      
      // Commit all changes
      await batch.commit();
      
      // Mark seeding as complete in local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seedCompletedKey, true);
      
      debugPrint('Database seeding completed successfully');
    } catch (e) {
      debugPrint('Error seeding database: $e');
      rethrow;
    }
  }
  
  /// Seeds category data
  void _seedCategories(WriteBatch batch) {
    final categories = [
      {
        'id': 'math',
        'name': 'Mathematics',
        'iconUrl': 'assets/icons/math.png',
        'description': 'Fun math puzzles and problems for young minds',
        'quizCount': 5,
        'requiredLevel': 1, // Unlock from the start
      },
      {
        'id': 'science',
        'name': 'Science',
        'iconUrl': 'assets/icons/science.png',
        'description': 'Exciting science facts and experiments',
        'quizCount': 5,
        'requiredLevel': 1, // Unlock from the start
      },
      {
        'id': 'language',
        'name': 'Language',
        'iconUrl': 'assets/icons/language.png',
        'description': 'Improve vocabulary and language skills',
        'quizCount': 3,
        'requiredLevel': 2, // Requires level 2
      },
      {
        'id': 'nature',
        'name': 'Nature',
        'iconUrl': 'assets/icons/nature.png',
        'description': 'Learn about animals, plants and our planet',
        'quizCount': 4,
        'requiredLevel': 3, // Requires level 3
      },
      {
        'id': 'history',
        'name': 'History',
        'iconUrl': 'assets/icons/history.png',
        'description': 'Discover amazing facts from the past',
        'quizCount': 3,
        'requiredLevel': 4, // Requires level 4
      }
    ];
    
    for (final category in categories) {
      final docRef = _firestore.collection('categories').doc(category['id'] as String);
      batch.set(docRef, category);
    }
  }
  
  /// Seeds question data
  void _seedQuestions(WriteBatch batch) {
    // Math questions
    final mathQuestions = [
      {
        'id': 'math_q1',
        'categoryId': 'math',
        'question': 'What is 2 + 2?',
        'options': ['3', '4', '5', '6'],
        'correctAnswer': '4',
        'difficulty': 'all',
        'points': 5
      },
      {
        'id': 'math_q2',
        'categoryId': 'math',
        'question': 'What is 5 - 2?',
        'options': ['1', '2', '3', '4'],
        'correctAnswer': '3',
        'difficulty': 'all',
        'points': 5
      },
      {
        'id': 'math_q3',
        'categoryId': 'math',
        'question': 'What is 3 × 4?',
        'options': ['7', '10', '12', '15'],
        'correctAnswer': '12',
        'difficulty': 'all',
        'points': 10
      },
      {
        'id': 'math_q4',
        'categoryId': 'math',
        'question': 'What is 10 ÷ 2?',
        'options': ['2', '4', '5', '8'],
        'correctAnswer': '5',
        'difficulty': 'all',
        'points': 10
      },
      {
        'id': 'math_q5',
        'categoryId': 'math',
        'question': 'What is half of 16?',
        'options': ['4', '6', '8', '10'],
        'correctAnswer': '8',
        'difficulty': 'all',
        'points': 10
      }
    ];
    
    // Science questions
    final scienceQuestions = [
      {
        'id': 'science_q1',
        'categoryId': 'science',
        'question': 'What planet is known as the Red Planet?',
        'options': ['Earth', 'Mars', 'Jupiter', 'Venus'],
        'correctAnswer': 'Mars',
        'difficulty': 'all',
        'points': 5
      },
      {
        'id': 'science_q2',
        'categoryId': 'science',
        'question': 'What do plants use to make their food?',
        'options': ['Sunlight', 'Water', 'Both A and B', 'Soil'],
        'correctAnswer': 'Both A and B',
        'difficulty': 'all',
        'points': 10
      },
      {
        'id': 'science_q3',
        'categoryId': 'science',
        'question': 'Which animal can fly?',
        'options': ['Fish', 'Bird', 'Snake', 'Frog'],
        'correctAnswer': 'Bird',
        'difficulty': 'all',
        'points': 5
      },
      {
        'id': 'science_q4',
        'categoryId': 'science',
        'question': 'What is the largest ocean on Earth?',
        'options': ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
        'correctAnswer': 'Pacific',
        'difficulty': 'all',
        'points': 10
      },
      {
        'id': 'science_q5',
        'categoryId': 'science',
        'question': 'What do we breathe in to stay alive?',
        'options': ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
        'correctAnswer': 'Oxygen',
        'difficulty': 'all',
        'points': 5
      }
    ];
    
    // Language questions
    final languageQuestions = [
      {
        'id': 'language_q1',
        'categoryId': 'language',
        'question': 'Which word means the opposite of "hot"?',
        'options': ['Warm', 'Cold', 'Burning', 'Boiling'],
        'correctAnswer': 'Cold',
        'difficulty': 'all',
        'points': 5
      },
      {
        'id': 'language_q2',
        'categoryId': 'language',
        'question': 'How many vowels are in the English alphabet?',
        'options': ['3', '4', '5', '6'],
        'correctAnswer': '5',
        'difficulty': 'all',
        'points': 5
      },
      {
        'id': 'language_q3',
        'categoryId': 'language',
        'question': 'Which of these is a color?',
        'options': ['Dog', 'House', 'Blue', 'Run'],
        'correctAnswer': 'Blue',
        'difficulty': 'all',
        'points': 5
      }
    ];
    
    // Combine all questions
    final allQuestions = [
      ...mathQuestions,
      ...scienceQuestions,
      ...languageQuestions,
    ];
    
    // Add all questions to the batch
    for (final question in allQuestions) {
      final docRef = _firestore.collection('questions').doc(question['id'] as String);
      batch.set(docRef, question);
    }
  }
  
  /// Force reseeding of database (use cautiously, typically only for development/testing)
  Future<void> forceReseed() async {
    if (!kDebugMode) {
      debugPrint('Force reseeding is disabled in production');
      return;
    }
    
    // Clear the seeding flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seedCompletedKey);
    
    // Delete existing data
    await _deleteCollection('categories');
    await _deleteCollection('questions');
    
    // Reseed
    await seedQuizData();
  }
  
  /// Helper to delete a collection
  Future<void> _deleteCollection(String collectionPath) async {
    final collection = await _firestore.collection(collectionPath).get();
    
    // Create a batch to delete documents
    final batch = _firestore.batch();
    var counter = 0;
    
    for (final doc in collection.docs) {
      batch.delete(doc.reference);
      counter++;
      
      // Firestore batches can only contain 500 operations at once
      if (counter >= 400) {
        await batch.commit();
        counter = 0;
      }
    }
    
    // Commit any remaining deletes
    if (counter > 0) {
      await batch.commit();
    }
  }
} 