import 'user_model.dart';

class ProductModel {
  final int id;
  final int farmerId;
  final String name;
  final String category;
  final double quantity; // in kg
  final double pricePerKg; // in INR
  final String? description;
  final String? imageUrl;
  final String? location;
  final String status; // "ACTIVE", "SOLD_OUT", "ARCHIVED"
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? farmer;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.pricePerKg,
    this.description,
    this.imageUrl,
    this.location,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.farmer,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isSoldOut => status.toUpperCase() == 'SOLD_OUT';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      farmerId: json['farmer_id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      imageUrl: json['image_url'],
      location: json['location'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      farmer: json['farmer'] != null ? UserModel.fromJson(json['farmer']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'price_per_kg': pricePerKg,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'status': status,
    };
  }
}
