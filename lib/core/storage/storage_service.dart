import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String keyToken = 'auth_token';
  static const String keyRole = 'user_role';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyServerUrl = 'server_base_url';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveAuthData({
    required String token,
    required String role,
    required int userId,
    required String name,
    String? email,
  }) async {
    await init();
    await _prefs!.setString(keyToken, token);
    await _prefs!.setString(keyRole, role);
    await _prefs!.setInt(keyUserId, userId);
    await _prefs!.setString(keyUserName, name);
    if (email != null) {
      await _prefs!.setString(keyUserEmail, email);
    }
  }

  static String? getToken() {
    return _prefs?.getString(keyToken);
  }

  static String? getRole() {
    return _prefs?.getString(keyRole);
  }

  static int? getUserId() {
    return _prefs?.getInt(keyUserId);
  }

  static String? getUserName() {
    return _prefs?.getString(keyUserName);
  }

  static String? getUserEmail() {
    return _prefs?.getString(keyUserEmail);
  }

  static Future<void> setServerUrl(String url) async {
    await init();
    await _prefs!.setString(keyServerUrl, url.trim());
  }

  static String? getServerUrl() {
    return _prefs?.getString(keyServerUrl);
  }

  static Future<void> resetServerUrl() async {
    await init();
    await _prefs!.remove(keyServerUrl);
  }

  static Future<void> clear() async {
    await init();
    await _prefs!.remove(keyToken);
    await _prefs!.remove(keyRole);
    await _prefs!.remove(keyUserId);
    await _prefs!.remove(keyUserName);
    await _prefs!.remove(keyUserEmail);
  }
}
