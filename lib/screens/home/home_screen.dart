import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../models/category_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../shop/shop_details_screen.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ShopProvider _shopProvider;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  // Map of category IDs to their icons and colors
  final Map<String, Map<String, dynamic>> _categoryStyles = {
    '1': {'icon': Icons.electrical_services, 'color': Colors.blue},
    '2': {'icon': Icons.plumbing, 'color': Colors.green},
    '3': {'icon': Icons.handyman, 'color': Colors.orange},
    '4': {'icon': Icons.format_paint, 'color': Colors.purple},
    '5': {'icon': Icons.ac_unit, 'color': Colors.red},
    '6': {'icon': Icons.cleaning_services, 'color': Colors.teal},
  };

  // Predefined categories
  final List<CategoryModel> _categories = CategoryModel.defaultCategories;

  @override
  void initState() {
    super.initState();
    _shopProvider = Provider.of<ShopProvider>(context, listen: false);
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      await _shopProvider.loadShops();

      // Fetch all ratings in a single query
      final ratingsSnapshot =
          await FirebaseFirestore.instance.collection('ratings').get();

      // Group ratings by shopId
      final ratingsByShopId = <String, List<Map<String, dynamic>>>{};
      for (var doc in ratingsSnapshot.docs) {
        final data = doc.data();
        final shopId = data['shopId'] as String;
        ratingsByShopId.putIfAbsent(shopId, () => []).add(data);
      }

      for (var shop in _shopProvider.shops) {
        try {
          // Get ratings for the current shop
          final shopRatings = ratingsByShopId[shop.id] ?? [];

          // Calculate the total rating and average rating
          final totalRating = shopRatings.fold<double>(
            0.0,
            (sum, rating) => sum + (rating['rating'] as int),
          );

          final averageRating =
              shopRatings.isNotEmpty ? totalRating / shopRatings.length : 0.0;

          // Check if the values have changed before updating Firestore
          if (shop.rating != averageRating ||
              shop.reviewCount != shopRatings.length) {
            shop.rating = averageRating;
            shop.reviewCount = shopRatings.length;

            // Update the shop document with the new values
            await FirebaseFirestore.instance
                .collection('shops')
                .doc(shop.id)
                .update({
                  'rating': shop.rating,
                  'reviewCount': shop.reviewCount,
                });
          }

          // Debug logs
          print(
            'Shop: ${shop.name}, Rating: ${shop.rating}, Reviews: ${shop.reviewCount}',
          );
        } catch (e) {
          // Handle errors for individual shops
          print('Error processing shop ${shop.name}: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load shops: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<ShopModel> get _paginatedShops {
    final filtered = _filteredShops; // Get the filtered shops
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    return filtered.sublist(
      startIndex,
      endIndex > filtered.length ? filtered.length : endIndex,
    );
  }

  List<ShopModel> get _filteredShops {
    var filtered = _shopProvider.shops;

    if (_selectedCategory != null) {
      filtered =
          filtered
              .where((shop) => shop.categories.contains(_selectedCategory))
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (shop) =>
                    shop.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    (shop.description?.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _logout(BuildContext context) async {
    try {
      // Sign out the user using Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Navigate to the LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      // Handle any errors during logout
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  void _showAllCategoriesPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ListTile(
                      title: Text(category.name), // Only show the category name
                      onTap: () {
                        setState(() {
                          _selectedCategory = category.id;
                        });
                        Navigator.pop(context); // Close the popup
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final username =
                userProvider.user?.name ??
                'User'; // Default to 'User' if name is null
            return Text('Welcome, $username');
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              } else if (value == 'refresh') {
                _loadShops();
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                      leading: Icon(Icons.refresh),
                      title: Text('Refresh'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
            icon: const Icon(Icons.menu), // Menu icon
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        hintText: 'Search shops...',
                      ),
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Categories section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _showAllCategoriesPopup(context);
                          },
                          child: const Text(
                            'Show All',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            _categories.length > 6
                                ? 6
                                : _categories.length, // Limit to 6
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = category.id == _selectedCategory;
                          final styles =
                              _categoryStyles[category.id] ??
                              {'icon': Icons.category, 'color': Colors.grey};
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory =
                                      isSelected ? null : category.id;
                                });
                              },
                              child: CategoryItem(
                                category: category,
                                isSelected: isSelected,
                                icon: styles['icon'] as IconData,
                                color: styles['color'] as Color,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Services section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedCategory !=
                                null) // Show only if a filter is applied
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text(
                              'Clear Filters',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Shop cards
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage != null)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadShops,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildShopList(),
                  ],
                ),
              ),
            ),
          ),
          // Pagination controls at the bottom
          Padding(
            padding: const EdgeInsets.all(2.0), // Reduced inner padding
            child: _buildPaginationControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopList() {
    final shops = _paginatedShops; // Use paginated shops
    if (shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No shops found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: shops.length,
          itemBuilder:
              (context, index) => _buildShopCard(context, shops[index]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildShopCard(BuildContext context, ShopModel shop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailsScreen(shop: shop),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  shop.imageUrl ?? 'https://via.placeholder.com/150',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.store,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < shop.rating.floor()
                                ? Icons.star
                                : (index < shop.rating
                                    ? Icons.star_half
                                    : Icons.star_border),
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${shop.rating.toStringAsFixed(1)} (${shop.reviewCount})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (shop.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        shop.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_filteredShops.length / _itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _currentPage > 0
                  ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                  : null, // Disable if on the first page
        ),
        Text(
          'Page ${_currentPage + 1} of $totalPages',
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed:
              _currentPage < totalPages - 1
                  ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                  : null, // Disable if on the last page
        ),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final IconData icon;
  final Color color;

  const CategoryItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Icon(icon, color: isSelected ? Colors.white : color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          category.name,
          style: TextStyle(
            color: isSelected ? color : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
