import 'package:flutter/material.dart';
import '../../models/chatModels/chatUser.dart';

class TextChatArea extends StatelessWidget {
  final ChatUser chatUser;

  const TextChatArea({Key? key, required this.chatUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Chat Area')),
      body: Center(
        child: Text(
          'UserID: ${chatUser.userID}\n'
          'Role: ${chatUser.userRole}\n'
          'ChatRoom: ${chatUser.chatRoomID}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
