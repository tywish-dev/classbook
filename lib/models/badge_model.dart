import 'package:cloud_firestore/cloud_firestore.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int requiredPoints;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.requiredPoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'requiredPoints': requiredPoints,
    };
  }

  factory Badge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Badge(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      requiredPoints: data['requiredPoints'] ?? 0,
    );
  }
}
