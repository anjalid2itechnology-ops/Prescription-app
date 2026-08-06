import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class RecentlyViewedPatient {
  final String id;
  final String name;
  final String phone;
  RecentlyViewedPatient({required this.id, required this.name, required this.phone});

  Map<String, dynamic> toJson() => {"id": id, "name": name, "phone": phone};
  factory RecentlyViewedPatient.fromJson(Map<String, dynamic> j) =>
      RecentlyViewedPatient(id: j["id"], name: j["name"], phone: j["phone"]);
}

class RecentlyViewedService {
  static const _key = "recently_viewed_patients_v1";
  static const _max = 6;

  Future<List<RecentlyViewedPatient>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => RecentlyViewedPatient.fromJson(jsonDecode(s))).toList();
  }

  Future<void> record(RecentlyViewedPatient patient) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();
    current.removeWhere((p) => p.id == patient.id);
    current.insert(0, patient);
    final trimmed = current.take(_max).toList();
    await prefs.setStringList(_key, trimmed.map((p) => jsonEncode(p.toJson())).toList());
  }
}
