import "package:flutter/material.dart";
import "../services/account_service.dart";
import "../services/patient_account_service.dart";
import "../theme/app_theme.dart";
import "../widgets/validators.dart";

enum ResetIdentifier { email, phone }

class ForgotPasswordScreen extends StatefulWidget {
  final ResetIdentifier identifier;
  const ForgotPasswordScreen({super.key, required this.identifier});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _idCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  bool _done = false;

  Future<void> _submit() async {
    final idError = widget.identifier == ResetIdentifier.email
        ? Validators.email(_idCtrl.text)
        : Validators.phone(_idCtrl.text);
    final passError = Validators.password(_passCtrl.text);
    if (idError != null) { setState(() => _error = idError); return; }
    if (passError != null) { setState(() => _error = passError); return; }

    setState(() { _busy = true; _error = null; });
    bool ok;
    if (widget.identifier == ResetIdentifier.email) {
      ok = await AccountService().resetPassword(email: _idCtrl.text.trim(), newPassword: _passCtrl.text.trim());
    } else {
      ok = await PatientAccountService().resetPassword(phone: _idCtrl.text.trim(), newPassword: _passCtrl.text.trim());
    }
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _error = "No account found with that ${widget.identifier == ResetIdentifier.email ? "email" : "phone number"}.");
      return;
    }
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.identifier == ResetIdentifier.email;
    return Scaffold(
      appBar: AppBar(title: const Text("Reset password")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _done ? _successView() : _formView(isEmail),
        ),
      ),
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
        const SizedBox(height: 16),
        const Text("Password updated", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 8),
        const Text("You can now log in with your new password.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Back to login")),
      ],
    );
  }

  Widget _formView(bool isEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(isEmail ? "Enter your registered email and choose a new password." : "Enter your registered phone number and choose a new password.",
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14.5)),
        const SizedBox(height: 22),
        TextField(
          controller: _idCtrl,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
          decoration: InputDecoration(labelText: isEmail ? "Email" : "Phone number", prefixIcon: Icon(isEmail ? Icons.email_outlined : Icons.phone_outlined)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: "New password", prefixIcon: Icon(Icons.lock_outline_rounded)),
        ),
        if (_error != null) ...[
          const SizedBox(height: 14),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
        ],
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Reset password"),
        ),
      ],
    );
  }
}
