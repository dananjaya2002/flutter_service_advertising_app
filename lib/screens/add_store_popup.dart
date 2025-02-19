import 'package:flutter/material.dart';

class AddStorePopup extends StatelessWidget {
  final Function(String) onSubmit;

  const AddStorePopup({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final TextEditingController storeNameController = TextEditingController();
    return AlertDialog(
      title: Text('Add Store'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: storeNameController,
            decoration: InputDecoration(labelText: 'Store Name'),
          ),
          // Add more fields as necessary
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            onSubmit(storeNameController.text); // Pass the store name
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
