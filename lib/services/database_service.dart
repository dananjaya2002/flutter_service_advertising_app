import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/shop_model.dart';
import '../models/category_model.dart';


import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection Reference
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  // Shops Collection Reference
  final CollectionReference shopsCollection = FirebaseFirestore.instance
      .collection('shops');

  // Categories Collection Reference
  final CollectionReference categoriesCollection = FirebaseFirestore.instance
      .collection('categories');

  // Comments Collection Reference
  final CollectionReference commentsCollection = FirebaseFirestore.instance
      .collection('comments'); 

  // Chats Collection Reference
  final CollectionReference chatsCollection = FirebaseFirestore.instance
      .collection('chats');

  // Messages Collection Reference
  final CollectionReference messagesCollection = FirebaseFirestore.instance
      .collection('messages');

  // Get user by id
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get all categories
  Stream<List<CategoryModel>> getCategories() {
    return categoriesCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return CategoryModel.fromMap(data);
          }).toList(),
    );
  }

  // Get shops
  Stream<List<ShopModel>> getShops() {
    return shopsCollection
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return ShopModel.fromMap(data);
              }).toList(),
        );
  }

  // Get shops by category
  Stream<List<ShopModel>> getShopsByCategory(String categoryId) {
    return shopsCollection
        .where('isPublished', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return ShopModel.fromMap(data);
              }).toList(),
        );
  }

  // Get shop by id
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      DocumentSnapshot doc = await shopsCollection.doc(shopId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ShopModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting shop: $e');
      return null;
    }
  }

  

  // Get shops owned by user
  Stream<List<ShopModel>> getUserShops(String userId) {
    return shopsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return ShopModel.fromMap(data);
              }).toList(),
        );
  }

  // Create a shop
  Future<String> createShop(ShopModel shop) async {
    try {
      DocumentReference docRef = await shopsCollection.add(shop.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating shop: $e');
      rethrow;
    }
  }

  // Update a shop
  Future<void> updateShop(String shopId, Map<String, dynamic> data) async {
    try {
      await shopsCollection.doc(shopId).update(data);
    } catch (e) {
      print('Error updating shop: $e');
      rethrow;
    }
  }

  // Delete a shop
  Future<void> deleteShop(String shopId) async {
    try {
      await shopsCollection.doc(shopId).delete();
    } catch (e) {
      print('Error deleting shop: $e');
      rethrow;
    }
  }
 
  
  
  // Create or get chat between customer and service provider
  Future<String> createOrGetChat(
    String customerId,
    String serviceProviderId,
    String shopId, {
    String? serviceRequestId,
  }) async {
    try {
      // Check if chat already exists
      QuerySnapshot chatSnapshot =
          await chatsCollection
              .where('customerId', isEqualTo: customerId)
              .where('serviceProviderId', isEqualTo: serviceProviderId)
              .where('shopId', isEqualTo: shopId)
              .limit(1)
              .get();

      if (chatSnapshot.docs.isNotEmpty) {
        // Update serviceRequestId if provided
        if (serviceRequestId != null) {
          await chatsCollection.doc(chatSnapshot.docs.first.id).update({
            'serviceRequestId': serviceRequestId,
          });
        }
        return chatSnapshot.docs.first.id;
      }

      // Create new chat
      ChatModel chat = ChatModel(
        id: '', // Will be updated after creation
        customerId: customerId,
        serviceProviderId: serviceProviderId,
        shopId: shopId,
        lastMessageTime: DateTime.now(),
        lastMessage: 'Chat started',
        isRead: true,
       
      );

      DocumentReference docRef = await chatsCollection.add(chat.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating/getting chat: $e');
      rethrow;
    }
  }

  // Get chats for a user (as customer)
  Stream<List<ChatModel>> getCustomerChats(String customerId) {
    return chatsCollection
        .where('customerId', isEqualTo: customerId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return ChatModel.fromMap(data);
              }).toList(),
        );
  }

  // Get chats for a user (as service provider)
  Stream<List<ChatModel>> getServiceProviderChats(String serviceProviderId) {
    return chatsCollection
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return ChatModel.fromMap(data);
              }).toList(),
        );
  }

  // Add message to chat
  Future<String> sendMessage(MessageModel message) async {
    try {
      // Add message
      DocumentReference docRef = await messagesCollection.add(message.toMap());

      // Update chat last message and time
      await chatsCollection.doc(message.chatId).update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp,
      });

      return docRef.id;
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return messagesCollection
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return MessageModel.fromMap(data, doc.id);
              }).toList(),
        );
  }

  // Add shop to user's favorites
  Future<void> addShopToFavorites(String userId, String shopId) async {
    try {
      await usersCollection.doc(userId).update({
        'favoriteShops': FieldValue.arrayUnion([shopId]),
      });
    } catch (e) {
      print('Error adding shop to favorites: $e');
      rethrow;
    }
  }

  // Remove shop from user's favorites
  Future<void> removeShopFromFavorites(String userId, String shopId) async {
    try {
      await usersCollection.doc(userId).update({
        'favoriteShops': FieldValue.arrayRemove([shopId]),
      });
    } catch (e) {
      print('Error removing shop from favorites: $e');
      rethrow;
    }
  }

  // Get user's favorite shops
  Stream<List<ShopModel>> getFavoriteShops(String userId) async* {
    try {
      // First get the user document to extract favorite shop IDs
      DocumentSnapshot userDoc = await usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        yield [];
        return;
      }

      List<String> favoriteIds = List<String>.from(
        (userDoc.data() as Map<String, dynamic>)['favoriteShops'] ?? [],
      );

      if (favoriteIds.isEmpty) {
        yield [];
        return;
      }

      // Then get the shop documents by those IDs
      yield* _firestore
          .collection('shops')
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) {
                  Map<String, dynamic> data = doc.data();
                  data['id'] = doc.id;
                  return ShopModel.fromMap(data);
                }).toList(),
          );
    } catch (e) {
      print('Error getting favorite shops: $e');
      yield [];
    }
  }

  // Get all documents from a collection
  Future<List<Map<String, dynamic>>> getCollection(
    String collectionPath,
  ) async {
    try {
      final snapshot = await _firestore.collection(collectionPath).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Add the document ID to the data map
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error getting collection $collectionPath: $e');
      rethrow;
    }
  }

  // Get existing chat between users for a specific shop
  Future<String> getExistingChat({
    required String customerId,
    required String serviceProviderId,
    required String shopId,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('chats')
              .where('customerId', isEqualTo: customerId)
              .where('serviceProviderId', isEqualTo: serviceProviderId)
              .where('shopId', isEqualTo: shopId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }

      return '';
    } catch (e) {
      debugPrint('Error checking for existing chat: $e');
      rethrow;
    }
  }

  // Get messages for a specific chat
  Stream<List<MessageModel>> getMessagesForChat(String chatId) {
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            return MessageModel.fromMap(data, doc.id);
          }).toList();
        });
  }

  // Get chats for a user (either customer or service provider)
  Stream<List<ChatModel>> getChatsForUser(String userType, String userId) {
    return chatsCollection
        .where(userType, isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = {'id': doc.id};

            // Add fields from the document
            if (doc.exists) {
              Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
              docData.forEach((key, value) {
                data[key] = value;
              });
            }

            return ChatModel.fromMap(data);
          }).toList();
        });
  }

  // Add document to a collection
  Future<String> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore.collection(collectionPath).add(data);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding document to $collectionPath: $e');
      rethrow;
    }
  }

  // Update document in a collection
  Future<void> updateDocument(
    String collectionPath,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
    } catch (e) {
      debugPrint('Error updating document in $collectionPath: $e');
      rethrow;
    }
  }

  // Get personal chats (chats with other shops)
  Stream<List<ChatModel>> getPersonalChats(String userId) {
    return chatsCollection
        .where('customerId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return ChatModel.fromMap(data);
          }).toList();
        });
  }

  // Get shop chats (chats related to user's shop)
  Stream<List<ChatModel>> getShopChats(String userId) {
    return chatsCollection
        .where('serviceProviderId', isEqualTo: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return ChatModel.fromMap(data);
          }).toList();
        });
  }
}
