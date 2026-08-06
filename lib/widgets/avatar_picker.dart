import "dart:io";
import "package:flutter/material.dart";

class AvatarOption {
  final IconData icon;
  final Color color;
  const AvatarOption(this.icon, this.color);
}

const List<AvatarOption> kAvatarOptions = [
  AvatarOption(Icons.medical_services_rounded, Color(0xFF0F766E)),
  AvatarOption(Icons.local_hospital_rounded, Color(0xFF2563EB)),
  AvatarOption(Icons.favorite_rounded, Color(0xFFF97362)),
  AvatarOption(Icons.psychology_rounded, Color(0xFF7C3AED)),
  AvatarOption(Icons.healing_rounded, Color(0xFF15803D)),
  AvatarOption(Icons.vaccines_rounded, Color(0xFFB45309)),
  AvatarOption(Icons.medication_rounded, Color(0xFFDB2777)),
  AvatarOption(Icons.eco_rounded, Color(0xFF57534E)),
];

class AvatarCircle extends StatelessWidget {
  final int index;
  final String? photoPath;
  final double size;
  const AvatarCircle({super.key, required this.index, this.photoPath, this.size = 44});

  @override
  Widget build(BuildContext context) {
    if (photoPath != null && photoPath!.isNotEmpty && File(photoPath!).existsSync()) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(photoPath!)),
      );
    }
    final opt = kAvatarOptions[index % kAvatarOptions.length];
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: opt.color.withOpacity(0.16),
      child: Icon(opt.icon, color: opt.color, size: size * 0.5),
    );
  }
}

class AvatarPickerRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const AvatarPickerRow({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kAvatarOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final opt = kAvatarOptions[i];
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: opt.color.withOpacity(0.16),
                border: Border.all(color: isSelected ? opt.color : Colors.transparent, width: 2.5),
              ),
              alignment: Alignment.center,
              child: Icon(opt.icon, color: opt.color, size: 26),
            ),
          );
        },
      ),
    );
  }
}

/// A tappable circle that opens a Camera/Gallery/Preset chooser.
class PhotoPickerCircle extends StatelessWidget {
  final int avatarIndex;
  final String? photoPath;
  final VoidCallback onTapCamera;
  final VoidCallback onTapGallery;
  final double size;

  const PhotoPickerCircle({
    super.key,
    required this.avatarIndex,
    required this.photoPath,
    required this.onTapCamera,
    required this.onTapGallery,
    this.size = 84,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            AvatarCircle(index: avatarIndex, photoPath: photoPath, size: size),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showSourceSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Take a photo"),
                onTap: () { Navigator.pop(ctx); onTapCamera(); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from gallery"),
                onTap: () { Navigator.pop(ctx); onTapGallery(); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
