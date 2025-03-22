import 'package:flutter/material.dart';
import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: service.image != null
            ? Image.asset(
                service.image!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        title: Text(service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description), // Display the service description
            const SizedBox(height: 4), // Add spacing between description and rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16), // Star icon
                const SizedBox(width: 4), // Add spacing between the star and rating
                Text(
                  service.rating.toStringAsFixed(1), // Display rating with one decimal place
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onFavoriteTap, // Handle favorite toggle or removal
        ),
        onTap: onTap, // Navigate to service details
      ),
    );
  }
}