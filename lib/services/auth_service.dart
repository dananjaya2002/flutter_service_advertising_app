// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart'; // Import the custom AppUser model

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // Convert Firebase User to your custom AppUser model
  AppUser? firebaseUserToAppUser(firebase_auth.User? firebaseUser) {
    return firebaseUser != null
        ? AppUser(
            uid: firebaseUser.uid,
            name: firebaseUser.displayName ?? '',
            email: firebaseUser.email ?? '',
            isServiceProvider: false, // Default to false until verified
          )
        : null;
  }

  // Sign in with email and password
  Future<AppUser?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return firebaseUserToAppUser(result.user);
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  // Create a new user
  Future<AppUser?> signUp(String name, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update user profile with name
      await result.user!.updateDisplayName(name);
      return firebaseUserToAppUser(result.user);
    } catch (e) {
      print('Sign-up failed: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}