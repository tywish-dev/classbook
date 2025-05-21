import 'package:cloud_firestore/cloud_firestore.dart';

class Classroom {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String teacherId;

  Classroom({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.teacherId,
  });

  // Firestore'a kaydetmek için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'teacherId': teacherId,
    };
  }

  // Firestore'dan almak için factory constructor
  factory Classroom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Classroom(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      teacherId: data['teacherId'] ?? '',
    );
  }
}
