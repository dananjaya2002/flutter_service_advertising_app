//lib/providers/chat_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChatModel> _chats = [];
  final Map<String, List<MessageModel>> _messages = {};
  bool _isLoading = false;
  String? _activeChatId;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get activeChatId => _activeChatId;

  // Get messages for a specific chat
  List<MessageModel> getMessagesForChat(String chatId) {
    return _messages[chatId] ?? [];
  }

  // Get user's chats stream
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _chatService.getUserChats(userId);
  }

  // Load user's chats
  Future<void> loadUserChats(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _chatService.getUserChats(userId).listen((chats) {
        _chats = chats;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading chats: $e');
    }
  }

  // Load messages for a chat
  Future<void> loadChatMessages(String chatId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('messages')
              .where('chatId', isEqualTo: chatId)
              .orderBy(
                'timestamp',
                descending: false,
              ) // Fetch messages in ascending order
              .get();

      final messages =
          querySnapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.data(), doc.id); // Pass document ID
          }).toList();

      _messages[chatId] = messages;
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // Send a message
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String content, {
    bool isImage = false,
  }) async {
    try {
      final messageRef = await _firestore.collection('messages').add({
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'timestamp': DateTime.now(),
        'isRead': false,
        'isAgreement': false,
        'isImage': isImage,
      });

      // Update the local message with the Firestore document ID
      final message = MessageModel(
        id: messageRef.id, // Use the Firestore document ID
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        isImage: isImage,
      );

      // Add the message locally
      addMessageLocally(chatId, message);

      // Update the last message in the chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': isImage ? '📷 Image' : content, // Show "Image" for image messages
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId) async {
    try {
      await _chatService.markChatAsRead(chatId);
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  // Get unread message count
  Stream<int> getUnreadMessageCount(String userId) {
    return _chatService.getUnreadMessageCount(userId);
  }

  // Create or get existing chat
  Future<String> createOrGetChat(
    String shopId,
    String customerId,
    String serviceProviderId,
  ) async {
    try {
      final chat = await _chatService.createOrGetChat(shopId, customerId);
      return chat.id;
    } catch (e) {
      print('Error creating or getting chat: $e');
      rethrow;
    }
  }

  // Add a message locally
  void addMessageLocally(String chatId, MessageModel message) {
    final chatMessages = _messages[chatId] ?? [];

    // Check if the message already exists in the list
    if (chatMessages.any((m) => m.id == message.id)) {
      return; // Do not add duplicate messages
    }

    // Add the new message
    chatMessages.add(message);

    // Sort messages by timestamp
    chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _messages[chatId] = chatMessages;
    notifyListeners();
  }

  // Set active chat
  void setActiveChat(String chatId) {
    _activeChatId = chatId;
    notifyListeners();
  }

  // Get personal chats stream
  Stream<List<ChatModel>> getPersonalChats(String userId) {
    return _chatService.getPersonalChats(userId);
  }

  // Get shop chats stream
  Stream<List<ChatModel>> getShopChats(String userId) {
    return _chatService.getShopChats(userId);
  }

  // Load personal chats
  Future<void> loadPersonalChats(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _chatService.getPersonalChats(userId).listen((chats) {
        _chats = chats;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading personal chats: $e');
    }
  }

  // Load shop chats
  Future<void> loadShopChats(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _chatService.getShopChats(userId).listen((chats) {
        _chats = chats;
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading shop chats: $e');
    }
  }

  // Send an agreement message
  Future<void> sendAgreement(
    String chatId,
    String senderId,
    String content,
  ) async {
    try {
      final messageRef = await _firestore.collection('messages').add({
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
        'timestamp': DateTime.now(),
        'isRead': false,
        'isAgreement': true,
        'agreementAccepted': null,
      });

      // Update the local message with the Firestore document ID
      final agreementMessage = MessageModel(
        id: messageRef.id, // Use the Firestore document ID
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
        isAgreement: true,
        agreementAccepted: null,
      );

      // Add the message locally
      addMessageLocally(chatId, agreementMessage);

      // Update the last message in the chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending agreement: $e');
      rethrow;
    }
  }

  // Update agreement status
  Future<void> updateAgreementStatus(String messageId, bool accepted) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'agreementAccepted': accepted,
      });
    } catch (e) {
      print('Error updating agreement status: $e');
      rethrow;
    }
  }
}
