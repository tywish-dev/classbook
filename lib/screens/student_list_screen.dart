import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../constants.dart';
import '../providers/points_provider.dart';
import 'student_add_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String classroomId;
  const StudentListScreen({super.key, required this.classroomId});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(
        context,
        listen: false,
      ).fetchStudents(widget.classroomId);
    });
  }

  Future<void> _deleteStudent(String studentId) async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    await provider.deleteStudent(widget.classroomId, studentId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Öğrenci silindi.')));
  }

  Future<void> _completeTaskForStudent(
    String studentId,
    String studentName,
  ) async {
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    // Örnek görev: "Haftalık Okuma Görevi"
    const taskId = 'weekly_reading_task';
    const taskTitle = 'Haftalık Okuma Görevi';
    final success = await pointsProvider.completeTaskAndAddPoints(
      studentId,
      studentName,
      taskId,
      taskTitle,
      pointsPerTask: 50,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Görev tamamlandı ve puan verildi!'
              : 'Bu görev zaten tamamlanmış.',
        ),
        backgroundColor: success ? AppColors.primaryGreen : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Listesi'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Öğrenci Ekle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          StudentAddScreen(classroomId: widget.classroomId),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Text(
                'Hata: ${provider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (provider.students.isEmpty) {
            return Center(
              child: Text(
                'Bu sınıfta henüz öğrenci yok.',
                style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppPaddings.large),
            itemCount: provider.students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final student = provider.students[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: AppBorders.medium,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${student.firstName} ${student.lastName}',
                            style: AppTextStyles.bodyBold,
                          ),
                          const SizedBox(height: 4),
                          Text(student.email, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Sil',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Öğrenciyi Sil'),
                                content: Text(
                                  '"${student.firstName} ${student.lastName}" adlı öğrenciyi silmek istediğinize emin misiniz?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('İptal'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    child: const Text('Sil'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          await _deleteStudent(student.id);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primaryGreen,
                      ),
                      tooltip: 'Görev Tamamla',
                      onPressed:
                          () => _completeTaskForStudent(
                            student.id,
                            student.firstName + ' ' + student.lastName,
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
