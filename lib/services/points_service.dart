import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';

class PointsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final CollectionReference _pointsCollection = FirebaseFirestore.instance
      .collection('user_points');

  final CollectionReference _readBooksCollection = FirebaseFirestore.instance
      .collection('read_books');

  // Add points to a user
  Future<void> addPoints(
    String userId,
    String userName,
    int points, {
    String? photoUrl,
  }) async {
    try {
      // Get current user points
      final userPointsDoc = await _pointsCollection.doc(userId).get();

      if (userPointsDoc.exists) {
        // User already has points, update them
        final currentPoints = userPointsDoc.get('points') as int? ?? 0;
        await _pointsCollection.doc(userId).update({
          'points': currentPoints + points,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new user points entry
        await _pointsCollection.doc(userId).set({
          'userId': userId,
          'userName': userName,
          'points': points,
          'photoUrl': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add points: ${e.toString()}');
    }
  }

  // Mark a book as read by a user
  Future<bool> markBookAsRead(
    String userId,
    String bookId,
    String bookTitle,
  ) async {
    try {
      // Check if book is already read by this user
      final readBookDoc =
          await _readBooksCollection
              .where('userId', isEqualTo: userId)
              .where('bookId', isEqualTo: bookId)
              .limit(1)
              .get();

      if (readBookDoc.docs.isNotEmpty) {
        // User has already read this book
        return false;
      }

      // Mark book as read
      await _readBooksCollection.add({
        'userId': userId,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'readAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to mark book as read: ${e.toString()}');
    }
  }

  // Check if a user has read a specific book
  Future<bool> hasUserReadBook(String userId, String bookId) async {
    try {
      final readBookDoc =
          await _readBooksCollection
              .where('userId', isEqualTo: userId)
              .where('bookId', isEqualTo: bookId)
              .limit(1)
              .get();

      return readBookDoc.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if book is read: ${e.toString()}');
    }
  }

  // Get leaderboard data (top users by points)
  Future<List<UserPoints>> getLeaderboard({int limit = 20}) async {
    try {
      final leaderboardDocs =
          await _pointsCollection
              .orderBy('points', descending: true)
              .limit(limit)
              .get();

      return leaderboardDocs.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserPoints.fromFirestore(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: ${e.toString()}');
    }
  }

  // Get user's points
  Future<int> getUserPoints(String userId) async {
    try {
      final userPointsDoc = await _pointsCollection.doc(userId).get();

      if (userPointsDoc.exists) {
        return userPointsDoc.get('points') as int? ?? 0;
      }

      return 0;
    } catch (e) {
      throw Exception('Failed to get user points: ${e.toString()}');
    }
  }

  // Get user ranking position
  Future<int> getUserRanking(String userId) async {
    try {
      final userPointsDoc = await _pointsCollection.doc(userId).get();

      if (!userPointsDoc.exists) {
        return 0; // No ranking if user has no points yet
      }

      final userPoints = userPointsDoc.get('points') as int? ?? 0;

      // Count users with more points
      final usersAboveQuery =
          await _pointsCollection
              .where('points', isGreaterThan: userPoints)
              .count()
              .get();

      // Add 1 since rankings are 1-based
      return (usersAboveQuery.count ?? 0) + 1;
    } catch (e) {
      throw Exception('Failed to get user ranking: ${e.toString()}');
    }
  }
}
