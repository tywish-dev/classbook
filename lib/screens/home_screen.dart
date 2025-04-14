import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/book_card.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/category_pill.dart';
import '../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  final List<Color> _bookCoverColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(child: _buildHeader()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverToBoxAdapter(child: _buildCategories()),
                ),
                // SliverPadding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 8,
                //   ),
                //   sliver: SliverToBoxAdapter(child: const SubscriptionCard()),
                // ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Trend Olanlar',
                      onSeeAll: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildTrendingBooks()),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(
                      title: '5 Dakikalık Okumalar',
                      onSeeAll: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildShortReadBooks()),
                // Add extra space for bottom elements
                const SliverToBoxAdapter(
                  child: SizedBox(height: 160), // For bottom nav + now playing
                ),
              ],
            ),

            // Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BookNexusBottomNavBar(
                currentIndex: _selectedNavIndex,
                onTap: (index) {
                  setState(() {
                    _selectedNavIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('İyi Günler', style: AppTextStyles.heading1),
            Container(
              height: 1,
              width: 100,
              color: AppColors.darkGrey,
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
          child: Center(child: Icon(Icons.person, color: Colors.grey.shade300)),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CategoryPill(
            label: 'Trend',
            iconAsset: 'assets/icons/fire_icon.svg',
            isSelected: true,
          ),
          SizedBox(width: 4),
          CategoryPill(
            label: '5 Dakikalık Okuma',
            iconAsset: 'assets/icons/book_icon.svg',
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingBooks() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          final bookNames = [
            'İyi İnsan',
            'Gelecek',
            'Yaratıcılığını Keşfet',
            'İyi İnsan',
            'Gelecek',
            'Yaratıcılığını Keşfet',
          ];

          final authors = [
            'Mehmet Yılmaz',
            'Ayşe Kaya',
            'Ali Demir',
            'Mehmet Yılmaz',
            'Ayşe Kaya',
            'Ali Demir',
          ];

          final times = [
            ['5dk', '8dk'],
            ['12dk', '9dk'],
            ['5dk', '5dk'],
            ['5dk', '8dk'],
            ['12dk', '9dk'],
            ['5dk', '5dk'],
          ];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BookCard(
              title: bookNames[index % bookNames.length],
              author: authors[index % authors.length],
              coverColor: _bookCoverColors[index % _bookCoverColors.length],
              listenTime: times[index % times.length][0],
              readTime: times[index % times.length][1],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShortReadBooks() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          final bookNames = [
            'Kuzey Mitolojisi',
            'Yaratıcılığını Keşfet',
            'Gelecek',
            'Kuzey Mitolojisi',
            'İyi İnsan',
            'Gelecek',
          ];

          final authors = [
            'Kemal Doğan',
            'Ali Demir',
            'Ayşe Kaya',
            'Kemal Doğan',
            'Mehmet Yılmaz',
            'Ayşe Kaya',
          ];

          final times = [
            ['5dk', '8dk'],
            ['5dk', '8dk'],
            ['5dk', '5dk'],
            ['5dk', '8dk'],
            ['5dk', '5dk'],
            ['5dk', '5dk'],
          ];

          // Reverse the colors for variety
          int colorIndex =
              _bookCoverColors.length - 1 - (index % _bookCoverColors.length);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BookCard(
              title: bookNames[index % bookNames.length],
              author: authors[index % authors.length],
              coverColor: _bookCoverColors[colorIndex],
              listenTime: times[index % times.length][0],
              readTime: times[index % times.length][1],
            ),
          );
        },
      ),
    );
  }
}
