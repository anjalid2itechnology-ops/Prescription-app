import "dart:async";
import "package:flutter/material.dart";
import "../services/otp_service.dart";
import "../theme/app_theme.dart";

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber;
  final Future<void> Function() onVerified;

  const OtpVerifyScreen({super.key, required this.phoneNumber, required this.onVerified});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _otpCtrl = TextEditingController();
  final _otpService = OtpService();
  bool _sending = true;
  bool _verifying = false;
  bool _proceeding = false;
  String? _error;
  String? _demoCode;
  int _resendIn = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _send();
  }

  void _send() {
    setState(() { _sending = true; _error = null; _demoCode = null; });
    _otpService.sendOtp(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (code) {
        if (!mounted) return;
        setState(() { _sending = false; _demoCode = code; });
        _startResendTimer();
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() { _sending = false; _error = msg; });
      },
    );
  }

  void _startResendTimer() {
    _resendIn = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    if (_otpCtrl.text.trim().length < 6) {
      setState(() => _error = "Enter the 6-digit code.");
      return;
    }
    setState(() { _verifying = true; _error = null; });
    final ok = await _otpService.verifyOtp(_otpCtrl.text.trim());
    setState(() => _verifying = false);
    if (!ok) {
      setState(() => _error = "Incorrect code. Try again.");
      return;
    }
    setState(() => _proceeding = true);
    await widget.onVerified();
    if (mounted) setState(() => _proceeding = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify your number")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.sms_outlined, size: 44, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text("We sent a 6-digit code to", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(widget.phoneNumber, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 20),
              if (_sending)
                const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
              else ...[
                if (_demoCode != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(color: AppColors.primaryDark, fontSize: 13),
                            children: [
                              const TextSpan(text: "Demo mode — your code is "),
                              TextSpan(text: _demoCode, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(counterText: "", labelText: "6-digit code"),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: (_verifying || _proceeding) ? null : _verify,
                    child: (_verifying || _proceeding)
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Verify"),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: _resendIn <= 0 ? _send : null,
                    child: Text(_resendIn <= 0 ? "Resend code" : "Resend in ${_resendIn}s"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
