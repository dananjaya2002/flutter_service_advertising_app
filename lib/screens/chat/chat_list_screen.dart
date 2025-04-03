import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/chat_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;
    if (userId != null) {
      await Provider.of<ChatProvider>(
        context,
        listen: false,
      ).loadPersonalChats(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid;

    if (userId == null) {
      return const Center(child: Text('Please log in to view chats'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Personal Chats'), Tab(text: 'Shop Chats')],
          onTap: (index) {
            if (index == 0) {
              Provider.of<ChatProvider>(
                context,
                listen: false,
              ).loadPersonalChats(userId);
            } else {
              Provider.of<ChatProvider>(
                context,
                listen: false,
              ).loadShopChats(userId);
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(context, userId, isPersonal: true),
          _buildChatList(context, userId, isPersonal: false),
        ],
      ),
    );
  }

  Widget _buildChatList(
    BuildContext context,
    String userId, {
    required bool isPersonal,
  }) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return StreamBuilder<List<ChatModel>>(
          stream:
              isPersonal
                  ? chatProvider.getPersonalChats(userId)
                  : chatProvider.getShopChats(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final chats = snapshot.data ?? [];

            if (chats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPersonal
                          ? 'No personal chats yet'
                          : 'No shop chats yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatTile(context, chat, userId, isPersonal);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    ChatModel chat,
    String userId,
    bool isPersonal,
  ) {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    

    return FutureBuilder<String?>(
      future:
          isPersonal
              ? shopProvider.getShopNameById(
                chat.shopId,
              ) // Fetch shop name for personal chats
              : userProvider.getUserNameById(
                chat.customerId,
              ), // Fetch customer name for shop chats
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Unknown';
        final imageUrl =
            isPersonal
                ? snapshot
                    .data
                    ?.imageUrl // Shop image for personal chats
                : null; // No image for customers (optional)

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child:
                imageUrl == null
                    ? Icon(isPersonal ? Icons.store : Icons.person)
                    : null,
          ),
          title: Text(name),
          subtitle: Text(
            chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(chat.lastMessageTime),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              if (!chat.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(chatId: chat.id),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

extension on String? {
  get imageUrl => null;
}
