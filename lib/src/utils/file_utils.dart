import 'dart:io';

import 'package:stmr_cli/src/utils/string_replacement.dart';

/// Utilitários para manipulação de arquivos
class FileUtils {
  /// Aplica substituições em um arquivo
  static Future<void> applyReplacements(final String filePath, final List<StringReplacement> replacements) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return;
    }

    var content = await file.readAsString();

    for (final replacement in replacements) {
      content = content.replaceAll(replacement.pattern, replacement.replacement);
    }

    await file.writeAsString(content);
  }

  /// Cria um diretório recursivamente
  static Future<void> createDirectoryRecursive(final String path) async {
    await Directory(path).create(recursive: true);
  }

  /// Verifica se um arquivo existe
  static Future<bool> fileExists(final String path) async => File(path).existsSync();

  /// Verifica se um diretório existe
  static Future<bool> directoryExists(final String path) async => Directory(path).existsSync();
}
