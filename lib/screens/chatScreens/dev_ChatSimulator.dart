import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_2/screens/chatScreens/chatMain.dart';
import '../../models/chatModels/chatUser.dart';

class DevChatSimulator extends StatelessWidget {
  const DevChatSimulator({super.key});

  // Two variables storing the IDs.
  final String customerID = "9682ySNqk0txuAGq75JI";
  final String serviceProviderID = "Idgkdk2tkKPEplx46z3h";
  final String chatRoomID = "Njf6u4bzzDIcSLKEtLz7";

  // Function to create a chat room document in Firestore.
  Future<void> createChatRoom() async {
    // Prepare the document data.
    Map<String, dynamic> chatRoomData = {
      "customer": {
        "docRef": customerID,
        "name": "Isuru Kumarasinghe",
        "profileImageUrl":
            "https://cdn.pixabay.com/photo/2018/04/04/23/21/glass-3291449_1280.jpg",
        "lastMessage":
            "https://res.cloudinary.com/dpjdmbozt/image/upload/v1742549217/ia5fjlppoblcxzo6leba.jpg",
        "lastUpdatedTime": "2025-03-12T12:45:53+05:30",
        "sendedTime": "2025-03-21T12:28:05+05:30",
      },
      "serviceProvider": {
        "docRef": serviceProviderID,
        "name": "Negombo Auto Experts",
        "profileImageUrl":
            "https://images.unsplash.com/photo-1606577924006-27d39b132ae2?q=80&w=1976&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        "timestamp": "2025-03-21T14:56:57+05:30",
      },
    };

    // Create the document in Firestore.
    try {
      await FirebaseFirestore.instance.collection("ChatRoom").add(chatRoomData);
    } catch (e) {
      print("Error creating chat room: $e");
      throw Exception("Error creating chat room: $e");
    }
  }

  // Navigate to ChatMain, passing only the userID.
  void navigateToChatMain(BuildContext context, String userID) {
    // For demonstration, we assign a placeholder chatRoomID.
    ChatUser chatUser = ChatUser(
      userID: userID,
      userRole: "",
      chatRoomID: chatRoomID,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatMain(chatUser: chatUser)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Simulator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Adds margins around the buttons.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Customer button: full width, extra height.
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  navigateToChatMain(context, customerID);
                },
                child: const Text('Customer'),
              ),
            ),
            const SizedBox(height: 20),
            // Service Provider button: full width, extra height.
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  navigateToChatMain(context, serviceProviderID);
                },
                child: const Text('Service Provider'),
              ),
            ),
          ],
        ),
      ),
      // // Bottom button: Anchored at the bottom center.
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(16.0), // Margin for the bottom button.
      //   child: SizedBox(
      //     width: double.infinity,
      //     height: 60,
      //     child: ElevatedButton(
      //       onPressed: () async {
      //         try {
      //           await createChatRoom();
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             const SnackBar(
      //               content: Text('Chat Room created successfully'),
      //             ),
      //           );
      //         } catch (e) {
      //           ScaffoldMessenger.of(
      //             context,
      //           ).showSnackBar(SnackBar(content: Text('Error: $e')));
      //         }
      //       },
      //       child: const Text('Create a Chat Room'),
      //     ),
      //   ),
      // ),
    );
  }
}
