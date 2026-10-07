import '../storage/storage_service.dart';

class ApiConstants {
  // Public Live API URL (accessible worldwide on Mobile Data, 4G, 5G, or any Wi-Fi via Cloudflare Tunnel)
  static const String publicApiUrl = 'https://june-wellness-configuration-transmitted.trycloudflare.com';

  // Machine local Wi-Fi IP address fallback
  static const String defaultLocalIp = '192.168.137.203';
  static const String defaultPort = '8000';

  // Local Wi-Fi API URL
  static String get localApiUrl => 'http://$defaultLocalIp:$defaultPort';

  // Default base API URL
  static String get defaultBaseUrl {
    return publicApiUrl;
  }

  // Active base API URL (custom preference overrides default)
  static String get baseUrl {
    final customUrl = StorageService.getServerUrl();
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      return customUrl.trim().replaceAll(RegExp(r'/+$'), '');
    }
    return defaultBaseUrl;
  }

  // Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  
  static const String products = '/products';
  static const String productSearch = '/products/search';
  
  static const String orders = '/orders';
  static const String orderStatus = '/orders'; // /orders/{id}/status
  
  static const String messages = '/messages';
  static const String conversations = '/messages/conversations';
  
  static const String uploadImage = '/upload/image';
  static const String users = '/users';
}
