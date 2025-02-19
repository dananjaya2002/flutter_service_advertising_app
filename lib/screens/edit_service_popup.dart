import 'package:flutter/material.dart';
import '../models/service.dart';

class EditServicePopup extends StatefulWidget {
  final List<Service> services;
  final Function(List<Service>) onUpdate;

  const EditServicePopup({super.key, required this.services, required this.onUpdate});

  @override
  _EditServicePopupState createState() => _EditServicePopupState();
}

class _EditServicePopupState extends State<EditServicePopup> {
  late List<Service> services;

  @override
  void initState() {
    super.initState();
    services = List.from(widget.services); // Make a copy of the original list
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Services'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(services[index].name),
                  subtitle: Text(services[index].description),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteService(index),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addService,
              child: const Text('Add Service'),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(services); // Pass the updated services list back
            Navigator.of(context).pop();
          },
          child: const Text('Done'),
        ),
      ],
    );
  }

  void _deleteService(int index) {
    setState(() {
      services.removeAt(index);
    });
  }

  void _addService() {
    setState(() {
      services.add(Service(
        name: 'New Service',
        description: 'Description of the new service',
        rating: 0.0,
      ));
    });
  }
}