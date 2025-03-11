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
  List<Service> services = [
    Service(name: 'Electric Components', description: 'All types of electric services', rating: 4.5),
    Service(name: 'Engineering Works', description: 'All types of engineering services', rating: 4.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.currentUser.isServiceProvider ? _buildServiceProviderUI() : _buildUserUI(),
      ),
    );
  }

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
              return ServiceCard(service: services[index]);
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

  void _editItemDetails() {
    // Logic to edit store details (title, description, etc.)
  }
}