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
        _logger.err('❌ ${e.message}');
        _logger.info('');
        _logger.info('Comandos disponíveis:');
        for (final command in commands.keys) {
          _logger.info('  stmr $command');
        }
        _logger.info('');
        _logger.info('Use "stmr --help" para ver informações detalhadas.');
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
        _logger.info('❌ Nenhum comando especificado.');
        _logger.info('');
        _logger.info('Comandos disponíveis:');
        for (final command in commands.keys) {
          _logger.info('  stmr $command');
        }
        _logger.info('');
        _logger.info('Use "stmr --help" para ver informações detalhadas.');
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
    _logger.info('');
    _logger.info('🚀 STMR CLI - Ferramenta para desenvolvimento Flutter');
    _logger.info('');
    _logger.info('Uso: stmr <comando> [argumentos]');
    _logger.info('');
    _logger.info('Opções globais:');
    _logger.info('  -h, --help       Mostra esta ajuda');
    _logger.info('  -v, --version    Mostra a versão do CLI');
    _logger.info('');
    _logger.info('Comandos disponíveis:');
    _logger.info('');
    _logger.info('  📦 create <projeto>              Cria um novo projeto Flutter');
    _logger.info('     --name <nome>                 Nome do projeto (substitui "skeleton")');
    _logger.info('     --org <organizacao>           Organização (padrão: tech.stmr)');
    _logger.info('');
    _logger.info('  🧩 feature <modulo>              Cria um novo módulo/feature');
    _logger.info('     --path <caminho>              Caminho personalizado para o módulo');
    _logger.info('');
    _logger.info('  ⚡ generate <tipo> <nome>        Gera componentes individuais');
    _logger.info('     page <nome>                   Gera uma página (EngineBasePage)');
    _logger.info('     controller <nome>             Gera um controlador (EngineBaseController)');
    _logger.info('     repository <nome>             Gera um repositório (interface + implementação)');
    _logger.info('     dto <nome> <json>             Gera um DTO a partir de JSON');
    _logger.info('');
    _logger.info('  🔄 upgrade                       Atualiza o CLI para a versão mais recente');
    _logger.info('     --force                       Força a reinstalação mesmo se já atualizado');
    _logger.info('');
    _logger.info('Exemplos:');
    _logger.info('  stmr create meu_app --name "Meu App" --org com.empresa');
    _logger.info('  stmr feature auth --path lib/modules');
    _logger.info('  stmr generate page login');
    _logger.info('  stmr generate controller user');
    _logger.info('  stmr generate repository user');
    _logger.info('  stmr generate dto user \'{"name": "João", "age": 30}\'');
    _logger.info('  stmr upgrade --force');
    _logger.info('');
    _logger.info('Para mais informações sobre um comando específico:');
    _logger.info('  stmr <comando> --help');
    _logger.info('');
  }
}
