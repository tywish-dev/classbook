import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../constants.dart';
import '../widgets/book_card.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/category_pill.dart';
import '../widgets/section_header.dart';
import 'profile_screen.dart';
import 'book_detail_screen.dart';
import '../widgets/search_bar.dart' as custom_search;
import '../widgets/category_selector.dart';
import '../models/book_model.dart';
import 'library_screen.dart';
import 'leaderboard_screen.dart';

// --- Open Library API Data Models ---
class BookDoc {
  final String key;
  final String title;
  final List<String>? authorName;
  final int? firstPublishYear;
  final int? coverI; // Cover ID

  BookDoc({
    required this.key,
    required this.title,
    this.authorName,
    this.firstPublishYear,
    this.coverI,
  });

  factory BookDoc.fromJson(Map<String, dynamic> json) {
    return BookDoc(
      key: json['key'] ?? 'N/A', // Provide default or handle null
      title: json['title'] ?? 'Unknown Title',
      authorName:
          json['author_name'] != null
              ? List<String>.from(json['author_name'])
              : null,
      firstPublishYear: json['first_publish_year'] as int?,
      coverI: json['cover_i'] as int?,
    );
  }

  String get coverUrl {
    if (coverI != null) {
      // Use -M for medium size cover
      return 'https://covers.openlibrary.org/b/id/$coverI-M.jpg';
    }
    // Return a placeholder or handle null appropriately
    return ''; // Consider adding a placeholder image URL
  }
}

class OpenLibraryResponse {
  final int numFound;
  final int start;
  final bool numFoundExact;
  final List<BookDoc> docs;

  OpenLibraryResponse({
    required this.numFound,
    required this.start,
    required this.numFoundExact,
    required this.docs,
  });

  factory OpenLibraryResponse.fromJson(Map<String, dynamic> json) {
    var docsList = json['docs'] as List? ?? []; // Handle null or non-list
    List<BookDoc> books = docsList.map((i) => BookDoc.fromJson(i)).toList();
    return OpenLibraryResponse(
      numFound: json['numFound'] ?? 0,
      start: json['start'] ?? 0,
      numFoundExact: json['numFoundExact'] ?? false,
      docs: books,
    );
  }
}

