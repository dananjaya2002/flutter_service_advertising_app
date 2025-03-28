import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_2/screens/chatScreens/chat_review_page.dart';
import '../../../models/chatModels/chat_user.dart';
import '../../../controllers/move_to_rating_controller.dart';

class MoveToRatingPage extends ConsumerWidget {
  final ChatUser chatUser;

  const MoveToRatingPage({Key? key, required this.chatUser}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(moveToRatingControllerProvider);

    return StreamBuilder(
      stream: controller.agreementLogStream(chatUser.chatRoomDocRefId),
      builder: (context, snapshot) {
        // Hide if there's no data or the document doesn't exist.
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final agreementLog = snapshot.data!;

        // Only show the widget if agreementStatus is 'accepted'.
        if (agreementLog.agreementStatus != 'accepted' ||
            chatUser.userRole == "serviceProvider") {
          return const SizedBox.shrink();
        }

        final bool isRated = agreementLog.isReated;
        return Container(
          width: double.infinity,
          color: Colors.black.withOpacity(0.5), // 50% transparent background.
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isRated
                      ? Colors.grey
                      : Colors.blue, // Disabled style when rated.
              foregroundColor: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed:
                isRated
                    ? null
                    : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatReviewPage(chatUser: chatUser),
                        ),
                      );
                    },
            child: const Text('Rate the Service'),
          ),
        );
      },
    );
  }
}
