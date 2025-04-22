import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_list_model.dart';
import '../models/book_model.dart';
import '../providers/auth_provider.dart';
import 'dart:math';

class BookListProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<BookList> _lists = [];
  String? _userId;
  bool _isLoading = false;

  // Initialize with user ID
  void initialize(String? userId) {
    _userId = userId;
    if (userId != null) {
      fetchLists();
    } else {
      _lists = [];
      notifyListeners();
    }
  }

  // Loading state
  bool get isLoading => _isLoading;

  // Get all lists
  List<BookList> get lists => _lists;

  // Get a specific list by id
  BookList? getListById(String id) {
    try {
      return _lists.firstWhere((list) => list.id == id);
    } catch (e) {
      return null;
    }
  }

  // Fetch all lists from Firestore
  Future<void> fetchLists() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('booklists')
              .where('userId', isEqualTo: _userId)
              .orderBy('createdAt', descending: true)
              .get();

      _lists = snapshot.docs.map((doc) => BookList.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching lists: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new list
  Future<BookList> createList(String name) async {
    if (_userId == null) {
      throw Exception('User not logged in');
    }

    final id =
        'list_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    final newList = BookList(id: id, name: name, userId: _userId!);

    _lists.add(newList);
    notifyListeners();

    // Save to Firestore
    try {
      await _firestore.collection('booklists').doc(id).set(newList.toMap());
    } catch (e) {
      print('Error creating list: $e');
      // Remove from local list if Firestore save fails
      _lists.removeWhere((list) => list.id == id);
      notifyListeners();
      rethrow;
    }

    return newList;
  }

  // Delete a list
  Future<void> deleteList(String id) async {
    _lists.removeWhere((list) => list.id == id);
    notifyListeners();

    // Delete from Firestore
    try {
      await _firestore.collection('booklists').doc(id).delete();
    } catch (e) {
      print('Error deleting list: $e');
      // Fetch lists again to restore state if delete fails
      await fetchLists();
    }
  }

  // Add a book to a list
  Future<void> addBookToList(String listId, Book book) async {
    final list = getListById(listId);
    if (list != null) {
      list.addBook(book);
      notifyListeners();

      // Update in Firestore
      try {
        await _firestore.collection('booklists').doc(listId).update({
          'books': list.books.map((b) => b.toMap()).toList(),
        });
      } catch (e) {
        print('Error adding book to list: $e');
        // Restore state if update fails
        await fetchLists();
      }
    }
  }

  // Remove a book from a list
  Future<void> removeBookFromList(String listId, Book book) async {
    final list = getListById(listId);
    if (list != null) {
      list.removeBook(book);
      notifyListeners();

      // Update in Firestore
      try {
        await _firestore.collection('booklists').doc(listId).update({
          'books': list.books.map((b) => b.toMap()).toList(),
        });
      } catch (e) {
        print('Error removing book from list: $e');
        // Restore state if update fails
        await fetchLists();
      }
    }
  }

  // Create a book from BookDetail parameters
  Book createBookFromDetails({
    required String title,
    List<String>? authors,
    String? coverUrl,
    int? publishYear,
    Color? backgroundColor,
  }) {
    return Book(
      title: title,
      author:
          authors != null && authors.isNotEmpty
              ? authors.first
              : 'Unknown Author',
      coverUrl: coverUrl ?? '',
      coverColor: backgroundColor,
    );
  }
}
