import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/lib.dart';
import 'package:version/version.dart';

/// Comando responsável por atualizar o CLI para a última versão
class UpgradeCommand implements ICommand {
  /// Construtor que recebe o logger para output
  UpgradeCommand(this._logger);

  final Logger _logger;

  @override
  ArgParser build() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
      ..addFlag('force', abbr: 'f', help: 'Força a atualização mesmo se já estiver na última versão')
      ..addFlag('check', abbr: 'c', help: 'Apenas verifica se há atualizações disponíveis');
  }

  @override
  Future<void> run(ArgResults command) async {
    final force = command['force'] as bool;
    final checkOnly = command['check'] as bool;

    _logger.info('🔍 Verificando atualizações disponíveis...');

    try {
      // Obter a versão atual
      final currentVersion = await _getCurrentVersion();
      _logger.info('📦 Versão atual: $currentVersion');

      // Obter a última versão disponível
      final latestVersion = await _getLatestVersion();
      _logger.info('📦 Última versão disponível: $latestVersion');

      // Comparar versões
      final current = Version.parse(currentVersion);
      final latest = Version.parse(latestVersion);

      if (current >= latest && !force) {
        _logger.success('✅ Você já está na última versão!');
        return;
      }

      if (checkOnly) {
        if (current < latest) {
          _logger.info('🆕 Nova versão disponível: $latestVersion');
          _logger.info('Execute "stmr upgrade" para atualizar.');
        }
        return;
      }

      if (current >= latest && force) {
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
      // Primeiro, tenta obter a versão pelo comando stmr diretamente
      try {
        final result = await Process.run('stmr', ['--version']);
        if (result.exitCode == 0) {
          return result.stdout.toString().trim();
        }
      } catch (e) {
        // Se não conseguir executar o comando stmr, tenta pegar do pubspec.yaml local
        _logger.warn('⚠️  Comando stmr não encontrado no PATH, verificando versão local...');
      }

      // Se não conseguir executar o comando stmr, tenta pegar do pubspec.yaml local
      final pubspecFile = File('pubspec.yaml');
      if (pubspecFile.existsSync()) {
        final pubspecContent = await pubspecFile.readAsString();
        final versionMatch = RegExp(r'version:\s*(.+)').firstMatch(pubspecContent);
        if (versionMatch != null) {
          return versionMatch.group(1)!.trim();
        }
      }

      // Se não conseguir de forma alguma, tenta verificar se o CLI está instalado globalmente
      final pubGlobalResult = await Process.run('dart', ['pub', 'global', 'list']);
      if (pubGlobalResult.exitCode == 0) {
        final pubList = pubGlobalResult.stdout.toString();
        final stmrMatch = RegExp(r'stmr_cli\s+(.+)').firstMatch(pubList);
        if (stmrMatch != null) {
          return stmrMatch.group(1)!.trim();
        }
      }

      throw Exception('Não foi possível determinar a versão atual do CLI');
    } catch (e) {
      throw Exception('Erro ao obter versão atual: $e');
    }
  }

  /// Obtém a última versão disponível no repositório
  Future<String> _getLatestVersion() async {
    try {
      // Primeiro, tenta obter a última tag remotamente sem clonar
      final remoteTagResult = await Process.run(
        'git',
        ['ls-remote', '--tags', '--sort=-version:refname', 'https://github.com/moreirawebmaster/stmr_cli.git'],
      );

      if (remoteTagResult.exitCode == 0) {
        final output = remoteTagResult.stdout.toString();
        final tagMatches = RegExp(r'refs/tags/v?(\d+\.\d+\.\d+)$', multiLine: true).allMatches(output);
        if (tagMatches.isNotEmpty) {
          final latestTag = tagMatches.first.group(1)!;
          return latestTag;
        }
      }

      // Se não conseguir remotamente, faz clone temporário
      final tempDir = Directory.systemTemp.createTempSync('stmr_upgrade');
      try {
        final result = await Process.run(
          'git',
          ['clone', '--depth', '1', 'https://github.com/moreirawebmaster/stmr_cli.git', tempDir.path],
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

        if (tagResult.exitCode != 0) {
          // Se não houver tags, pega a versão do pubspec.yaml do repositório
          final pubspecFile = File('${tempDir.path}/pubspec.yaml');
          if (pubspecFile.existsSync()) {
            final pubspecContent = await pubspecFile.readAsString();
            final versionMatch = RegExp(r'version:\s*(.+)').firstMatch(pubspecContent);
            if (versionMatch != null) {
              return versionMatch.group(1)!.trim();
            }
          }
          throw Exception('Erro ao obter última tag: ${tagResult.stderr}');
        }

        return tagResult.stdout.toString().trim();
      } finally {
        // Limpar o diretório temporário
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      }
    } catch (e) {
      throw Exception('Erro ao obter última versão: $e');
    }
  }

  /// Realiza o upgrade do CLI
  Future<void> _performUpgrade(String version) async {
    try {
      // Verificar se o pacote está instalado globalmente
      final pubResult = await Process.run('dart', ['pub', 'global', 'list']);
      if (pubResult.exitCode != 0) {
        throw Exception('Erro ao listar pacotes globais: ${pubResult.stderr}');
      }

      final pubList = pubResult.stdout.toString();
      final isInstalled = pubList.split('\n').any((line) => line.startsWith('stmr_cli'));

      if (isInstalled) {
        _logger.info('🗑️  Removendo versão atual...');
        // Remover versão atual
        final deactivateResult = await Process.run('dart', ['pub', 'global', 'deactivate', 'stmr_cli']);
        if (deactivateResult.exitCode != 0) {
          _logger.warn('⚠️  Aviso ao desativar: ${deactivateResult.stderr}');
        }
      } else {
        _logger.info('📦 CLI não está instalado globalmente, instalando...');
      }

      // Instalar nova versão
      _logger.info('⬇️  Instalando versão $version...');

      // Tenta instalar com tag primeiro
      List<String> installArgs = [
        'pub',
        'global',
        'activate',
        'stmr_cli',
        '--source',
        'git',
        'https://github.com/moreirawebmaster/stmr_cli.git',
      ];

      // Se a versão não é a mesma do pubspec.yaml atual, tenta usar a tag
      if (version.startsWith('v')) {
        installArgs.addAll(['--git-ref', version]);
      } else if (version != '1.0.0') {
        installArgs.addAll(['--git-ref', 'v$version']);
      }

      final installResult = await Process.run('dart', installArgs);

      if (installResult.exitCode != 0) {
        // Se falhou com tag, tenta sem tag (versão mais recente)
        _logger.warn('⚠️  Falha ao instalar versão específica, tentando versão mais recente...');
        final fallbackArgs = [
          'pub',
          'global',
          'activate',
          'stmr_cli',
          '--source',
          'git',
          'https://github.com/moreirawebmaster/stmr_cli.git',
        ];

        final fallbackResult = await Process.run('dart', fallbackArgs);
        if (fallbackResult.exitCode != 0) {
          throw Exception('Erro ao instalar nova versão: ${fallbackResult.stderr}');
        }
      }

      _logger.info('✅ Instalação concluída!');
    } catch (e) {
      throw Exception('Erro ao realizar upgrade: $e');
    }
  }
}
