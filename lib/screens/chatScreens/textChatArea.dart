// lib/ui/screens/text_chat_area.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_2/models/chatModels/chat_message.dart';
import 'package:test_2/screens/chatScreens/chat_agreement_screen.dart';
import 'package:test_2/screens/chatScreens/chat_widgets/agreement_banner.dart';
import '../../models/chatModels/chat_user.dart';
import '../../controllers/chat_controller.dart';

import 'package:intl/intl.dart';

class TextChatArea extends ConsumerStatefulWidget {
  final ChatUser chatUser;
  final String otherUserName;

  const TextChatArea({
    Key? key,
    required this.chatUser,
    required this.otherUserName,
  }) : super(key: key);

  @override
  _TextChatAreaState createState() => _TextChatAreaState();
}

class _TextChatAreaState extends ConsumerState<TextChatArea> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start listening to messages.
    ref
        .read(chatControllerProvider.notifier)
        .subscribeToMessages(widget.chatUser.chatRoomDocRefId);

    // Add listener for pagination.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref
            .read(chatControllerProvider.notifier)
            .loadMoreMessages(widget.chatUser.chatRoomDocRefId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.otherUserName),
        backgroundColor: const Color.fromARGB(255, 190, 200, 255),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            // Main UI content
            Column(
              children: [
                // Chat messages list.
                Expanded(
                  child:
                      chatState.messages.isEmpty
                          ? Center(
                            child: Text(
                              "No messages yet",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                          : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatState.messages[index];
                              return _ChatMessageItem(
                                message: message,
                                chatUser: widget.chatUser,
                              );
                            },
                          ),
                ),
                // Input area.
                _ChatInputSection(
                  controller: _controller,
                  onSend: () async {
                    if (_controller.text.trim().isEmpty) return;
                    await ref
                        .read(chatControllerProvider.notifier)
                        .sendMessage(
                          chatRoomDocRefId: widget.chatUser.chatRoomDocRefId,
                          userID: widget.chatUser.id,
                          message: _controller.text.trim(),
                          messageType: "textMessage",
                        );
                    _controller.clear();
                  },
                  onImagePressed: () {
                    ref
                        .read(chatControllerProvider.notifier)
                        .uploadImagePlaceholder();
                  },
                ),
              ],
            ),
            widget.chatUser.userRole == 'serviceProvider'
                ? // AgreementBanner component overlay
                AgreementBanner(chatUser: widget.chatUser)
                : Container(),
          ],
        ),
      ),
    );
  }
}

/// Input section widget.
class _ChatInputSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onImagePressed;

  const _ChatInputSection({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.onImagePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, bottomInset),
      child: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.image), onPressed: onImagePressed),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) onSend();
                },
              ),
            ),
            IconButton(icon: Icon(Icons.send), onPressed: onSend),
          ],
        ),
      ),
    );
  }
}

// class AgreementBanner extends StatelessWidget {
//   final bool agreementSent;
//   final String message;
//   final VoidCallback onPressed;
//   final Color backgroundColor;

//   const AgreementBanner({
//     Key? key,
//     required this.agreementSent,
//     required this.message,
//     required this.onPressed,
//     this.backgroundColor = const Color(0xFF333333), // default background color
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // This widget assumes it will be placed in a Stack for absolute positioning.
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         color: backgroundColor,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // First row: Button with dynamic text and color.
//             ElevatedButton(
//               onPressed: onPressed,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: agreementSent ? Colors.green : Colors.blue,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 12.0,
//                   horizontal: 24.0,
//                 ),
//               ),
//               child: Text(
//                 agreementSent ? "Agreement Sended" : "Send an Agreement",
//                 style: const TextStyle(fontSize: 16.0),
//               ),
//             ),
//             const SizedBox(height: 8.0),
//             // Second row: Display text from parent.
//             Text(
//               message,
//               style: const TextStyle(fontSize: 16.0, color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// Simple widget to display a chat message.
class _ChatMessageItem extends StatelessWidget {
  final ChatMessage message;
  final ChatUser chatUser;

  const _ChatMessageItem({
    Key? key,
    required this.message,
    required this.chatUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = message.senderId == chatUser.id;
    return Container(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: isOwnMessage ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Conditional rendering based on message type
            message.messageType == 'AgreementRequest'
                ? ChatAgreementScreen(
                  chatRoomDocRefId: chatUser.chatRoomDocRefId,
                  userRole: chatUser.userRole,
                  onAccept: () {
                    // Additional post-accept logic
                  },
                )
                : Text(message.value),

            if (message.status == 'pending')
              Text(
                "Sending...",
                style: TextStyle(
                  fontSize: 10,
                  color: const Color.fromARGB(255, 12, 1, 77),
                ),
              ),
            if (message.status == 'sent')
              Text(
                message.sendTime != null
                    ? formatMessageTime(message.sendTime!)
                    : "Sending...", // Fallback if sendTime is null
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
            if (message.status == 'error')
              Text(
                "Error",
                style: TextStyle(
                  fontSize: 10,
                  color: const Color.fromARGB(255, 12, 1, 77),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String formatMessageTime(DateTime sendTime) {
  final now = DateTime.now();
  // Check if the sendTime is today
  if (sendTime.year == now.year &&
      sendTime.month == now.month &&
      sendTime.day == now.day) {
    return DateFormat('hh:mm a').format(sendTime);
  } else {
    return DateFormat('dd MMM').format(sendTime);
  }
}
