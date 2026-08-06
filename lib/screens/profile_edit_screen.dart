import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "../models/user_account.dart";
import "../services/account_service.dart";

import "../services/photo_service.dart";
import "../theme/app_theme.dart";
import "../widgets/avatar_picker.dart";
import "../widgets/validators.dart";

class ProfileEditScreen extends StatefulWidget {
  final UserAccount account;
  const ProfileEditScreen({super.key, required this.account});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final _nameCtrl = TextEditingController(text: widget.account.name);
  late final _emailCtrl = TextEditingController(text: widget.account.email);
  late final _specialtyCtrl = TextEditingController(text: widget.account.specialty ?? "");
  late int _avatarIndex = widget.account.avatarIndex;
  late String? _photoPath = widget.account.photoPath;
  bool _busy = false;
  String? _error;

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

  Future<void> _save() async {
    final nameErr = Validators.required(_nameCtrl.text, "Name");
    final emailErr = Validators.email(_emailCtrl.text);
    if (nameErr != null) { setState(() => _error = nameErr); return; }
    if (emailErr != null) { setState(() => _error = emailErr); return; }

    setState(() { _busy = true; _error = null; });
    final updated = UserAccount(
      id: widget.account.id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      passwordHash: widget.account.passwordHash,
      role: widget.account.role,
      specialty: widget.account.role == StaffRole.doctor ? _specialtyCtrl.text.trim() : null,
      atSign: widget.account.atSign,
      createdAt: widget.account.createdAt,
      avatarIndex: _avatarIndex,
      photoPath: _photoPath,
    );
    await AccountService().updateAccount(updated);
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated.")));
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDoctor = widget.account.role == StaffRole.doctor;
    return Scaffold(
      appBar: AppBar(title: const Text("Edit profile")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
              AvatarPickerRow(selected: _avatarIndex, onChanged: (i) => setState(() { _avatarIndex = i; _photoPath = null; })),
              const SizedBox(height: 26),
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Full name", prefixIcon: Icon(Icons.badge_outlined))),
              const SizedBox(height: 14),
              TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined))),
              if (isDoctor) ...[
                const SizedBox(height: 14),
                TextField(controller: _specialtyCtrl, decoration: const InputDecoration(labelText: "Specialty", prefixIcon: Icon(Icons.medical_information_outlined))),
              ],
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Save changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

