import 'package:flutter/material.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';
import '../models/category.dart';

class HomeScreen extends StatefulWidget {
  // Callback to toggle favorite status
  final Function(Service) onToggleFavorite;

  const HomeScreen({
    super.key,
    required this.onToggleFavorite,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Dummy services data
  final List<Service> _allServices = [
    Service(
      name: 'Tronic LK',
      description:
          'Offers high-quality electronic components and tools, including Arduinos, Raspberry Pis, and 3D printers.',
      category: 'Electronics',
      rating: 4.4,
      image: 'assets/images/service_provider.jpg', // Replace with actual image path
    ),
    Service(
      name: 'Slim Co Eng.',
      description: 'All kinds of engineering works',
      category: 'Repairs',
      rating: 4.3,
      image: null, // No image for this service
    ),
    Service(
      name: 'Next Service',
      description: 'Service description',
      category: 'Maintenance',
      rating: 2.3,
      image: null, // No image for this service
    ),
  ];

  // Track the currently selected category
  String? _selectedCategory;

  // Track the search query
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtered services based on the selected category and search query
  List<Service> get _filteredServices {
    List<Service> filtered = _allServices;

    // Filter by category (if selected)
    if (_selectedCategory != null) {
      filtered = filtered.where((service) => service.category == _selectedCategory).toList();
    }

    // Filter by search query (case-insensitive)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((service) => service.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _selectedCategory = null; // Reset the selected category
      _searchQuery = ''; // Clear the search query
      _searchController.clear(); // Clear the search bar text
    });
  }

  // Navigate to service details screen
  void _onServiceCardTap(BuildContext context, Service service) {
    Navigator.pushNamed(
      context,
      '/service_details',
      arguments: service, // Pass the entire service object
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello User!'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Add logic for notifications if needed.
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Add logic for menu if needed.
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Search by service name',
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query; // Update the search query
                  });
                },
              ),
              const SizedBox(height: 20),

              // Categories Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal Categories List
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category.title; // Update the selected category
                          });
                        },
                        child: CategoryItem(category: category), // Use the updated CategoryItem
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Display the selected category or search query (if any)
              if (_selectedCategory != null || _searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_selectedCategory != null)
                        Text(
                          'Showing services for: $_selectedCategory',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      if (_searchQuery.isNotEmpty)
                        Text(
                          'Search results for: "$_searchQuery"',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text(
                          'Clear Filters',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),

              // List of Service Cards
              Column(
                children: _filteredServices.map((service) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: ServiceCard(
                      service: service,
                      isFavorite: service.isFavorite,
                      onFavoriteTap: () {
                        widget.onToggleFavorite(service); // Toggle favorite status
                      },
                      onTap: () => _onServiceCardTap(context, service),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy categories data
final List<Category> _categories = [
  Category(title: 'Landscaping', image: 'assets/images/landscaping.png'),
  Category(title: 'Outdoor', image: 'assets/images/wells.png'),
  Category(title: 'Repairs', image: 'assets/images/others.png'),
  Category(title: 'Maintenance', image: 'assets/images/repair.png'),
];

// CategoryItem Widget
class CategoryItem extends StatelessWidget {
  final Category category;

  const CategoryItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the category image
        CircleAvatar(
          radius: 35, // Adjust the size of the image
          backgroundImage: AssetImage(category.image), // Load the image from assets
          backgroundColor: Colors.grey[200], // Fallback background color
        ),
        const SizedBox(height: 8), // Add spacing between the image and title
        // Display the category title
        Text(
          category.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}