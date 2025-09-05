import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'file_picker_service.dart';

/// Mobile/Desktop implementation with basic functionality
class MobileFilePickerService implements FilePickerService {
  @override
  Future<Uint8List?> pickImageFile() async {
    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image);
    
    if (result != null && result.files.isNotEmpty) {
      return result.files.first.bytes;
    }
    return null;
  }

  @override
  Future<void> saveFile({required String content, required String filename}) async {
    // Basic file save for desktop platforms
    try {
      final file = File(filename);
      await file.writeAsString(content);
    } catch (e) {
      // Fallback - show in console
      print('File content: $content');
    }
  }
}

/// Factory function for mobile/desktop platforms
FilePickerService createService() => MobileFilePickerService();
