class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role; // "FARMER" or "BUYER"
  final String? location;
  final String? profileImage;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.location,
    this.profileImage,
    this.createdAt,
  });

  bool get isFarmer => role.toUpperCase() == 'FARMER';
  bool get isBuyer => role.toUpperCase() == 'BUYER';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'BUYER',
      location: json['location'],
      profileImage: json['profile_image'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'location': location,
      'profile_image': profileImage,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
