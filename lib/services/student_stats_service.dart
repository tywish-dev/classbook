import 'package:cloud_firestore/cloud_firestore.dart';

class StudentStats {
  final int booksRead;
  final int tasksCompleted;
  final int totalPoints;

  StudentStats({
    required this.booksRead,
    required this.tasksCompleted,
    required this.totalPoints,
  });
}

class StudentStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StudentStats> getStatsForStudent(String studentId) async {
    // Kitap okuma sayısı
    final booksSnapshot =
        await _firestore
            .collection('read_books')
            .where('userId', isEqualTo: studentId)
            .get();
    final booksRead = booksSnapshot.size;

    // Tamamlanan görev sayısı
    final tasksSnapshot =
        await _firestore
            .collection('completed_tasks')
            .where('userId', isEqualTo: studentId)
            .get();
    final tasksCompleted = tasksSnapshot.size;

    // Toplam puan
    final pointsDoc =
        await _firestore.collection('user_points').doc(studentId).get();
    final totalPoints =
        pointsDoc.exists ? (pointsDoc.data()?['points'] ?? 0) as int : 0;

    return StudentStats(
      booksRead: booksRead,
      tasksCompleted: tasksCompleted,
      totalPoints: totalPoints,
    );
  }
}
