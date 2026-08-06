import "dart:io";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";

class PhotoService {
  final _picker = ImagePicker();

  Future<String?> pickAndSave({required ImageSource source}) async {
    final picked = await _picker.pickImage(source: source, maxWidth: 640, imageQuality: 80);
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg";
    final savedPath = "${dir.path}/$fileName";
    await File(picked.path).copy(savedPath);
    return savedPath;
  }
}
