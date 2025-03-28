// lib\controllers\move_to_rating_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chatModels/chat_agreement/agreement_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoveToRatingController {
  // Returns a stream of AgreementLog for the given chat room.
  Stream<AgreementLog?> agreementLogStream(String chatRoomDocRefId) {
    return FirebaseFirestore.instance
        .doc('/ChatRoom/$chatRoomDocRefId/AgreementRecords/agreementLogDoc')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return AgreementLog.fromFirestore(doc);
        });
  }
}

// Riverpod provider for the controller.
final moveToRatingControllerProvider = Provider(
  (ref) => MoveToRatingController(),
);
