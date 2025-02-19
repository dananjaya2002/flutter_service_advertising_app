import 'package:flutter/material.dart';
import 'package:test_2/screens/chat_ui_screen.dart'; // Import ChatDetailScreen

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy chat data (replace with real data as needed)
    final List<Map<String, String>> chats = [
      {
        'name': 'Alice',
        'message': 'Hey, how are you?',
        'time': '09:30 AM',
      },
      {
        'name': 'Bob',
        'message': "Let's catch up later!",
        'time': '10:15 AM',
      },
      {
        'name': 'Charlie',
        'message': 'Did you check out the store?',
        'time': '11:00 AM',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          return Column(
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/48',
                      headers: {
                        'Cache-Control': 'no-cache',
                      },
                    ),
                    radius: 24,
                  ),
                  title: Text(
                    chat['name']!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    chat['message']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: Text(
                    chat['time']!,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    // Navigate to the ChatDetailScreen with the appropriate data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatUIScreen(
                          contactName: chat['name']!,
                          initialMessages: [chat['message'] ?? ''],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (index < chats.length - 1)
                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  indent: 24.0,
                  endIndent: 24.0,
                  color: Colors.grey[200],
                ),
            ],
          );
        },
      ),
    );
  }
}