import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _user;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isServiceProvider => _user?.role == 'service_provider';

  // Initialize user data
  Future<void> initialize() async {
    if (_authService.currentUser != null) {
      await refreshUserData();
    }
  }

  // Refresh user data from Firestore
  Future<void> refreshUserData() async {
  try {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.getUserData();
    if (_user == null) {
      throw Exception("User data not found in Firestore.");
    }

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    print("Error refreshing user data: $e");
  }
}

  // Sign in user
  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signInWithEmailAndPassword(email, password);
      await refreshUserData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Register user
  Future<void> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Register the user
      await _authService.registerWithEmailAndPassword(email, password, name);

      // Automatically sign in after registration
      await _authService.signInWithEmailAndPassword(email, password);
      await refreshUserData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
  try {
    _isLoading = true;
    notifyListeners();

    // Sign out from Firebase Authentication
    await FirebaseAuth.instance.signOut();

    // Clear user data
    _user = null;

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    print("Logout error: $e");
    rethrow;
  }
}

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateUserData(data);
      await refreshUserData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Set service provider status
  Future<void> setServiceProviderStatus(bool status) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.setServiceProviderStatus(status);
      await refreshUserData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Listen to auth state changes
  void listenToAuthChanges() {
  _authService.authStateChanges.listen((user) async {
    print("Auth state changed. User: ${user?.uid}");
    if (user != null) {
      await refreshUserData();
    } else {
      _user = null;
      notifyListeners();
    }
  });
}

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });

      if (_user != null) {
        _user = _user!.copyWith(role: newRole);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  Future<String?> getUserNameById(String userId) async {
  try {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data()?['name'] as String?;
    }
    return null;
  } catch (e) {
    print('Error fetching user name: $e');
    return null;
  }
}
}
