import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/student_model.dart';
import '../providers/student_provider.dart';
import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAddScreen extends StatefulWidget {
  final String classroomId;
  const StudentAddScreen({super.key, required this.classroomId});

  @override
  State<StudentAddScreen> createState() => _StudentAddScreenState();
}

class _StudentAddScreenState extends State<StudentAddScreen> {
  String? _selectedStudentId;
  bool _isLoading = false;
  String? _error;

  Future<void> _addStudent() async {
    if (_selectedStudentId == null) {
      setState(() => _error = 'Lütfen bir öğrenci seçin');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_selectedStudentId)
              .get();
      final data = userDoc.data();
      if (data == null) throw Exception('Kullanıcı bulunamadı');
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      final student = Student(
        id: userDoc.id,
        firstName: data['name'] ?? '',
        lastName: '',
        email: data['email'] ?? '',
        createdAt: DateTime.now(),
      );
      await studentProvider.addStudent(widget.classroomId, student);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Öğrenci başarıyla eklendi!')),
      );
      setState(() => _selectedStudentId = null);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Bir hata oluştu: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Ekle'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPaddings.large),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(AppPaddings.large),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: AppBorders.large,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Kayıtlı Öğrenciden Ekle',
                  style: AppTextStyles.heading2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'student')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Hata: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Text('Kayıtlı öğrenci bulunamadı.');
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedStudentId,
                      items:
                          docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                '${data['name'] ?? ''} - ${data['email'] ?? ''}',
                              ),
                            );
                          }).toList(),
                      onChanged:
                          (val) => setState(() => _selectedStudentId = val),
                      decoration: const InputDecoration(
                        labelText: 'Öğrenci Seç',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                    );
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: AppColors.primaryGreen
                          .withOpacity(0.5),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.textWhite,
                                ),
                              ),
                            )
                            : Text(
                              'Ekle',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
