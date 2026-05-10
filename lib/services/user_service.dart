import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create a new user
  Future<void> createUser(UserProfile user) async {
    try {
      await _firestore.collection(_collection).doc(user.uid).set(user.toJson());
    } catch (e) {
      debugPrint('Error creating user: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['uid'] = uid; // Ensure UID is included
        return UserProfile.fromJson(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserProfile user) async {
    try {
      await _firestore.collection(_collection).doc(user.uid).update(user.toJson());
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  // Update user XP
  Future<void> updateUserXP(String uid, int additionalXP) async {
    try {
      final userDoc = _firestore.collection(_collection).doc(uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        
        if (snapshot.exists) {
          final currentXP = snapshot.data()?['xp'] ?? 0;
          transaction.update(userDoc, {'xp': currentXP + additionalXP});
        }
      });
    } catch (e) {
      debugPrint('Error updating user XP: $e');
      rethrow;
    }
  }

  // Add badge to user
  Future<void> addUserBadge(String uid, String badge) async {
    try {
      final userDoc = _firestore.collection(_collection).doc(uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        
        if (snapshot.exists) {
          final badges = List<String>.from(snapshot.data()?['badges'] ?? []);
          
          if (!badges.contains(badge)) {
            badges.add(badge);
            transaction.update(userDoc, {'badges': badges});
          }
        }
      });
    } catch (e) {
      debugPrint('Error adding user badge: $e');
      rethrow;
    }
  }

  // Update category progress
  Future<void> updateCategoryProgress(String uid, String category, int score) async {
    try {
      final userDoc = _firestore.collection(_collection).doc(uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        
        if (snapshot.exists) {
          final progress = Map<String, dynamic>.from(snapshot.data()?['progress'] ?? {});
          
          // Just store the score directly with the category
          final currentScore = progress[category] ?? 0;
          progress[category] = currentScore + score;
          
          transaction.update(userDoc, {'progress': progress});
        }
      });
    } catch (e) {
      debugPrint('Error updating category progress: $e');
      rethrow;
    }
  }

  // User profile stream
  Stream<UserProfile?> userProfileStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            data['uid'] = uid;
            return UserProfile.fromJson(data);
          }
          return null;
        });
  }
} 