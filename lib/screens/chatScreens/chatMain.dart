import 'package:flutter/material.dart';
import 'privateChatScreen.dart';
import 'serviceChatScreen.dart';
import '../../models/chatModels/chatUser.dart';

class ChatMain extends StatelessWidget {
  final ChatUser chatUser;

  const ChatMain({Key? key, required this.chatUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Private and Service
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat Main'),
          bottom: TabBar(
            tabs: [Tab(text: 'Personal Chat'), Tab(text: 'Shop Chat')],
          ),
        ),
        body: TabBarView(
          children: [
            // Passing userID to the Personal chat tab.
            PrivateChatScreen(chatUser: chatUser),
            // For now, ServiceChatScreen can be a placeholder.
            ServiceChatScreen(chatUser: chatUser),
          ],
        ),
      ),
    );
  }
}
