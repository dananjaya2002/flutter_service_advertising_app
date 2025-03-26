// lib/screens/chatScreens/chat_widgets/agreement_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../controllers/agreement_controller.dart';
import '../../../models/chatModels/agreement_status_model.dart';
import '../../../models/chatModels/chat_user.dart'; // Ensure ChatUser is defined here

class AgreementBanner extends ConsumerWidget {
  final ChatUser chatUser;

  const AgreementBanner({Key? key, required this.chatUser}) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to changes on the agreement status document.
    final agreementState = ref.watch(
      agreementProvider(chatUser.chatRoomDocRefId),
    );

    // Determine the base button color and details text.
    Color baseButtonColor = Colors.blue;
    String detailsText = "";
    bool actionLocked = false; // Used to prevent multiple triggers.

    if (agreementState.agreementStatus == 'Requested') {
      baseButtonColor = Colors.yellow;
      detailsText =
          "Date: ${_formatDate(agreementState.agreementRequestedDate)}";
      actionLocked = true;
    } else if (agreementState.agreementStatus == 'Accepted') {
      baseButtonColor = Colors.green;
      detailsText = _formatDate(agreementState.agreementAcceptedDate);
      actionLocked = true;
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.black87, // Background for the entire component.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // First row: Button always shows "Send Agreement".
            ElevatedButton(
              onPressed: () async {
                if (actionLocked || chatUser.userRole == 'customer') return;
                // Trigger the agreement request:
                await ref
                    .read(agreementProvider(chatUser.chatRoomDocRefId).notifier)
                    .sendAgreementRequest();
                // (Additional logic such as sending a chat message is handled elsewhere.)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    actionLocked
                        ? baseButtonColor.withOpacity(0.5)
                        : baseButtonColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 24.0,
                ),
              ),
              child: const Text(
                "Send Agreement",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 8.0),
            // Second row: Display date details if available.
            Text(
              detailsText,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
