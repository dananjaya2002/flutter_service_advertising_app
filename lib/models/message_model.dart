// lib/models/message_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final bool isAgreement; // Indicates if the message is an agreement
  final bool? agreementAccepted; // Null if not yet accepted/rejected
  final bool isImage; // Indicates if the message is an image

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.isAgreement = false, // Default to false
    this.agreementAccepted, // Default to null
    this.isImage = false, // Default to false
  });

  // Factory method to create a MessageModel from a Firestore document with document ID
  factory MessageModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MessageModel(
      id: documentId, // Use the Firestore document ID
      chatId: map['chatId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool,
      isAgreement: map['isAgreement'] as bool? ?? false,
      agreementAccepted: map['agreementAccepted'] as bool?,
      isImage: map['isImage'] as bool? ?? false, // Default to false if not present
    );
  }

  // Convert MessageModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'isAgreement': isAgreement,
      'agreementAccepted': agreementAccepted,
      'isImage': isImage,
    };
  }

  // Create a copy of the MessageModel with updated fields
  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    bool? isAgreement,
    bool? agreementAccepted,
    bool? isImage,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isAgreement: isAgreement ?? this.isAgreement,
      agreementAccepted: agreementAccepted ?? this.agreementAccepted,
      isImage: isImage ?? this.isImage,
    );
  }
}