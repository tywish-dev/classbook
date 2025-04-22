import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'book_list_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Get user data from Firestore
        final userDoc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (userDoc.exists) {
          // If user exists in Firestore, use that data
          _currentUser = User(
            id: firebaseUser.uid,
            name: userDoc.data()?['name'] ?? firebaseUser.displayName ?? '',
            email: userDoc.data()?['email'] ?? firebaseUser.email ?? '',
            genrePreferences: List<String>.from(
              userDoc.data()?['genrePreferences'] ?? [],
            ),
          );
        } else {
          // If user doesn't exist in Firestore yet, use Firebase Auth data
          _currentUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
          );

          // Save initial user data to Firestore
          await _firestore.collection('users').doc(firebaseUser.uid).set({
            'name': firebaseUser.displayName,
            'email': firebaseUser.email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  // Check if a user with given email exists
  Future<bool> checkUserExists(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final methods = await firebase.FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);
      final exists = methods.isNotEmpty;

      _isLoading = false;
      notifyListeners();

      return exists;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login with email and password
  Future<bool> login(
    String email,
    String password,
    BuildContext? context,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.login(email, password);

      // Initialize book list provider with the new user
      if (context != null) {
        final bookListProvider = Provider.of<BookListProvider>(
          context,
          listen: false,
        );
        bookListProvider.initialize(_currentUser?.id);
      }

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

  // Sign up with email and password
  Future<bool> signUp(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _authService.signUp(name, email, password);

      // Save additional user data to Firestore
      await _firestore.collection('users').doc(user.id).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentUser = user;
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

  // Social login (Google)
  Future<bool> socialLogin(String provider) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.socialLogin(provider);

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

  // Logout
  Future<bool> logout(BuildContext? context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();

      // Reset book list provider
      if (context != null) {
        final bookListProvider = Provider.of<BookListProvider>(
          context,
          listen: false,
        );
        bookListProvider.initialize(null);
      }

      _currentUser = null;
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

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

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

  // Reset password
  Future<bool> resetPassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(newPassword);

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

  // Save user genre preferences
  Future<bool> saveGenrePreferences(List<String> genreIds) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      await _firestore.collection('users').doc(_currentUser!.id).set({
        'genrePreferences': genreIds,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

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
}
