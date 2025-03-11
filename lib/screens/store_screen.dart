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
        child: widget.currentUser.isServiceProvider ? _buildUserUI() :_buildServiceProviderUI() ,
      ),
    );
  }

  Widget _buildUserUI() {
    return Container(
      width: 450,
      height: 150,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 166, 213, 233),
        borderRadius: BorderRadius.circular(8),
       
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),

       child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Become a Seller",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

         const SizedBox(height: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, size: 24),
              onPressed: () {
                //when click open bottom sheet
                _displayBottomSheet(context);
              },
            ),
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

  Future _displayBottomSheet(BuildContext context){
    return showModalBottomSheet(
      context: context,
       backgroundColor: Colors.white,
       barrierColor: Colors.black87.withOpacity(0.5),
       isDismissible: true,
       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top:Radius.circular(30))),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(22.0),
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Add Store',
            style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 25,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
          labelText: 'Store Name',
          border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
          labelText: 'Address',
          border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
          labelText: 'Location',
          border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
            ElevatedButton(
            onPressed: () {
              // Handle form submission
            },
            style: ElevatedButton.styleFrom(
            
            backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Text('Add Store'),
            ),
          ],
          ),
        ),
      ),
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