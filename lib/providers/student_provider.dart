import 'package:flutter/material.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  final StudentService _studentService = StudentService();
  List<Student> _students = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStudents(String classroomId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _students = await _studentService.getStudentsOfClass(classroomId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addStudent(String classroomId, Student student) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _studentService.addStudentToClass(
        classroomId: classroomId,
        student: student,
      );
      await fetchStudents(classroomId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String classroomId, String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _studentService.deleteStudentFromClass(
        classroomId: classroomId,
        studentId: studentId,
      );
      await fetchStudents(classroomId);
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
