import 'package:flutter/material.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Service> favoriteServices;

  const FavoritesScreen({
    super.key,
    required this.favoriteServices,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Remove a service from favorites
  void _removeFromFavorites(Service service) {
    setState(() {
      widget.favoriteServices.remove(service); // Remove the service from the list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: widget.favoriteServices.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.favoriteServices.length,
              itemBuilder: (context, index) {
                final service = widget.favoriteServices[index];
                return ServiceCard(
                  service: service,
                  isFavorite: true, // Always true in FavoritesScreen
                  onFavoriteTap: () => _removeFromFavorites(service), // Handle removal
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
    );
  }
}