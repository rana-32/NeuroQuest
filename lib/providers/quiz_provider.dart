import 'dart:async';
import 'package:flutter/widgets.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../models/category.dart' as app_category;

class QuizProvider with ChangeNotifier {
  final QuizService _quizService = QuizService();
  final UserService _userService = UserService();
  
  bool _isLoading = false;
  List<app_category.Category> _categories = [];
  String _error = '';
  
  // Current quiz state
  String _currentCategory = '';
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  List<int> _userAnswers = [];
  bool _isQuizCompleted = false;
  int _remainingTime = 30;
  Timer? _timer;
  Map<String, dynamic>? _latestResult;
  app_category.Category? _selectedCategory;
  
  // Getters
  bool get isLoading => _isLoading;
  List<app_category.Category> get categories => _categories;
  String get error => _error;
  String get currentCategory => _currentCategory;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int> get userAnswers => _userAnswers;
  int get totalQuestions => _questions.length;
  bool get isQuizComplete => _currentQuestionIndex >= totalQuestions;
  
  // Added getters to match errors
  bool get isQuizCompleted => _isQuizCompleted;
  Map<String, dynamic>? get latestResult => _latestResult;
  Question? get currentQuestion => 
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length 
          ? _questions[_currentQuestionIndex] 
          : null;
  int get remainingTime => _remainingTime;
  app_category.Category? get selectedCategory => _selectedCategory;
  
  // Load categories
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = '';
      // Don't call notifyListeners here - doing so during build causes an error
      
      _categories = await _quizService.getCategories();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Load categories with post-frame callback - safe to call during build
  void loadCategoriesSafely(BuildContext context) {
    // Use a post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadCategories();
    });
  }
  
  // Select a category
  void selectCategory(app_category.Category category) {
    _selectedCategory = category;
    _currentCategory = category.id;
    notifyListeners();
  }
  
  // Start a new quiz
  Future<bool> startQuiz() async {
    if (_selectedCategory == null) {
      _error = 'Please select a category';
      notifyListeners();
      return false;
    }
    
    return await startQuizWithCategory(_currentCategory);
  }
  
  // Start a new quiz with category
  Future<bool> startQuizWithCategory(String categoryId) async {
    try {
      _isLoading = true;
      _error = '';
      _isQuizCompleted = false;
      _latestResult = null;
      notifyListeners();
      
      _currentCategory = categoryId;
      _currentQuestionIndex = 0;
      _userAnswers = [];
      
      _questions = await _quizService.getQuestions(categoryId);
      
      if (_questions.isEmpty) {
        _error = 'No questions available for this category';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      _startTimer(30);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Answer a question - numeric index version
  void answerQuestion(int answerIndex) {
    if (_currentQuestionIndex < totalQuestions) {
      _userAnswers.add(answerIndex);
      
      _cancelTimer();
      
      // Don't automatically move to next question
      // Let the UI control when to move to the next question
      notifyListeners();
    }
  }
  
  // Answer a question - string version for backward compatibility
  void submitAnswer(String answer) {
    if (_isQuizCompleted) return;
    
    // Convert string answer to numeric index if needed
    final currentQ = currentQuestion;
    int answerIndex = -1;
    
    if (currentQ != null) {
      answerIndex = currentQ.options.indexOf(answer);
      if (answerIndex == -1) answerIndex = 0; // Default to first option if not found
    }
    
    // Add the answer
    _userAnswers.add(answerIndex);
    
    _cancelTimer();
    
    // Don't automatically move to the next question
    notifyListeners();
  }
  
  // Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      _startTimer(30);
      notifyListeners();
    } else if (!_isQuizCompleted) {
      _completeQuiz();
    }
  }
  
  // Complete the quiz
  Future<void> _completeQuiz() async {
    _cancelTimer();
    _isQuizCompleted = true;
    
    // Calculate results
    final results = getResults();
    _latestResult = {
      'categoryId': _currentCategory,
      'score': results['score'],
      'total': results['total'],
      'percentage': results['percentage'],
      'completedAt': DateTime.now().millisecondsSinceEpoch,
    };
    
    notifyListeners();
  }
  
  // Start timer
  void _startTimer(int seconds) {
    _cancelTimer();
    _remainingTime = seconds;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        notifyListeners();
      } else {
        // Time's up, move to next question
        if (_currentQuestionIndex < totalQuestions - 1) {
          _userAnswers.add(-1); // Add "no answer"
          nextQuestion();
        } else {
          _userAnswers.add(-1); // Add "no answer"
          _completeQuiz();
        }
      }
    });
  }
  
  // Cancel timer
  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }
  }
  
  // Get quiz results
  Map<String, dynamic> getResults() {
    int correctAnswers = 0;
    
    for (int i = 0; i < _userAnswers.length; i++) {
      if (i < _questions.length) {
        final question = _questions[i];
        final correctAnswerIndex = question.correctAnswerIndex;
        
        if (_userAnswers[i] == correctAnswerIndex) {
          correctAnswers++;
        }
      }
    }
    
    return {
      'score': correctAnswers,
      'total': totalQuestions,
      'percentage': totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0,
    };
  }
  
  // Reset quiz
  void resetQuiz() {
    _cancelTimer();
    _currentCategory = '';
    _questions = [];
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _error = '';
    _isQuizCompleted = false;
    _latestResult = null;
    _selectedCategory = null;
    notifyListeners();
  }
  
  // Save quiz results and update user XP
  Future<bool> saveQuizResults(String userId) async {
    if (_latestResult == null) return false;
    
    try {
      // Calculate XP based on score
      final int xpEarned = _quizService.calculateXP(_latestResult!['score'] as int);
      
      // Add XP and user ID to result
      final resultWithXP = {
        ..._latestResult!,
        'userId': userId,
        'xpEarned': xpEarned,
      };
      
      // Save result to database
      return await _quizService.saveQuizResult(resultWithXP, userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
} 