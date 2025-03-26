// lib/models/chatModels/agreement_status_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AgreementStatusModel {
  final String agreementStatus; // "none", "Requested", or "Accepted"
  final DateTime? agreementRequestedDate;
  final DateTime? agreementAcceptedDate;

  AgreementStatusModel({
    required this.agreementStatus,
    this.agreementRequestedDate,
    this.agreementAcceptedDate,
  });

  factory AgreementStatusModel.fromMap(Map<String, dynamic> data) {
    return AgreementStatusModel(
      agreementStatus: data['agreementStatus'] ?? 'none',
      agreementRequestedDate:
          data['agreementRequestedDate'] != null
              ? (data['agreementRequestedDate'] as Timestamp).toDate()
              : null,
      agreementAcceptedDate:
          data['agreementAcceptedDate'] != null
              ? (data['agreementAcceptedDate'] as Timestamp).toDate()
              : null,
    );
  }
}
