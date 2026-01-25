import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class ChatFileHelper {
  /// Pick PDF / DOC
  static Future<File?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.single.path == null) return null;
    return File(result.files.single.path!);
  }

  /// Pick Image or Video
  static Future<File?> pickMedia({
    required bool isVideo,
    ImageSource source = ImageSource.gallery,
  }) async {
    final picker = ImagePicker();

    final picked = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(
            source: source,
            imageQuality: 70,
          );

    if (picked == null) return null;
    return File(picked.path);
  }
}
