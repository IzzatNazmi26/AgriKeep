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

  // In auth_provider.dart - Update the signUpWithEmailPassword method
  Future<void> signUpWithEmailPassword(
      String email,
      String password,
      String username, // Changed: removed fullName parameter
      String country,
      ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Check if username exists
      final usernameCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'username-exists',
          message: 'Username already taken',
        );
      }

      // 2. Create Firebase Auth user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 3. Save to Firestore - SIMPLE DIRECT SAVE
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': email,
          'username': username.toLowerCase(),
          'country': country,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
          'isEmailVerified': false,
        });

        // 4. Create local user model
        _currentUser = UserModel(
          id: user.uid,
          email: email,
          username: username.toLowerCase(),
          country: country,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: false,
        );

        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
    } catch (e) {
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
        'username': username ?? _currentUser!.username, // Changed from fullName
        'country': country ?? _currentUser!.country,
        'state': state ?? _currentUser!.state,
        'phoneNumber': phoneNumber ?? _currentUser!.phoneNumber,
        'profileImageUrl': profileImageUrl ?? _currentUser!.profileImageUrl,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Update local model
      _currentUser = _currentUser!.copyWith(
        username: username ?? _currentUser!.username, // Changed from fullName
        country: country ?? _currentUser!.country,
        state: state ?? _currentUser!.state,
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
        return 'Authentication failed';
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