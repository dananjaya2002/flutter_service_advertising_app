import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get an existing chat
  Future<ChatModel> createOrGetChat(String shopId, String customerId) async {
    try {
      // Get the shop owner's ID
      final shopDoc = await _firestore.collection('shops').doc(shopId).get();
      final shopData = shopDoc.data();

      if (shopData == null || shopData['ownerId'] == null) {
        throw Exception('Shop owner ID is missing for shopId: $shopId, $customerId, $shopData');
      }

      final serviceProviderId = shopData['ownerId'] as String;

      // Check if a chat already exists
      final querySnapshot =
          await _firestore
              .collection('chats')
              .where('customerId', isEqualTo: customerId)
              .where('serviceProviderId', isEqualTo: serviceProviderId)
              .where('shopId', isEqualTo: shopId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Chat already exists, return it
        return ChatModel.fromMap(querySnapshot.docs.first.data());
      }

      // Create a new chat if it doesn't exist
      final chatRef = _firestore.collection('chats').doc();
      final chat = ChatModel(
        id: chatRef.id,
        shopId: shopId,
        customerId: customerId,
        serviceProviderId: serviceProviderId,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        isRead: true,
      );

      await chatRef.set(chat.toMap());
      return chat;
    } catch (e) {
      print('Error creating or getting chat: $e');
      rethrow;
    }
  }

  // Create a new chat
  Future<ChatModel> createChat(String shopId, String customerId) async {
    try {
      // Get the shop owner's ID
      final shopDoc = await _firestore.collection('shops').doc(shopId).get();
      final serviceProviderId = shopDoc.data()?['ownerId'] as String;

      // Check if a chat already exists
      final querySnapshot =
          await _firestore
              .collection('chats')
              .where('customerId', isEqualTo: customerId)
              .where('serviceProviderId', isEqualTo: serviceProviderId)
              .where('shopId', isEqualTo: shopId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Chat already exists, return it
        return ChatModel.fromMap(querySnapshot.docs.first.data());
      }

      // Create a new chat if it doesn't exist
      final chatRef = _firestore.collection('chats').doc();
      final chat = ChatModel(
        id: chatRef.id,
        shopId: shopId,
        customerId: customerId,
        serviceProviderId: serviceProviderId,
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        isRead: true,
      );

      await chatRef.set(chat.toMap());
      return chat;
    } catch (e) {
      print('Error creating or getting chat: $e');
      rethrow;
    }
  }

  // Get chat by ID
  Future<ChatModel?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists) {
        return ChatModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting chat: $e');
      rethrow;
    }
  }

  // Get all chats for a user
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants.$userId', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Send a message
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String content,
  ) async {
    try {
      final messageRef = _firestore.collection('messages').doc();
      final message = MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Add message to messages collection
      await messageRef.set(message.toMap());

      // Update chat's last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'isRead': false,
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({'isRead': true});

      // Mark all messages as read
      final messages =
          await _firestore
              .collection('messages')
              .where('chatId', isEqualTo: chatId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marking chat as read: $e');
      rethrow;
    }
  }

  // Get unread message count for a user
  Stream<int> getUnreadMessageCount(String userId) {
    return _firestore
        .collection('chats')
        .where('participants.$userId', isEqualTo: true)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get personal chats (chats with other shops)
  Stream<List<ChatModel>> getPersonalChats(String userId) {
    return _firestore
        .collection('chats')
        .where('customerId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Get shop chats (chats related to user's shop)
  Stream<List<ChatModel>> getShopChats(String userId) {
    return _firestore
        .collection('chats')
        .where('serviceProviderId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList();
        });
  }
}
