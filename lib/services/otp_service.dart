import "dart:async";
import "dart:math";

class OtpService {
  static String? _currentCode;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String demoCode) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final code = (100000 + Random().nextInt(900000)).toString();
    _currentCode = code;
    onCodeSent(code);
  }

  Future<bool> verifyOtp(String smsCode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return smsCode.trim() == _currentCode;
  }
}
