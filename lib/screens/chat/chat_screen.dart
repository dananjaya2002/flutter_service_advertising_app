//lib/chat/chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/shop_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final double _rating = 3.0;
  bool _canSendAgreement = false;
  bool _isUploading = false; // Tracks if an image is being uploaded

  @override
  void initState() {
    super.initState();
    _initializeChatDetails();
    _loadMessages();
    _markChatAsRead();
  }

  Future<void> _initializeChatDetails() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.uid;

      if (userProvider.user?.role != 'service_provider' || userId == null) {
        return; // Exit if the user is not a service provider or not logged in
      }

      // Fetch the serviceProviderId from the chats collection using chatId
      final chatSnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .get();

      if (!chatSnapshot.exists) {
        print('Chat not found.');
        return;
      }

      final serviceProviderId =
          chatSnapshot.data()?['serviceProviderId'] as String?;
      if (serviceProviderId == null) {
        print('Service provider ID not found in chat.');
        return;
      }

      // Compare the serviceProviderId with the current user's userId
      if (serviceProviderId == userId) {
        setState(() {
          _canSendAgreement = true; // Allow the button to be shown
        });
      }
    } catch (e) {
      print('Error initializing chat details: $e');
    }
  }

  Future<void> _loadMessages() async {
    await Provider.of<ChatProvider>(
      context,
      listen: false,
    ).loadChatMessages(widget.chatId);
  }

  Future<void> _markChatAsRead() async {
    await Provider.of<ChatProvider>(
      context,
      listen: false,
    ).markChatAsRead(widget.chatId);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    if (userId != null) {
      final messageContent = _messageController.text.trim();

      // Clear the input field
      _messageController.clear();

      // Send the message to Firestore
      try {
        await chatProvider.sendMessage(widget.chatId, userId, messageContent);

        // Scroll to the bottom after sending the message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } catch (e) {
        // Handle errors
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
      }
    }
  }

  Future<void> _sendAgreement() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
      return;
    }

    try {
      // Send the agreement message to Firestore
      await chatProvider.sendAgreement(
        widget.chatId,
        userId,
        'Agreement: Please accept the terms of the service.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agreement sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send agreement: $e')));
    }
  }

  Future<void> _acceptAgreement(String messageId) async {
    print('Accepting agreement for message ID: $messageId');
    if (messageId.isEmpty) {
      print('Error: Message ID is empty');
      return;
    } // Debug log
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    try {
      await chatProvider.updateAgreementStatus(messageId, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Agreement accepted!')));
    } catch (e) {
      print('Error updating agreement status: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to accept agreement: $e')));
    }
  }

  Future<void> _rejectAgreement(String messageId) async {
    print('Rejecting agreement for message ID: $messageId'); // Debug log
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    try {
      await chatProvider.updateAgreementStatus(messageId, false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Agreement rejected!')));
    } catch (e) {
      print('Error updating agreement status: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reject agreement: $e')));
    }
  }

  void _showRatingPopup(BuildContext context) {
    final TextEditingController commentController = TextEditingController();
    double localRating = _rating; // Use a local variable for the slider value

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Rating and Comment'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Slider for rating
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rating (1-5)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: localRating,
                        min: 1,
                        max: 5,
                        divisions: 4, // Divisions for 1, 2, 3, 4, 5
                        label: localRating.toString(),
                        onChanged: (value) {
                          setState(() {
                            localRating =
                                value; // Update the local slider value
                          });
                        },
                      ),
                      Text(
                        'Selected Rating: ${localRating.toInt()}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // TextField for comment
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final comment = commentController.text.trim();

                if (localRating < 1 || localRating > 5) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a valid rating.'),
                    ),
                  );
                  return;
                }

                // Save the rating and comment (e.g., to Firestore)
                _saveRatingAndComment(localRating.toInt(), comment);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  /// Fetch shopId from chatId
  Future<String?> _getShopIdFromChatId(String chatId) async {
    try {
      final chatSnapshot =
          await FirebaseFirestore.instance
              .collection('chats')
              .doc(chatId)
              .get();

      if (chatSnapshot.exists) {
        return chatSnapshot.data()?['shopId'] as String?;
      }
    } catch (e) {
      print('Error fetching shopId: $e');
    }
    return null;
  }

  Future<void> _saveRatingAndComment(int rating, String comment) async {
    try {
      // Fetch the shopId from the chatId
      final shopId = await _getShopIdFromChatId(widget.chatId);

      // Use chatId as the document ID to ensure uniqueness
      await FirebaseFirestore.instance
          .collection('ratings')
          .doc(widget.chatId) // Use chatId as the document ID
          .set({
            'chatId': widget.chatId,
            'shopId': shopId, // Add shopId
            'rating': rating,
            'comment': comment,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)); // Overwrite if the document exists

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating and comment submitted successfully!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating and comment: $e')),
      );
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = timestamp.toDate();
      final time = TimeOfDay.fromDateTime(dateTime);
      return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
    } catch (e) {
      print('Error formatting timestamp: $e');
      return '';
    }
  }

  Future<void> _pickAndSendImage() async {
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    setState(() {
      _isUploading = true; // Start uploading
    });

    try {
      // Use the pickImage function from ShopProvider to pick and upload the image
      final imageUrl = await shopProvider.pickImage();

      if (imageUrl.isNotEmpty) {
        // Send the image URL as a message
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userId = userProvider.user?.uid;

        if (userId != null) {
          await Provider.of<ChatProvider>(context, listen: false).sendMessage(
            widget.chatId,
            userId,
            imageUrl,
            isImage: true, // Indicate that this is an image message
          );

          // Scroll to the bottom after sending the message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
    } finally {
      setState(() {
        _isUploading = false; // Stop uploading
      });
    }
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        if (_isUploading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CircularProgressIndicator(), // Show loading indicator
          )
        else
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickAndSendImage, // Call the image picker function
          ),
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send),
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final shopProvider = Provider.of<ShopProvider>(context);
    final userId = userProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<ShopModel?>(
          future: shopProvider.getShopById(widget.chatId),
          builder: (context, snapshot) {
            return Text(snapshot.data?.name ?? 'Chat');
          },
        ),
        actions: [
          if (_canSendAgreement) // Only for service providers
            IconButton(
              onPressed: _sendAgreement,
              icon: const Icon(Icons.assignment),
              tooltip: 'Send Agreement',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.getMessagesForChat(widget.chatId);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index]; // Display messages in natural order
                    final isMe = message.senderId == userId;

                    if (message.isAgreement) {
                      return Column(
                        crossAxisAlignment:
                            isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              message.content,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          if (message.agreementAccepted == null && !isMe)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () => _acceptAgreement(message.id),
                                  child: const Text('Accept'),
                                ),
                                TextButton(
                                  onPressed: () => _rejectAgreement(message.id),
                                  child: const Text('Reject'),
                                ),
                              ],
                            ),
                          if (message.agreementAccepted != null)
                            Column(
                              crossAxisAlignment:
                                  isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.agreementAccepted == true
                                      ? 'Agreement Accepted'
                                      : 'Agreement Rejected',
                                  style: TextStyle(
                                    color:
                                        message.agreementAccepted == true
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                if (message.agreementAccepted == true && !isMe)
                                  GestureDetector(
                                    onTap: () => _showRatingPopup(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue, // Background color
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ), // Rounded corners
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withAlpha(
                                              (0.3 * 255).toInt(),
                                            ), // Shadow color
                                            spreadRadius: 1,
                                            blurRadius: 3,
                                            offset: const Offset(
                                              0,
                                              2,
                                            ), // Shadow position
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'Add Rating and Comment',
                                        style: TextStyle(
                                          color: Colors.white, // Text color
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      );
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isMe
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft:
                                isMe ? const Radius.circular(20) : Radius.zero,
                            bottomRight:
                                isMe ? Radius.zero : const Radius.circular(20),
                          ),
                        ),
                        child:
                            message.isImage
                                ? Column(
                                  crossAxisAlignment:
                                      isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        message.content,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(
                                        Timestamp.fromDate(message.timestamp),
                                      ),
                                      style: TextStyle(
                                        color:
                                            isMe
                                                ? Colors.white70
                                                : Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                                : Column(
                                  crossAxisAlignment:
                                      isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(
                                        Timestamp.fromDate(message.timestamp),
                                      ),
                                      style: TextStyle(
                                        color:
                                            isMe
                                                ? Colors.white70
                                                : Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.2 * 255).toInt()),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: _buildMessageInput(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
