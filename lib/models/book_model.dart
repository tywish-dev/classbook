import 'package:flutter/material.dart';

class Book {
  final String title;
  final String author;
  final String coverUrl; // Could be local asset or network URL
  final Color? coverColor; // Used for placeholder/generated covers
  final String? listenTime; // e.g., '5dk'
  final String? readTime; // e.g., '8dk'
  // Add other relevant fields like description, genre, id, etc.

  Book({
    required this.title,
    required this.author,
    this.coverUrl = '',
    this.coverColor,
    this.listenTime,
    this.readTime,
  });

  // Convert a Book instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'coverColorValue': coverColor?.value,
      'listenTime': listenTime,
      'readTime': readTime,
    };
  }

  // Create a Book instance from a Firestore Map
  static Book fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'] ?? 'Unknown Title',
      author: map['author'] ?? 'Unknown Author',
      coverUrl: map['coverUrl'] ?? '',
      coverColor:
          map['coverColorValue'] != null ? Color(map['coverColorValue']) : null,
      listenTime: map['listenTime'],
      readTime: map['readTime'],
    );
  }

  // Placeholder static data for demonstration
  static final List<Book> popularBooks = [
    Book(
      title: 'Placeholder Book 1',
      author: 'Author A',
      coverColor: Colors.blue,
      listenTime: '5dk',
      readTime: '10dk',
    ),
    Book(
      title: 'Placeholder Book 2',
      author: 'Author B',
      coverColor: Colors.red,
      listenTime: '7dk',
      readTime: '12dk',
    ),
    Book(
      title: 'Placeholder Book 3',
      author: 'Author C',
      coverColor: Colors.green,
      listenTime: '6dk',
      readTime: '9dk',
    ),
  ];

  static final List<Book> newReleases = [
    Book(
      title: 'New Release 1',
      author: 'Author D',
      coverColor: Colors.purple,
      listenTime: '8dk',
      readTime: '15dk',
    ),
    Book(
      title: 'New Release 2',
      author: 'Author E',
      coverColor: Colors.orange,
      listenTime: '4dk',
      readTime: '8dk',
    ),
  ];
}
