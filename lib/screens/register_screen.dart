import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "../models/user_account.dart";
import "../services/account_service.dart";
import "../services/patient_account_service.dart";
import "../services/photo_service.dart";
import "../theme/app_theme.dart";
import "../widgets/common_widgets.dart";
import "../widgets/avatar_picker.dart";
import "doctor/doctor_dashboard.dart";
import "pharmacist/pharmacist_dashboard.dart";
import "patient/patient_dashboard.dart";

enum RegisterRole { doctor, pharmacist, patient }

class RegisterScreen extends StatefulWidget {
  final RegisterRole role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  int _avatarIndex = 0;
  String? _photoPath;
  bool _busy = false;
  String? _error;

  bool get _isPatient => widget.role == RegisterRole.patient;

  Color get _color {
    switch (widget.role) {
      case RegisterRole.doctor: return AppColors.doctorTag;
      case RegisterRole.pharmacist: return AppColors.pharmacistTag;
      case RegisterRole.patient: return AppColors.patientTag;
    }
  }

  String get _title {
    switch (widget.role) {
      case RegisterRole.doctor: return "Doctor registration";
      case RegisterRole.pharmacist: return "Pharmacist registration";
      case RegisterRole.patient: return "Patient registration";
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final path = await PhotoService().pickAndSave(source: source);
      if (path != null) setState(() => _photoPath = path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't access camera/gallery. Check app permissions.")),
        );
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_nameCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      setState(() => _error = "Fill in all required fields.");
      return;
    }
    if (!_isPatient && _emailCtrl.text.trim().isEmpty) {
      setState(() => _error = "Email is required.");
      return;
    }
    if (_isPatient && _phoneCtrl.text.trim().length < 10) {
      setState(() => _error = "Enter a valid phone number.");
      return;
    }

    setState(() { _busy = true; _error = null; });

    if (_isPatient) {
      final ok = await PatientAccountService().register(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        avatarIndex: _avatarIndex,
      );
      setState(() => _busy = false);
      if (!mounted) return;
      if (!ok) {
        setState(() => _error = "An account with this phone number already exists.");
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PatientDashboard(phoneNumber: _phoneCtrl.text.trim())),
        (route) => false,
      );
      return;
    }

    final role = widget.role == RegisterRole.doctor ? StaffRole.doctor : StaffRole.pharmacist;
    final result = await AccountService().createAccount(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      role: role,
      specialty: role == StaffRole.doctor ? _specialtyCtrl.text.trim() : null,
      avatarIndex: _avatarIndex,
      photoPath: _photoPath,
    );
    setState(() => _busy = false);
    if (!mounted) return;
    if (result == null) {
      setState(() => _error = "Something went wrong. Try again.");
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => role == StaffRole.doctor
          ? DoctorDashboard(account: result)
          : PharmacistDashboard(account: result)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: PhotoPickerCircle(
                    avatarIndex: _avatarIndex,
                    photoPath: _photoPath,
                    onTapCamera: () => _pickPhoto(ImageSource.camera),
                    onTapGallery: () => _pickPhoto(ImageSource.gallery),
                    size: 88,
                  ),
                ),
                const SizedBox(height: 14),
                const Text("Or pick a preset icon", textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                AvatarPickerRow(selected: _avatarIndex, onChanged: (i) => setState(() { _avatarIndex = i; _photoPath = null; })),
                const SizedBox(height: 22),
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Full name", prefixIcon: Icon(Icons.badge_outlined))),
                const SizedBox(height: 14),
                if (_isPatient)
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: "Phone number", prefixIcon: Icon(Icons.phone_outlined)),
                  )
                else
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined)),
                  ),
                const SizedBox(height: 14),
                if (!_isPatient && widget.role == RegisterRole.doctor) ...[
                  TextField(controller: _specialtyCtrl, decoration: const InputDecoration(labelText: "Specialty", prefixIcon: Icon(Icons.medical_information_outlined))),
                  const SizedBox(height: 14),
                ],
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline_rounded)),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                    ]),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text("Create account", style: TextStyle(fontSize: 15.5)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
