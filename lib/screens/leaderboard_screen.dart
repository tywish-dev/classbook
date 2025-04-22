import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';
import '../providers/points_provider.dart';
import '../models/leaderboard_model.dart';
import '../widgets/bottom_navbar.dart';

class LeaderboardScreen extends StatefulWidget {
  final int selectedNavIndex;
  final Function(int)? onNavTap;

  const LeaderboardScreen({
    super.key,
    this.selectedNavIndex = 3,
    this.onNavTap,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await Future.wait([
        pointsProvider.loadLeaderboard(),
        pointsProvider.loadUserPointsData(authProvider.currentUser!.id),
      ]);
    } else {
      await pointsProvider.loadLeaderboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final pointsProvider = Provider.of<PointsProvider>(context);
    final currentUserId = authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Liderlik Tablosu',
          style: AppTextStyles.heading2.copyWith(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: Column(
            children: [
              // User's stats card (if logged in)
              if (currentUserId != null)
                _buildUserStatsCard(pointsProvider, authProvider),

              const SizedBox(height: 16),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'En Çok Okuyanlar',
                      style: AppTextStyles.heading2.copyWith(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      'Puan',
                      style: AppTextStyles.heading2.copyWith(
                        fontSize: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Leaderboard list
              Expanded(
                child:
                    pointsProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildLeaderboardList(pointsProvider, currentUserId),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: widget.selectedNavIndex,
        onTap: widget.onNavTap,
      ),
    );
  }

  Widget _buildUserStatsCard(
    PointsProvider pointsProvider,
    AuthProvider authProvider,
  ) {
    final user = authProvider.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // User profile icon
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Kullanıcı',
                        style: AppTextStyles.heading2.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events_outlined,
                            color: AppColors.primaryGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sıralama: ${pointsProvider.userRanking}',
                            style: AppTextStyles.body?.copyWith(
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Points
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${pointsProvider.userPoints} P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(
    PointsProvider pointsProvider,
    String? currentUserId,
  ) {
    final leaderboard = pointsProvider.leaderboard;

    if (leaderboard.isEmpty) {
      return const Center(child: Text('Henüz kimse kitap okumamış'));
    }

    return ListView.builder(
      itemCount: leaderboard.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final userPoints = leaderboard[index];
        final isCurrentUser = userPoints.userId == currentUserId;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                isCurrentUser
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border:
                isCurrentUser
                    ? Border.all(color: AppColors.primaryGreen, width: 1)
                    : null,
          ),
          child: Row(
            children: [
              // Rank
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _getRankColor(index),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // User profile icon
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                child: Text(
                  userPoints.userName.isNotEmpty
                      ? userPoints.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Username
              Expanded(
                child: Text(
                  userPoints.userName,
                  style: TextStyle(
                    fontWeight:
                        isCurrentUser ? FontWeight.bold : FontWeight.normal,
                    color:
                        isCurrentUser
                            ? AppColors.primaryGreen
                            : AppColors.textWhite,
                  ),
                ),
              ),

              // Points
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${userPoints.points} P',
                  style: TextStyle(
                    color:
                        isCurrentUser
                            ? AppColors.primaryGreen
                            : AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0: // 1st place
        return Colors.amber;
      case 1: // 2nd place
        return Colors.grey.shade400;
      case 2: // 3rd place
        return Colors.brown.shade300;
      default:
        return AppColors.primaryGreen;
    }
  }
}
