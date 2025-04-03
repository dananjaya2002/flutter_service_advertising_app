import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShopProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ShopModel> _shops = [];
  List<CategoryModel> _categories = [];
  final List<ShopModel> _filteredShops = [];
  String _selectedCategoryId = '';
  bool _isLoading = false;

  String? _errorMessage;

  List<ShopModel> get shops => _shops;
  List<CategoryModel> get categories => _categories;
  List<ShopModel> get filteredShops => _filteredShops;
  String get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize shop data
  void initialize() {
    _loadCategories();
    _loadShops();
  }

  // Load categories from Firestore
  void _loadCategories() {
    _databaseService.getCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  // Load shops from Firestore
  void _loadShops() {
    _isLoading = true;
    notifyListeners();

    _databaseService.getShops().listen((shops) {
      _shops = shops;
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    });
  }

  // Filter shops by category
  void filterByCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters (category and location)
  void _applyFilters() {
    List<ShopModel> result = List.from(_shops);

    // Apply category filter
    if (_selectedCategoryId.isNotEmpty) {
      result =
          result
              .where((shop) => shop.categories.contains(_selectedCategoryId))
              .toList();
    }
  }

  // Create a new shop
  Future<String> createShop(
    String name,
    String description,
    List<String> categories,
    GeoPoint location,
    String ownerId,
    File? imageFile,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create shop with default values
      ShopModel shop = ShopModel(
        id: '',
        ownerId: ownerId,
        name: name,
        description: description,
        location: location,
        categories: categories,
        createdAt: Timestamp.now(),
      );

      // Upload shop image if provided
      String? imageUrl;
      if (imageFile != null) {
        // We need the shop ID first to organize storage, so save first, then update
        String shopId = await _databaseService.createShop(shop);

        // Update shop with image URL
        await _databaseService.updateShop(shopId, {'imageUrl': imageUrl});

        _isLoading = false;
        notifyListeners();

        return shopId;
      } else {
        // Save shop without image
        String shopId = await _databaseService.createShop(shop);

        _isLoading = false;
        notifyListeners();

        return shopId;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error creating shop: $e');
      rethrow;
    }
  }

  // Update shop details
  Future<void> updateShop(
    String shopId,
    Map<String, dynamic> data,
    File? newImageFile,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.updateShop(shopId, data);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error updating shop: $e');
      rethrow;
    }
  }

  // Publish shop (make visible to customers)
  Future<void> publishShop(String shopId, bool isPublished) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.updateShop(shopId, {'isPublished': isPublished});

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error publishing shop: $e');
      rethrow;
    }
  }

  // Get shop by ID
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      return await _databaseService.getShopById(shopId);
    } catch (e) {
      print('Error getting shop by id: $e');
      return null;
    }
  }

  // Get shops owned by a user
  Stream<List<ShopModel>> getUserShops(String userId) {
    return _databaseService.getUserShops(userId);
  }

  // Load shops from Firestore
  Future<void> loadShops() async {
    try {
      final snapshot = await _firestore.collection('shops').get();
      _shops =
          snapshot.docs
              .map((doc) => ShopModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading shops: $e');
      rethrow;
    }
  }

  // Alias for loadShops to maintain compatibility
  Future<void> fetchShops() async {
    return loadShops();
  }

  // Load categories from Firestore
  Future<void> loadCategories() async {
    _setLoading(true);

    try {
      final categoriesData = await _databaseService.getCollection('categories');
      _categories =
          categoriesData.map((data) => CategoryModel.fromMap(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter shops by category
  List<ShopModel> filterShopsByCategory(String categoryId) {
    return _shops
        .where((shop) => shop.categories.contains(categoryId))
        .toList();
  }

  // Search shops by name or description
  List<ShopModel> searchShops(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _shops.where((shop) {
      return shop.name.toLowerCase().contains(lowercaseQuery) ||
          (shop.description ?? '').toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Initialize default categories if none exist
  Future<void> initializeDefaultCategories() async {
    try {
      final categories = await _databaseService.getCollection('categories');
      if (categories.isEmpty) {
        final defaultCategories = [
          {
            'name': 'Electrician',
            'description': 'Professional electrical services and repairs',
            'imageUrl': 'https://example.com/electrician.jpg',
            'sortOrder': 1,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Plumber',
            'description': 'Expert plumbing services and maintenance',
            'imageUrl': 'https://example.com/plumber.jpg',
            'sortOrder': 2,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Carpenter',
            'description': 'Custom woodwork and furniture repairs',
            'imageUrl': 'https://example.com/carpenter.jpg',
            'sortOrder': 3,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Painter',
            'description': 'Professional painting services',
            'imageUrl': 'https://example.com/painter.jpg',
            'sortOrder': 4,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'AC Repair',
            'description': 'Air conditioning maintenance and repairs',
            'imageUrl': 'https://example.com/ac-repair.jpg',
            'sortOrder': 5,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Cleaning',
            'description': 'Professional cleaning services',
            'imageUrl': 'https://example.com/cleaning.jpg',
            'sortOrder': 6,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
        ];

        for (var category in defaultCategories) {
          await _databaseService.addDocument('categories', category);
        }

        // Reload categories after adding
        await loadCategories();
      }
    } catch (e) {
      debugPrint('Error initializing default categories: $e');
    }
  }

  Future<void> addShop(ShopModel shop) async {
    try {
      final docRef = await _firestore.collection('shops').add(shop.toMap());
      final newShop = ShopModel.fromMap({...shop.toMap(), 'id': docRef.id});
      _shops.add(newShop);
      notifyListeners();
    } catch (e) {
      print('Error adding shop: $e');
      rethrow;
    }
  }

  Future<ShopModel?> getShopByOwnerId(String ownerId) async {
    try {
      final snapshot =
          await _firestore
              .collection('shops')
              .where('ownerId', isEqualTo: ownerId)
              .get();

      if (snapshot.docs.isEmpty) return null;

      return ShopModel.fromMap({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      print('Error getting shop by owner ID: $e');
      rethrow;
    }
  }

  Future<void> updateServices(
    String shopId,
    List<Map<String, dynamic>> services,
  ) async {
    try {
      // Reference to the services subcollection
      final servicesRef = FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .collection('services');

      // Clear existing services
      final existingServices = await servicesRef.get();
      for (var doc in existingServices.docs) {
        await doc.reference.delete();
      }

      // Add updated services
      for (var service in services) {
        await servicesRef.add({
          'name': service['name'],
          'description': service['description'],
          'imageUrl': service['imageUrl'], // Include the image URL
          'createdAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update services: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchServices(String shopId) async {
    try {
      final servicesRef = FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .collection('services');

      final servicesSnapshot = await servicesRef.get();

      return servicesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'description': data['description'] ?? '', // Optional description
          'imageUrl': data['imageUrl'] ?? '', // Include the image URL
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  Future<String?> getShopNameById(String shopId) async {
    try {
      final shopDoc =
          await FirebaseFirestore.instance
              .collection('shops')
              .doc(shopId)
              .get();

      if (shopDoc.exists) {
        return shopDoc.data()?['name'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching shop name: $e');
      return null;
    }
  }

  // Upload image to Cloudinary
  Future<String> pickImage() async {
    try {
      // Step 1: Pick an image from the device
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        // User canceled the image picking
        return '';
      }

      // Step 2: Upload the image to Cloudinary
      final String cloudinaryUrl =
          'https://api.cloudinary.com/v1_1/dw9iw9vhk/image/upload';
      final String uploadPreset = 'image_type_1';

      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(
        await http.MultipartFile.fromPath('file', pickedFile.path),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        // Step 3: Parse the response to get the image URL
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> jsonResponse = json.decode(responseData);
        final String imageUrl = jsonResponse['secure_url'];

        return imageUrl; // Return the image URL
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      print('Error picking or uploading image: $e');
      return '';
    }
  }
}
