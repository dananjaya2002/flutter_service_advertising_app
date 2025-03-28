// lib/controllers/agreement_controller.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chatModels/agreement_banner_model.dart';

class AgreementController extends StateNotifier<AgreementStatusModel> {
  final String chatRoomDocRefId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final StreamSubscription _subscription;

  AgreementController({required this.chatRoomDocRefId})
    : super(AgreementStatusModel(agreementStatus: 'none')) {
    // Listen to changes on the ChatRoom document.
    _subscription = _firestore
        .collection("ChatRoom")
        .doc(chatRoomDocRefId)
        .snapshots()
        .listen((docSnap) {
          if (docSnap.exists) {
            final data = docSnap.data()!;
            state = AgreementStatusModel.fromMap(data);
          }
        });
  }

  /// Called when the user presses the button.
  /// This method updates the ChatRoom document with agreement request fields.
  Future<void> sendAgreementRequest() async {
    try {
      await _firestore.collection("ChatRoom").doc(chatRoomDocRefId).update({
        'agreementStatus': 'requested',
        'agreementRequestedDate': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      print("Error sending agreement request: $error");
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Riverpod provider that takes the chatRoomDocRefId as a parameter.
final agreementProvider = StateNotifierProvider.family<
  AgreementController,
  AgreementStatusModel,
  String
>((ref, chatRoomDocRefId) {
  return AgreementController(chatRoomDocRefId: chatRoomDocRefId);
});
