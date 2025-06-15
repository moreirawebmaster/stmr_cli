import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:yaml/yaml.dart';

import '../version.dart';

/// Utilitários para trabalhar com pubspec.yaml
class PubspecUtils {
  /// Obtém a versão do CLI de forma simples
  static String getVersion() {
    return cliVersion; // Usa sempre a versão compilada
  }

  /// Obtém versão do pubspec.yaml (para desenvolvimento)
  static String? getVersionFromPubspec() {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) return null;

      final pubspecContent = pubspecFile.readAsStringSync();
      final yaml = loadYaml(pubspecContent) as Map;
      return yaml['version']?.toString();
    } catch (e) {
      return null;
    }
  }

  /// Obtém versão remota do GitHub
  static Future<String?> getRemoteVersion() async {
    try {
      final result = await Process.run('curl', [
        '-s',
        'https://raw.githubusercontent.com/thiagomoreira/stmr_cli/main/pubspec.yaml',
      ]);

      if (result.exitCode == 0) {
        final yaml = loadYaml(result.stdout) as Map;
        return yaml['version']?.toString();
      }
    } catch (e) {
      Logger().err('Erro ao obter versão remota: $e');
    }
    return null;
  }
}
