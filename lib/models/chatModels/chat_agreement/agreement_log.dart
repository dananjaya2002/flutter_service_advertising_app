// lib\models\chatModels\chat_agreement\agreement_log.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AgreementLog {
  final String agreementStatus;
  final bool isReated;

  AgreementLog({required this.agreementStatus, required this.isReated});

  factory AgreementLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgreementLog(
      agreementStatus: data['agreementStatus'] ?? '',
      isReated: data['isReated'] ?? false,
    );
  }
}
