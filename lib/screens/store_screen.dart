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
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  // List of services in the store
  List<Service> services = [
    Service(
      name: 'Electric Components',
      description: 'All types of electric services',
      category: 'Electrician',
      rating: 4.5,
      image: 'assets/images/electric_components.jpg', // Replace with actual image path
    ),
    Service(
      name: 'Engineering Works',
      description: 'All types of engineering services',
      category: 'Engineering',
      rating: 4.0,
      image: 'assets/images/engineering_services.jpg', // Replace with actual image path
    ),
  ];

  // Toggle favorite status
  void _toggleFavorite(Service service) {
    setState(() {
      if (service.isFavorite) {
        service.isFavorite = false;
      } else {
        service.isFavorite = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.currentUser.isServiceProvider
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCard(
                service: service,
                isFavorite: service.isFavorite,
                onFavoriteTap: () => _toggleFavorite(service),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/service_details',
                    arguments: service,
                  );
                },
              );
            },
          ),
          EditItemButton(onPressed: _editItemDetails),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _showEditServicesPopup,
            child: const Text('Edit Services'),
          ),
        ],
      ),
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