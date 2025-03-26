// lib/models/chatModels/chat_rooms_query_params.dart
class ChatRoomsQueryParams {
  final String role; // e.g. 'customer' or 'serviceProvider'
  final String id;

  ChatRoomsQueryParams({required this.role, required this.id});
}
