// lib/models/chat_user.dart
class ChatUser {
  final String id;
  final String chatRoomDocRefId;
  final String userRole; // "customer" or "serviceProvider"
  final String name;

  ChatUser({
    required this.id,
    required this.chatRoomDocRefId,
    required this.userRole,
    required this.name,
  });
}
