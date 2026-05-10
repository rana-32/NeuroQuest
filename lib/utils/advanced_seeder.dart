import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Advanced seeder to generate and upload large amounts of quiz data
class AdvancedSeeder {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Random _random = Random();
  static const String _seedCompletedKey = 'advanced_seed_completed';
  
  // Configuration for bulk seeding
  final int questionsPerCategory;
  final bool includeDifficulties;
  final bool includeExplanations;
  
  AdvancedSeeder({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    this.questionsPerCategory = 50,
    this.includeDifficulties = true,
    this.includeExplanations = true,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance;
  
  // Helper to get a random difficulty (40% easy, 40% medium, 20% hard)
  int _getDifficultyRoll() {
    return _random.nextInt(100);
  }
  
  // Helper to determine difficulty based on roll
  String _getDifficultyString(int roll) {
    if (roll < 40) return 'easy';
    if (roll < 80) return 'medium';
    return 'hard';
  }
  
  // Helper to determine points based on difficulty roll
  int _getPointsForDifficulty(int roll) {
    if (roll < 40) return 5;  // easy
    if (roll < 80) return 10; // medium
    return 15;                // hard
  }
  
  /// Check if advanced seeding has been completed
  Future<bool> _hasAdvancedSeedingBeenDone() async {
    try {
      // Check local preference first
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_seedCompletedKey) == true) {
        debugPrint('Advanced seeding already completed according to local preferences');
        return true;
      }
      
      // Double-check by counting questions
      final categoriesSnapshot = await _firestore.collection('categories').get();
      if (categoriesSnapshot.docs.isEmpty) {
        return false;
      }
      
      // Check if we have the expected number of questions
      for (final category in categoriesSnapshot.docs) {
        final categoryId = category.id;
        final querySnapshot = await _firestore
            .collection('questions')
            .where('categoryId', isEqualTo: categoryId)
            .count()
            .get();
            
        if ((querySnapshot.count ?? 0) < questionsPerCategory) {
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking if advanced seeding was done: $e');
      return false;
    }
  }
  
  /// Seed large amount of quiz data
  Future<void> seedLargeQuizData() async {
    // Skip in production unless explicitly forced
    if (!kDebugMode) {
      debugPrint('Skipping advanced data seeding in production');
      return;
    }
    
    try {
      // Check if already seeded
      if (await _hasAdvancedSeedingBeenDone()) {
        debugPrint('Database already contains advanced data, skipping seeding');
        return;
      }
      
      debugPrint('Starting advanced database seeding process...');
      
      // Make sure we have an authenticated user for Firestore writes
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        try {
          final userCredential = await _auth.signInAnonymously();
          currentUser = userCredential.user;
          debugPrint('Signed in anonymously for advanced database seeding');
        } catch (e) {
          debugPrint('Error signing in anonymously: $e');
          rethrow;
        }
      }
      
      // Get existing categories or seed new ones if needed
      final categories = await _getOrCreateCategories();
      
      // Generate and upload questions in batches
      int totalSeeded = 0;
      for (final category in categories) {
        final categoryId = category['id'] as String;
        debugPrint('Seeding $questionsPerCategory questions for category: $categoryId');
        
        // Seed questions in smaller batches to avoid hitting Firestore limits
        const batchSize = 100;
        for (int i = 0; i < questionsPerCategory; i += batchSize) {
          final count = min(batchSize, questionsPerCategory - i);
          await _seedQuestionsForCategory(categoryId, i, count);
          totalSeeded += count;
          debugPrint('Seeded batch of $count questions for $categoryId (total: $totalSeeded)');
        }
      }
      
      // Update category doc counts
      await _updateCategoryQuizCounts(categories);
      
      // Mark seeding as complete in local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seedCompletedKey, true);
      
      debugPrint('Advanced database seeding completed successfully. Total questions: $totalSeeded');
    } catch (e) {
      debugPrint('Error seeding large database: $e');
      rethrow;
    }
  }
  
  /// Get existing categories or create new ones if needed
  Future<List<Map<String, dynamic>>> _getOrCreateCategories() async {
    final categoriesSnapshot = await _firestore.collection('categories').get();
    
    if (categoriesSnapshot.docs.isNotEmpty) {
      return categoriesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    }
    
    // If no categories exist, create them
    final categories = [
      {
        'id': 'math',
        'name': 'Mathematics',
        'iconUrl': 'assets/icons/math.png',
        'description': 'Fun math puzzles and problems for young minds',
        'quizCount': questionsPerCategory,
        'requiredLevel': 1,
        'color': '#4CAF50', // Green
      },
      {
        'id': 'science',
        'name': 'Science',
        'iconUrl': 'assets/icons/science.png',
        'description': 'Exciting science facts and experiments',
        'quizCount': questionsPerCategory,
        'requiredLevel': 1,
        'color': '#2196F3', // Blue
      },
      {
        'id': 'language',
        'name': 'Language',
        'iconUrl': 'assets/icons/language.png',
        'description': 'Improve vocabulary and language skills',
        'quizCount': questionsPerCategory,
        'requiredLevel': 2,
        'color': '#FF9800', // Orange
      },
      {
        'id': 'nature',
        'name': 'Nature',
        'iconUrl': 'assets/icons/nature.png',
        'description': 'Learn about animals, plants and our planet',
        'quizCount': questionsPerCategory,
        'requiredLevel': 3,
        'color': '#8BC34A', // Light Green
      },
      {
        'id': 'history',
        'name': 'History',
        'iconUrl': 'assets/icons/history.png',
        'description': 'Discover amazing facts from the past',
        'quizCount': questionsPerCategory,
        'requiredLevel': 4,
        'color': '#9C27B0', // Purple
      },
      {
        'id': 'geography',
        'name': 'Geography',
        'iconUrl': 'assets/icons/geography.png',
        'description': 'Explore countries, cities and landmarks',
        'quizCount': questionsPerCategory,
        'requiredLevel': 5,
        'color': '#F44336', // Red
      },
      {
        'id': 'animals',
        'name': 'Animals',
        'iconUrl': 'assets/icons/animals.png',
        'description': 'Fascinating facts about animal kingdom',
        'quizCount': questionsPerCategory,
        'requiredLevel': 2,
        'color': '#FFC107', // Amber
      },
      {
        'id': 'space',
        'name': 'Space',
        'iconUrl': 'assets/icons/space.png',
        'description': 'Journey through planets, stars and galaxies',
        'quizCount': questionsPerCategory,
        'requiredLevel': 3,
        'color': '#3F51B5', // Indigo
      }
    ];
    
    // Upload categories
    final batch = _firestore.batch();
    for (final category in categories) {
      final docRef = _firestore.collection('categories').doc(category['id'] as String);
      batch.set(docRef, category);
    }
    await batch.commit();
    
    return categories;
  }
  
  /// Seed a batch of questions for a specific category
  Future<void> _seedQuestionsForCategory(String categoryId, int startIndex, int count) async {
    final batch = _firestore.batch();
    final Map<String, int> difficultyCounters = {
      'easy': 0,
      'medium': 0,
      'hard': 0
    };
    
    for (int i = 0; i < count; i++) {
      final questionIndex = startIndex + i;
      final question = _generateQuestion(categoryId, questionIndex);
      
      // Keep track of how many questions of each difficulty we've created
      final questionDifficulty = question['difficulty'] as String;
      difficultyCounters[questionDifficulty] = (difficultyCounters[questionDifficulty] ?? 0) + 1;
      
      final docRef = _firestore.collection('questions').doc(question['id'] as String);
      batch.set(docRef, question);
    }
    
    await batch.commit();
    
    // Log how many questions of each difficulty were created
    debugPrint('Created questions for $categoryId - Easy: ${difficultyCounters['easy']}, '
               'Medium: ${difficultyCounters['medium']}, Hard: ${difficultyCounters['hard']}');
  }
  
  /// Update quiz counts in categories
  Future<void> _updateCategoryQuizCounts(List<Map<String, dynamic>> categories) async {
    final batch = _firestore.batch();
    
    for (final category in categories) {
      final categoryId = category['id'] as String;
      final docRef = _firestore.collection('categories').doc(categoryId);
      
      batch.update(docRef, {'quizCount': questionsPerCategory});
    }
    
    await batch.commit();
  }
  
  /// Generate a question based on category and index
  Map<String, dynamic> _generateQuestion(String categoryId, int index) {
    // Create a simple ID with category and index
    final id = '${categoryId}_${index.toString().padLeft(3, '0')}';
    
    // Generate question based on category
    switch (categoryId) {
      case 'math':
        return _generateMathQuestion(id);
      case 'science':
        return _generateScienceQuestion(id);
      case 'language':
        return _generateLanguageQuestion(id);
      case 'nature': 
        return _generateNatureQuestion(id);
      case 'history':
        return _generateHistoryQuestion(id);
      case 'geography':
        return _generateGeographyQuestion(id);
      case 'animals':
        return _generateAnimalsQuestion(id);
      case 'space':
        return _generateSpaceQuestion(id);
      default:
        return _generateGenericQuestion(id, categoryId);
    }
  }
  
  int _getDifficultyForIndex(int index) {
    // Distribute difficulties: 40% easy (1), 40% medium (2), 20% hard (3)
    final roll = _random.nextInt(100);
    if (roll < 40) return 1;
    if (roll < 80) return 2;
    return 3;
  }
  
  Map<String, dynamic> _generateMathQuestion(String id) {
    final questionTypes = [
      _generateAdditionQuestion,
      _generateSubtractionQuestion,
      _generateMultiplicationQuestion,
      _generateDivisionQuestion,
      _generateFractionQuestion,
    ];
    
    final generator = questionTypes[_random.nextInt(questionTypes.length)];
    return generator(id);
  }
  
  Map<String, dynamic> _generateAdditionQuestion(String id) {
    int num1, num2;
    final roll = _getDifficultyRoll();
    if (roll < 40) {
      num1 = _random.nextInt(10) + 1;
      num2 = _random.nextInt(10) + 1;
    } else if (roll < 80) {
      num1 = _random.nextInt(50) + 10;
      num2 = _random.nextInt(50) + 10;
    } else {
      num1 = _random.nextInt(100) + 50;
      num2 = _random.nextInt(100) + 50;
    }
    
    final correctAnswer = (num1 + num2).toString();
    final options = _generateNumericOptions(num1 + num2);
    
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'math',
      'question': 'What is $num1 + $num2?',
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': 'To add $num1 and $num2, you count all the units together to get $correctAnswer.'
    };
  }
  
