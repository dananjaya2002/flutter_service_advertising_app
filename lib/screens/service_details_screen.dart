import 'package:flutter/material.dart';
import '../models/service.dart'; // Import your Service model

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the service data passed as an argument
    final Service? service = ModalRoute.of(context)?.settings.arguments as Service?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: service == null
            ? _buildNoDetailsAvailable()
            : _buildServiceDetails(context, service),
      ),
    );
  }

  // Widget for displaying "No details available"
  Widget _buildNoDetailsAvailable() {
    return const Center(
      child: Text(
        'No details available',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  // Widget for displaying service details
  Widget _buildServiceDetails(BuildContext context, Service service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service image or placeholder
        service.image != null
            ? Image.asset(
          service.image!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        )
            : Container(
          width: double.infinity,
          height: 200,
          color: Colors.yellow[100],
          child: const Icon(
            Icons.image,
            size: 50,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),

        // Shop name and rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              service.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.blue),
                const Icon(Icons.star, color: Colors.blue),
                const Icon(Icons.star, color: Colors.blue),
                const Icon(Icons.star, color: Colors.blue),
                const Icon(Icons.star, color: Colors.blue),
                const SizedBox(width: 5),
                Text(
                  '5.0(54)', // Rating hardcoded for now; can be dynamic
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Description
        const Text(
          'Descriptions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          service.description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Action buttons: Call, Chat, Map, Share
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(Icons.call, 'Call'),
            _buildActionButton(Icons.chat, 'Chat'),
            _buildActionButton(Icons.map, 'Map'),
            _buildActionButton(Icons.share, 'Share'),
          ],
        ),
        const SizedBox(height: 16),

        // Service cards (replace with dynamic content)
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildServiceCard('Engine Oil Change'),
              _buildServiceCard('Tire Replacement'),
              _buildServiceCard('Brake Inspection'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reviews Section
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildReview('Nethmina Wickramasinghe', 'Great service and reasonable prices! Highly recommend.', 4),
        _buildReview('Nethmina Wickramasinghe', 'Great service and reasonable prices! Highly recommend.', 4),
        _buildReview('Nethmina Wickramasinghe', 'Great service and reasonable prices! Highly recommend.', 4),
      ],
    );
  }

  // Function to build action buttons (Call, Chat, Map, Share)
  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: () {
            // Add action logic here
          },
        ),
        Text(label),
      ],
    );
  }

  // Function to build service cards
  Widget _buildServiceCard(String serviceName) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50),
            ),
            const SizedBox(height: 8),
            Text(
              serviceName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'High-quality service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build reviews
  Widget _buildReview(String name, String reviewText, int rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: List.generate(
                      rating,
                          (index) => const Icon(Icons.star, color: Colors.blue, size: 18),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(reviewText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
