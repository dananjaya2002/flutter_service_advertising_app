// import 'dart:developer';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import '/screens/chatScreens/chatMain.dart';
// import 'screens/login_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'screens/signup_screen.dart';
// import 'screens/service_details_screen.dart';
// import 'screens/main_screen.dart';
// import 'models/user.dart' as app_model; // Custom User model
// import 'services/auth_service.dart'; // Import AuthService

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   log("This is a log message");
//   try {
//     await Firebase.initializeApp();
//     log("Firebase initialized successfully"); // Replaces print
//   } catch (e) {
//     log("Error initializing Firebase: $e"); // Replaces print
//   }
//   // For testing, launch directly into the chat feature.
//   runApp(const MyApp(initialRoute: '/chat'));
//   // When done testing, revert back to: runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   final String initialRoute;
//   const MyApp({super.key, this.initialRoute = '/'});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       // Use the passed initialRoute parameter here instead of hardcoding '/'
//       initialRoute: initialRoute,
//       routes: {
//         '/': (context) => const SplashScreen(),
//         '/login': (context) => const LoginScreen(),
//         '/signup': (context) => const SignupScreen(),
//         '/service_details': (context) => const ServiceDetailsScreen(),
//         '/main':
//             (context) => MainScreen(
//               currentUser:
//                   ModalRoute.of(context)!.settings.arguments
//                       as app_model.AppUser,
//             ),
//         '/chat': (context) => ChatMain(), // Temporary chat route
//       },
//     );
//   }
// }

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final AuthService authService = AuthService();

//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (snapshot.hasData) {
//           // User is authenticated, convert Firebase User to AppUser
//           final firebaseUser = snapshot.data!;
//           final appUser = authService.firebaseUserToAppUser(firebaseUser);

//           if (appUser != null) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Navigator.pushReplacementNamed(
//                 context,
//                 '/main',
//                 arguments: appUser,
//               );
//             });
//           } else {
//             // Handle the case where appUser is null
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Navigator.pushReplacementNamed(context, '/login');
//             });
//           }
//         } else {
//           // User is not authenticated, navigate to LoginScreen
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             Navigator.pushReplacementNamed(context, '/login');
//           });
//         }
//         return Container(); // Empty container while waiting for navigation
//       },
//     );
//   }
// }

import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/chatScreens/textChatArea.dart';
import 'models/chatModels/chat_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chatScreens/dev_ChatSimulator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  log("This is a log message");
  try {
    await Firebase.initializeApp();
    log("Firebase initialized successfully");
  } catch (e) {
    log("Error initializing Firebase: $e");
  }
  // Directly run the ChatMain screen, bypassing the existing routing logic.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App - Chat Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Directly set home to ChatMain. This bypasses all your other routes.
      home: DevChatSimulator(),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     title: 'My App - Chat Test',
  //     theme: ThemeData(primarySwatch: Colors.blue),
  //     // Directly set home to ChatMain. This bypasses all your other routes.
  //     home: TextChatArea(
  //       chatUser: ChatUser(
  //         id: '9682ySNqk0txuAGq75JI',
  //         chatRoomDocRefId: 'Njf6u4bzzDIcSLKEtLz7',
  //         userRole: 'customer',
  //         name: 'Isuru Kumarasinghe',
  //       ),
  //     ),
  //   );
  // }
}
