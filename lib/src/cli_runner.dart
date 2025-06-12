import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';

import 'commands/commands.dart';

/// Classe principal que executa os comandos do CLI
class StmrCliRunner {
  final Logger _logger = Logger();

  /// Executa o CLI com os argumentos fornecidos
  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addCommand('create')
      ..addCommand('feature')
      ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
      ..addFlag('version', abbr: 'v', help: 'Mostra a versão do CLI');

    try {
      final results = parser.parse(arguments);

      if (results['help'] as bool) {
        _showHelp(parser);
        return;
      }

      if (results['version'] as bool) {
        _showVersion();
        return;
      }

      final command = results.command;
      if (command == null) {
        _showHelp(parser);
        return;
      }

      switch (command.name) {
        case 'create':
          await CreateCommand(_logger).run(command);
          break;
        case 'feature':
          await FeatureCommand(_logger).run(command);
          break;
        default:
          _logger.err('Comando desconhecido: ${command.name}');
          _showHelp(parser);
      }
    } catch (e) {
      _logger.err('Erro: $e');
      exit(1);
    }
  }

  void _showHelp(ArgParser parser) {
    _logger.info('''
🚀 STMR CLI - Official CLI for STMR Flutter projects

Uso: stmr <comando> [argumentos]

Comandos disponíveis:
  create project <nome>     Cria um novo projeto Flutter baseado no skeleton STMR
  feature <nome>            Cria uma nova feature com estrutura completa

Opções:
${parser.usage}

Exemplos:
  stmr create project meu_app
  stmr feature login
  stmr feature dashboard

Para mais informações, visite: https://github.com/moreirawebmaster/stmr_cli
    ''');
  }

  void _showVersion() {
    _logger.info('STMR CLI versão 1.0.0');
  }
}
