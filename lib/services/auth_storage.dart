import "package:flutter_secure_storage/flutter_secure_storage.dart";

class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";
  static const _roleKey = "auth_role";

  static Future<void> saveToken(String token, String role) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }
}
