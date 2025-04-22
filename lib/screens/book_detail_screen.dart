import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/book_model.dart';
import 'package:provider/provider.dart';
import '../providers/book_list_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/points_provider.dart';

class BookDetail extends StatefulWidget {
  final String title;
  final List<String>? authors;
  final String? coverUrl;
  final int? publishYear;
  final String? description;
  final Color backgroundColor;
  final String? workId; // Open Library work ID

  const BookDetail({
    super.key,
    required this.title,
    this.authors,
    this.coverUrl,
    this.publishYear,
    this.description,
    this.backgroundColor = Colors.white,
    this.workId,
  });

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  bool _isLoading = true;
  String? _error;
  String? _bookDescription;
  List<Map<String, dynamic>> _similarBooks = [];

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  // Fetch book details from Open Library API
  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Extract work ID from the key (if provided)
      String? workId = widget.workId;

      if (workId == null) {
        // If no key, try to search for the book by title and author
        await _searchBookByTitleAndAuthor();
      } else {
        // Fetch book details using work ID
        final url = Uri.parse('https://openlibrary.org/works/$workId.json');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Get description (could be string or object with value field)
          if (data['description'] != null) {
            if (data['description'] is String) {
              _bookDescription = data['description'];
            } else if (data['description'] is Map &&
                data['description']['value'] != null) {
              _bookDescription = data['description']['value'];
            }
          }

          // Get similar books from subjects
          if (data['subjects'] != null &&
              data['subjects'] is List &&
              data['subjects'].isNotEmpty) {
            String subject = data['subjects'][0];
            await _fetchSimilarBooksBySubject(subject);
          }
        } else {
          throw Exception(
            'Failed to load book details: ${response.statusCode}',
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching book details: $e');
      setState(() {
        _error = 'Kitap detayları yüklenirken bir hata oluştu.';
        _isLoading = false;
      });
    }
  }

