import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/stmr_cli.dart';

/// Comando responsável por atualizar o CLI para a última versão
class UpgradeCommand implements ICommand {
  /// Cria uma nova instância do comando upgrade
  UpgradeCommand(this._logger);

  /// Logger para output do comando
  final Logger _logger;

  @override
  ArgParser build() => ArgParser()..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda');

  @override
  Future<void> run(final ArgResults command) async {
    if (command['help'] as bool) {
      _showHelp();
      return;
    }

    _logger.info('🔄 Atualizando CLI...');

    try {
      final result = await Process.run(
        'dart',
        ['pub', 'global', 'activate', 'stmr_cli'],
      );

      if (result.exitCode == 0) {
        _logger.info('✅ CLI atualizado com sucesso!');
      } else {
        _logger.err('❌ Erro ao atualizar CLI: ${result.stderr}');
      }
    } catch (e) {
      _logger.err('❌ Erro inesperado: $e');
    }
  }

  /// Mostra informações de ajuda do comando upgrade
  void _showHelp() {
    _logger
      ..info('Comando para atualizar o CLI para a versão mais recente')
      ..info('')
      ..info('Uso: stmr upgrade')
      ..info('')
      ..info('Flags:')
      ..info('  -h, --help     Mostra esta ajuda');
  }
}