  Map<String, dynamic> _generateSubtractionQuestion(String id) {
    int num1, num2;
    final roll = _getDifficultyRoll();
    if (roll < 40) {
      num1 = _random.nextInt(10) + 11; // Ensure positive difference
      num2 = _random.nextInt(num1 - 1) + 1;
    } else if (roll < 80) {
      num1 = _random.nextInt(50) + 51;
      num2 = _random.nextInt(50) + 1;
    } else {
      num1 = _random.nextInt(100) + 101;
      num2 = _random.nextInt(100) + 1;
    }
    
    final correctAnswer = (num1 - num2).toString();
    final options = _generateNumericOptions(num1 - num2);
    
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'math',
      'question': 'What is $num1 - $num2?',
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': 'To subtract $num2 from $num1, you take away $num2 units from $num1 to get $correctAnswer.'
    };
  }
  
  Map<String, dynamic> _generateMultiplicationQuestion(String id) {
    int num1, num2;
    final roll = _getDifficultyRoll();
    if (roll < 40) {
      num1 = _random.nextInt(5) + 1;
      num2 = _random.nextInt(5) + 1;
    } else if (roll < 80) {
      num1 = _random.nextInt(7) + 3;
      num2 = _random.nextInt(7) + 3;
    } else {
      num1 = _random.nextInt(10) + 5;
      num2 = _random.nextInt(10) + 5;
    }
    
    final correctAnswer = (num1 * num2).toString();
    final options = _generateNumericOptions(num1 * num2);
    
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'math',
      'question': 'What is $num1 × $num2?',
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': 'To multiply $num1 by $num2, you add $num1 to itself $num2 times to get $correctAnswer.'
    };
  }
  
  Map<String, dynamic> _generateDivisionQuestion(String id) {
    int result, divisor;
    final roll = _getDifficultyRoll();
    if (roll < 40) {
      result = _random.nextInt(5) + 1;
      divisor = _random.nextInt(5) + 1;
    } else if (roll < 80) {
      result = _random.nextInt(10) + 1;
      divisor = _random.nextInt(5) + 1;
    } else {
      result = _random.nextInt(12) + 1;
      divisor = _random.nextInt(10) + 1;
    }
    
    final dividend = result * divisor;
    final correctAnswer = result.toString();
    final options = _generateNumericOptions(result);
    
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'math',
      'question': 'What is $dividend ÷ $divisor?',
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': 'To divide $dividend by $divisor, you find how many groups of $divisor can be made from $dividend to get $correctAnswer.'
    };
  }
  
  Map<String, dynamic> _generateFractionQuestion(String id) {
    int denominator, numerator;
    final roll = _getDifficultyRoll();
    if (roll < 40) {
      denominator = 2;
      numerator = 1;
    } else if (roll < 80) {
      denominator = _random.nextInt(3) * 2 + 2; // 2, 4, 6
      numerator = denominator ~/ 2;
    } else {
      denominator = _random.nextInt(4) * 2 + 4; // 4, 6, 8, 10
      numerator = _random.nextInt(denominator - 1) + 1;
    }
    
    final fraction = '$numerator/$denominator';
    final decimal = (numerator / denominator).toStringAsFixed(2);
    final percentage = '${((numerator / denominator) * 100).toStringAsFixed(0)}%';
    
    String questionText;
    String correctAnswer;
    List<String> options;
    
    final questionType = _random.nextInt(3);
    switch (questionType) {
      case 0:
        questionText = 'What is $fraction as a decimal?';
        correctAnswer = decimal;
        options = [
          decimal,
          (numerator / (denominator - 1)).toStringAsFixed(2),
          (numerator / (denominator + 1)).toStringAsFixed(2),
          ((numerator + 1) / denominator).toStringAsFixed(2),
        ];
        break;
      case 1:
        questionText = 'What is $decimal as a fraction?';
        correctAnswer = fraction;
        options = [
          fraction,
          '${numerator + 1}/$denominator',
          '$numerator/${denominator + 1}',
          '${numerator - 1}/$denominator',
        ];
        break;
      default:
        questionText = 'What is $fraction as a percentage?';
        correctAnswer = percentage;
        options = [
          percentage,
          '${((numerator / denominator) * 10).toStringAsFixed(0)}%',
          '${((numerator / denominator) * 1000).toStringAsFixed(0)}%',
          '${((numerator + 1) / denominator * 100).toStringAsFixed(0)}%',
        ];
    }
    
    options.shuffle();
    
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'math',
      'question': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': 'The fraction $fraction equals $decimal or $percentage.'
    };
  }
  
  Map<String, dynamic> _generateScienceQuestion(String id) {
    final scienceQuestions = [
      {
        'question': 'Which planet is closest to the Sun?',
        'options': ['Mercury', 'Venus', 'Earth', 'Mars'],
        'correctAnswer': 'Mercury',
        'explanation': 'Mercury is the first planet from the Sun and the smallest planet in our Solar System.'
      },
      {
        'question': 'What is the hardest natural substance on Earth?',
        'options': ['Gold', 'Iron', 'Diamond', 'Platinum'],
        'correctAnswer': 'Diamond',
        'explanation': 'Diamond is the hardest naturally occurring substance found on Earth, made from pure carbon.'
      },
      {
        'question': 'Which gas do plants absorb from the atmosphere?',
        'options': ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Hydrogen'],
        'correctAnswer': 'Carbon Dioxide',
        'explanation': 'Plants absorb carbon dioxide during photosynthesis and release oxygen.'
      }
    ];
    
    final baseQ = scienceQuestions[_random.nextInt(scienceQuestions.length)];
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'science',
      'question': baseQ['question'],
      'options': baseQ['options'],
      'correctAnswer': baseQ['correctAnswer'],
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': baseQ['explanation']
    };
  }
  
  Map<String, dynamic> _generateLanguageQuestion(String id) {
    final questions = [
      {
        'question': 'Which of these is a synonym for "happy"?',
        'options': ['Sad', 'Joyful', 'Angry', 'Tired'],
        'correctAnswer': 'Joyful',
        'explanation': 'A synonym is a word with the same meaning. "Joyful" means the same as "happy".'
      },
      {
        'question': 'Which word is spelled correctly?',
        'options': ['Recieve', 'Receive', 'Receve', 'Reciave'],
        'correctAnswer': 'Receive',
        'explanation': 'The correct spelling follows the rule "i before e except after c".'
      }
    ];
    
    final baseQ = questions[_random.nextInt(questions.length)];
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'language',
      'question': baseQ['question'],
      'options': baseQ['options'],
      'correctAnswer': baseQ['correctAnswer'],
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': baseQ['explanation']
    };
  }
  
  Map<String, dynamic> _generateNatureQuestion(String id) {
    final questions = [
      {
        'question': 'Which animal is a mammal?',
        'options': ['Shark', 'Snake', 'Dolphin', 'Lizard'],
        'correctAnswer': 'Dolphin',
        'explanation': 'Dolphins are mammals because they breathe air, give birth to live young, and produce milk for their babies.'
      },
      {
        'question': 'What type of tree stays green all year long?',
        'options': ['Evergreen', 'Deciduous', 'Oak', 'Maple'],
        'correctAnswer': 'Evergreen',
        'explanation': 'Evergreen trees keep their green leaves or needles throughout the year, unlike deciduous trees which shed their leaves.'
      }
    ];
    
    final baseQ = questions[_random.nextInt(questions.length)];
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'nature',
      'question': baseQ['question'],
      'options': baseQ['options'],
      'correctAnswer': baseQ['correctAnswer'],
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': baseQ['explanation']
    };
  }
  
  Map<String, dynamic> _generateHistoryQuestion(String id) {
    final questions = [
      {
        'question': 'Who was the first president of the United States?',
        'options': ['Thomas Jefferson', 'George Washington', 'Abraham Lincoln', 'John Adams'],
        'correctAnswer': 'George Washington',
        'explanation': 'George Washington served as the first president of the United States from 1789 to 1797.'
      },
      {
        'question': 'In which year did Christopher Columbus first arrive in the Americas?',
        'options': ['1492', '1776', '1620', '1066'],
        'correctAnswer': '1492',
        'explanation': 'Columbus first reached the Americas in 1492 during his first transatlantic voyage.'
      }
    ];
    
    final baseQ = questions[_random.nextInt(questions.length)];
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'history',
      'question': baseQ['question'],
      'options': baseQ['options'],
      'correctAnswer': baseQ['correctAnswer'],
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': baseQ['explanation']
    };
  }
  
  Map<String, dynamic> _generateGeographyQuestion(String id) {
    final questions = [
      {
        'question': 'What is the capital of France?',
        'options': ['London', 'Berlin', 'Paris', 'Madrid'],
        'correctAnswer': 'Paris',
        'explanation': 'Paris is the capital city of France, known for landmarks like the Eiffel Tower.'
      },
      {
        'question': 'Which is the largest ocean in the world?',
        'options': ['Atlantic Ocean', 'Indian Ocean', 'Arctic Ocean', 'Pacific Ocean'],
        'correctAnswer': 'Pacific Ocean',
        'explanation': 'The Pacific Ocean is the largest and deepest ocean on Earth.'
      }
    ];
    
    final baseQ = questions[_random.nextInt(questions.length)];
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'geography',
      'question': baseQ['question'],
      'options': baseQ['options'],
      'correctAnswer': baseQ['correctAnswer'],
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': baseQ['explanation']
    };
  }
  
  Map<String, dynamic> _generateAnimalsQuestion(String id) {
    final questions = [
      {
        'question': 'Which animal is the fastest land animal?',
        'options': ['Lion', 'Cheetah', 'Horse', 'Kangaroo'],
        'correctAnswer': 'Cheetah',
        'explanation': 'The cheetah can reach speeds of up to 70 mph (112 km/h), making it the fastest land animal.'
      },
      {
        'question': 'Which animal can change its skin color to match its surroundings?',
        'options': ['Chameleon', 'Snake', 'Frog', 'Gecko'],
        'correctAnswer': 'Chameleon',
        'explanation': 'Chameleons can change the color of their skin to blend with their environment and regulate body temperature.'
      }
    ];
    
    final baseQ = questions[_random.nextInt(questions.length)];
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'animals',
      'question': baseQ['question'],
      'options': baseQ['options'],
      'correctAnswer': baseQ['correctAnswer'],
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': baseQ['explanation']
    };
  }
  
  Map<String, dynamic> _generateSpaceQuestion(String id) {
    final questions = [
      {
        'question': 'Which planet is known as the Red Planet?',
        'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        'correctAnswer': 'Mars',
        'explanation': 'Mars is called the Red Planet because of the iron oxide (rust) on its surface that gives it a reddish appearance.'
      },
      {
        'question': 'What is the largest planet in our solar system?',
        'options': ['Earth', 'Saturn', 'Jupiter', 'Neptune'],
        'correctAnswer': 'Jupiter',
        'explanation': 'Jupiter is the largest planet in our solar system, with a mass more than twice that of all other planets combined.'
      }
    ];
    
    final baseQ = questions[_random.nextInt(questions.length)];
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': 'space',
      'question': baseQ['question'],
      'options': baseQ['options'],
      'correctAnswer': baseQ['correctAnswer'],
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': baseQ['explanation']
    };
  }
  
  Map<String, dynamic> _generateGenericQuestion(String id, String categoryId) {
    final roll = _getDifficultyRoll();
    final difficulty = _getDifficultyString(roll);
    final points = _getPointsForDifficulty(roll);
    
    return {
      'id': id,
      'categoryId': categoryId,
      'question': 'Question for $categoryId (Difficulty: $difficulty)',
      'options': ['Option A', 'Option B', 'Option C', 'Option D'],
      'correctAnswer': 'Option A',
      'difficulty': difficulty,
      'points': points,
      if (includeExplanations) 'explanation': 'This is a generic question for $categoryId with $difficulty difficulty.'
    };
  }
  
  List<String> _generateNumericOptions(int correctAnswer) {
    final options = <String>[];
    final roll = _getDifficultyRoll();
    final range = roll < 40 ? 3 : roll < 80 ? 6 : 9; // Wider range for higher difficulties
    
    options.add(correctAnswer.toString());
    
    while (options.length < 4) {
      final offset = _random.nextInt(range * 2 + 1) - range;
      
      // Ensure we don't add the correct answer again or add negative numbers
      final newOption = (correctAnswer + offset).toString();
      if (offset != 0 && !options.contains(newOption) && correctAnswer + offset > 0) {
        options.add(newOption);
      }
    }
    
    options.shuffle();
    return options;
  }
  
  /// Force reseeding the database with large dataset
  Future<void> forceReseedLarge() async {
    if (!kDebugMode) {
      debugPrint('Force reseeding large dataset is disabled in production');
      return;
    }
    
    // Clear the seeding flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seedCompletedKey);
    
    // Delete existing questions
    await _deleteCollection('questions');
    
    // Reseed
    await seedLargeQuizData();
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
  
  /// Force update or create all categories
  Future<void> forceUpdateCategories() async {
    // If no categories exist, create them
    final categories = [
      {
        'id': 'math',
        'name': 'Mathematics',
        'iconUrl': 'assets/icons/math.png',
        'description': 'Fun math puzzles and problems for young minds',
        'quizCount': questionsPerCategory,
        'requiredLevel': 1,
        'color': '#4CAF50', // Green
      },
      {
        'id': 'science',
        'name': 'Science',
        'iconUrl': 'assets/icons/science.png',
        'description': 'Exciting science facts and experiments',
        'quizCount': questionsPerCategory,
        'requiredLevel': 1,
        'color': '#2196F3', // Blue
      },
      {
        'id': 'language',
        'name': 'Language',
        'iconUrl': 'assets/icons/language.png',
        'description': 'Improve vocabulary and language skills',
        'quizCount': questionsPerCategory,
        'requiredLevel': 2,
        'color': '#FF9800', // Orange
      },
      {
        'id': 'nature',
        'name': 'Nature',
        'iconUrl': 'assets/icons/nature.png',
        'description': 'Learn about animals, plants and our planet',
        'quizCount': questionsPerCategory,
        'requiredLevel': 3,
        'color': '#8BC34A', // Light Green
      },
      {
        'id': 'history',
        'name': 'History',
        'iconUrl': 'assets/icons/history.png',
        'description': 'Discover amazing facts from the past',
        'quizCount': questionsPerCategory,
        'requiredLevel': 4,
        'color': '#9C27B0', // Purple
      },
      {
        'id': 'geography',
        'name': 'Geography',
        'iconUrl': 'assets/icons/geography.png',
        'description': 'Explore countries, cities and landmarks',
        'quizCount': questionsPerCategory,
        'requiredLevel': 5,
        'color': '#F44336', // Red
      },
      {
        'id': 'animals',
        'name': 'Animals',
        'iconUrl': 'assets/icons/animals.png',
        'description': 'Fascinating facts about animal kingdom',
        'quizCount': questionsPerCategory,
        'requiredLevel': 2,
        'color': '#FFC107', // Amber
      },
      {
        'id': 'space',
        'name': 'Space',
        'iconUrl': 'assets/icons/space.png',
        'description': 'Journey through planets, stars and galaxies',
        'quizCount': questionsPerCategory,
        'requiredLevel': 3,
        'color': '#3F51B5', // Indigo
      }
    ];
    
    // Upload categories
    final batch = _firestore.batch();
    for (final category in categories) {
      final docRef = _firestore.collection('categories').doc(category['id'] as String);
      batch.set(docRef, category, SetOptions(merge: true));
    }
    await batch.commit();
    
    debugPrint('All categories have been updated/created');
  }
} 