import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserInfo {
  final String docRef;
  final String name;
  final String profileImageUrl;
  final DateTime? timestamp;
  final DateTime? sendedTime;
  final DateTime? lastUpdatedTime;
  final String? lastMessage;

  UserInfo({
    required this.docRef,
    required this.name,
    this.profileImageUrl = '',
    this.timestamp,
    this.sendedTime,
    this.lastUpdatedTime,
    this.lastMessage,
  });

  // Factory constructor to parse from Firestore data
  factory UserInfo.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return UserInfo(docRef: '', name: 'Unknown User');
    }

    return UserInfo(
      docRef: (data['docRef'] as String?) ?? '',
      name: (data['name'] as String?) ?? 'Unknown User',
      profileImageUrl: (data['profileImageUrl'] as String?) ?? '',
      timestamp:
          data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
      sendedTime:
          data['sendedTime'] is Timestamp
              ? (data['sendedTime'] as Timestamp).toDate()
              : null,
      lastUpdatedTime:
          data['lastUpdatedTime'] is Timestamp
              ? (data['lastUpdatedTime'] as Timestamp).toDate()
              : null,
      lastMessage: data['lastMessage'] as String?,
    );
  }
}

class ChatRoom {
  final String id;
  final UserInfo customer;
  final UserInfo serviceProvider;
  final String? lastMessage;
  final DateTime? lastMessageReceivedDate;
  final DateTime? timestamp;

  ChatRoom({
    required this.id,
    required this.customer,
    required this.serviceProvider,
    this.lastMessage,
    this.lastMessageReceivedDate,
    this.timestamp,
  });

  // Factory method to parse from Firestore document
  factory ChatRoom.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Log the full data for debugging
    log('Parsing ChatRoom document: ${doc.id}', name: 'ChatRoom');
    // log('Full data: $data');

    return ChatRoom(
      id: doc.id,
      customer: UserInfo.fromMap(data['customer']),
      serviceProvider: UserInfo.fromMap(data['serviceProvider']),
      lastMessage: data['lastMessage'] as String?,
      lastMessageReceivedDate:
          data['lastMessageReceivedDate'] is Timestamp
              ? (data['lastMessageReceivedDate'] as Timestamp).toDate()
              : null,
      timestamp:
          data['timestamp'] is Timestamp
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
    );
  }
}
