import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_screen.dart';

class ShopDetailsScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  bool _isLoading = true;
  bool _isFavorite = false;
  ShopModel? _shop;
  String? _errorMessage;
  List<Map<String, dynamic>> _ratings = []; // Store ratings with user details

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
    _loadRatings();
  }

  Future<void> _loadShopDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final favoriteProvider = Provider.of<FavoriteProvider>(
        context,
        listen: false,
      );

      final shop = await shopProvider.getShopById(widget.shop.id);
      final services = await shopProvider.fetchServices(widget.shop.id);

      // Ensure services include the imageUrl field
      final updatedServices =
          services.map((service) {
            return {
              'name': service['name'],
              'description': service['description'],
              'imageUrl': service['imageUrl'], // Include imageUrl
            };
          }).toList();

      final updatedShop = shop?.copyWith(services: updatedServices);

      if (shop == null) {
        setState(() {
          _errorMessage = 'Shop not found';
          _isLoading = false;
        });
        return;
      }

      final userId = userProvider.user?.uid;
      bool isFavorite = false;
      if (userId != null) {
        isFavorite = await favoriteProvider.isShopFavorited(
          userId,
          widget.shop.id,
        );
      }

      if (mounted) {
        setState(() {
          _shop = updatedShop;
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load shop details: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRatings() async {
    try {
      // Query ratings where the shopId matches the current shop's ID
      final ratingsSnapshot =
          await FirebaseFirestore.instance
              .collection('ratings')
              .where('shopId', isEqualTo: widget.shop.id) // Filter by shopId
              .get();

      final List<Map<String, dynamic>> ratings = [];

      for (var doc in ratingsSnapshot.docs) {
        final ratingData = doc.data();
        final chatId = ratingData['chatId'];

        // Fetch the chat document to get the customerId
        final chatSnapshot =
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .get();

        final chatData = chatSnapshot.data();
        final customerId = chatData?['customerId'];

        // Fetch user details using customerId
        if (customerId != null) {
          final userSnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(customerId)
                  .get();

          final userData = userSnapshot.data();
          ratings.add({
            'name': userData?['name'] ?? 'Anonymous',
            'profileImage': userData?['profileImage'], // Null if unavailable
            'rating': ratingData['rating'],
            'comment': ratingData['comment'],
          });
        }
      }

      setState(() {
        _ratings = ratings;
      });
    } catch (e) {
      print('Error loading ratings: $e');
    }
  }

  /// Calculate the average rating from the ratings list
  double _calculateAverageRating() {
    if (_ratings.isEmpty) return 0.0;

    final totalRating = _ratings.fold<double>(
      0.0,
      (sum, rating) => sum + (rating['rating'] as int),
    );

    return totalRating / _ratings.length;
  }

  Future<void> _toggleFavorite() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    final userId = userProvider.user?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add favorites')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await favoriteProvider.removeFromFavorites(userId, widget.shop.id);
      } else {
        await favoriteProvider.addToFavorites(userId, widget.shop.id);
      }

      setState(() {
        _isFavorite = !_isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));
    }
  }

  Future<void> _startChat() async {
    if (_shop == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a conversation')),
      );
      return;
    }

    if (userId == _shop!.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final chatId = await chatProvider.createOrGetChat(
        _shop!.id,
        userId,
        _shop!.ownerId,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId)),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorWidget()
                : _buildShopDetails(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadShopDetails,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildShopDetails() {
    final shop = _shop!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Image or Placeholder
        shop.imageUrl != null
            ? Image.network(
              shop.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.store, size: 50, color: Colors.white),
                );
              },
            )
            : Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.store, size: 50, color: Colors.white),
            ),
        const SizedBox(height: 16),

        // Shop Name and Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.shop.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children: [
                // Display stars based on the average rating
                ...List.generate(5, (index) {
                  final averageRating = _calculateAverageRating();
                  return Icon(
                    index < averageRating.floor()
                        ? Icons.star
                        : (index < averageRating
                            ? Icons.star_half
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ],
            ),
            const SizedBox(width: 8),
            // Display average rating and number of ratings
            Text(
              '${_calculateAverageRating().toStringAsFixed(1)} (${_ratings.length})',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          shop.description ?? 'No description available',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Action Buttons: Call, Chat, Map, Share
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(Icons.call, 'Call', () {
              if (_shop?.phoneNumber != null) {
                _showCallPopup(_shop!.phoneNumber!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number not available')),
                );
              }
            }),
            _buildActionButton(Icons.chat, 'Chat', _startChat),
            _buildActionButton(Icons.share, 'Share', () {
              if (_shop != null) {
                final shareContent =
                    'Check out this shop using Shop connect mobile app: ${_shop!.name}\n\nShop Description:\n${_shop!.description ?? ''}';
                Clipboard.setData(ClipboardData(text: shareContent));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Shop details copied to clipboard! Share it manually.',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shop details not available to share.'),
                  ),
                );
              }
            }),
          ],
        ),
        const SizedBox(height: 16),

        // Services Section
        const Text(
          'Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 230, // Fixed height for the ListView
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shop.services.length,
            itemBuilder: (context, index) {
              final service = shop.services[index];
              return _buildServiceCard(service);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Reviews Section
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_ratings.isEmpty)
          const Text('No reviews yet.', style: TextStyle(fontSize: 16))
        else
          ListView.builder(
            shrinkWrap:
                true, // Allows the ListView to take only as much space as needed
            physics:
                const NeverScrollableScrollPhysics(), // Prevents scrolling inside the ListView
            itemCount: _ratings.length,
            itemBuilder: (context, index) {
              final rating = _ratings[index];
              return _buildReview(
                rating['name'],
                rating['comment'],
                rating['rating'],
                rating['profileImage'],
              );
            },
          ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, size: 30), onPressed: onPressed),
        Text(label),
      ],
    );
  }

  void _showCallPopup(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contact Number'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: phoneNumber));
                  Navigator.pop(context); // Close the popup
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number copied to clipboard!'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy to Clipboard'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the popup
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            // Display the service image or a default placeholder
            service['imageUrl'] != null && service['imageUrl']!.isNotEmpty
                ? Image.network(
                  service['imageUrl'],
                  width: double.infinity,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                )
                : Container(
                  width: double.infinity,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
            const SizedBox(height: 8),
            Text(
              service['name'] ?? 'Unnamed Service',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                service['description'] ?? 'No description available',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(
    String name,
    String reviewText,
    int rating,
    String? profileImage,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  profileImage != null
                      ? NetworkImage(profileImage)
                      : null, // Use profile image if available
              child:
                  profileImage == null
                      ? const Icon(Icons.person, size: 20) // Default icon
                      : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: List.generate(
                      rating,
                      (index) =>
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(reviewText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
