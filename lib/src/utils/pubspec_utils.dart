import 'dart:io';

import 'package:yaml/yaml.dart';

/// Utilitários para trabalhar com pubspec.yaml
class PubspecUtils {
  /// Lê a versão atual do pubspec.yaml
  static String getVersion() {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      throw Exception('Arquivo pubspec.yaml não encontrado');
    }

    final content = pubspecFile.readAsStringSync();
    final yaml = loadYaml(content) as Map;

    final version = yaml['version'] as String?;
    if (version == null || version.isEmpty) {
      throw Exception('Versão não encontrada no pubspec.yaml');
    }

    return version;
  }
}
