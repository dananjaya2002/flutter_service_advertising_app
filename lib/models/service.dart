class Service {
  final String name;
  final String description;
  final String category;
  final double rating;
  final String? image; // Optional image URL or asset path
  bool isFavorite; // Tracks whether the service is marked as a favorite

  Service({
    required this.name,
    required this.description,
    required this.category,
    required this.rating,
    this.image, // Make this optional by using `this.image`
    this.isFavorite = false, // Default to not favorited
  });
}