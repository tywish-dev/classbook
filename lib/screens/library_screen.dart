import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/book_list_provider.dart';
import '../providers/auth_provider.dart';
import '../models/book_list_model.dart';
import '../models/book_model.dart';
import '../widgets/bottom_navbar.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final int selectedNavIndex;
  final Function(int)? onNavTap;

  const LibraryScreen({super.key, this.selectedNavIndex = 2, this.onNavTap});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the book list provider is initialized with the current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookListProvider = Provider.of<BookListProvider>(
        context,
        listen: false,
      );
      if (authProvider.currentUser != null) {
        bookListProvider.initialize(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookListProvider>(
      builder: (context, bookListProvider, child) {
        // Loading state
        if (bookListProvider.isLoading) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final lists = bookListProvider.lists;

        // Main content - match exactly the structure from HomeScreen
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Kütüphanem',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () => _showCreateListDialog(context),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main Content
                    lists.isEmpty
                        ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(context),
                        )
                        : SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _buildListCard(context, lists[index]),
                              childCount: lists.length,
                            ),
                          ),
                        ),

                    // Bottom padding for navigation bar
                    const SliverToBoxAdapter(child: SizedBox(height: 160)),
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
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz bir liste oluşturmadınız',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kitaplarınızı düzenlemek için bir liste oluşturun',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateListDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Liste Oluştur', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context, BookList list) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookListDetailScreen(list: list),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${list.books.length} Kitap',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (list.books.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: list.books.length > 5 ? 5 : list.books.length,
                    itemBuilder: (context, index) {
                      final book = list.books[index];
                      return _buildBookCover(context, book, index);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(BuildContext context, Book book, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BookDetail(
                    title: book.title,
                    authors: [book.author],
                    coverUrl: book.coverUrl,
                    backgroundColor: book.coverColor ?? Colors.blue,
                  ),
            ),
          );
        },
        child: Container(
          width: 80,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: book.coverColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:
              book.coverUrl.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Center(
                            child: Icon(Icons.book, color: Colors.white54),
                          ),
                    ),
                  )
                  : Center(
                    child: Icon(
                      Icons.book,
                      color: Colors.white.withOpacity(0.7),
                      size: 40,
                    ),
                  ),
        ),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giriş yapmalısınız')));
      return;
    }

    final TextEditingController controller = TextEditingController();

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
                    final bookListProvider = Provider.of<BookListProvider>(
                      context,
                      listen: false,
                    );

                    await bookListProvider.createList(controller.text.trim());
                    Navigator.pop(context);
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Liste oluşturulamadı: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Oluştur'),
            ),
          ],
        );
      },
    );
  }
}

// Detail screen for a book list
class BookListDetailScreen extends StatelessWidget {
  final BookList list;

  const BookListDetailScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          list.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body:
          list.books.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bu listede henüz kitap yok',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kitap detay sayfasından kitapları bu listeye ekleyebilirsiniz',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: list.books.length,
                itemBuilder: (context, index) {
                  final book = list.books[index];
                  return _buildBookItem(context, book);
                },
              ),
    );
  }

  Widget _buildBookItem(BuildContext context, Book book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BookDetail(
                    title: book.title,
                    authors: [book.author],
                    coverUrl: book.coverUrl,
                    backgroundColor: book.coverColor ?? Colors.blue,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Book cover
              Container(
                width: 70,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: book.coverColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    book.coverUrl.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            book.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Center(
                                  child: Icon(
                                    Icons.book,
                                    color: Colors.white54,
                                  ),
                                ),
                          ),
                        )
                        : Center(
                          child: Icon(
                            Icons.book,
                            color: Colors.white.withOpacity(0.7),
                            size: 32,
                          ),
                        ),
              ),
              const SizedBox(width: 16),
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // Remove button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  try {
                    final bookListProvider = Provider.of<BookListProvider>(
                      context,
                      listen: false,
                    );

                    // Show loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kitap siliniyor...'),
                        duration: Duration(milliseconds: 500),
                      ),
                    );

                    await bookListProvider.removeBookFromList(list.id, book);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${book.title}" kitabı listeden kaldırıldı',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kitap kaldırılırken hata oluştu: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Listeyi Sil'),
          content: Text(
            '${list.name} listesini silmek istediğinize emin misiniz?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.pop(context);

                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Liste siliniyor...'),
                      duration: Duration(milliseconds: 500),
                    ),
                  );

                  await Provider.of<BookListProvider>(
                    context,
                    listen: false,
                  ).deleteList(list.id);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${list.name}" listesi silindi'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Liste silinirken hata oluştu: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }
}
