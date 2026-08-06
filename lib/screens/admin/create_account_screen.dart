import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "../../models/user_account.dart";
import "../../services/account_service.dart";
import "../../services/photo_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/avatar_picker.dart";

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  StaffRole _role = StaffRole.doctor;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  int _avatarIndex = 0;
  String? _photoPath;
  bool _busy = false;

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
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill in all required fields.")),
      );
      return;
    }
    setState(() => _busy = true);
    final result = await AccountService().createAccount(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      role: _role,
      specialty: _role == StaffRole.doctor ? _specialtyCtrl.text.trim() : null,
      avatarIndex: _avatarIndex,
      photoPath: _photoPath,
    );
    setState(() => _busy = false);
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${result.name} created successfully!")),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New staff account")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<StaffRole>(
              segments: const [
                ButtonSegment(value: StaffRole.doctor, label: Text("Doctor"), icon: Icon(Icons.medical_services_outlined)),
                ButtonSegment(value: StaffRole.pharmacist, label: Text("Pharmacist"), icon: Icon(Icons.medication_outlined)),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 20),
            Center(
              child: PhotoPickerCircle(
                avatarIndex: _avatarIndex,
                photoPath: _photoPath,
                onTapCamera: () => _pickPhoto(ImageSource.camera),
                onTapGallery: () => _pickPhoto(ImageSource.gallery),
                size: 76,
              ),
            ),
            const SizedBox(height: 12),
            AvatarPickerRow(selected: _avatarIndex, onChanged: (i) => setState(() { _avatarIndex = i; _photoPath = null; })),
            const SizedBox(height: 20),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Full name")),
            const SizedBox(height: 14),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Temporary password"),
            ),
            const SizedBox(height: 14),
            if (_role == StaffRole.doctor)
              TextField(
                controller: _specialtyCtrl,
                decoration: const InputDecoration(labelText: "Specialty"),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}
