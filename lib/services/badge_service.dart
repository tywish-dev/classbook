import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge_model.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Tüm rozetleri çek
  Future<List<Badge>> getAllBadges() async {
    final snapshot =
        await _firestore.collection('badges').orderBy('requiredPoints').get();
    return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
  }

  /// Öğrencinin mevcut puanına göre kazandığı rozetleri getir
  Future<List<Badge>> getBadgesForPoints(int points) async {
    final snapshot =
        await _firestore
            .collection('badges')
            .where('requiredPoints', isLessThanOrEqualTo: points)
            .orderBy('requiredPoints')
            .get();
    return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
  }

  /// Öğrenciye rozet ata (kazanılan rozetler alt koleksiyonunda tutulur)
  Future<void> assignBadgeToStudent({
    required String studentId,
    required Badge badge,
  }) async {
    await _firestore
        .collection('user_badges')
        .doc(studentId)
        .collection('badges')
        .doc(badge.id)
        .set(badge.toMap());
  }

  /// Öğrencinin sahip olduğu rozetleri getir
  Future<List<Badge>> getStudentBadges(String studentId) async {
    final snapshot =
        await _firestore
            .collection('user_badges')
            .doc(studentId)
            .collection('badges')
            .get();
    return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
  }
}
