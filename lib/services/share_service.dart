import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Pure static service for sharing files via the OS share sheet.
class ShareService {
  ShareService._();

  /// Writes [bytes] to a temporary file named [filename] and opens the OS
  /// share sheet so the user can send it via email, messaging, files, etc.
  static Future<void> sharePdf(Uint8List bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: filename.replaceAll('_', ' ').replaceAll('.pdf', ''),
    );
  }

  /// Writes [jsonString] to a temporary file named [filename] and opens the
  /// OS share sheet so the user can save or send the JSON file.
  static Future<void> shareJson(String jsonString, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(jsonString);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: filename.replaceAll('_', ' ').replaceAll('.json', ''),
    );
  }
}
