import 'dart:typed_data';

/// Abstract interface for file operations across platforms
abstract class FilePickerService {
  /// Pick an image file and return its bytes
  Future<Uint8List?> pickImageFile();

  /// Save a file with given content and filename
  Future<void> saveFile({required String content, required String filename});
}
