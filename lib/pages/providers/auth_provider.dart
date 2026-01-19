import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrikeep/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc.id, doc.data()!);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> signInWithUsernameOrEmail(
      String identifier,
      String password,
      ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      String email = identifier.trim();

      // If input does NOT look like email, treat as username
      if (!identifier.contains('@')) {
        // Look for username in Firestore
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: identifier.toLowerCase())
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this username',
          );
        }

        email = snapshot.docs.first['email'];
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailPassword(
      String email,
      String password,
      String username,
      String state,
      String phoneNumber,
      ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Starting signup for: $email');

      // 1. First create Firebase Auth user
      print('1. Creating Firebase Auth user...');
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase Auth user created: ${userCredential.user?.uid}');

      final user = userCredential.user;
      if (user != null) {
        // 2. Save to Firestore
        print('2. Saving to Firestore...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': email,
          'username': username.toLowerCase(),
          'state': state,
          'phoneNumber': phoneNumber,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'isEmailVerified': false,
        });

        print('✅ Firestore document saved');

        // 3. Create local model
        _currentUser = UserModel(
          id: user.uid,
          email: email,
          username: username.toLowerCase(),
          phoneNumber: phoneNumber,
          state: state,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: false,
        );

        print('✅ Local user model created');
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      _error = _getErrorMessage(e.code);
    } catch (e) {
      print('❌ General error: $e');
      print('❌ Error type: ${e.runtimeType}');
      _error = 'Failed to create account: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// Also update the updateUserProfile method to remove fullName:
  Future<void> updateUserProfile({
    String? username, // Changed: from fullName to username
    String? country,
    String? state,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      if (_currentUser == null) return;

      _isLoading = true;
      notifyListeners();

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.id)
          .update({
        'username': username ?? _currentUser!.username,
        'state': state ?? _currentUser!.state, // CHANGED: from country to state
        'phoneNumber': phoneNumber ?? _currentUser!.phoneNumber,
        'profileImageUrl': profileImageUrl ?? _currentUser!.profileImageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update local model
      _currentUser = _currentUser!.copyWith(
        username: username ?? _currentUser!.username,
        state: state ?? _currentUser!.state, // CHANGED: from country to state
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update profile';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email or username';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email is already in use';
      case 'username-exists':
        return 'Username is already taken';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication failed. Please check again';
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
    } catch (e) {
      _error = 'Failed to sign out';
      notifyListeners();
    }
  }
}