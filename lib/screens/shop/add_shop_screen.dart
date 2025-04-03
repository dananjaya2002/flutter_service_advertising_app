import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';
import '../../models/category_model.dart';

class AddShopScreen extends StatelessWidget {
  const AddShopScreen({super.key});

  Future<void> _showNotServiceProviderDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Become a Service Provider'),
          content: const Text(
            'You are not currently a service provider. Add your shop to become one.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to the previous screen
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert dialog
                _showAddShopPopup(context); // Show the Add Shop popup
              },
              child: const Text('Add Shop'),
            ),
          ],
        );
      },
    );
  }

  void _showAddShopPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddShopFormDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Automatically show the dialog when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNotServiceProviderDialog(context);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Add Shop')),
      body: const Center(
        child: Text(
          'Go Back to the previous screen',
        ), // Placeholder text while the dialog is shown
      ),
    );
  }
}

class _AddShopFormDialog extends StatefulWidget {
  @override
  State<_AddShopFormDialog> createState() => _AddShopFormDialogState();
}

class _AddShopFormDialogState extends State<_AddShopFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory;
  String? _imageUrl;
  bool _isLoading = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveShop(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final userId = userProvider.user!.uid;

      // Create a GeoPoint from the location string (you might want to use a proper location picker)
      final locationParts = _locationController.text.split(',');
      final location =
          locationParts.length == 2
              ? GeoPoint(
                double.parse(locationParts[0].trim()),
                double.parse(locationParts[1].trim()),
              )
              : null;

      final newShop = ShopModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: userId,
        name: _shopNameController.text,
        description: _descriptionController.text,
        phoneNumber: _phoneController.text,
        location: location,
        imageUrl: _imageUrl,
        categories: [_selectedCategory!],
        rating: 0,
        reviewCount: 0,
        createdAt: Timestamp.now(),
      );

      await shopProvider.addShop(newShop);
      await userProvider.updateUserRole(userId, 'service_provider');

      if (mounted) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shop added successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding shop: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit Shop Page',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter shop name'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter description'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter phone number'
                              : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      CategoryModel.defaultCategories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => _selectedCategory = value),
                  validator:
                      (value) =>
                          value == null ? 'Please select a category' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value?.isEmpty ?? true
                              ? 'Please enter location'
                              : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final shopProvider = Provider.of<ShopProvider>(
                      context,
                      listen: false,
                    );
                    final imageUrl =
                        await shopProvider
                            .pickImage(); // Call pickImage from ShopProvider
                    if (imageUrl.isNotEmpty) {
                      setState(() {
                        _imageUrl =
                            imageUrl; // Update the _imageUrl with the returned URL
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image upload ing'),
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child:
                          _imageUrl != null
                              ? Image.network(
                                _imageUrl!,
                              ) // Display the uploaded image
                              : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined),
                                  Text('Add an image'),
                                ],
                              ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _saveShop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
