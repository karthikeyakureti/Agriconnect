import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/message_model.dart';

class ApiService {
  // ================= AUTH =================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String role,
    String? location,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'location': location,
      },
    );
    return response as Map<String, dynamic>;
  }

  static Future<UserModel> getMe() async {
    final response = await ApiClient.get(ApiConstants.me);
    return UserModel.fromJson(response);
  }

  static Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? profileImage,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (location != null) body['location'] = location;
    if (profileImage != null) body['profile_image'] = profileImage;

    final response = await ApiClient.put(
      '${ApiConstants.users}/me',
      data: body,
    );
    return UserModel.fromJson(response);
  }

  // ================= PRODUCTS =================
  static Future<List<ProductModel>> getProducts({
    String? category,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? farmerId,
  }) async {
    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      queryParams['category'] = category;
    }
    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice.toString();
    }
    if (farmerId != null) {
      queryParams['farmer_id'] = farmerId.toString();
    }

    final response = await ApiClient.get(ApiConstants.products, queryParams: queryParams);
    final List<dynamic> list = response as List<dynamic>;
    return list.map((item) => ProductModel.fromJson(item)).toList();
  }

  static Future<List<ProductModel>> searchProducts(String query) async {
    final response = await ApiClient.get(
      ApiConstants.productSearch,
      queryParams: {'q': query},
    );
    final List<dynamic> list = response as List<dynamic>;
    return list.map((item) => ProductModel.fromJson(item)).toList();
  }

  static Future<ProductModel> getProduct(int id) async {
    final response = await ApiClient.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(response);
  }

  static Future<ProductModel> createProduct({
    required String name,
    required String category,
    required double quantity,
    required double pricePerKg,
    String? description,
    String? imageUrl,
    String? location,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.products,
      data: {
        'name': name,
        'category': category,
        'quantity': quantity,
        'price_per_kg': pricePerKg,
        'description': description,
        'image_url': imageUrl,
        'location': location,
      },
    );
    return ProductModel.fromJson(response);
  }

  static Future<ProductModel> updateProduct(
    int id, {
    String? name,
    String? category,
    double? quantity,
    double? pricePerKg,
    String? description,
    String? imageUrl,
    String? location,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (category != null) data['category'] = category;
    if (quantity != null) data['quantity'] = quantity;
    if (pricePerKg != null) data['price_per_kg'] = pricePerKg;
    if (description != null) data['description'] = description;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (location != null) data['location'] = location;
    if (status != null) data['status'] = status;

    final response = await ApiClient.put('${ApiConstants.products}/$id', data: data);
    return ProductModel.fromJson(response);
  }

  static Future<void> deleteProduct(int id) async {
    await ApiClient.delete('${ApiConstants.products}/$id');
  }

  // ================= ORDERS =================
  static Future<OrderModel> createOrder({
    required int productId,
    required double quantity,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.orders,
      data: {
        'product_id': productId,
        'quantity': quantity,
      },
    );
    return OrderModel.fromJson(response);
  }

  static Future<List<OrderModel>> getOrders({String? status}) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
      queryParams['status'] = status.toUpperCase();
    }
    final response = await ApiClient.get(ApiConstants.orders, queryParams: queryParams);
    final List<dynamic> list = response as List<dynamic>;
    return list.map((item) => OrderModel.fromJson(item)).toList();
  }

  static Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    final response = await ApiClient.put(
      '${ApiConstants.orders}/$orderId/status',
      data: {'status': status.toUpperCase()},
    );
    return OrderModel.fromJson(response);
  }

  // ================= MESSAGES =================
  static Future<MessageModel> sendMessage({
    required int receiverId,
    required String message,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.messages,
      data: {
        'receiver_id': receiverId,
        'message': message,
      },
    );
    return MessageModel.fromJson(response);
  }

  static Future<List<MessageModel>> getMessages(int userId) async {
    final response = await ApiClient.get('${ApiConstants.messages}/$userId');
    final List<dynamic> list = response as List<dynamic>;
    return list.map((item) => MessageModel.fromJson(item)).toList();
  }

  static Future<List<ConversationSummaryModel>> getConversations() async {
    final response = await ApiClient.get(ApiConstants.conversations);
    final List<dynamic> list = response as List<dynamic>;
    return list.map((item) => ConversationSummaryModel.fromJson(item)).toList();
  }
}
