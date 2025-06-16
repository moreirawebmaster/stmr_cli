import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/stmr_cli.dart';

class CliRunner {
  CliRunner({required final Logger logger}) : _logger = logger;
  final Logger _logger;

  /// Executa o CLI com os argumentos fornecidos
  Future<void> run(final List<String> args) async {
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
        _logger
          ..err('❌ ${e.message}')
          ..info('')
          ..info('Comandos disponíveis:');
        for (final command in commands.keys) {
          _logger.info('  stmr $command');
        }
        _logger
          ..info('')
          ..info('Use "stmr --help" para ver informações detalhadas.');
        return;
      }

      if (results['help'] as bool) {
        _showHelp();
        return;
      }

      if (results['version'] as bool) {
        _logger.info(PubspecUtils.getVersion());
        return;
      }

      if (results.command == null) {
        _logger
          ..info('❌ Nenhum comando especificado.')
          ..info('')
          ..info('Comandos disponíveis:');
        for (final command in commands.keys) {
          _logger.info('  stmr $command');
        }
        _logger
          ..info('')
          ..info('Use "stmr --help" para ver informações detalhadas.');
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

  /// Exibe informações de ajuda detalhadas do CLI
  void _showHelp() {
    _logger
      ..info('')
      ..info('🚀 STMR CLI - Ferramenta para desenvolvimento Flutter')
      ..info('')
      ..info('Uso: stmr <comando> [argumentos]')
      ..info('')
      ..info('Opções globais:')
      ..info('  -h, --help       Mostra esta ajuda')
      ..info('  -v, --version    Mostra a versão do CLI')
      ..info('')
      ..info('Comandos disponíveis:')
      ..info('')
      ..info('  📦 create <projeto>              Cria um novo projeto Flutter')
      ..info('     --name <nome>                 Nome do projeto (substitui "skeleton")')
      ..info('     --org <organizacao>           Organização (padrão: tech.stmr)')
      ..info('')
      ..info('  🧩 feature <modulo>              Cria um novo módulo/feature')
      ..info('     --path <caminho>              Caminho personalizado para o módulo')
      ..info('')
      ..info('  ⚡ generate <tipo> <nome>        Gera componentes individuais')
      ..info('     page <nome>                   Gera uma página (EngineBasePage)')
      ..info('     controller <nome>             Gera um controlador (EngineBaseController)')
      ..info('     repository <nome>             Gera um repositório (interface + implementação)')
      ..info('     dto <nome> <json>             Gera um DTO a partir de JSON')
      ..info('')
      ..info('  🔄 upgrade                       Atualiza o CLI para a versão mais recente')
      ..info('     --force                       Força a reinstalação mesmo se já atualizado')
      ..info('')
      ..info('Exemplos:')
      ..info('  stmr create meu_app --name "Meu App" --org com.empresa')
      ..info('  stmr feature auth --path lib/modules')
      ..info('  stmr generate page login')
      ..info('  stmr generate controller user')
      ..info('  stmr generate repository user')
      ..info('  stmr generate dto user \'{"name": "João", "age": 30}\'')
      ..info('  stmr upgrade --force')
      ..info('')
      ..info('Para mais informações sobre um comando específico:')
      ..info('  stmr <comando> --help')
      ..info('');
  }
}
