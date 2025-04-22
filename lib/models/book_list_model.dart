import 'book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookList {
  String id;
  String name;
  List<Book> books;
  DateTime createdAt;
  String userId; // To associate lists with users

  BookList({
    required this.id,
    required this.name,
    required this.userId,
    List<Book>? books,
    Timestamp? createdTimestamp,
  }) : books = books ?? [],
       createdAt = createdTimestamp?.toDate() ?? DateTime.now();

  // Add a book to the list if it's not already in the list
  void addBook(Book book) {
    if (!books.any((b) => b.title == book.title && b.author == book.author)) {
      books.add(book);
    }
  }

  // Remove a book from the list
  void removeBook(Book book) {
    books.removeWhere((b) => b.title == book.title && b.author == book.author);
  }

  // Convert to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'books': books.map((book) => book.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create BookList from Firestore document
  static BookList fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> bookData = data['books'] ?? [];

    return BookList(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? 'Unnamed List',
      userId: data['userId'] ?? '',
      books: bookData.map((book) => Book.fromMap(book)).toList(),
      createdTimestamp: data['createdAt'] as Timestamp?,
    );
  }
}
