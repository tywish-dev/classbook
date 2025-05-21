class User {
  final String id;
  final String name;
  final String email;
  final List<String> genrePreferences;
  final String? photoUrl;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.genrePreferences = const [],
    this.photoUrl,
    this.role = 'student',
  });

  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? genrePreferences,
    String? photoUrl,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      genrePreferences: genrePreferences ?? this.genrePreferences,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }

  // Convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'genrePreferences': genrePreferences,
      'photoUrl': photoUrl,
      'role': role,
    };
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      genrePreferences: List<String>.from(json['genrePreferences'] ?? []),
      role: json['role'] as String? ?? 'student',
    );
  }

  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      genrePreferences: List<String>.from(data['genrePreferences'] ?? []),
      role: data['role'] as String? ?? 'student',
    );
  }
}
