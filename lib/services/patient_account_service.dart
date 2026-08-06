import "dart:convert";
import "package:http/http.dart" as http;
import "api_config.dart";
import "auth_storage.dart";

class PatientAccountService {
  Future<bool> register({
    required String name,
    required String phone,
    required String password,
    int avatarIndex = 0,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/patient-accounts/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "phone": phone, "password": password, "avatarIndex": avatarIndex}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> verifyLogin({required String phone, required String password}) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/patient-accounts/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      if (data["token"] != null) {
        await AuthStorage.saveToken(data["token"], "patient");
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String phone) async {
    try {
      final res = await http.get(Uri.parse("${ApiConfig.baseUrl}/patient-accounts/$phone"));
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile({
    required String phone,
    required String name,
    required int avatarIndex,
    String? photoPath,
  }) async {
    try {
      await http.put(
        Uri.parse("${ApiConfig.baseUrl}/patient-accounts/$phone"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "avatarIndex": avatarIndex, "photoPath": photoPath}),
      );
    } catch (_) {}
  }

  Future<bool> resetPassword({required String phone, required String newPassword}) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/patient-accounts/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "newPassword": newPassword}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

