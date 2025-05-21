import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'classroom_create_screen.dart';
import 'profile_screen.dart';
import 'student_list_screen.dart';
import 'student_stats_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _MyClassesPage(),
      _StudentsTabPage(),
      _StatsTabPage(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: SafeArea(
        child: _TeacherBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class _TeacherBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  static const double height = 72.0;

  const _TeacherBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.darkGrey, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Sınıflarım', Icons.class_),
          _buildNavItem(1, 'Öğrenciler', Icons.group),
          _buildNavItem(2, 'İstatistik', Icons.bar_chart),
          _buildNavItem(3, 'Profil', Icons.person),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, dynamic icon) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon is String
                ? SvgPicture.asset(
                  icon,
                  height: 20,
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    isSelected ? AppColors.primaryGreen : AppColors.textGrey,
                    BlendMode.srcIn,
                  ),
                )
                : Icon(
                  icon as IconData,
                  size: 20,
                  color:
                      isSelected ? AppColors.primaryGreen : AppColors.textGrey,
                ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primaryGreen : AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sınıflarım sekmesi: Öğretmenin kendi sınıflarını listeler ve sınıf oluşturma imkanı sunar
class _MyClassesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınıflarım'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Sınıf Oluştur',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClassroomCreateScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body:
          user == null
              ? const Center(child: Text('Kullanıcı bulunamadı'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('classrooms')
                        .where('teacherId', isEqualTo: user.id)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Henüz bir sınıfınız yok. Sağ üstten yeni sınıf oluşturabilirsiniz.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppPaddings.large),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final classroom = Classroom.fromFirestore(docs[index]);
                      return ListTile(
                        title: Text(
                          classroom.name,
                          style: AppTextStyles.bodyBold,
                        ),
                        subtitle: Text(classroom.description),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          // Sınıf detayına veya öğrenci listesine gidebilir
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StudentListScreen(
                                    classroomId: classroom.id,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}

// Öğrenciler sekmesi: Tüm öğrencileri (role == 'student') listele
class _StudentsTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenciler'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return Center(child: Text('Hata: \\${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'Henüz öğrenci yok.',
                style: AppTextStyles.body.copyWith(color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppPaddings.large),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(
                  Icons.person,
                  color: AppColors.primaryGreen,
                ),
                title: Text(data['name'] ?? '', style: AppTextStyles.bodyBold),
                subtitle: Text(data['email'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}

// İstatistik sekmesi: Önce sınıf seçtir, sonra istatistikleri göster
class _StatsTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body:
          user == null
              ? const Center(child: Text('Kullanıcı bulunamadı'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('classrooms')
                        .where('teacherId', isEqualTo: user.id)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Önce bir sınıf oluşturmalısınız.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppPaddings.large),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final classroom = Classroom.fromFirestore(docs[index]);
                      return ListTile(
                        title: Text(
                          classroom.name,
                          style: AppTextStyles.bodyBold,
                        ),
                        subtitle: Text(classroom.description),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StudentStatsScreen(
                                    classroomId: classroom.id,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
