class User {
  final String id;
  final String name;
  final String email;
  final List<String> genrePreferences;
  final String? photoUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.genrePreferences = const [],
    this.photoUrl,
  });

  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? genrePreferences,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      genrePreferences: genrePreferences ?? this.genrePreferences,
      photoUrl: photoUrl ?? this.photoUrl,
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
    };
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      genrePreferences: List<String>.from(json['genrePreferences'] ?? []),
      photoUrl: json['photoUrl'],
    );
  }
}
