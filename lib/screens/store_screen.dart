import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';
import '../widgets/edit_item_button.dart';
import 'add_store_popup.dart';
import 'edit_service_popup.dart';

class StoreScreen extends StatefulWidget {
  final User currentUser; // Pass the current user
  const StoreScreen({super.key, required this.currentUser});

  @override
  StoreScreenState createState() => StoreScreenState();
}

class StoreScreenState extends State<StoreScreen> {
  // List of services in the store
  List<Service> services = [
    Service(
      name: 'Electric Components',
      description: 'All types of electric services',
      category: 'Electrician',
      rating: 4.5,
      image: 'assets/images/electrician.jpg', // Replace with actual image path
    ),
    Service(
      name: 'Engineering Works',
      description: 'All types of engineering services',
      category: 'Engineering',
      rating: 4.0,
      image: 'assets/images/sec1.jpg', // Replace with actual image path
    ),
    Service(
      name: 'work 3',
      description: 'description for work 3',// now this is not showing in ui so if we dont need it we can remove description
      category: 'Engineering',
      rating: 4.0,
      image: 'assets/images/sec2.jpg', // Replace with actual image path
    ),
    Service(
      name: 'work 4',
      description: 'description for work 4',
      category: 'Engineering',
      rating: 4.0,
      image: 'assets/images/sec3.jpg', // Replace with actual image path
    ),
  ];

  // Toggle favorite status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            widget.currentUser.isServiceProvider
                ? _buildServiceProviderUI()
                : _buildUserUI(),
      ),
    );
  }

  // UI for users who don't have a store yet
  Widget _buildUserUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('You don’t have a store yet.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showAddStorePopup,
            child: const Text('Add Store Page'),
          ),
        ],
      ),
    );
  }

  // UI for service providers
  Widget _buildServiceProviderUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStoreHeader(), // Shop page header with rating and description
          _buildShopOverview(), // Shop overview section
          _buildEditButtons(), // Edit Page and Edit Services buttons
          _buildServiceList(), // List of services offered
          _buildReviews(), // Review section
        ],
      ),
    );
  }

  // Build the header with shop name, rating, and description
  Widget _buildStoreHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/service_provider.jpg', // Placeholder for shop image
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 10),
        Text(
          'Tronic Lk', // Example store name
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.yellow),
            const SizedBox(width: 4),
            const Text(
              '5.0 (54)',
              style: TextStyle(fontSize: 16),
            ), // Example rating
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Add the description of the shop here.', // Example description
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildShopOverview() {
    // List of overview items
    final List<Map<String, String>> overviewItems = [
      {'label': 'Waiting', 'count': '95'},
      {'label': 'Completed', 'count': '95'},
      {'label': 'Items', 'count': '95'},
      {'label': 'Agreements', 'count': '95'},
      {'label': 'Avg Ratings', 'count': '95'},
      {'label': 'Messages', 'count': '95'},
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.blue[50],
      child: GridView.builder(
        shrinkWrap: true, // Ensures the GridView fits within its parent
        physics:
            const NeverScrollableScrollPhysics(), // Disable scrolling for the GridView
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns
          mainAxisSpacing: 8.0, // Spacing between rows
          crossAxisSpacing: 8.0, // Spacing between columns
          childAspectRatio: 1.5, // Aspect ratio of each item (width / height)
        ),
        itemCount: overviewItems.length,
        itemBuilder: (context, index) {
          final item = overviewItems[index];
          return _buildOverviewItem(item['label']!, item['count']!);
        },
      ),
    );
  }

  // Shop overview items (e.g., Waiting, Completed)
  Widget _buildOverviewItem(String label, String count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // Shadow position
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Edit buttons section
  Widget _buildEditButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _editItemDetails,
            child: const Text('Edit Page'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _showEditServicesPopup,
            child: const Text('Edit Services'),
          ),
        ],
      ),
    );
  }

  // List of services offered
  Widget _buildServiceList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Services Offered',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: 120, // Fixed height for the horizontal scroll view
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Horizontal scrolling
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceItem(service);
          },
        ),
      ),
    ],
  );
}

Widget _buildServiceItem(Service service) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: GestureDetector(
      onTap: () {
        //nothing to push
      },
      child: Container(
        width: 150, // Fixed width for each service item  
        margin: const EdgeInsets.symmetric(vertical: 2.0),      
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.3 * 255).toInt()),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2), // Shadow position
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (service.image != null)
              Image.asset(
                service.image!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              )
            else
              const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              service.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Reviews section
  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            'Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3, // Example number of reviews
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Nethmina Wickramasinghe'), // Example name
              subtitle: const Text(
                'Great service and reasonable prices! Highly recommend.',
              ), // Example review text
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Colors.yellow),
                  SizedBox(width: 4),
                  Text('4'), // Example rating
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Show popup to add a store
  void _showAddStorePopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddStorePopup(
          onSubmit: (storeDetails) {
            setState(() {
              widget.currentUser.isServiceProvider = true;
            });
          },
        );
      },
    );
  }

  // Show popup to edit services
  void _showEditServicesPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditServicePopup(
          services: services,
          onUpdate: (updatedServices) {
            setState(() {
              services = updatedServices;
            });
          },
        );
      },
    );
  }

  // Logic to edit store details (title, description, etc.)
  void _editItemDetails() {
    // Implement logic to edit store details here
  }
}
