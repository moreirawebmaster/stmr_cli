import 'dart:io';

import 'string_replacement.dart';

class FileUtils {
  static Future<void> replaceInFile(File file, List<StringReplacement> replacements) async {
    if (!file.existsSync()) return;

    String content = await file.readAsString();

    for (final replacement in replacements) {
      content = content.replaceAll(replacement.from, replacement.to);
    }

    await file.writeAsString(content);
  }

  static Future<void> createDirectoryRecursive(String path) async {
    await Directory(path).create(recursive: true);
  }

  static Future<bool> fileExists(String path) async {
    return File(path).existsSync();
  }

  static Future<bool> directoryExists(String path) async {
    return Directory(path).existsSync();
  }
}
