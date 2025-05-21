import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth/auth_button.dart';
import '../constants.dart';

class ClassroomCreateScreen extends StatefulWidget {
  const ClassroomCreateScreen({super.key});

  @override
  State<ClassroomCreateScreen> createState() => _ClassroomCreateScreenState();
}

class _ClassroomCreateScreenState extends State<ClassroomCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user == null || user.role != 'teacher') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu sayfaya sadece öğretmenler erişebilir.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _saveClassroom() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Oturum açmış bir öğretmen bulunamadı.'),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }
      final docRef = FirebaseFirestore.instance.collection('classrooms').doc();
      final classroom = Classroom(
        id: docRef.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        createdAt: DateTime.now(),
        teacherId: user.id,
      );
      await docRef.set(classroom.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sınıf başarıyla oluşturuldu!')),
      );
      _formKey.currentState!.reset();
      _nameController.clear();
      _descController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınıf Oluştur'),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Yeni Sınıf Oluştur',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textWhite,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Sınıf adı',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textGrey,
                      ),
                      fillColor: Colors.black.withOpacity(0.2),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.darkGrey,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.darkGrey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Sınıf adı zorunludur';
                      }
                      if (value.trim().length < 3) {
                        return 'Sınıf adı en az 3 karakter olmalı';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textWhite,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Açıklama',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textGrey,
                      ),
                      fillColor: Colors.black.withOpacity(0.2),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.darkGrey,
                          width: 1.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.darkGrey,
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Açıklama zorunludur';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  AuthButton(
                    text: 'Kaydet',
                    onPressed: _saveClassroom,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
