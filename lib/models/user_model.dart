class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.role = 'customer',
    required this.createdAt,
  });

  // Getter for displayName to maintain compatibility with code that expects it
  String get displayName => name;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
      role: map['role'] as String? ?? 'customer',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
