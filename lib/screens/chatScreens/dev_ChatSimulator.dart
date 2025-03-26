import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_2/screens/chatScreens/chatMain.dart';
import '../../models/chatModels/chat_user.dart';

class DevChatSimulator extends StatefulWidget {
  const DevChatSimulator({super.key});

  @override
  _DevChatSimulatorState createState() => _DevChatSimulatorState();
}

class _DevChatSimulatorState extends State<DevChatSimulator> {
  // Hard-coded flag to auto-navigate.
  final bool autoNavigate = false;
  // Two variables storing the IDs.
  final String customerID = "9682ySNqk0txuAGq75JI";
  final String serviceProviderID = "Idgkdk2tkKPEplx46z3h";
  final String chatRoomID = "Njf6u4bzzDIcSLKEtLz7";
  final int initialTabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (autoNavigate) {
      // Schedule the navigation after the first frame to ensure context is available.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // You can choose which user to simulate; here we're using customerID.
        navigateToChatMain(customerID, 0);
      });
    }
  }

  // Function to create a chat room document in Firestore.
  Future<void> createChatRoom() async {
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
            "https://images.unsplash.com/photo-1606577924006-27d39b132ae2?q=80&w=1976&auto=format&fit=crop&ixlib=rb-4.0.3",
        "chatRoomCreatedDate": "2025-03-21T14:56:57+05:30",
        "lastMessageReceivedDate": "2025-03-21T14:56:57+05:30",
      },
    };

    try {
      await FirebaseFirestore.instance.collection("ChatRoom").add(chatRoomData);
      print('Chat room created successfully.');
    } catch (e) {
      print("Error creating chat room: $e");
      throw Exception("Error creating chat room: $e");
    }
  }

  // Navigate to ChatMain, passing only the userID.
  void navigateToChatMain(String userID, int tabIndex) {
    ChatUser chatUser = ChatUser(
      id: userID,
      chatRoomDocRefId: chatRoomID,
      userRole: userID == customerID ? "customer" : "serviceProvider",
      name:
          userID == customerID ? "Isuru Kumarasinghe" : "Negombo Auto Experts",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatMain(chatUser: chatUser, initialTabIndex: tabIndex),
      ),
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
                  navigateToChatMain(customerID, 0);
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
                  navigateToChatMain(serviceProviderID, 1);
                },
                child: const Text('Service Provider'),
              ),
            ),
          ],
        ),
      ),
      // Uncomment the following if you want a button to create a chat room.
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(16.0),
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
      //           ScaffoldMessenger.of(context).showSnackBar(
      //             SnackBar(content: Text('Error: $e')),
      //           );
      //         }
      //       },
      //       child: const Text('Create a Chat Room'),
      //     ),
      //   ),
      // ),
    );
  }
}
