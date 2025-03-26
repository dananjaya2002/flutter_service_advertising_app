// screens/chat_agreement_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/chat_agreement_controller.dart';

class ChatAgreementScreen extends ConsumerStatefulWidget {
  final String chatRoomDocRefId;
  final String userRole; // "customer" or "serviceProvider"
  final VoidCallback? onAccept;

  const ChatAgreementScreen({
    Key? key,
    required this.chatRoomDocRefId,
    required this.userRole,
    this.onAccept,
  }) : super(key: key);

  @override
  _ChatAgreementScreenState createState() => _ChatAgreementScreenState();
}

class _ChatAgreementScreenState extends ConsumerState<ChatAgreementScreen> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatAgreementProvider({
      'chatRoomDocRefId': widget.chatRoomDocRefId,
      'userRole': widget.userRole,
    }));

    // Determine dynamic background color; accepted state takes priority.
    Color buttonColor;
    if (state.accepted) {
      buttonColor = const Color(0xFF2ecc71);
    } else if (isPressed) {
      buttonColor = const Color(0xFF357ab8);
    } else {
      buttonColor = const Color(0xFF4a90e2);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Accept the Service",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                isPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                isPressed = false;
              });
            },
            onTapCancel: () {
              setState(() {
                isPressed = false;
              });
            },
            onTap: () async {
              await ref
                  .read(chatAgreementProvider({
                'chatRoomDocRefId': widget.chatRoomDocRefId,
                'userRole': widget.userRole,
              }).notifier)
                  .acceptAgreement();
              if (state.accepted == false && widget.onAccept != null) {
                widget.onAccept!();
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 56,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 3),
                    blurRadius: 4,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: (state.loading || state.initialLoading)
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
                  : Text(
                state.accepted ? "Accepted" : "Accept",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
