import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Bir sınıfa öğrenci ekle
  Future<void> addStudentToClass({
    required String classroomId,
    required Student student,
  }) async {
    final docRef = _firestore
        .collection('classrooms')
        .doc(classroomId)
        .collection('students')
        .doc(student.id);
    await docRef.set(student.toMap());
  }

  /// Bir sınıftaki öğrencileri listele
  Future<List<Student>> getStudentsOfClass(String classroomId) async {
    final snapshot =
        await _firestore
            .collection('classrooms')
            .doc(classroomId)
            .collection('students')
            .orderBy('createdAt', descending: false)
            .get();
    return snapshot.docs.map((doc) => Student.fromFirestore(doc)).toList();
  }

  /// Bir sınıftan öğrenci sil
  Future<void> deleteStudentFromClass({
    required String classroomId,
    required String studentId,
  }) async {
    await _firestore
        .collection('classrooms')
        .doc(classroomId)
        .collection('students')
        .doc(studentId)
        .delete();
  }
}
