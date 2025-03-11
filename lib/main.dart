import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import LoginScreen
import 'screens/signup_screen.dart'; // Import SignupScreen
import 'screens/service_details_screen.dart'; // Import ServiceDetailsScreen
import 'screens/main_screen.dart'; // Import MainScreen
import 'models/user.dart'; // Import User model

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Default route (SplashScreen or AuthFlow)
      routes: {
        '/': (context) => const SplashScreen(), // Splash screen or auth flow
        '/login': (context) => const LoginScreen(), // LoginScreen
        '/signup': (context) => const SignupScreen(), // SignupScreen
        '/service_details': (context) => const ServiceDetailsScreen(), // ServiceDetailsScreen
      },
    );
  }
}

// Splash Screen or Authentication Flow
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate fetching the current user (e.g., from shared preferences or an API)
    final User currentUser = _fetchCurrentUser();

    // Navigate to the appropriate screen based on the user's authentication status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentUser.isServiceProvider || currentUser.name.isNotEmpty) {
        // If the user is authenticated, navigate to MainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(currentUser: currentUser),
          ),
        );
      } else {
        // If the user is not authenticated, navigate to LoginScreen
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  // Simulate fetching the current user (replace with actual logic)
  User _fetchCurrentUser() {
    // Replace this with actual logic to fetch the user (e.g., from shared preferences or an API)
    return User(
      name: 'John Doe', // Replace with actual user data
      isServiceProvider: true,
    );
  }
}