import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/lib.dart';

/// Comando responsável por atualizar o CLI para a última versão
class UpgradeCommand implements Command {
  /// Construtor que recebe o logger para output
  UpgradeCommand(this._logger);

  final Logger _logger;

  @override
  ArgParser build() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
      ..addFlag('force', abbr: 'f', help: 'Força a atualização mesmo se já estiver na última versão');
  }

  @override
  Future<void> run(ArgResults command) async {
    final force = command['force'] as bool;

    _logger.info('🔍 Verificando atualizações disponíveis...');

    try {
      // Obter a versão atual
      final currentVersion = await _getCurrentVersion();
      _logger.info('📦 Versão atual: $currentVersion');

      // Obter a última versão disponível
      final latestVersion = await _getLatestVersion();
      _logger.info('📦 Última versão disponível: $latestVersion');

      if (currentVersion == latestVersion && !force) {
        _logger.success('✅ Você já está na última versão!');
        return;
      }

      if (currentVersion == latestVersion && force) {
        _logger.info('🔄 Forçando reinstalação da versão atual...');
      } else {
        _logger.info('🔄 Atualizando para a versão $latestVersion...');
      }

      // Realizar o upgrade
      await _performUpgrade(latestVersion);

      _logger.success('✅ CLI atualizado com sucesso!');
    } catch (e) {
      _logger.err('❌ Erro ao atualizar: $e');
    }
  }

  /// Obtém a versão atual do CLI
  Future<String> _getCurrentVersion() async {
    try {
      final result = await Process.run('stmr', ['--version']);
      if (result.exitCode != 0) {
        throw Exception('Erro ao obter versão atual: ${result.stderr}');
      }
      return result.stdout.toString().trim();
    } catch (e) {
      throw Exception('Erro ao obter versão atual: $e');
    }
  }

  /// Obtém a última versão disponível no repositório
  Future<String> _getLatestVersion() async {
    try {
      // Clonar o repositório temporariamente
      final tempDir = Directory.systemTemp.createTempSync('stmr_upgrade');
      final result = await Process.run(
        'git',
        ['clone', '--depth', '1', 'https://github.com/thiagomoreira/stmr.git', tempDir.path],
      );

      if (result.exitCode != 0) {
        throw Exception('Erro ao clonar repositório: ${result.stderr}');
      }

      // Obter a última tag
      final tagResult = await Process.run(
        'git',
        ['describe', '--tags', '--abbrev=0'],
        workingDirectory: tempDir.path,
      );

      // Limpar o diretório temporário
      await tempDir.delete(recursive: true);

      if (tagResult.exitCode != 0) {
        throw Exception('Erro ao obter última tag: ${tagResult.stderr}');
      }

      return tagResult.stdout.toString().trim();
    } catch (e) {
      throw Exception('Erro ao obter última versão: $e');
    }
  }

  /// Realiza o upgrade do CLI
  Future<void> _performUpgrade(String version) async {
    try {
      // Obter o diretório de instalação do pub
      final pubResult = await Process.run('dart', ['pub', 'global', 'list']);
      if (pubResult.exitCode != 0) {
        throw Exception('Erro ao listar pacotes globais: ${pubResult.stderr}');
      }

      final pubList = pubResult.stdout.toString();
      pubList.split('\n').firstWhere(
            (line) => line.startsWith('stmr_cli'),
            orElse: () => throw Exception('stmr_cli não encontrado nos pacotes globais'),
          );

      // Remover versão atual
      await Process.run('dart', ['pub', 'global', 'deactivate', 'stmr_cli']);

      // Instalar nova versão
      final installResult = await Process.run(
        'dart',
        ['pub', 'global', 'activate', 'stmr_cli', '--source', 'git', '--git-ref', version],
      );

      if (installResult.exitCode != 0) {
        throw Exception('Erro ao instalar nova versão: ${installResult.stderr}');
      }
    } catch (e) {
      throw Exception('Erro ao realizar upgrade: $e');
    }
  }
}
