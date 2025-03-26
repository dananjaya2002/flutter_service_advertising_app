// lib/models/chat_message.dart
class ChatMessage {
  final String id;
  final String senderId;
  final String messageType; // "textMessage", "imageURL", "AgreementRequest"
  final String value;
  final DateTime? sendTime;
  final String status; // "pending", "sent", "error"

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.messageType,
    required this.value,
    this.sendTime,
    required this.status,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? messageType,
    String? value,
    final DateTime? sendTime,
    String? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      messageType: messageType ?? this.messageType,
      value: value ?? this.value,
      sendTime: sendTime ?? this.sendTime,
      status: status ?? this.status,
    );
  }
}
