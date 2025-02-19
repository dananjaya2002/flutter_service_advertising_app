import 'package:flutter/material.dart';

class EditItemButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EditItemButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Edit Item'),
    );
  }
}
