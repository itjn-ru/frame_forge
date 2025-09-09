import 'dart:async';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'file_picker_service.dart';

/// Web implementation of file picker using modern web APIs
class WebFilePickerService implements FilePickerService {
  @override
  Future<Uint8List?> pickImageFile() async {
    final Completer<Uint8List?> completer = Completer<Uint8List?>();

    final web.HTMLInputElement input = web.HTMLInputElement();
    input.type = 'file';
    input.accept = 'image/*';

    input.addEventListener(
      'change',
      (web.Event event) {
        final web.FileList? files = input.files;
        if (files == null || files.length == 0) {
          completer.complete(null);
          return;
        }

        final web.File? file = files.item(0);
        if (file == null) {
          completer.complete(null);
          return;
        }

        final web.FileReader reader = web.FileReader();
        reader.addEventListener(
          'loadend',
          (web.Event event) {
            final JSAny? result = reader.result;
            if (result != null && result.isA<JSArrayBuffer>()) {
              final ByteBuffer buffer = (result as JSArrayBuffer).toDart;
              final Uint8List bytes = buffer.asUint8List();
              completer.complete(bytes);
            } else {
              completer.complete(null);
            }
          }.toJS,
        );

        reader.readAsArrayBuffer(file);
      }.toJS,
    );

    input.click();
    return completer.future;
  }

  @override
  Future<void> saveFile({
    required String content,
    required String filename,
  }) async {
    final Uint8List bytes = Uint8List.fromList(content.codeUnits);
    final List<JSUint8Array> arrayParts = <JSUint8Array>[bytes.toJS];
    final web.Blob blob = web.Blob(arrayParts.toJS);
    final String url = web.URL.createObjectURL(blob);

    final web.HTMLAnchorElement anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.click();

    web.URL.revokeObjectURL(url);
  }
}

/// Factory function for web platform
FilePickerService createService() => WebFilePickerService();
