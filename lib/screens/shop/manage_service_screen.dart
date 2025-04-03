import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';

const String defaultImageAsset =
    'assets/icons/others.png'; // Default placeholder image

class ManageServicesScreen extends StatefulWidget {
  final List<Map<String, dynamic>>
  services; // List of services with name, description, and image
  final Function(List<Map<String, dynamic>>) onSave;

  const ManageServicesScreen({
    super.key,
    required this.services,
    required this.onSave,
  });

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  late List<Map<String, dynamic>> _services;
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescriptionController =
      TextEditingController();
  String?
  _selectedImageUrl; // Temporary variable to store the selected image URL

  @override
  void initState() {
    super.initState();
    _services = List.from(widget.services); // Copy the services list
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    super.dispose();
  }

  void _addService() {
    if (_serviceNameController.text.trim().isNotEmpty) {
      setState(() {
        _services.add({
          'name': _serviceNameController.text.trim(),
          'description': _serviceDescriptionController.text.trim(),
          'imageUrl': _selectedImageUrl, // Keep null if no image is selected
        });
        _selectedImageUrl =
            null; // Reset the image URL after adding the service
      });
      _serviceNameController.clear();
      _serviceDescriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service name cannot be empty')),
      );
    }
  }

  void _editService(int index) {
    _serviceNameController.text = _services[index]['name'];
    _serviceDescriptionController.text = _services[index]['description'];
    setState(() {
      _selectedImageUrl = _services[index]['imageUrl'];
      _services.removeAt(index); // Temporarily remove the service
    });
  }

  void _deleteService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  Future<void> _pickServiceImage() async {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final imageUrl = await shopProvider.pickImage();

    setState(() {
      _selectedImageUrl =
          imageUrl.isNotEmpty
              ? imageUrl
              : null; // Keep null if no image is selected
    });

    if (imageUrl.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No image selected.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await _showUnsavedChangesDialog();
        return shouldLeave ?? false; // Prevent navigation if the user cancels
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Services'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                widget.onSave(_services); // Pass the updated services back
                Navigator.pop(context); // Go back to the previous screen
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Service Name Input
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name (up to 25 characters)',
                  border: OutlineInputBorder(),
                  counterText: '', // Hide the default character counter
                ),
                maxLength: 25, // Limit to 25 characters
              ),
              const SizedBox(height: 16),

              // Service Description Input
              TextFormField(
                controller: _serviceDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Service Description (up to 80 characters)',
                  border: OutlineInputBorder(),
                  counterText: '', // Hide the default character counter
                ),
                maxLength: 80, // Limit to 80 characters
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Image Picker
              InkWell(
                onTap: _pickServiceImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      _selectedImageUrl != null
                          ? Image.network(_selectedImageUrl!, fit: BoxFit.cover)
                          : const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ), // Show an icon instead of the default asset image
                ),
              ),
              const SizedBox(height: 16),

              // Add Service Button
              ElevatedButton(
                onPressed: _addService,
                child: const Text('Add Service'),
              ),
              const SizedBox(height: 16),

              // List of Services
              Expanded(
                child: ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading:
                            _services[index]['imageUrl'] != null &&
                                    _services[index]['imageUrl']!.isNotEmpty
                                ? Image.network(
                                  _services[index]['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Use default image if the network image fails to load
                                    return Image.asset(
                                      defaultImageAsset,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                                : Image.asset(
                                  defaultImageAsset, // Use local placeholder image if no image URL
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                        title: Text(_services[index]['name']),
                        subtitle: Text(_services[index]['description']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editService(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteService(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. Do you want to leave without saving?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Stay on the screen
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Allow navigation
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }
}
