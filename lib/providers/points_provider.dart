import 'package:flutter/foundation.dart';
import '../models/leaderboard_model.dart';
import '../services/points_service.dart';

class PointsProvider with ChangeNotifier {
  final PointsService _pointsService = PointsService();

  List<UserPoints> _leaderboard = [];
  int _userPoints = 0;
  int _userRanking = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<UserPoints> get leaderboard => _leaderboard;
  int get userPoints => _userPoints;
  int get userRanking => _userRanking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mark book as read and add points
  Future<bool> markBookAsReadAndAddPoints(
    String userId,
    String userName,
    String bookId,
    String bookTitle, {
    String? photoUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if user has already read this book
      final hasRead = await _pointsService.hasUserReadBook(userId, bookId);

      if (hasRead) {
        _isLoading = false;
        notifyListeners();
        return false; // Book already read
      }

      // Mark book as read
      await _pointsService.markBookAsRead(userId, bookId, bookTitle);

      // Add points to user
      const pointsPerBook = 100;
      await _pointsService.addPoints(
        userId,
        userName,
        pointsPerBook,
        photoUrl: photoUrl,
      );

      // Update user's points data
      await loadUserPointsData(userId);

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

  // Check if user has read a book
  Future<bool> hasUserReadBook(String userId, String bookId) async {
    try {
      return await _pointsService.hasUserReadBook(userId, bookId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Load leaderboard data
  Future<void> loadLeaderboard({int limit = 20}) async {
    try {
      _isLoading = true;
      notifyListeners();

      _leaderboard = await _pointsService.getLeaderboard(limit: limit);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load user's points and ranking
  Future<void> loadUserPointsData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get user points
      _userPoints = await _pointsService.getUserPoints(userId);

      // Get user ranking
      _userRanking = await _pointsService.getUserRanking(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
