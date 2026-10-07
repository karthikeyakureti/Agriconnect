import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiClient {
  static final http.Client _client = http.Client();

  static Map<String, String> _getHeaders({bool isMultipart = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Bypass-Tunnel-Reminder': 'true',
    };
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }

    final token = StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Test connectivity to a specific server URL or the active baseUrl
  static Future<bool> testConnection([String? customUrl]) async {
    try {
      final target = (customUrl ?? ApiConstants.baseUrl).replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$target/health');
      final response = await _client
          .get(uri, headers: {'Bypass-Tunnel-Reminder': 'true', 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client
          .get(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Connection timed out. Cannot reach backend at ${ApiConstants.baseUrl}. Make sure your PC backend is running and phone is on the same Wi-Fi.');
    } on SocketException {
      throw ApiException('Cannot reach backend at ${ApiConstants.baseUrl}. Please check your Wi-Fi and server IP settings.');
    } on http.ClientException {
      throw ApiException('Network error connecting to ${ApiConstants.baseUrl}. Please verify the server is running.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Connection timed out. Cannot reach backend at ${ApiConstants.baseUrl}. Make sure your PC backend is running and phone is on the same Wi-Fi.');
    } on SocketException {
      throw ApiException('Cannot reach backend at ${ApiConstants.baseUrl}. Please check your Wi-Fi and server IP settings.');
    } on http.ClientException {
      throw ApiException('Network error connecting to ${ApiConstants.baseUrl}. Please verify the server is running.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  static Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Connection timed out. Cannot reach backend at ${ApiConstants.baseUrl}. Make sure your PC backend is running and phone is on the same Wi-Fi.');
    } on SocketException {
      throw ApiException('Cannot reach backend at ${ApiConstants.baseUrl}. Please check your Wi-Fi and server IP settings.');
    } on http.ClientException {
      throw ApiException('Network error connecting to ${ApiConstants.baseUrl}. Please verify the server is running.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .delete(uri, headers: _getHeaders())
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Connection timed out. Cannot reach backend at ${ApiConstants.baseUrl}. Make sure your PC backend is running and phone is on the same Wi-Fi.');
    } on SocketException {
      throw ApiException('Cannot reach backend at ${ApiConstants.baseUrl}. Please check your Wi-Fi and server IP settings.');
    } on http.ClientException {
      throw ApiException('Network error connecting to ${ApiConstants.baseUrl}. Please verify the server is running.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected network error occurred: $e');
    }
  }

  static Future<dynamic> uploadFile(String endpoint, List<int> bytes, String filename) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_getHeaders(isMultipart: true));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Upload timed out. Please check your internet connection.');
    } on SocketException {
      throw ApiException('Cannot reach backend at ${ApiConstants.baseUrl}. Please check your connection.');
    } on http.ClientException {
      throw ApiException('Network error connecting to ${ApiConstants.baseUrl}.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Upload error: $e');
    }
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    String errorMessage = 'Request failed with status: ${response.statusCode}';
    bool hasDetail = false;
    try {
      final errorJson = jsonDecode(utf8.decode(response.bodyBytes));
      if (errorJson is Map && errorJson.containsKey('detail')) {
        final detail = errorJson['detail'];
        if (detail is List) {
          // FastAPI 422 validation errors list: [{'loc': [...], 'msg': '...'}]
          errorMessage = detail.map((e) => e is Map ? (e['msg'] ?? e.toString()) : e.toString()).join(', ');
        } else {
          errorMessage = detail.toString();
        }
        hasDetail = true;
      }
    } catch (_) {
      // Use fallback error message
    }

    if (response.statusCode == 400) {
      throw ApiException(hasDetail ? errorMessage : 'Bad request. Please check your input.', 400);
    } else if (response.statusCode == 401) {
      // Clear invalid credentials
      StorageService.clear();
      throw ApiException(hasDetail ? errorMessage : 'Session expired or unauthorized. Please log in again.', 401);
    } else if (response.statusCode == 403) {
      throw ApiException(hasDetail ? errorMessage : 'Access forbidden. You do not have permission for this action.', 403);
    } else if (response.statusCode == 404) {
      throw ApiException(hasDetail ? errorMessage : 'Resource not found.', 404);
    } else if (response.statusCode == 422) {
      throw ApiException(hasDetail ? 'Validation error: $errorMessage' : 'Invalid data format provided.', 422);
    } else if (response.statusCode == 500) {
      throw ApiException('Server error. Please try again later.', 500);
    } else if (response.statusCode == 530 ||
        response.statusCode == 503 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.body.contains('Tunnel Unavailable') ||
        response.body.contains('Origin DNS error')) {
      throw ApiException(
        'Backend server is temporarily unavailable (HTTP ${response.statusCode}). Please check your connection.',
        response.statusCode,
      );
    } else {
      throw ApiException(errorMessage, response.statusCode);
    }
  }
}
