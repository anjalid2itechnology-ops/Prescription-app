import "package:flutter/material.dart";
import "../models/user_account.dart";
import "../services/account_service.dart";
import "../services/patient_account_service.dart";
import "../theme/app_theme.dart";
import "../widgets/common_widgets.dart";
import "register_screen.dart";
import "forgot_password_screen.dart";
import "doctor/doctor_dashboard.dart";
import "patient/patient_dashboard.dart";
import "pharmacist/pharmacist_dashboard.dart";
import "admin/admin_dashboard.dart";
import "dart:convert";
import "package:crypto/crypto.dart";

class RoleRouterScreen extends StatefulWidget {
  const RoleRouterScreen({super.key});

  @override
  State<RoleRouterScreen> createState() => _RoleRouterScreenState();
}

enum _Role { doctor, patient, pharmacist, admin }

class _RoleRouterScreenState extends State<RoleRouterScreen> {
  _Role? _role;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  static const _adminPasswordHash =
      "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8";

  String _hash(String s) => sha256.convert(utf8.encode(s.trim())).toString();

  Future<void> _submitStaffLogin(StaffRole staffRole) async {
    setState(() { _busy = true; _error = null; });
    try {
      final account = await AccountService().login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: staffRole,
      );
      if (account == null) {
        setState(() => _error = "Invalid email or password.");
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => staffRole == StaffRole.doctor
            ? DoctorDashboard(account: account)
            : PharmacistDashboard(account: account),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitAdminLogin() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (_hash(_passCtrl.text) != _adminPasswordHash) {
        setState(() => _error = "Invalid admin password.");
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitPatientLogin() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (_phoneCtrl.text.trim().length < 10) {
        setState(() => _error = "Enter a valid phone number.");
        return;
      }
      final ok = await PatientAccountService().verifyLogin(
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (!ok) {
        setState(() => _error = "Invalid phone number or password.");
        return;
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => PatientDashboard(phoneNumber: _phoneCtrl.text.trim()),
      ));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _role == null
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() { _role = null; _error = null; }),
              ),
            ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _role == null ? _roleGrid() : _credentialForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleGrid() {
    final roles = [
      (_Role.doctor, "Doctor", "Write prescriptions & manage patients", Icons.medical_services_rounded, AppColors.doctorTag),
      (_Role.patient, "Patient", "Track your prescriptions & appointments", Icons.person_rounded, AppColors.patientTag),
      (_Role.pharmacist, "Pharmacist", "Dispense orders & manage stock", Icons.medication_rounded, AppColors.pharmacistTag),
      (_Role.admin, "Admin", "Manage clinic staff access", Icons.admin_panel_settings_rounded, AppColors.adminTag),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        FadeSlideIn(
          index: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Continue as", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 30)),
              const SizedBox(height: 6),
              Text("Pick your role to sign in.", style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        ...roles.asMap().entries.map((e) {
          final r = e.value;
          return FadeSlideIn(
            index: e.key + 1,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TapScale(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _role = r.$1),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(color: r.$5.withOpacity(0.14), borderRadius: BorderRadius.circular(15)),
                        alignment: Alignment.center,
                        child: Icon(r.$4, color: r.$5, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5)),
                            const SizedBox(height: 3),
                            Text(r.$3, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _openRegister(RegisterRole role) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterScreen(role: role)));
  }

  void _openForgotPassword(ResetIdentifier id) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForgotPasswordScreen(identifier: id)));
  }

  Widget _credentialForm() {
    Widget body;
    VoidCallback onSubmit;
    IconData icon;
    Color color;
    String title;
    Widget? registerLink;
    Widget? forgotLink;

    switch (_role!) {
      case _Role.doctor:
        body = _emailPasswordFields();
        onSubmit = () => _submitStaffLogin(StaffRole.doctor);
        icon = Icons.medical_services_rounded; color = AppColors.doctorTag; title = "Doctor login";
        registerLink = _linkButton("Don\'t have an account? Register", () => _openRegister(RegisterRole.doctor));
        forgotLink = _linkButton("Forgot password?", () => _openForgotPassword(ResetIdentifier.email));
        break;
      case _Role.pharmacist:
        body = _emailPasswordFields();
        onSubmit = () => _submitStaffLogin(StaffRole.pharmacist);
        icon = Icons.medication_rounded; color = AppColors.pharmacistTag; title = "Pharmacist login";
        registerLink = _linkButton("Don\'t have an account? Register", () => _openRegister(RegisterRole.pharmacist));
        forgotLink = _linkButton("Forgot password?", () => _openForgotPassword(ResetIdentifier.email));
        break;
      case _Role.admin:
        body = TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Admin password", prefixIcon: Icon(Icons.lock_outline_rounded)),
        );
        onSubmit = _submitAdminLogin;
        icon = Icons.admin_panel_settings_rounded; color = AppColors.adminTag; title = "Admin login";
        registerLink = null;
        forgotLink = null;
        break;
      case _Role.patient:
        body = Column(children: [
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Phone number", prefixIcon: Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline_rounded)),
          ),
        ]);
        onSubmit = _submitPatientLogin;
        icon = Icons.person_rounded; color = AppColors.patientTag; title = "Patient login";
        registerLink = _linkButton("Don\'t have an account? Register", () => _openRegister(RegisterRole.patient));
        forgotLink = _linkButton("Forgot password?", () => _openForgotPassword(ResetIdentifier.phone));
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        FadeSlideIn(
          index: 0,
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(18)),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FadeSlideIn(index: 1, child: body),
        if (_error != null) ...[
          const SizedBox(height: 12),
          FadeSlideIn(
            index: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 24),
        FadeSlideIn(
          index: 3,
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _busy ? null : onSubmit,
              child: _busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Continue", style: TextStyle(fontSize: 15.5)),
            ),
          ),
        ),
        if (forgotLink != null) ...[
          const SizedBox(height: 8),
          forgotLink,
        ],
        if (registerLink != null) ...[
          const SizedBox(height: 4),
          registerLink,
        ],
      ],
    );
  }

  Widget _linkButton(String text, VoidCallback onTap) {
    return Center(
      child: TextButton(onPressed: onTap, child: Text(text)),
    );
  }

  Widget _emailPasswordFields() {
    return Column(
      children: [
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline_rounded)),
        ),
      ],
    );
  }
}
