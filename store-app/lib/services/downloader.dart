import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// Streams an APK to the app's external cache with progress callbacks, so the UI
// can show a real download bar before the install dialog appears.
class Downloader {
  Future<File> download(
    String url,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getExternalCacheDirectories();
    final base = (dir != null && dir.isNotEmpty)
        ? dir.first
        : await getTemporaryDirectory();
    final file = File("${base.path}/$fileName");

    final req = http.Request("GET", Uri.parse(url));
    final res = await http.Client().send(req);
    if (res.statusCode != 200) {
      throw Exception("download ${res.statusCode}");
    }

    final total = res.contentLength ?? 0;
    var received = 0;
    final sink = file.openWrite();
    await for (final chunk in res.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (total > 0) onProgress?.call(received / total);
    }
    await sink.close();
    return file;
  }
}
