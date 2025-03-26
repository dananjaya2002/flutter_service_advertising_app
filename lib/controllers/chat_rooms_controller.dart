import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chatModels/chat_room.dart';
import '../models/chatModels/chat_rooms_query_params.dart';

final chatRoomsProvider = StateNotifierProvider.family<
  ChatRoomsController,
  ChatRoomsState,
  ChatRoomsQueryParams
>((ref, params) => ChatRoomsController(params));

class ChatRoomsState {
  final List<ChatRoom> chatRooms;
  final bool isLoading;
  final String? errorMessage;

  ChatRoomsState({
    this.chatRooms = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatRoomsState copyWith({
    List<ChatRoom>? chatRooms,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatRoomsState(
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChatRoomsController extends StateNotifier<ChatRoomsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatRoomsQueryParams params;
  DocumentSnapshot? lastDoc;
  bool isFetchingMore = false;
  static const int pageSize = 10;
  StreamSubscription? _subscription;

  ChatRoomsController(this.params) : super(ChatRoomsState()) {
    fetchInitialChatRooms();
  }

  String get queryField {
    switch (params.role) {
      case 'customer':
        return 'customer.docRef';
      case 'serviceProvider':
        return 'serviceProvider.docRef';
      default:
        throw ArgumentError("Unknown role: ${params.role}");
    }
  }

  Future<void> fetchInitialChatRooms() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      Query query = _firestore
          .collection('ChatRoom')
          .where(queryField, isEqualTo: params.id)
          .orderBy('lastMessageReceivedDate', descending: true)
          .limit(pageSize);

      final snapshot = await query.get();
      List<ChatRoom> rooms =
          snapshot.docs.map((doc) => ChatRoom.fromDocument(doc)).toList();

      if (rooms.isNotEmpty) {
        lastDoc = snapshot.docs.last;
        state = state.copyWith(chatRooms: rooms, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No chat rooms found',
        );
      }

      // Start streaming updates
      _startStreamListener();
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load chat rooms: $error',
      );
      log("Failed to load chat rooms: $error");
    }
  }

  void _startStreamListener() {
    _subscription?.cancel();

    Query query = _firestore
        .collection('ChatRoom')
        .where(queryField, isEqualTo: params.id)
        .orderBy('lastMessageReceivedDate', descending: true)
        .limit(pageSize);

    _subscription = query.snapshots().listen(
      (snapshot) {
        try {
          List<ChatRoom> rooms =
              snapshot.docs.map((doc) => ChatRoom.fromDocument(doc)).toList();

          if (rooms.isNotEmpty && !_isSameData(state.chatRooms, rooms)) {
            state = state.copyWith(chatRooms: rooms, errorMessage: null);
          }
        } catch (e) {
          state = state.copyWith(
            errorMessage: 'Error processing chat rooms updates: $e',
          );
        }
      },
      onError: (error) {
        state = state.copyWith(errorMessage: 'Stream error: $error');
      },
      cancelOnError: true,
    );
  }

  Future<void> loadMoreChatRooms() async {
    if (lastDoc == null || isFetchingMore) return;

    isFetchingMore = true;
    state = state.copyWith(isLoading: true);

    try {
      Query query = _firestore
          .collection('ChatRoom')
          .where(queryField, isEqualTo: params.id)
          .orderBy('lastMessageReceivedDate', descending: true)
          .startAfterDocument(lastDoc!)
          .limit(pageSize);

      final snapshot = await query.get();
      List<ChatRoom> moreRooms =
          snapshot.docs.map((doc) => ChatRoom.fromDocument(doc)).toList();

      if (moreRooms.isNotEmpty) {
        state = state.copyWith(
          chatRooms: [...state.chatRooms, ...moreRooms],
          isLoading: false,
        );
        lastDoc = snapshot.docs.last;
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load more chat rooms: $error',
      );
    } finally {
      isFetchingMore = false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

bool _isSameData(List<ChatRoom> oldList, List<ChatRoom> newList) {
  if (oldList.length != newList.length) return false;

  for (int i = 0; i < oldList.length; i++) {
    if (oldList[i].id != newList[i].id) return false;
  }

  return true;
}
