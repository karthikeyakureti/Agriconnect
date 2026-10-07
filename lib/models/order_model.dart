import 'user_model.dart';
import 'product_model.dart';

class OrderModel {
  final int id;
  final int buyerId;
  final int farmerId;
  final int productId;
  final double quantity;
  final double totalPrice;
  final String status; // "PENDING", "CONFIRMED", "DELIVERED", "CANCELLED"
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserModel? buyer;
  final UserModel? farmer;
  final ProductModel? product;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.buyer,
    this.farmer,
    this.product,
  });

  String get orderNumber => '#AGI${id.toString().padLeft(4, '0')}';

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isConfirmed => status.toUpperCase() == 'CONFIRMED';
  bool get isDelivered => status.toUpperCase() == 'DELIVERED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      buyerId: json['buyer_id'] ?? 0,
      farmerId: json['farmer_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      buyer: json['buyer'] != null ? UserModel.fromJson(json['buyer']) : null,
      farmer: json['farmer'] != null ? UserModel.fromJson(json['farmer']) : null,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }
}