  // Fallback: Search for book by title and author
  Future<void> _searchBookByTitleAndAuthor() async {
    try {
      String query = widget.title;
      if (widget.authors != null && widget.authors!.isNotEmpty) {
        query += ' author:${widget.authors!.first}';
      }

      final url = Uri.parse(
        'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=1',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['docs'] != null && data['docs'].isNotEmpty) {
          final bookData = data['docs'][0];

          // Extract workId and fetch additional details
          if (bookData['key'] != null) {
            final workId = bookData['key'].toString().split('/').last;
            final detailUrl = Uri.parse(
              'https://openlibrary.org/works/$workId.json',
            );
            final detailResponse = await http.get(detailUrl);

            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);

              // Extract description
              if (detailData['description'] != null) {
                if (detailData['description'] is String) {
                  _bookDescription = detailData['description'];
                } else if (detailData['description'] is Map &&
                    detailData['description']['value'] != null) {
                  _bookDescription = detailData['description']['value'];
                }
              }

              // Get similar books from subjects
              if (detailData['subjects'] != null &&
                  detailData['subjects'] is List &&
                  detailData['subjects'].isNotEmpty) {
                String subject = detailData['subjects'][0];
                await _fetchSimilarBooksBySubject(subject);
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error searching for book: $e');
    }
  }

  // Fetch similar books by subject
  Future<void> _fetchSimilarBooksBySubject(String subject) async {
    try {
      final url = Uri.parse(
        'https://openlibrary.org/subjects/${Uri.encodeComponent(subject.toLowerCase())}.json?limit=5',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['works'] != null && data['works'] is List) {
          List<Map<String, dynamic>> books = [];

          for (var work in data['works']) {
            if (work['title'] != null) {
              // Get cover ID
              int? coverId;
              if (work['cover_id'] != null) {
                coverId = work['cover_id'];
              }

              books.add({
                'title': work['title'],
                'authors':
                    work['authors'] != null
                        ? List<Map<String, dynamic>>.from(
                          work['authors'],
                        ).map((a) => a['name'] as String).toList()
                        : [],
                'coverId': coverId,
                'key': work['key'], // Store the work key for navigation
              });
            }
          }

          setState(() {
            _similarBooks = books;
          });
        }
      }
    } catch (e) {
      print('Error fetching similar books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Colors.grey.shade700;

    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    // Error state
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Text(_error!, style: TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    // Content loaded state
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: iconColor),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share_outlined, color: iconColor),
                  onPressed: () {
                    // Share functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border, color: iconColor),
                  onPressed: () {
                    // Bookmark functionality
                  },
                ),
              ],
            ),

            // Book Cover and Basic Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover
                    Center(
                      child: Container(
                        height: 260,
                        width: 180,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              widget.coverUrl != null &&
                                      widget.coverUrl!.isNotEmpty
                                  ? Image.network(
                                    widget.coverUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (ctx, error, stackTrace) => Container(
                                          color: widget.backgroundColor,
                                          child: const Icon(
                                            Icons.book,
                                            size: 80,
                                            color: Colors.white54,
                                          ),
                                        ),
                                  )
                                  : Container(
                                    color: widget.backgroundColor,
                                    child: const Icon(
                                      Icons.book,
                                      size: 80,
                                      color: Colors.white54,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    // Book Title
                    Text(
                      widget.title,
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Author
                    if (widget.authors != null && widget.authors!.isNotEmpty)
                      Text(
                        'Yazar: ${widget.authors!.join(", ")}',
                        style: AppTextStyles.body?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),

                    // Publish Year
                    if (widget.publishYear != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Yayın Yılı: ${widget.publishYear}',
                          style: AppTextStyles.body?.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.check_circle_outline,
                          label: 'Okudum',
                          color: AppColors.primaryGreen,
                          onTap: () {
                            _markBookAsRead(context);
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.playlist_add,
                          label: 'Listeye Ekle',
                          color: AppColors.primaryGreen,
                          onTap: () {
                            _showAddToListDialog(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Description Section
                    Text('Açıklama', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),

                    // Display original description without translation
                    Text(
                      _bookDescription ??
                          widget.description ??
                          'Bu kitap için açıklama bulunmamaktadır.',
                      style: AppTextStyles.body,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Similar Books Section
                    Text('Benzer Kitaplar', style: AppTextStyles.heading2),
                    const SizedBox(height: 16),

                    // Show API fetched similar books or fallback to dummy books
                    _similarBooks.isNotEmpty
                        ? _buildApiSimilarBooks()
                        : _buildSimilarBooks(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiSimilarBooks() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarBooks.length,
        itemBuilder: (context, index) {
          final book = _similarBooks[index];
          String? coverUrl;
          String? workId;

          // Generate cover URL if coverId exists
          if (book['coverId'] != null) {
            coverUrl =
                'https://covers.openlibrary.org/b/id/${book['coverId']}-M.jpg';
          }

          // Extract work ID if present
          if (book['key'] != null) {
            final keyParts = book['key'].toString().split('/');
            if (keyParts.length > 1) {
              workId = keyParts.last;
            }
          }

          return GestureDetector(
            onTap: () {
              // Navigate to detail page for this book
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => BookDetail(
                        title: book['title'],
                        authors:
                            book['authors'] != null
                                ? List<String>.from(book['authors'])
                                : null,
                        coverUrl: coverUrl,
                        backgroundColor:
                            Colors.primaries[index % Colors.primaries.length],
                        workId: workId, // Pass work ID if available
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 180,
                    width: 120,
                    decoration: BoxDecoration(
                      color:
                          coverUrl == null
                              ? Colors.primaries[index %
                                  Colors.primaries.length]
                              : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        coverUrl != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (ctx, err, st) => Center(
                                      child: Icon(
                                        Icons.book,
                                        color: Colors.white.withOpacity(0.8),
                                        size: 40,
                                      ),
                                    ),
                              ),
                            )
                            : Center(
                              child: Icon(
                                Icons.book,
                                color: Colors.white.withOpacity(0.8),
                                size: 40,
                              ),
                            ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: Text(
                      book['title'],
                      style: AppTextStyles.body?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimilarBooks() {
    final List<Book> dummyBooks = Book.popularBooks;

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dummyBooks.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 180,
                  width: 120,
                  decoration: BoxDecoration(
                    color: dummyBooks[index].coverColor ?? Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.book,
                      color: Colors.white.withOpacity(0.8),
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120,
                  child: Text(
                    dummyBooks[index].title,
                    style: AppTextStyles.body?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddToListDialog(BuildContext context) {
    final bookListProvider = Provider.of<BookListProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if user is logged in
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listeye eklemek için giriş yapmalısınız'),
        ),
      );
      return;
    }

    final lists = bookListProvider.lists;

    // Convert current book to Book model
    final currentBook = bookListProvider.createBookFromDetails(
      title: widget.title,
      authors: widget.authors,
      coverUrl: widget.coverUrl,
      publishYear: widget.publishYear,
      backgroundColor: widget.backgroundColor,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Listeye Ekle'),
          content:
              bookListProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : lists.isEmpty
                  ? const Text(
                    'Henüz bir listeniz yok. Önce bir liste oluşturun.',
                  )
                  : SizedBox(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: lists.length,
                      itemBuilder: (context, index) {
                        final list = lists[index];
                        return ListTile(
                          title: Text(list.name),
                          trailing: Text('${list.books.length} kitap'),
                          onTap: () async {
                            try {
                              Navigator.pop(context);
                              // Show loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kitap ekleniyor...'),
                                  duration: Duration(milliseconds: 500),
                                ),
                              );

                              await bookListProvider.addBookToList(
                                list.id,
                                currentBook,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '"${widget.title}" kitabı "${list.name}" listesine eklendi',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Kitap eklenirken hata oluştu: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showCreateListDialog(context, currentBook);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Yeni Liste Oluştur'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateListDialog(BuildContext context, Book book) {
    final TextEditingController controller = TextEditingController();
    final bookListProvider = Provider.of<BookListProvider>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Liste Oluştur'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Liste adı',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  try {
                    Navigator.pop(context);
                    // Show loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Liste oluşturuluyor...'),
                        duration: Duration(milliseconds: 500),
                      ),
                    );

                    // Create new list and add the book to it
                    final newList = await bookListProvider.createList(
                      controller.text.trim(),
                    );
                    await bookListProvider.addBookToList(newList.id, book);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${widget.title}" kitabı "${newList.name}" listesine eklendi',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('İşlem sırasında hata oluştu: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Oluştur ve Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _markBookAsRead(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);

    // Check if user is logged in
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kitabı okudum olarak işaretlemek için giriş yapmalısınız',
          ),
        ),
      );
      return;
    }

    final user = authProvider.currentUser!;

    // Convert book details to a unique ID (using workId if available or title)
    final bookId =
        widget.workId ?? widget.title.replaceAll(' ', '_').toLowerCase();

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşleniyor...'),
          duration: Duration(milliseconds: 500),
        ),
      );

      final success = await pointsProvider.markBookAsReadAndAddPoints(
        user.id,
        user.name,
        bookId,
        widget.title,
        photoUrl: user.photoUrl,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tebrikler! 100 puan kazandınız'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu kitabı zaten okumuşsunuz')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
