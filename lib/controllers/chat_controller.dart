// lib/controllers/chat_controller.dart
// import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chatModels/chat_message.dart';
import 'dart:async';
import 'dart:developer';

// Riverpod provider for the chat controller
final chatControllerProvider = StateNotifierProvider<ChatController, ChatState>(
  (ref) {
    return ChatController();
  },
);

// ChatState holds the list of messages and a loading flag.
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // For pagination
  DocumentSnapshot? lastDoc;
  bool isFetchingMore = false;
  static const int pageSize = 15;
  StreamSubscription? _subscription;

  ChatController() : super(ChatState(messages: []));

  /// Subscribes to messages in a given chat room.
  void subscribeToMessages(String chatRoomDocRefId) {
    // Cancel previous subscription if any.
    _subscription?.cancel();

    final messagesRef = _firestore
        .collection('ChatRoom')
        .doc(chatRoomDocRefId)
        .collection('Messages');
    final query = messagesRef
        .orderBy('sendTime', descending: true)
        .limit(pageSize);

    _subscription = query.snapshots().listen((snapshot) {
      List<ChatMessage> fetchedMessages =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            DateTime? sendTime;
            if (data['sendTime'] != null) {
              sendTime = (data['sendTime'] as Timestamp).toDate();
            }
            return ChatMessage(
              id: doc.id,
              senderId: data['senderId'] ?? '',
              messageType: data['messageType'] ?? 'textMessage',
              value: data['value'] ?? '',
              sendTime: sendTime,
              status: 'sent',
            );
          }).toList();

      // Logging
      //log('Fetched: ${fetchedMessages}');

      // Update the last document for pagination.
      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;
      }
      state = state.copyWith(messages: fetchedMessages);
    });
  }

  /// Loads more messages for pagination.
  Future<void> loadMoreMessages(String chatRoomDocRefId) async {
    if (lastDoc == null || isFetchingMore) return;
    isFetchingMore = true;
    print('Loading more messages...');

    final messagesRef = _firestore
        .collection('ChatRoom')
        .doc(chatRoomDocRefId)
        .collection('Messages');
    final query = messagesRef
        .orderBy('sendTime', descending: true)
        .startAfterDocument(lastDoc!)
        .limit(pageSize);
    final snapshot = await query.get();
    List<ChatMessage> moreMessages =
        snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime? sendTime;
          if (data['sendTime'] != null) {
            sendTime = (data['sendTime'] as Timestamp).toDate();
          }
          return ChatMessage(
            id: doc.id,
            senderId: data['senderId'] ?? '',
            messageType: data['messageType'] ?? 'textMessage',
            value: data['value'] ?? '',
            sendTime: sendTime,
            status: 'sent',
          );
        }).toList();

    print('Loaded ${moreMessages.length} more messages.');

    state = state.copyWith(messages: [...state.messages, ...moreMessages]);
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
    }
    isFetchingMore = false;
  }

  /// Sends a message with optimistic UI update.
  Future<void> sendMessage({
    required String chatRoomDocRefId,
    required String userID,
    required String message,
    required String messageType,
  }) async {
    final messagesRef = _firestore
        .collection('ChatRoom')
        .doc(chatRoomDocRefId)
        .collection('Messages');
    final newMessageRef = messagesRef.doc();
    final messageId = newMessageRef.id;

    // Create an optimistic message.
    final optimisticMessage = ChatMessage(
      id: messageId,
      senderId: userID,
      messageType: messageType,
      value: message,
      sendTime: DateTime.now(),
      status: 'pending',
    );

    // Immediately update local state.
    state = state.copyWith(messages: [optimisticMessage, ...state.messages]);
    print('Optimistically added message with ID: $messageId');

    try {
      final messageData = {
        'senderId': userID,
        'messageType': messageType,
        'value': message,
        'sendTime': FieldValue.serverTimestamp(),
      };

      final batch = _firestore.batch();
      batch.set(newMessageRef, messageData);
      final chatDocRef = _firestore
          .collection('ChatRoom')
          .doc(chatRoomDocRefId);
      print("Updating chat document: $chatRoomDocRefId");
      batch.update(chatDocRef, {
        'lastMessage': message,
        'sendTime': FieldValue.serverTimestamp(),
      });
      await batch.commit();

      // On success, update the message status.
      state = state.copyWith(
        messages:
            state.messages.map((m) {
              if (m.id == messageId) {
                return m.copyWith(status: 'sent');
              }
              return m;
            }).toList(),
      );

      print('Message $messageId sent successfully.');
    } catch (error) {
      // On error, mark message as error.
      state = state.copyWith(
        messages:
            state.messages.map((m) {
              if (m.id == messageId) {
                return m.copyWith(status: 'error');
              }
              return m;
            }).toList(),
      );
      print("Error sending message: $error");
    }
  }

  /// Placeholder for image upload (using image_picker later)
  Future<void> uploadImagePlaceholder() async {
    print("Image picker triggered – placeholder function");
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
