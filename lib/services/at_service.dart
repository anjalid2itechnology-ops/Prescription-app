import "dart:convert";
import "package:shared_preferences/shared_preferences.dart";

class AtService {
  AtService._internal();
  static final AtService instance = AtService._internal();

  static const String namespace = "prescriptionapp";
  static const String _prefsKey = "at_service_store_v1";

  Map<String, Map<String, dynamic>> _store = {};
  bool _loaded = false;
  String? _currentAtSign = "@demo";

  String? get currentAtSign => _currentAtSign;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _store = decoded.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_store));
  }

  Future<void> initSession({
    required String atSign,
    dynamic atChops,
    dynamic atLookUp,
  }) async {
    _currentAtSign = atSign.startsWith("@") ? atSign : "@$atSign";
  }

  Future<bool> putJson({
    required String key,
    required Map<String, dynamic> value,
    String? sharedWithAtSign,
    bool isPublic = false,
    Duration? ttl,
  }) async {
    await _ensureLoaded();
    _store[key] = Map<String, dynamic>.from(value);
    await _persist();
    return true;
  }

  Future<Map<String, dynamic>?> getJson({
    required String key,
    String? sharedByAtSign,
    bool bypassCache = false,
  }) async {
    await _ensureLoaded();
    return _store[key];
  }

  Future<List<Map<String, dynamic>>> getAllForPrefix({
    required String prefix,
    String? sharedByAtSign,
  }) async {
    await _ensureLoaded();
    return _store.entries
        .where((e) => e.key.startsWith(prefix))
        .map((e) => e.value)
        .toList();
  }

  Future<bool> notifyUpdate({
    required String key,
    required Map<String, dynamic> value,
    required String toAtSign,
  }) async {
    await _ensureLoaded();
    _store[key] = Map<String, dynamic>.from(value);
    await _persist();
    return true;
  }
}
