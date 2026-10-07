import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel> _products = [];
  List<ProductModel> _farmerProducts = [];
  ProductModel? _selectedProduct;
  
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ProductModel> get products => _products;
  List<ProductModel> get farmerProducts => _farmerProducts;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    fetchMarketplaceProducts();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    if (query.trim().isEmpty) {
      fetchMarketplaceProducts();
    } else {
      search(query);
    }
  }

  Future<void> fetchMarketplaceProducts({
    double? minPrice,
    double? maxPrice,
    String? location,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final prods = await ApiService.getProducts(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      _products = prods;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      if (!silent) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchFarmerProducts(int farmerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _farmerProducts = await ApiService.getProducts(farmerId: farmerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      fetchMarketplaceProducts();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await ApiService.searchProducts(query.trim());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedProduct = await ApiService.getProduct(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct({
    required String name,
    required String category,
    required double quantity,
    required double pricePerKg,
    String? description,
    String? imageUrl,
    String? location,
    required int farmerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProd = await ApiService.createProduct(
        name: name,
        category: category,
        quantity: quantity,
        pricePerKg: pricePerKg,
        description: description,
        imageUrl: imageUrl,
        location: location,
      );
      _farmerProducts.insert(0, newProd);
      _products.insert(0, newProd);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct({
    required int id,
    String? name,
    String? category,
    double? quantity,
    double? pricePerKg,
    String? description,
    String? imageUrl,
    String? location,
    String? status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await ApiService.updateProduct(
        id,
        name: name,
        category: category,
        quantity: quantity,
        pricePerKg: pricePerKg,
        description: description,
        imageUrl: imageUrl,
        location: location,
        status: status,
      );

      final fIndex = _farmerProducts.indexWhere((p) => p.id == id);
      if (fIndex != -1) _farmerProducts[fIndex] = updated;

      final mIndex = _products.indexWhere((p) => p.id == id);
      if (mIndex != -1) _products[mIndex] = updated;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteProduct(id);
      _farmerProducts.removeWhere((p) => p.id == id);
      _products.removeWhere((p) => p.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
