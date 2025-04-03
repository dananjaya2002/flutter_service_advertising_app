import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'auth/login_screen.dart';
import 'main/main_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize user data and listen to auth changes
    Future.delayed(Duration.zero, () {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.initialize();
      userProvider.listenToAuthChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoading = userProvider.isLoading;

    // Show a loading indicator while checking auth state
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Return either the Login screen or Main screen based on auth state
    if (userProvider.isAuthenticated) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
