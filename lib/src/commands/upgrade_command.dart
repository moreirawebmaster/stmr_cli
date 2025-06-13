import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/lib.dart';

/// Comando responsável por atualizar o CLI para a última versão
class UpgradeCommand implements ICommand {
  /// Construtor que recebe o logger para output
  UpgradeCommand(this._logger);

  final Logger _logger;

  @override
  ArgParser build() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
      ..addFlag('version', abbr: 'v', help: 'Mostra a versão atual')
      ..addFlag('force', abbr: 'f', help: 'Força a atualização mesmo se já estiver na última versão')
      ..addFlag('check', abbr: 'c', help: 'Apenas verifica se há atualizações disponíveis');
  }

  @override
  Future<void> run(ArgResults command) async {
    // Verificar flags primeiro
    if (command['help'] as bool) {
      _showHelp();
      return;
    }

    if (command['version'] as bool) {
      _logger.info(PubspecUtils.getVersion());
      return;
    }

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
      final currentIsNewer = _compareVersions(currentVersion, latestVersion) >= 0;

      if (currentIsNewer && !force) {
        _logger.success('✅ Você já está na última versão!');
        return;
      }

      if (checkOnly) {
        if (!currentIsNewer) {
          _logger.info('🆕 Nova versão disponível: $latestVersion');
          _logger.info('Execute "stmr upgrade" para atualizar.');
        }
        return;
      }

      if (currentIsNewer && force) {
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
      final localVersion = PubspecUtils.getVersion();
      return localVersion;
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

      // Usar sempre a versão mais recente do repositório
      // A detecção de versão serve apenas para informar o usuário
      final installArgs = [
        'pub',
        'global',
        'activate',
        '-s',
        'git',
        'https://github.com/moreirawebmaster/stmr_cli.git',
      ];

      final installResult = await Process.run('dart', installArgs);
      if (installResult.exitCode != 0) {
        throw Exception('Erro ao instalar nova versão: ${installResult.stderr}');
      }

      _logger.info('✅ Instalação concluída!');
    } catch (e) {
      throw Exception('Erro ao realizar upgrade: $e');
    }
  }

  /// Compara duas versões no formato semantic versioning (x.y.z)
  /// Retorna: -1 se v1 < v2, 0 se v1 == v2, 1 se v1 > v2
  int _compareVersions(String v1, String v2) {
    // Remove prefixo 'v' se existir
    final version1 = v1.startsWith('v') ? v1.substring(1) : v1;
    final version2 = v2.startsWith('v') ? v2.substring(1) : v2;

    final parts1 = version1.split('.').map(int.parse).toList();
    final parts2 = version2.split('.').map(int.parse).toList();

    // Garantir que ambas as versões tenham 3 partes
    while (parts1.length < 3) {
      parts1.add(0);
    }
    while (parts2.length < 3) {
      parts2.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }

    return 0;
  }

  /// Mostra informações de ajuda do comando upgrade
  void _showHelp() {
    _logger.info('Comando para atualizar o CLI para a versão mais recente');
    _logger.info('');
    _logger.info('Uso: stmr upgrade [opções]');
    _logger.info('');
    _logger.info('Descrição:');
    _logger.info('  Verifica se há uma nova versão do CLI disponível e atualiza');
    _logger.info('  automaticamente. O CLI é instalado/atualizado globalmente');
    _logger.info('  usando dart pub global.');
    _logger.info('');
    _logger.info('Opções:');
    _logger.info('  -f, --force    Força a reinstalação mesmo na versão atual');
    _logger.info('  -c, --check    Apenas verifica atualizações sem instalar');
    _logger.info('  -h, --help     Mostra esta ajuda');
    _logger.info('  -v, --version  Mostra a versão');
    _logger.info('');
    _logger.info('Exemplos:');
    _logger.info('  stmr upgrade           # Atualiza para a versão mais recente');
    _logger.info('  stmr upgrade --check   # Apenas verifica se há atualizações');
    _logger.info('  stmr upgrade --force   # Força a reinstalação');
    _logger.info('');
    _logger.info('Processo de atualização:');
    _logger.info('  1. Verifica a versão atual instalada');
    _logger.info('  2. Busca a versão mais recente no GitHub');
    _logger.info('  3. Remove a versão atual (se instalada)');
    _logger.info('  4. Instala a nova versão do repositório');
  }
}
