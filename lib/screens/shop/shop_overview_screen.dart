import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../shop/manage_service_screen.dart'; // Update the path to the correct location of ManageServicesScreen

class ShopOverviewScreen extends StatefulWidget {
  const ShopOverviewScreen({super.key});

  @override
  State<ShopOverviewScreen> createState() => _ShopOverviewScreenState();
}

class _ShopOverviewScreenState extends State<ShopOverviewScreen> {
  bool _isLoading = true;
  bool _isServicesLoading = true; // Tracks loading state for services
  bool _isReviewsLoading = true; // Tracks loading state for reviews
  ShopModel? _shop;
  List<Map<String, dynamic>> _ratings = []; // Store ratings with user details

  @override
  void initState() {
    super.initState();
    _loadShopData().then((_) {
      if (_shop != null) {
        _loadRatings();
      }
    });
  }

  Future<void> _loadShopData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.uid;
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    try {
      final shop = await shopProvider.getShopByOwnerId(userId);

      // Fetch services from the Firestore subcollection
      setState(() {
        _isServicesLoading = true; // Start loading services
      });

      final services =
          shop != null ? await shopProvider.fetchServices(shop.id) : [];

      setState(() {
        if (shop != null) {
          _shop = shop.copyWith(
            services: services.cast<Map<String, dynamic>>(),
          ); // Update _shop with services
        }
        _isServicesLoading = false; // Stop loading services
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading shop data: $e')));
      }
      setState(() {
        _isServicesLoading = false; // Stop loading services
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRatings() async {
    try {
      setState(() {
        _isReviewsLoading = true; // Start loading reviews
      });

      final ratingsSnapshot =
          await FirebaseFirestore.instance
              .collection('ratings')
              .where('shopId', isEqualTo: _shop!.id)
              .get();

      final List<Map<String, dynamic>> ratings = [];

      for (var doc in ratingsSnapshot.docs) {
        final ratingData = doc.data();
        final chatId = ratingData['chatId'];

        final chatSnapshot =
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .get();

        final chatData = chatSnapshot.data();
        final customerId = chatData?['customerId'];

        if (customerId != null) {
          final userSnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(customerId)
                  .get();

          final userData = userSnapshot.data();
          ratings.add({
            'name': userData?['name'] ?? 'Anonymous',
            'profileImage': userData?['profileImage'],
            'rating': ratingData['rating'],
            'comment': ratingData['comment'],
            'timestamp': ratingData['timestamp'], // Add timestamp field
          });
        }
      }

      setState(() {
        _ratings = ratings;
        _isReviewsLoading = false; // Stop loading reviews
      });
    } catch (e) {
      print('Error loading ratings: $e');
      setState(() {
        _isReviewsLoading = false; // Stop loading reviews
      });
    }
  }

  double _calculateAverageRating() {
    if (_ratings.isEmpty) return 0.0;

    final totalRating = _ratings.fold<double>(
      0.0,
      (sum, rating) => sum + (rating['rating'] as int),
    );

    return totalRating / _ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_shop == null) {
      return const Scaffold(
        body: Center(child: Text('No shop found. Please create a shop first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_shop!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditShopPopup,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildShopDetails(), _buildServiceList(), _buildReviews()],
        ),
      ),
    );
  }

  Widget _buildShopDetails() {
    final shop = _shop!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
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
                            child: const Icon(
                              Icons.store,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                      : Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.store,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
            ),
            const SizedBox(height: 16),

            // Shop Name and Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
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
                Text(
                  '${_calculateAverageRating().toStringAsFixed(1)} (${_ratings.length})',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // About Section
            const Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              shop.description ?? 'No description available',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList() {
    return Card(
      elevation: 2, // Subtle shadow for a modern look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      margin: const EdgeInsets.all(5), // Add margin around the card
      child: Padding(
        padding: const EdgeInsets.all(16), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Manage Services Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Services Offered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _navigateToManageServicesScreen,
                  child: const Text('Manage Services'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Loading Indicator or Services List
            if (_isServicesLoading)
              const Center(child: CircularProgressIndicator())
            else if (_shop!.services.isEmpty)
              const Text(
                'No services added.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              SizedBox(
                height: 230, // Fixed height for the ListView
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _shop!.services.length,
                  itemBuilder: (context, index) {
                    final service = _shop!.services[index];
                    return _buildServiceItem(service);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.3 * 255).toInt()),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the service image or a default image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  service['imageUrl'] != null && service['imageUrl']!.isNotEmpty
                      ? Image.network(
                        service['imageUrl'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
            ),
            const SizedBox(height: 8),
            // Service Name
            Text(
              service['name'] ?? 'Unnamed Service',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Service Description
            Text(
              service['description'] ?? 'No description available',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return Card(
      elevation: 2, // Subtle shadow for a modern look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      margin: const EdgeInsets.all(5), // Add margin around the card
      child: Padding(
        padding: const EdgeInsets.all(16), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    _showAllRatingsPopup(); // Show all ratings in a popup
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Loading Indicator or Reviews List
            if (_isReviewsLoading)
              const Center(child: CircularProgressIndicator())
            else if (_ratings.isEmpty)
              SizedBox(
                width: double.infinity, // Ensure the card takes full width
                child: const Text(
                  'No reviews yet.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true, // Allow the ListView to fit within the card
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling
                itemCount: _ratings.length,
                itemBuilder: (context, index) {
                  final rating = _ratings[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildReview(
                      rating['name'],
                      rating['comment'],
                      rating['rating'],
                      rating['profileImage'],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(
    String name,
    String comment,
    int rating,
    String? profileImage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        width: double.infinity, // Ensure the review card takes full width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1), // Softer shadow
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2), // Shadow position
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12), // Reduced padding for compactness
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align items at the top
            children: [
              // Profile Image (Left Column)
              CircleAvatar(
                radius: 20, // Slightly smaller avatar for better proportion
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child:
                    profileImage == null
                        ? const Icon(Icons.person, size: 20)
                        : null,
              ),
              const SizedBox(width: 12), // Space between image and details
              // Name, Comment, and Rating (Right Column)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600, // Slightly bold
                      ),
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    // Comment
                    Text(
                      comment,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.3, // Compact line height
                      ),
                      maxLines: 2, // Limit comment to 2 lines for compactness
                      overflow:
                          TextOverflow
                              .ellipsis, // Add ellipsis if text overflows
                    ),
                    const SizedBox(height: 6), // Reduced spacing
                    // Rating Stars
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16, // Smaller stars for compactness
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllRatingsPopup() {
    // Sort the ratings by timestamp (latest first)
    final sortedRatings = List<Map<String, dynamic>>.from(_ratings)..sort(
      (a, b) =>
          (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('All Ratings'),
          content: SizedBox(
            width: double.maxFinite, // Ensure the dialog takes full width
            child:
                sortedRatings.isEmpty
                    ? const Text(
                      'No ratings available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedRatings.length,
                      itemBuilder: (context, index) {
                        final rating = sortedRatings[index];
                        return _buildReview(
                          rating['name'],
                          rating['comment'],
                          rating['rating'],
                          rating['profileImage'],
                        );
                      },
                    ),
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

  void _showEditShopPopup() {
    final nameController = TextEditingController(text: _shop?.name);
    final descriptionController = TextEditingController(
      text: _shop?.description,
    );
    String? imageUrl = _shop?.imageUrl; // Initialize with the current image URL

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Shop Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shop Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Shop Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Image Picker
                    InkWell(
                      onTap: () async {
                        final shopProvider = Provider.of<ShopProvider>(
                          context,
                          listen: false,
                        );
                        final pickedImageUrl = await shopProvider.pickImage();

                        if (pickedImageUrl.isNotEmpty) {
                          setState(() {
                            imageUrl = pickedImageUrl; // Update the image URL
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image upload canceled or failed'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            imageUrl != null
                                ? Image.network(imageUrl!, fit: BoxFit.cover)
                                : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_photo_alternate_outlined),
                                      SizedBox(height: 8),
                                      Text('Tap to add an image'),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedData = {
                      'name': nameController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'imageUrl': imageUrl?.trim(),
                    };

                    try {
                      await Provider.of<ShopProvider>(
                        context,
                        listen: false,
                      ).updateShop(_shop!.id, updatedData, null);

                      setState(() {
                        _shop = _shop!.copyWith(
                          name: updatedData['name'],
                          description: updatedData['description'],
                          imageUrl: updatedData['imageUrl'],
                        );
                      });

                      Navigator.pop(context); // Close the dialog

                      // Refresh the shop overview screen
                      await _loadShopData();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Shop details updated!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update shop: $e')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToManageServicesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ManageServicesScreen(
              services: List<Map<String, dynamic>>.from(
                _shop!.services,
              ), // Ensure correct structure
              onSave: (updatedServices) async {
                try {
                  // Update the services in Firestore
                  await Provider.of<ShopProvider>(
                    context,
                    listen: false,
                  ).updateServices(_shop!.id, updatedServices);

                  // Update the local state
                  setState(() {
                    _shop = _shop!.copyWith(services: updatedServices);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Services updated!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update services: $e')),
                  );
                }
              },
            ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
