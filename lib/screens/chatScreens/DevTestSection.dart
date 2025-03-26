import 'package:flutter/material.dart';

class DevTestSection extends StatefulWidget {
  @override
  _DevTestSectionState createState() => _DevTestSectionState();
}

class _DevTestSectionState extends State<DevTestSection> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  // Populate with dummy items to simulate messages.
  List<String> items = List.generate(20, (index) => "Test message $index");

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Helper to add new items to the list.
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      // Insert at beginning since we're reversing the list.
      items.insert(0, _controller.text.trim());
    });
    _controller.clear();
    // Optionally, scroll to the top of the list.
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dev Test Section")),
      body: Column(
        children: [
          // The message list.
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // Mimics chat behavior.
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(items[index]),
                  ),
                );
              },
            ),
          ),
          // Input area.
          Container(
            padding: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 4.0,
              top: 4.0,
            ),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
