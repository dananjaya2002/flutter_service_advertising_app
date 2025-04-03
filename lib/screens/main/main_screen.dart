import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/shop_provider.dart';
import '../home/home_screen.dart';
import '../chat/chat_list_screen.dart';

import '../favorites/favorites_screen.dart';
import '../shop/shop_overview_screen.dart';
import '../shop/add_shop_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatListScreen(),
    const SizedBox(), // Placeholder for store tab
    const FavoritesScreen(),
  ];

  void _handleStoreTap(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    // Check if user already has a shop
    final existingShop = await shopProvider.getShopByOwnerId(user.uid);

    if (existingShop != null || user.role == 'service_provider') {
      // User has a shop, show shop overview
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ShopOverviewScreen()),
      );
    } else {
      // User doesn't have a shop, show add shop dialog
      await showDialog(
        context: context,
        builder: (context) => const AddShopScreen(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            // Store tab
            _handleStoreTap(context);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
