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
        errorMessage = errorJson['detail'].toString();
        hasDetail = true;
      }
    } catch (_) {
      // Use fallback error message
    }

    if (response.statusCode == 401) {
      if (hasDetail) {
        throw ApiException(errorMessage, 401);
      }
      throw ApiException('Session expired or unauthorized. Please log in again.', 401);
    } else if (response.statusCode == 403) {
      if (hasDetail) {
        throw ApiException(errorMessage, 403);
      }
      throw ApiException('Access forbidden. You do not have permission for this action.', 403);
    } else if (response.statusCode == 404) {
      throw ApiException(errorMessage, 404);
    } else if (response.statusCode == 530 ||
        response.statusCode == 503 ||
        response.statusCode == 502 ||
        response.statusCode == 504 ||
        response.body.contains('Tunnel Unavailable') ||
        response.body.contains('Origin DNS error')) {
      throw ApiException(
        'Backend server or Cloudflare tunnel is offline (HTTP ${response.statusCode}). Please ensure the backend launcher is running on your PC and check Server Settings.',
        response.statusCode,
      );
    } else {
      throw ApiException(errorMessage, response.statusCode);
    }
  }
}
