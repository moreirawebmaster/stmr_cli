import 'dart:io';

import 'string_replacement.dart';

/// Utilitários para manipulação de arquivos
class FileUtils {
  /// Substitui strings em um arquivo usando uma lista de substituições
  static Future<void> replaceInFile(File file, List<StringReplacement> replacements) async {
    if (!file.existsSync()) return;

    String content = await file.readAsString();

    for (final replacement in replacements) {
      content = content.replaceAll(replacement.from, replacement.to);
    }

    await file.writeAsString(content);
  }

  /// Cria um diretório recursivamente
  static Future<void> createDirectoryRecursive(String path) async {
    await Directory(path).create(recursive: true);
  }

  /// Verifica se um arquivo existe
  static Future<bool> fileExists(String path) async {
    return File(path).existsSync();
  }

  /// Verifica se um diretório existe
  static Future<bool> directoryExists(String path) async {
    return Directory(path).existsSync();
  }
}
