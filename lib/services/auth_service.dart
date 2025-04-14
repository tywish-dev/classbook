import 'dart:async';
import '../models/user.dart';

// This is a mock implementation of AuthService for demonstration purposes
// In a real app, this would integrate with Firebase Auth or another authentication service
class AuthService {
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
    await Future.delayed(const Duration(seconds: 1));

    email = email.toLowerCase();

    if (!_users.containsKey(email)) {
      throw Exception('User not found');
    }

    // In a real app, we would check the password hash
    // For demo purposes, any password is accepted

    _currentUser = _users[email];
    return _currentUser!;
  }

  // Sign up with email and password
  Future<User> signUp(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    email = email.toLowerCase();

    if (_users.containsKey(email)) {
      throw Exception('Email already in use');
    }

    // Create new user
    final newUser = User(
      id: ((_users.length) + 1).toString(),
      name: name,
      email: email,
    );

    // Save user to mock database
    _users[email] = newUser;
    _currentUser = newUser;

    return newUser;
  }

  // Social login (Google, Facebook, Apple)
  Future<User> socialLogin(String provider) async {
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, create a new user or return existing one
    final email = '$provider.user@example.com';

    if (_users.containsKey(email)) {
      _currentUser = _users[email]!;
      return _currentUser!;
    }

    // Create new user
    final newUser = User(
      id: ((_users.length) + 1).toString(),
      name: '$provider User',
      email: email,
      photoUrl: 'assets/icons/auth/$provider.png',
    );

    // Save user to mock database
    _users[email] = newUser;
    _currentUser = newUser;

    return newUser;
  }

  // Logout
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = null;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    email = email.toLowerCase();

    if (!_users.containsKey(email)) {
      throw Exception('User not found');
    }

    _resetEmail = email;
    // In a real app, this would send an email
    print('Password reset code: $_mockVerificationCode');
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
    await Future.delayed(const Duration(seconds: 1));

    if (_resetEmail == null) {
      throw Exception('No reset email set');
    }

    // In a real app, this would update the password in the database
    print('Password reset for $_resetEmail');

    // Clear reset email
    _resetEmail = null;
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
