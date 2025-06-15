import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';

import '../utils/pubspec_utils.dart';
import 'i_command.dart';

/// Comando responsável por atualizar o CLI para a última versão
class UpgradeCommand implements ICommand {
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
    // Verificar flags primeiro
    if (command['help'] as bool) {
      _showHelp();
      return;
    }

    final force = command['force'] as bool;

    _logger.info('🔍 Verificando por atualizações...');

    final currentVersion = PubspecUtils.getVersion();
    _logger.info('📦 Versão atual: $currentVersion');

    final remoteVersion = await PubspecUtils.getRemoteVersion();
    if (remoteVersion == null) {
      _logger.err('❌ Não foi possível verificar a versão remota.');
      return;
    }

    _logger.info('📦 Versão remota: $remoteVersion');

    if (currentVersion == remoteVersion && !force) {
      _logger.success('✅ Você já está usando a versão mais recente do STMR CLI.');
      return;
    }

    if (force) {
      _logger.info('🔄 Forçando atualização...');
    } else {
      _logger.info('🆕 Nova versão disponível: $remoteVersion');
    }

    _logger.info('⬇️  Atualizando STMR CLI...');

    final result = await Process.run('dart', [
      'pub',
      'global',
      'activate',
      '--source',
      'git',
      'https://github.com/thiagomoreira/stmr_cli.git',
    ]);

    if (result.exitCode == 0) {
      _logger.success('✅ STMR CLI atualizado com sucesso para a versão $remoteVersion!');
    } else {
      _logger.err('❌ Erro ao atualizar STMR CLI:');
      _logger.err(result.stderr.toString());
    }
  }

  /// Mostra informações de ajuda do comando upgrade
  void _showHelp() {
    _logger.info('Comando para atualizar o CLI para a versão mais recente');
    _logger.info('');
    _logger.info('Uso: stmr upgrade [opções]');
    _logger.info('');
    _logger.info('Opções:');
    _logger.info('  -f, --force    Força a reinstalação mesmo na versão atual');
    _logger.info('  -h, --help     Mostra esta ajuda');
    _logger.info('');
    _logger.info('Exemplos:');
    _logger.info('  stmr upgrade           # Atualiza para a versão mais recente');
    _logger.info('  stmr upgrade --force   # Força a reinstalação');
  }
}
