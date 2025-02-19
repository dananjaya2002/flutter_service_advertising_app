import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/service.dart';
import '../widgets/category_item.dart';
import '../widgets/service_card.dart';

class HomeScreen extends StatelessWidget {
  // Dummy categories data
  final List<Category> _categories = [
    Category(title: 'Landscaping', imageUrl: ''),
    Category(title: 'Outdoor', imageUrl: ''),
    Category(title: 'Repairs', imageUrl: ''),
    Category(title: 'Maintenance', imageUrl: ''),
  ];

  // Dummy services data
  final List<Service> _services = [
    Service(
      name: 'Tronic LK',
      description:
          'Offers high-quality electronic components and tools, including Arduinos, Raspberry Pis, and 3D printers.',
      rating: 4.4,
      image:
          'assets/images/service_provider.jpg', // Replace with actual image path
    ),
    Service(
      name: 'Slim Co Eng.',
      description: 'All kinds of engineering works',
      rating: 4.3,

      // without an image
    ),
  ];

  HomeScreen({super.key});

  // Show all categories in a popup dialog
  void _showAllCategoriesPopup(BuildContext context) {
    // List of categories to display in the popup
    final List<String> categories = [
      'Landscaping',
      'Outdoor',
      'Repairs',
      'Maintenance',
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('All Categories'),
            content: SizedBox(
              width:
                  double.maxFinite, // Allow the content to take up full width
              child: ListView.builder(
                shrinkWrap: true, // Ensure the ListView fits within the dialog
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category),
                    onTap: () {
                      // Handle category tap (e.g., navigate to a specific category screen)
                      Navigator.pop(context); // Close the dialog
                      // You can add navigation logic here if needed
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: const Text('Close'),
              ),
            ],
          ),
    );
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
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Search',
                ),
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
                    onPressed: () => _showAllCategoriesPopup(context),
                    child: const Text('See All'),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CategoryItem(category: _categories[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // List of Service Cards
              Column(
                children:
                    _services.map((service) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () => _onServiceCardTap(context, service),
                          child: ServiceCard(service: service),
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
