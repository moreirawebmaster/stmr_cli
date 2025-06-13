import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/lib.dart';

/// Runner principal do CLI
class CliRunner {
  /// Construtor que recebe o logger para output
  CliRunner(this._logger);

  final Logger _logger;

  /// Executa o CLI com os argumentos fornecidos
  Future<void> run(List<String> args) async {
    try {
      final parser = ArgParser()
        ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
        ..addFlag('version', abbr: 'v', help: 'Mostra a versão do CLI');

      final commands = <String, ICommand>{
        'create': CreateCommand(_logger),
        'feature': FeatureCommand(_logger),
        'generate': GenerateCommand(_logger),
        'upgrade': UpgradeCommand(_logger),
      };

      for (final command in commands.entries) {
        parser.addCommand(command.key, command.value.build());
      }

      ArgResults results;
      try {
        results = parser.parse(args);
      } on ArgParserException catch (e) {
        _logger.err(e.message);
        _logger.info('\nComandos disponíveis:');
        for (final command in commands.keys) {
          _logger.info('  stmr $command');
        }
        return;
      }

      if (results['help'] as bool) {
        _logger.info(parser.usage);
        return;
      }

      if (results['version'] as bool) {
        _logger.info(PubspecUtils.getVersion());
        return;
      }

      if (results.command == null) {
        _logger.info('Comandos disponíveis:');
        for (final command in commands.keys) {
          _logger.info('  stmr $command');
        }
        return;
      }

      final command = commands[results.command!.name];
      if (command == null) {
        _logger.err('Comando não encontrado: ${results.command!.name}');
        return;
      }

      await command.run(results.command!);
    } catch (e) {
      _logger.err('Erro ao executar comando: $e');
    }
  }
}
