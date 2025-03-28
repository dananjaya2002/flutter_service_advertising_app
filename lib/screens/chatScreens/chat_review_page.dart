import 'package:flutter/material.dart';
import '../../models/chatModels/chat_user.dart';

class ChatReviewPage extends StatelessWidget {
  final ChatUser chatUser;

  const ChatReviewPage({Key? key, required this.chatUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace with your actual chat review UI.
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Review')),
      body: Center(child: Text('Review for ${chatUser.id}')),
    );
  }
}
