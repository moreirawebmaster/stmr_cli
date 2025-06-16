import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/src/version.dart';
import 'package:yaml/yaml.dart';

/// Utilitários para trabalhar com pubspec.yaml
class PubspecUtils {
  /// Obtém a versão do CLI de forma simples
  static String getVersion() => cliVersion;

  /// Obtém versão do pubspec.yaml (para desenvolvimento)
  static String? getVersionFromPubspec() {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (!pubspecFile.existsSync()) {
        return null;
      }

      final pubspecContent = pubspecFile.readAsStringSync();
      final yaml = loadYaml(pubspecContent) as Map;
      return yaml['version']?.toString();
    } catch (e) {
      return null;
    }
  }

  /// Busca arquivo pubspec.yaml em diretório
  static Future<File?> _searchPubspec(final Directory dir) async {
    final pubspecFile = File('${dir.path}/pubspec.yaml');
    if (pubspecFile.existsSync()) {
      return pubspecFile;
    }
    return null;
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

  static Future<File?> findPubspecFile() async => await _searchPubspec(Directory.current);
}
