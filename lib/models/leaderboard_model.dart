class UserPoints {
  final String userId;
  final String userName;
  final int points;
  final String? photoUrl;

  const UserPoints({
    required this.userId,
    required this.userName,
    required this.points,
    this.photoUrl,
  });

  // Create a copy with updated fields
  UserPoints copyWith({
    String? userId,
    String? userName,
    int? points,
    String? photoUrl,
  }) {
    return UserPoints(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      points: points ?? this.points,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'points': points,
      'photoUrl': photoUrl,
    };
  }

  // Create from JSON
  factory UserPoints.fromJson(Map<String, dynamic> json) {
    return UserPoints(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      points: json['points'] as int,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  // Create from Firestore document
  factory UserPoints.fromFirestore(Map<String, dynamic> data, String id) {
    return UserPoints(
      userId: id,
      userName: data['userName'] as String? ?? 'Unknown User',
      points: data['points'] as int? ?? 0,
      photoUrl: data['photoUrl'] as String?,
    );
  }
}
