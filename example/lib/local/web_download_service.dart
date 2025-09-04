import 'dart:convert';

import 'package:web/web.dart';


class WebDownloadService {

static  Future<void> save({required String body, required String filename}) async {

 String source = base64Encode(utf8.encode(body));
HTMLAnchorElement()
      ..href = 'data:application/octet-stream;base64,$source'
      ..download = filename
      ..click();
  }
}




