import 'package:flutter/material.dart';

// Define a data model for the favorite items
class FavoriteItem {
  final IconData icon;
  final String title;
  final String subtitle;

  FavoriteItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

// Custom ListTile widget for displaying favorite items
class FavoriteItemTile extends StatelessWidget {
  final FavoriteItem item;

  const FavoriteItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          item.icon,
          size: 50,
        ),
        title: Text(item.title),
        subtitle: Text(item.subtitle),
        onTap: () {
          // Navigate to Service Details Screen with data
          Navigator.pushNamed(
            context,
            '/service-details',
            arguments: item,
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy favorites data (replace with your real data model)
    final List<FavoriteItem> favorites = [
      FavoriteItem(
        icon: Icons.favorite,
        title: 'Favorite Service 1',
        subtitle: 'High quality service for your needs',
      ),
      FavoriteItem(
        icon: Icons.star,
        title: 'Favorite Service 2',
        subtitle: 'Reliable and trusted',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final fav = favorites[index];
          return FavoriteItemTile(item: fav);
        },
      ),
    );
  }
}