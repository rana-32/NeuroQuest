import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/models.dart';
import '../services/services.dart';

class AuthProvider with ChangeNotifier {
  AuthService? _authService;
  UserService? _userService;
  
  User? _user;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String _error = '';
  bool _isFirebaseInitialized = false;

  // Getters
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String get error => _error;
  bool get isFirebaseInitialized => _isFirebaseInitialized;

  // Constructor to listen to auth changes
  AuthProvider() {
    _checkFirebaseInitialization();
  }

  // Check if Firebase is initialized and set up services
  Future<void> _checkFirebaseInitialization() async {
    try {
      // Check if Firebase is initialized
      Firebase.app();
      _isFirebaseInitialized = true;
      
      // Set up services
      _authService = AuthService();
      _userService = UserService();
      
      // Initialize auth state
      _init();
    } catch (e) {
      _isFirebaseInitialized = false;
      _error = 'Firebase is not initialized. Some features will be unavailable.';
      debugPrint('Error initializing Firebase: $e');
    }
    notifyListeners();
  }

  // Manually check Firebase initialization - can be called from UI
  Future<void> tryReconnectFirebase() async {
    if (!_isFirebaseInitialized) {
      await _checkFirebaseInitialization();
    }
  }

  // Initialize auth state
  Future<void> _init() async {
    if (_authService == null) return;
    
    _authService!.userStream.listen((User? user) async {
      _user = user;
      
      if (user != null && _userService != null) {
        await _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
      }
      
      notifyListeners();
    });
  }

  // Load user profile
  Future<void> _loadUserProfile(String uid) async {
    if (_userService == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      _userProfile = await _userService!.getUserProfile(uid);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Sign in anonymously
  Future<bool> signInAnonymously() async {
    if (_authService == null) {
      _error = 'Authentication service not available';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final user = await _authService!.signInAnonymously();
      
      _isLoading = false;
      notifyListeners();
      
      return user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (_authService == null) {
      _error = 'Authentication service not available';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final user = await _authService!.signInWithEmailAndPassword(email, password);
      
      _isLoading = false;
      notifyListeners();
      
      return user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    if (_authService == null) {
      _error = 'Authentication service not available';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final user = await _authService!.signInWithGoogle();
      
      _isLoading = false;
      notifyListeners();
      
      return user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
    int age,
  ) async {
    if (_authService == null) {
      _error = 'Authentication service not available';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final user = await _authService!.registerWithEmailAndPassword(
        email,
        password,
        name,
        age,
      );
      
      _isLoading = false;
      notifyListeners();
      
      return user != null;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    if (_authService == null) {
      _error = 'Authentication service not available';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final success = await _authService!.sendPasswordResetEmail(email);
      
      _isLoading = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (_authService == null) {
      _error = 'Authentication service not available';
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      await _authService!.signOut();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    int? age,
  }) async {
    if (_userService == null || _user == null || _userProfile == null) {
      _error = 'User service not available or user not logged in';
      notifyListeners();
      return false;
    }
    
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      
      final updatedProfile = _userProfile!.copyWith(
        name: name,
        age: age,
      );
      
      await _userService!.updateUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      
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

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
  
  // Refresh user profile from Firestore
  Future<void> refreshUserProfile() async {
    if (_userService == null || _user == null) {
      _error = 'User service not available or user not logged in';
      return;
    }
    
    try {
      await _loadUserProfile(_user!.uid);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 