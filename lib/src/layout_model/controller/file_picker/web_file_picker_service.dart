import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'file_picker_service.dart';

/// Web implementation of file picker using modern web APIs
class WebFilePickerService implements FilePickerService {
  @override
  Future<Uint8List?> pickImageFile() async {
    final completer = Completer<Uint8List?>();
    
    final input = web.HTMLInputElement();
    input.type = 'file';
    input.accept = 'image/*';
    
    input.addEventListener('change', (web.Event event) {
      final files = input.files;
      if (files == null || files.length == 0) {
        completer.complete(null);
        return;
      }
      
      final file = files.item(0);
      if (file == null) {
        completer.complete(null);
        return;
      }
      
      final reader = web.FileReader();
      reader.addEventListener('loadend', (web.Event event) {
        final result = reader.result;
        if (result != null && result.isA<JSArrayBuffer>()) {
          final buffer = (result as JSArrayBuffer).toDart;
          final bytes = buffer.asUint8List();
          completer.complete(bytes);
        } else {
          completer.complete(null);
        }
      }.toJS);
      
      reader.readAsArrayBuffer(file);
    }.toJS);
    
    input.click();
    return completer.future;
  }

  @override
  Future<void> saveFile({required String content, required String filename}) async {
    final bytes = Uint8List.fromList(content.codeUnits);
    final arrayParts = <JSUint8Array>[bytes.toJS];
    final blob = web.Blob(arrayParts.toJS);
    final url = web.URL.createObjectURL(blob);
    
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.click();
    
    web.URL.revokeObjectURL(url);
  }
}

/// Factory function for web platform
FilePickerService createService() => WebFilePickerService();
