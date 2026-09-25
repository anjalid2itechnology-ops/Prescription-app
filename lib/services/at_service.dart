import "dart:convert";
import "package:at_client_mobile/at_client_mobile.dart";
import "package:at_commons/at_commons.dart";

class AtService {
  AtService._internal();
  static final AtService instance = AtService._internal();

  static const String namespace = "prescriptionapp";

  String? get currentAtSign =>
      AtClientManager.getInstance().atClient.getCurrentAtSign();

  AtClient get _atClient => AtClientManager.getInstance().atClient;

  Future<void> initSession({
    required String atSign,
    dynamic atChops,
    dynamic atLookUp,
  }) async {
    // AtClientManager already has current atSign set by AtOnboarding flow.
    // Nothing extra needed here — kept for backward compatibility with callers.
  }

  Future<bool> putJson({
    required String key,
    required Map<String, dynamic> value,
    String? sharedWithAtSign,
    bool isPublic = false,
    Duration? ttl,
  }) async {
    try {
      final atKey = AtKey()
        ..key = key
        ..namespace = namespace
        ..sharedWith = sharedWithAtSign
        ..metadata = (Metadata()
          ..isPublic = isPublic
          ..ttl = ttl?.inMilliseconds ?? 0);

      final jsonString = jsonEncode(value);
      final putResult = await _atClient.put(atKey, jsonString);
      return putResult;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getJson({
    required String key,
    String? sharedByAtSign,
    bool bypassCache = false,
  }) async {
    try {
      final atKey = AtKey()
        ..key = key
        ..namespace = namespace
        ..sharedBy = sharedByAtSign;

      final getResult = await _atClient.get(atKey);
      final value = getResult.value;
      if (value == null) return null;
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllForPrefix({
    required String prefix,
    String? sharedByAtSign,
  }) async {
    try {
      final keys = await _atClient.getAtKeys(
        regex: prefix,
        sharedBy: sharedByAtSign,
      );

      final results = <Map<String, dynamic>>[];
      for (final k in keys) {
        final res = await _atClient.get(k);
        if (res.value != null) {
          results.add(jsonDecode(res.value) as Map<String, dynamic>);
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }

  Future<bool> notifyUpdate({
    required String key,
    required Map<String, dynamic> value,
    required String toAtSign,
  }) async {
    try {
      final atKey = AtKey()
        ..key = key
        ..namespace = namespace
        ..sharedWith = toAtSign;

      final jsonString = jsonEncode(value);
      await _atClient.put(atKey, jsonString);

      await _atClient.notificationService.notify(
        NotificationParams.forUpdate(atKey, value: jsonString),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}