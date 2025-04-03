import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../services/database_service.dart';

class FavoriteProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Add shop to favorites
  Future<void> addToFavorites(String userId, String shopId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.addShopToFavorites(userId, shopId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove shop from favorites
  Future<void> removeFromFavorites(String userId, String shopId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.removeShopFromFavorites(userId, shopId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  // Get user's favorite shops
  Stream<List<ShopModel>> getFavoriteShops(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    return _databaseService.getFavoriteShops(userId);
  }

  // Check if shop is in favorites
  Future<bool> isShopFavorited(String userId, String shopId) async {
    if (userId.isEmpty || shopId.isEmpty) {
      return false;
    }

    try {
      final doc = await _databaseService.usersCollection.doc(userId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final List<dynamic> favoriteShops = data['favoriteShops'] ?? [];

      return favoriteShops.contains(shopId);
    } catch (e) {
      print('Error checking if shop is favorited: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String userId, String shopId) async {
    try {
      bool isFavorite = await isShopFavorited(userId, shopId);

      if (isFavorite) {
        await removeFromFavorites(userId, shopId);
        return false;
      } else {
        await addToFavorites(userId, shopId);
        return true;
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }
}
