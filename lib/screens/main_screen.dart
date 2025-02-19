import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen
import 'chat_list_screen.dart'; // Import ChatListScreen
import 'store_screen.dart'; // Import StoreScreen
import 'favorites_screen.dart'; // Import FavoritesScreen
import '../models/user.dart'; // Import User model

class MainScreen extends StatefulWidget {
  final User currentUser; // Pass the current user to the MainScreen
  const MainScreen({super.key, required this.currentUser});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Tracks the currently selected tab

  // List of screens corresponding to each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens with the currentUser passed to StoreScreen
    _screens = [
      HomeScreen(), // Index 0: Home
      const ChatListScreen(), // Index 1: Chat
      StoreScreen(currentUser: widget.currentUser), // Index 2: Store
      const FavoritesScreen(), // Index 3: Favorites
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Display the current screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex, // Current selected index
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
        ],
      ),
    );
  }
}