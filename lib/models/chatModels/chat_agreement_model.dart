// models/chat_agreement_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatAgreement {
  final bool accepted;
  final DateTime? acceptedTime;

  ChatAgreement({
    required this.accepted,
    this.acceptedTime,
  });

  factory ChatAgreement.fromMap(Map<String, dynamic> data) {
    return ChatAgreement(
      accepted: data['agreement'] == 'accepted',
      acceptedTime: data['acceptedTime'] != null
          ? (data['acceptedTime'] as Timestamp).toDate()
          : null,
    );
  }
}
