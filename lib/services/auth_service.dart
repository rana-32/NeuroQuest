import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/models.dart';
import 'user_service.dart';

class AuthService {
  late final FirebaseAuth _auth;
  late final GoogleSignIn _googleSignIn;
  final UserService _userService = UserService();
  bool _isInitialized = false;

  AuthService() {
    _initServices();
  }

  void _initServices() {
    try {
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing AuthService: $e');
      _isInitialized = false;
    }
  }

  // Auth change user stream
  Stream<User?> get userStream {
    if (!_isInitialized) {
      // Return empty stream if not initialized
      return Stream.value(null);
    }
    return _auth.authStateChanges();
  }
  
  // Get current user
  User? get currentUser {
    if (!_isInitialized) return null;
    return _auth.currentUser;
  }

  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    if (!_isInitialized) {
      throw Exception('Firebase Auth is not initialized');
    }

    try {
      final userCredential = await _auth.signInAnonymously();
      await _createUserProfileIfNotExists(userCredential.user!);
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }

  // Sign in with email & password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    if (!_isInitialized) {
      throw Exception('Firebase Auth is not initialized');
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      return null;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    if (!_isInitialized) {
      throw Exception('Firebase Auth is not initialized');
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in flow
        debugPrint('Google Sign In: User canceled the sign-in flow');
        return null;
      }
      
      try {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        // Sign in to Firebase with the Google credential
        final userCredential = await _auth.signInWithCredential(credential);
        
        // Create or update user profile
        await _createUserProfileIfNotExists(userCredential.user!);
        
        return userCredential.user;
      } catch (authError) {
        // Handle auth specific errors 
        debugPrint('Error during Google authentication: $authError');
        
        // Try to sign out of Google to avoid stuck state
        try {
          await _googleSignIn.signOut();
        } catch (e) {
          debugPrint('Failed to sign out of Google after auth error: $e');
        }
        
        return null;
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      
      // Try to sign out of Google to clean up the state
      try {
        await _googleSignIn.signOut();
      } catch (signOutError) {
        debugPrint('Failed to sign out of Google after error: $signOutError');
      }
      
      return null;
    }
  }

  // Register with email & password
  Future<User?> registerWithEmailAndPassword(
    String email, 
    String password, 
    String name, 
    int age
  ) async {
    if (!_isInitialized) {
      throw Exception('Firebase Auth is not initialized');
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create a new user profile
      await _userService.createUser(
        UserProfile(
          uid: userCredential.user!.uid,
          name: name,
          age: age,
          xp: 50,
          badges: [],
          progress: {},
        ),
      );
      
      return userCredential.user;
    } catch (e) {
      debugPrint('Error registering with email and password: $e');
      return null;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    if (!_isInitialized) {
      throw Exception('Firebase Auth is not initialized');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!_isInitialized) {
      throw Exception('Firebase Auth is not initialized');
    }

    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Create user profile if not exists
  Future<void> _createUserProfileIfNotExists(User user) async {
    try {
      final userProfile = await _userService.getUserProfile(user.uid);
      
      if (userProfile == null) {
        final prefs = await SharedPreferences.getInstance();
        final String defaultName = user.displayName ?? 'Player${user.uid.substring(0, 4)}';
        final int defaultAge = 8;
        
        // Create a new user profile
        await _userService.createUser(
          UserProfile(
            uid: user.uid,
            name: defaultName,
            age: defaultAge,
            xp: 50,
            badges: [],
            progress: {},
          ),
        );
        
        // Store user created flag
        await prefs.setBool('user_created', true);
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
    }
  }
} 