// --- HomeScreen Widget ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BookDoc> _apiBooks = [];
  bool _isLoadingApiBooks = true;
  String? _apiError;
  int _selectedNavIndex = 0;
  final List<Book> _popularBooks = Book.popularBooks;
  final List<Book> _newReleases = Book.newReleases;
  final List<String> _categories = [
    'Tümü',
    'Bilim Kurgu',
    'Fantastik',
    'Macera',
    'Polisiye',
    'Romantik',
  ];
  String _selectedCategory = 'Tümü';

  final List<Color> _bookCoverColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
  ];

  // Map Turkish category names to English subject names for API
  final Map<String, String> _categoryToSubject = {
    'Tümü': 'popular',
    'Bilim Kurgu': 'science_fiction',
    'Fantastik': 'fantasy',
    'Macera': 'adventure',
    'Polisiye': 'mystery',
    'Romantik': 'romance',
  };

  final List<Widget> _screens = [
    const HomeScreen(),
    const LibraryScreen(selectedNavIndex: 1),
    const LibraryScreen(selectedNavIndex: 2),
    const LeaderboardScreen(selectedNavIndex: 3),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchApiBooks(_categoryToSubject[_selectedCategory] ?? 'popular');
  }

  Future<void> _fetchApiBooks(String subject) async {
    setState(() {
      _isLoadingApiBooks = true;
      _apiError = null;
    });

    final url = Uri.parse(
      'https://openlibrary.org/search.json?subject=$subject&limit=10&fields=key,title,author_name,first_publish_year,cover_i',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final openLibraryResponse = OpenLibraryResponse.fromJson(data);
        setState(() {
          _apiBooks = openLibraryResponse.docs;
          _isLoadingApiBooks = false;
        });
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching API books: $e');
      setState(() {
        _apiError = 'Failed to load books from API.';
        _isLoadingApiBooks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.currentUser;

    // If index is not 0 (home), return the appropriate screen
    if (_selectedNavIndex != 0) {
      if (_selectedNavIndex == 1) {
        // For now, library screen is used for exploration
        return LibraryScreen(
          selectedNavIndex: _selectedNavIndex,
          onNavTap: _onItemTapped,
        );
      } else if (_selectedNavIndex == 2) {
        return LibraryScreen(
          selectedNavIndex: _selectedNavIndex,
          onNavTap: _onItemTapped,
        );
      } else if (_selectedNavIndex == 3) {
        return LeaderboardScreen(
          selectedNavIndex: _selectedNavIndex,
          onNavTap: _onItemTapped,
        );
      }
    }

    // Default - render home screen (index 0)
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(child: _buildHeader(user)),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverToBoxAdapter(child: custom_search.SearchBar()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: CategorySelector(
                      categories: _categories,
                      initialCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                          // Fetch books based on selected category
                          final subject =
                              _categoryToSubject[category] ?? 'popular';
                          _fetchApiBooks(subject);
                        });
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(
                      title:
                          _selectedCategory == 'Tümü'
                              ? 'Popüler Kitaplar'
                              : '$_selectedCategory Kitapları',
                      onSeeAll: () {},
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildApiBookList()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 160), // For bottom nav + now playing
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BookNexusBottomNavBar(
                currentIndex: _selectedNavIndex,
                onTap: _onItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(User? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba${user != null ? ', ${user.name}' : ''}!',
              style: AppTextStyles.heading1,
            ),
            Container(
              height: 1,
              width: 100,
              color: AppColors.darkGrey,
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (Provider.of<AuthProvider>(context, listen: false).currentUser !=
                null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Login required.')));
            }
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey[600], size: 30),
          ),
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

  Widget _buildApiBookList() {
    if (_isLoadingApiBooks) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '$_selectedCategory kitapları yükleniyor...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    if (_apiError != null) {
      return Center(
        child: Text(_apiError!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (_apiBooks.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Text(
            '$_selectedCategory için kitap bulunamadı.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Example: Simple horizontal list for fetched books
    return SizedBox(
      height: 300, // Increase height to accommodate larger covers
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _apiBooks.length,
        itemBuilder: (context, index) {
          final book = _apiBooks[index];
          final imageUrl = book.coverUrl;

          // Extract work ID from the key
          String? workId;
          if (book.key.isNotEmpty) {
            final keyParts = book.key.split('/');
            if (keyParts.length > 1) {
              workId = keyParts.last;
            }
          }

          // Make the card clickable using GestureDetector
          return GestureDetector(
            onTap: () {
              // Navigate to book detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BookDetail(
                        title: book.title,
                        authors: book.authorName,
                        coverUrl: imageUrl,
                        publishYear: book.firstPublishYear,
                        backgroundColor:
                            _bookCoverColors[index % _bookCoverColors.length],
                        workId: workId, // Pass the work ID
                      ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              elevation: 4.0, // Add more elevation for better shadow
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 210, // Increased from 80x120 to 140x210
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          4.0,
                        ), // Slightly rounded corners
                        child:
                            imageUrl.isNotEmpty
                                ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (ctx, err, st) =>
                                          const Icon(Icons.book, size: 50),
                                )
                                : Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.book, size: 50),
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 140, // Increased width to match cover width
                      child: Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ), // Increased font size
                      ),
                    ),
                    // Add author name if available
                    if (book.authorName != null && book.authorName!.isNotEmpty)
                      SizedBox(
                        width: 140,
                        child: Text(
                          book.authorName!.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookSection(List<Book> books) {
    return SizedBox(
      height: 280, // Standard height for these sections
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () {
              // Navigate to book detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BookDetail(
                        title: book.title,
                        authors: [book.author],
                        backgroundColor:
                            book.coverColor ??
                            _bookCoverColors[index % _bookCoverColors.length],
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: BookCard(
                title: book.title,
                author: book.author,
                // Use book.coverColor or a fallback color
                coverColor:
                    book.coverColor ??
                    _bookCoverColors[index % _bookCoverColors.length],
                listenTime: book.listenTime ?? '',
                readTime: book.readTime ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}
