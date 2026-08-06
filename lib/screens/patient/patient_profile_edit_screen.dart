import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "../../services/patient_account_service.dart";
import "../../services/photo_service.dart";
import "../../theme/app_theme.dart";
import "../../widgets/avatar_picker.dart";
import "../../widgets/validators.dart";

class PatientProfileEditScreen extends StatefulWidget {
  final String phoneNumber;
  final String currentName;
  final int currentAvatarIndex;
  final String? currentPhotoPath;

  const PatientProfileEditScreen({
    super.key,
    required this.phoneNumber,
    required this.currentName,
    required this.currentAvatarIndex,
    this.currentPhotoPath,
  });

  @override
  State<PatientProfileEditScreen> createState() => _PatientProfileEditScreenState();
}

class _PatientProfileEditScreenState extends State<PatientProfileEditScreen> {
  late final _nameCtrl = TextEditingController(text: widget.currentName);
  late int _avatarIndex = widget.currentAvatarIndex;
  late String? _photoPath = widget.currentPhotoPath;
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
    if (nameErr != null) { setState(() => _error = nameErr); return; }

    setState(() { _busy = true; _error = null; });
    await PatientAccountService().updateProfile(
      phone: widget.phoneNumber,
      name: _nameCtrl.text.trim(),
      avatarIndex: _avatarIndex,
      photoPath: _photoPath,
    );
    setState(() => _busy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated.")));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                enabled: false,
                controller: TextEditingController(text: widget.phoneNumber),
                decoration: const InputDecoration(labelText: "Phone number", prefixIcon: Icon(Icons.phone_outlined)),
              ),
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
