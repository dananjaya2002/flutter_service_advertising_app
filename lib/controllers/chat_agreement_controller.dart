// controllers/chat_agreement_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_2/models/chatModels/chat_agreement_params.dart';
import '../models/chatModels/chat_agreement_model.dart';

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

  ChatAgreementController({
    required this.chatRoomDocRefId,
    required this.userRole,
  }) : super(ChatAgreementState()) {
    _checkAgreementStatus();
  }

  Future<void> _checkAgreementStatus() async {
    try {
      final docRef = _firestore.collection("ChatRoom").doc(chatRoomDocRefId);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>;
        final agreement = ChatAgreement.fromMap(data);
        if (agreement.accepted) {
          state = state.copyWith(accepted: true);
        }
      }
    } catch (error) {
      print("Error checking agreement status: $error");
    } finally {
      state = state.copyWith(initialLoading: false);
    }
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
        'agreement': 'accepted',
        'acceptedTime': FieldValue.serverTimestamp(),
      });
      state = state.copyWith(accepted: true);
    } catch (error) {
      print("Error accepting agreement: $error");
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}
