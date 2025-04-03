import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/user_provider.dart'; // Ensure this is the correct path to UserProvider
import '../shop/shop_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid;

    if (userId == null || userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: const Center(child: Text('Please log in to view favorites')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: StreamBuilder<List<ShopModel>>(
        stream: favoriteProvider.getFavoriteShops(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite shops found'));
          } else {
            final shops = snapshot.data ?? [];
            return ListView.builder(
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return ListTile(
                  leading:
                      shop.imageUrl != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(shop.imageUrl!),
                          )
                          : const CircleAvatar(child: Icon(Icons.store)),
                  title: Text(shop.name),
                  subtitle: Text(
                    shop.description ?? 'No description available',
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShopDetailsScreen(shop: shop),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () async {
                      await favoriteProvider.removeFromFavorites(
                        userId,
                        shop.id,
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
