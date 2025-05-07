import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../widgets/bottom_navbar.dart';
import 'book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final int selectedNavIndex;
  final Function(int)? onNavTap;

  const SearchScreen({super.key, this.selectedNavIndex = 1, this.onNavTap});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = Uri.parse(
        'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&fields=key,title,author_name,first_publish_year,cover_i&limit=20',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Map<String, dynamic>> books = [];

        if (data['docs'] != null) {
          for (var doc in data['docs']) {
            String? coverUrl;
            if (doc['cover_i'] != null) {
              coverUrl =
                  'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg';
            }

            String? workId;
            if (doc['key'] != null) {
              final keyParts = doc['key'].toString().split('/');
              if (keyParts.length > 1) {
                workId = keyParts.last;
              }
            }

            books.add({
              'title': doc['title'] ?? 'Unknown Title',
              'authors': doc['author_name'] ?? [],
              'coverUrl': coverUrl,
              'publishYear': doc['first_publish_year'],
              'workId': workId,
            });
          }
        }

        setState(() {
          _searchResults = books;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      setState(() {
        _error = 'Arama yapılırken bir hata oluştu';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Kitap veya yazar ara...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildSearchResults()),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BookNexusBottomNavBar(
                currentIndex: widget.selectedNavIndex,
                onTap: widget.onNavTap ?? (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_searchResults.isEmpty) {
      if (_searchController.text.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'Kitap veya yazar aramak için yazın',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        );
      } else {
        return Center(
          child: Text(
            'Sonuç bulunamadı',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        );
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BookDetail(
                        title: book['title'],
                        authors: List<String>.from(book['authors']),
                        coverUrl: book['coverUrl'],
                        publishYear: book['publishYear'],
                        backgroundColor:
                            Colors.primaries[index % Colors.primaries.length],
                        workId: book['workId'],
                      ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Book cover
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                    ),
                    child:
                        book['coverUrl'] != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                book['coverUrl']!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.book,
                                      color: Colors.white54,
                                    ),
                              ),
                            )
                            : const Icon(Icons.book, color: Colors.white54),
                  ),
                  const SizedBox(width: 16),
                  // Book details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book['authors'].isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            book['authors'][0],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                        if (book['publishYear'] != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Yayın Yılı: ${book['publishYear']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
