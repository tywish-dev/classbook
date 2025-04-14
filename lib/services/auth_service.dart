import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../models/user.dart';

// This is a mock implementation of AuthService for demonstration purposes
// In a real app, this would integrate with Firebase Auth or another authentication service
class AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  // Get current user
  firebase.User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<firebase.User?> get authStateChanges => _auth.authStateChanges();

  // Mock user data
  final Map<String, User> _users = {
    'test@example.com': User(
      id: '1',
      name: 'Test User',
      email: 'test@example.com',
      genrePreferences: ['1', '4'], // Romance and Fantasy
    ),
  };

  // Current user data
  User? _currentUser;
  String? _resetEmail;
  String _mockVerificationCode = '123456';

  // Check if a user with the given email exists
  Future<bool> checkUserExists(String email) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    return _users.containsKey(email.toLowerCase());
  }

  // Login with email and password
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return User(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? '',
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<User> signUp(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      return User(id: userCredential.user!.uid, name: name, email: email);
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  // Social login (Google)
  Future<User> socialLogin(String provider) async {
    try {
      // TODO: Implement Google Sign In
      throw Exception('Google Sign In not implemented yet');
    } catch (e) {
      throw Exception('Failed to login with $provider: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  // Verify reset code
  Future<bool> verifyResetCode(String code) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_resetEmail == null) {
      throw Exception('No reset email set');
    }

    // Check if code matches
    return code == _mockVerificationCode;
  }

  // Reset password
  Future<void> resetPassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  // Save user genre preferences
  Future<void> saveGenrePreferences(
    String userId,
    List<String> genreIds,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    // Find user by ID
    final userEntry = _users.entries.firstWhere(
      (entry) => entry.value.id == userId,
      orElse: () => throw Exception('User not found'),
    );

    // Update user preferences
    _users[userEntry.key] = userEntry.value.copyWith(
      genrePreferences: genreIds,
    );

    // Update current user if it's the same user
    if (_currentUser?.id == userId) {
      _currentUser = _users[userEntry.key];
    }
  }
}
