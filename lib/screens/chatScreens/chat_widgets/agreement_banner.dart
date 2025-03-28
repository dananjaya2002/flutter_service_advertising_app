// lib/screens/chatScreens/chat_widgets/agreement_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:test_2/controllers/chat_controller.dart';

import '../../../controllers/agreement_banner_controller.dart';
import '../../../models/chatModels/agreement_banner_model.dart';
import '../../../models/chatModels/chat_user.dart'; // Ensure ChatUser is defined here

class AgreementBanner extends ConsumerWidget {
  final ChatUser chatUser;
  final String chatRoomDocRefId;

  const AgreementBanner({
    Key? key,
    required this.chatUser,
    required this.chatRoomDocRefId,
  }) : super(key: key);

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
    String buttonText = "Send Agreement";

    if (agreementState.agreementStatus == 'requested') {
      baseButtonColor = const Color.fromARGB(255, 0, 233, 8);
      detailsText =
          "Date: ${_formatDate(agreementState.agreementRequestedDate)}";
      buttonText = "Agreement Sent";
      actionLocked = true;
    } else if (agreementState.agreementStatus == 'accepted') {
      baseButtonColor = const Color.fromARGB(255, 131, 180, 132);
      detailsText =
          "Date: ${_formatDate(agreementState.agreementAcceptedDate)}";
      buttonText = "Agreement Sent";
      actionLocked = true;
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: const Color.fromARGB(
          193,
          0,
          0,
          0,
        ), // Background for the entire component.
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

                // Now send the corresponding chat message:
                await ref
                    .read(chatControllerProvider.notifier)
                    .sendMessage(
                      chatRoomDocRefId: chatUser.chatRoomDocRefId,
                      userID: chatUser.id,
                      message: "<Agreement Request>",
                      messageType: "agreementRequest",
                    );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    actionLocked
                        ? baseButtonColor.withOpacity(0.5)
                        : baseButtonColor,
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 24.0,
                ),
              ),
              child: Text(buttonText, style: TextStyle(fontSize: 16.0)),
            ),
            const SizedBox(height: 8.0),
            // Second row: Display date details if available.
            Text(
              detailsText,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
