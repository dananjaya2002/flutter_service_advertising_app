// lib/models/chatModels/chatUser.dart
class ChatUser {
  final String userID;
  final String? userRole;
  final String chatRoomID;

  ChatUser({required this.userID, this.userRole, required this.chatRoomID});
}
