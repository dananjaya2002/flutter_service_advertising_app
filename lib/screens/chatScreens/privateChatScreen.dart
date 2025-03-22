import 'package:flutter/material.dart';
import 'package:test_2/screens/chatScreens/textChatArea.dart';
import '../../models/chatModels/chatUser.dart';

class PrivateChatScreen extends StatelessWidget {
  final ChatUser chatUser;

  const PrivateChatScreen({Key? key, required this.chatUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simulated list of chat rooms or messages.
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Chat Room ${index + 1}'),
                onTap: () {
                  // Optionally, you could navigate to TextChatArea here as well.
                },
              );
            },
          ),
        ),
        // Button to navigate to the TextChatArea (chat interface).
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // Create a new ChatUser with an updated userRole value.
                ChatUser updatedChatUser = ChatUser(
                  userID: chatUser.userID,
                  userRole: "personal", // Set the desired role here.
                  chatRoomID: chatUser.chatRoomID,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TextChatArea(chatUser: updatedChatUser),
                  ),
                );
              },
              child: const Text("Go to Chat Area"),
            ),
          ),
        ),
      ],
    );
  }
}
