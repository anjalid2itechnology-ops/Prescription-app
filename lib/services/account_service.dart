import "dart:convert";
import "package:http/http.dart" as http;
import "../models/user_account.dart";
import "api_config.dart";
import "auth_storage.dart";

class AccountService {
  Future<UserAccount?> createAccount({
    required String name,
    required String email,
    required String password,
    required StaffRole role,
    String? assignedAtSign,
    String? specialty,
    int avatarIndex = 0,
    String? photoPath,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/accounts/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "role": role.name,
          "specialty": specialty,
          "avatarIndex": avatarIndex,
          "photoPath": photoPath,
        }),
      );
      if (res.statusCode != 200) return null;
      return UserAccount.fromJson(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }

  Future<UserAccount?> login({
    required String email,
    required String password,
    required StaffRole role,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/accounts/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password, "role": role.name}),
      );
      if (res.statusCode != 200) return null;
      final account = UserAccount.fromJson(jsonDecode(res.body));
      if (account.token != null) {
        await AuthStorage.saveToken(account.token!, account.role.name);
      }
      return account;
    } catch (_) {
      return null;
    }
  }

  Future<List<UserAccount>> getAllAccounts() async {
    try {
      final res = await http.get(Uri.parse("${ApiConfig.baseUrl}/accounts"));
      if (res.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((j) => UserAccount.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  List<UserAccount> doctorsOnly(List<UserAccount> all) =>
      all.where((a) => a.role == StaffRole.doctor).toList();

  List<UserAccount> pharmacistsOnly(List<UserAccount> all) =>
      all.where((a) => a.role == StaffRole.pharmacist).toList();

  Future<bool> resetPassword({required String email, required String newPassword}) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/accounts/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<UserAccount?> updateAccount(UserAccount account) async {
    try {
      final res = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/accounts/${account.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(account.toJson()),
      );
      if (res.statusCode != 200) return null;
      return UserAccount.fromJson(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }
}

