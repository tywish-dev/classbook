import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../services/student_stats_service.dart';
import '../services/badge_service.dart';
import '../constants.dart';
import '../models/badge_model.dart' as appBadge;

class StudentStatsScreen extends StatefulWidget {
  final String classroomId;
  const StudentStatsScreen({super.key, required this.classroomId});

  @override
  State<StudentStatsScreen> createState() => _StudentStatsScreenState();
}

class _StudentStatsScreenState extends State<StudentStatsScreen> {
  late Future<List<_StudentWithStats>> _futureStats;

  @override
  void initState() {
    super.initState();
    _futureStats = _fetchAllStats();
  }

  Future<List<_StudentWithStats>> _fetchAllStats() async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    await provider.fetchStudents(widget.classroomId);
    final students = provider.students;
    final statsService = StudentStatsService();
    final badgeService = BadgeService();
    final List<_StudentWithStats> result = [];
    for (final student in students) {
      final stats = await statsService.getStatsForStudent(student.id);
      final badges = await badgeService.getStudentBadges(student.id);
      result.add(
        _StudentWithStats(
          name: '${student.firstName} ${student.lastName}',
          email: student.email,
          booksRead: stats.booksRead,
          tasksCompleted: stats.tasksCompleted,
          totalPoints: stats.totalPoints,
          badges: badges,
        ),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci İstatistikleri'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: FutureBuilder<List<_StudentWithStats>>(
        future: _futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Hata: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final statsList = snapshot.data ?? [];
          if (statsList.isEmpty) {
            return Center(
              child: Text(
                'Bu sınıfta henüz öğrenci yok.',
                style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppPaddings.large),
            itemCount: statsList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final s = statsList[index];
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: AppTextStyles.bodyBold),
                    const SizedBox(height: 4),
                    Text(s.email, style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatChip(
                          label: 'Kitap',
                          value: s.booksRead.toString(),
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Görev',
                          value: s.tasksCompleted.toString(),
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          label: 'Puan',
                          value: s.totalPoints.toString(),
                        ),
                      ],
                    ),
                    if (s.badges.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            s.badges
                                .map((badge) => _BadgeChip(badge: badge))
                                .toList(),
                      ),
                    ],
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

class _StudentWithStats {
  final String name;
  final String email;
  final int booksRead;
  final int tasksCompleted;
  final int totalPoints;
  final List<appBadge.Badge> badges;
  _StudentWithStats({
    required this.name,
    required this.email,
    required this.booksRead,
    required this.tasksCompleted,
    required this.totalPoints,
    required this.badges,
  });
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text('$label: ', style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.bodyBold),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final appBadge.Badge badge;
  const _BadgeChip({required this.badge});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge.iconUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Image.network(
                badge.iconUrl,
                width: 20,
                height: 20,
                errorBuilder:
                    (_, __, ___) => const Icon(Icons.emoji_events, size: 20),
              ),
            ),
          Text(
            badge.name,
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
