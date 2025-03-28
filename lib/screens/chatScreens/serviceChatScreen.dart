import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_2/models/chatModels/chat_room.dart';
import '../../controllers/chat_rooms_controller.dart';
import '../../models/chatModels/chat_rooms_query_params.dart';
import '../../models/chatModels/chat_user.dart';
import 'textChatArea.dart';

class ServiceChatScreen extends ConsumerStatefulWidget {
  final ChatUser chatUser;

  const ServiceChatScreen({Key? key, required this.chatUser}) : super(key: key);

  @override
  _ServiceChatScreenState createState() => _ServiceChatScreenState();
}

class _ServiceChatScreenState extends ConsumerState<ServiceChatScreen> {
  late ChatRoomsQueryParams _params;

  @override
  void initState() {
    super.initState();
    _params = ChatRoomsQueryParams(
      role: 'serviceProvider',
      id: widget.chatUser.id,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomsProvider(_params).notifier).fetchInitialChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsState = ref.watch(chatRoomsProvider(_params));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child:
                chatRoomsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chatRoomsState.errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${chatRoomsState.errorMessage}'),
                          ElevatedButton(
                            onPressed:
                                () =>
                                    ref
                                        .read(
                                          chatRoomsProvider(_params).notifier,
                                        )
                                        .fetchInitialChatRooms(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : chatRoomsState.chatRooms.isEmpty
                    ? const Center(
                      child: Text(
                        'No chat rooms found',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                    )
                    : ListView.separated(
                      itemCount: chatRoomsState.chatRooms.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                            height: 1,
                            color: Colors.grey,
                            indent: 80,
                          ),
                      itemBuilder: (context, index) {
                        final room = chatRoomsState.chatRooms[index];
                        return _ChatRoomItem(
                          room: room,
                          onTap: () {
                            ChatUser updatedChatUser = ChatUser(
                              id: widget.chatUser.id,
                              chatRoomDocRefId: room.id,
                              userRole: "serviceProvider",
                              name: widget.chatUser.name,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => TextChatArea(
                                      chatUser: updatedChatUser,
                                      otherUserName:
                                          room.customer.name ?? 'Unknown User',
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ChatRoomItem extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const _ChatRoomItem({Key? key, required this.room, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white, // Set your desired background color here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            children: [
              // Column 1: Profile Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal.shade100,
                backgroundImage:
                    room.serviceProvider.profileImageUrl.isNotEmpty
                        ? NetworkImage(room.customer.profileImageUrl)
                        : null,
                child:
                    room.serviceProvider.profileImageUrl.isEmpty
                        ? Text(
                          room.customer.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.teal,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16),
              // Column 2: Message Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row: Other Person's Name
                    Text(
                      room.customer.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Second row: Last Message and Timestamp
                    Row(
                      children: [
                        // Last text message with ellipsis if long
                        Expanded(
                          child: Text(
                            room.lastMessage ?? 'No messages yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Timestamp
                        Text(
                          _formatTime(
                            room.lastMessageReceivedDate ?? DateTime.now(),
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to format time
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
