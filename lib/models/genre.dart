class Genre {
  final String id;
  final String name;
  final String iconPath;

  const Genre({required this.id, required this.name, required this.iconPath});

  // Convert Genre object to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'iconPath': iconPath};
  }

  // Create Genre object from JSON
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
      iconPath: json['iconPath'],
    );
  }
}
