import 'dart:io';

import 'package:yaml/yaml.dart';

/// Utilitários para trabalhar com pubspec.yaml
class PubspecUtils {
  /// Lê a versão atual do pubspec.yaml
  static String getVersion() {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) {
        return '1.0.0'; // fallback
      }

      final content = pubspecFile.readAsStringSync();
      final yaml = loadYaml(content) as Map;

      return yaml['version'] as String? ?? '1.0.0';
    } catch (e) {
      return '1.0.0'; // fallback em caso de erro
    }
  }
}
