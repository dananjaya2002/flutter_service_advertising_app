// controllers/chat_agreement_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_2/models/chatModels/chat_agreement_params.dart';
import '../models/chatModels/chat_agreement_model.dart';
import 'dart:async'; // Import for StreamSubscription

class ChatAgreementState {
  final bool accepted;
  final bool loading;
  final bool initialLoading;

  ChatAgreementState({
    this.accepted = false,
    this.loading = false,
    this.initialLoading = true,
  });

  ChatAgreementState copyWith({
    bool? accepted,
    bool? loading,
    bool? initialLoading,
  }) {
    return ChatAgreementState(
      accepted: accepted ?? this.accepted,
      loading: loading ?? this.loading,
      initialLoading: initialLoading ?? this.initialLoading,
    );
  }
}

// Riverpod provider for the ChatAgreementController.
final chatAgreementProvider = StateNotifierProvider.family<
  ChatAgreementController,
  ChatAgreementState,
  ChatAgreementParams
>((ref, params) {
  // params must contain 'chatRoomDocRefId' and 'userRole'
  return ChatAgreementController(
    chatRoomDocRefId: params.chatRoomDocRefId,
    userRole: params.userRole,
  );
});

class ChatAgreementController extends StateNotifier<ChatAgreementState> {
  final String chatRoomDocRefId;
  final String userRole; // "customer" or "serviceProvider"
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription; // Add StreamSubscription

  ChatAgreementController({
    required this.chatRoomDocRefId,
    required this.userRole,
  }) : super(ChatAgreementState()) {
    _listenForAgreementChanges(); // Use listener instead of _checkAgreementStatus
  }

  void _listenForAgreementChanges() {
    _subscription = _firestore
        .collection("ChatRoom")
        .doc(chatRoomDocRefId)
        .snapshots()
        .listen(
          (docSnap) {
            if (docSnap.exists) {
              final data = docSnap.data() as Map<String, dynamic>;
              final agreementStatus = ChatAgreement.fromMap(data);
              state = state.copyWith(
                accepted: agreementStatus.accepted,
                initialLoading:
                    false, // Initial loading is done after first data received.
              );
            } else {
              state = state.copyWith(
                initialLoading: false,
              ); // Handle doc not existing.
            }
          },
          onError: (error) {
            print("Error listening for agreement changes: $error");
            state = state.copyWith(initialLoading: false); // Handle error.
          },
        );
  }

  Future<void> acceptAgreement() async {
    if (state.accepted ||
        state.loading ||
        userRole == "serviceProvider" ||
        state.initialLoading) {
      return;
    }
    state = state.copyWith(loading: true);

    try {
      final docRef = _firestore.collection("ChatRoom").doc(chatRoomDocRefId);
      await docRef.update({
        'agreementStatus': 'accepted',
        'agreementAcceptedDate': FieldValue.serverTimestamp(),
      });
      state = state.copyWith(accepted: true);
    } catch (error) {
      print("Error accepting agreement: $error");
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Cancel the subscription
    super.dispose();
  }
}
