import 'dart:convert';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  static List<CategoryModel> get defaultCategories => [
    CategoryModel(
      id: '1',
      name: 'Electrician',
      description: 'Professional electrical services and repairs',
      imageUrl: 'assets/icons/electrician.png',
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '2',
      name: 'Plumber',
      description: 'Expert plumbing services and maintenance',
      imageUrl: 'assets/icons/plumber.png',
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '3',
      name: 'Carpenter',
      description: 'Custom woodwork and furniture repairs',
      imageUrl: 'assets/icons/carpenter.png',
      sortOrder: 3,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '4',
      name: 'Painter',
      description: 'Professional painting services',
      imageUrl: 'assets/icons/painter.png',
      sortOrder: 4,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '5',
      name: 'AC Repair',
      description: 'Air conditioning maintenance and repairs',
      imageUrl: 'assets/icons/ac-repair.png',
      sortOrder: 5,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '6',
      name: 'Cleaning',
      description: 'Professional cleaning services',
      imageUrl: 'assets/icons/cleaning.png',
      sortOrder: 6,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '7',
      name: 'Gardening',
      description: 'Expert gardening and landscaping services',
      imageUrl: 'assets/icons/gardening.png',
      sortOrder: 7,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '8',
      name: 'Mason',
      description: 'Professional masonry services',
      imageUrl: 'assets/icons/mason.png',
      sortOrder: 8,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    // Additional Categories
    CategoryModel(
      id: '9',
      name: 'Computer Repair',
      description: 'Expert computer and laptop repair services',
      imageUrl: 'assets/icons/computer-repair.png',
      sortOrder: 9,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '10',
      name: 'Mobile Repair',
      description: 'Professional mobile phone repair services',
      imageUrl: 'assets/icons/mobile-repair.png',
      sortOrder: 10,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '11',
      name: 'Home Appliances',
      description: 'Repair and maintenance of home appliances',
      imageUrl: 'assets/icons/home-appliances.png',
      sortOrder: 11,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '12',
      name: 'Pest Control',
      description: 'Professional pest control services',
      imageUrl: 'assets/icons/pest-control.png',
      sortOrder: 12,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '13',
      name: 'Vehicle Repair',
      description: 'Car and bike repair and maintenance services',
      imageUrl: 'assets/icons/vehicle-repair.png',
      sortOrder: 13,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '14',
      name: 'Tutor',
      description: 'Private tutoring and educational services',
      imageUrl: 'assets/icons/tutor.png',
      sortOrder: 14,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '15',
      name: 'Fitness Trainer',
      description: 'Personal fitness training and coaching',
      imageUrl: 'assets/icons/fitness-trainer.png',
      sortOrder: 15,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '16',
      name: 'Event Planner',
      description: 'Event planning and management services',
      imageUrl: 'assets/icons/event-planner.png',
      sortOrder: 16,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '17',
      name: 'Photography',
      description: 'Professional photography and videography services',
      imageUrl: 'assets/icons/photography.png',
      sortOrder: 17,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '18',
      name: 'Security Services',
      description: 'Professional security and surveillance services',
      imageUrl: 'assets/icons/security-services.png',
      sortOrder: 18,
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  factory CategoryModel.fromJson(String str) =>
      CategoryModel.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      sortOrder: map['sortOrder'] as int,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
