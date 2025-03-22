// lib/models/user.dart
class AppUser {
  final String uid;
  final String name;
  final String email;
  bool isServiceProvider;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.isServiceProvider = false,
  });
}
