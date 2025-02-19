class Service {
  final String name;
  final String description;
  final double rating;
  final String? image; // Optional image URL or asset path

  Service({
    required this.name,
    required this.description,
    required this.rating,
    this.image, // Make this optional by using `this.image`
  });
}