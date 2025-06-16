import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/stmr_cli.dart';

/// Comando responsável por gerar diversos elementos como pages, controllers, repositories e DTOs
class GenerateCommand implements ICommand {
  /// Cria uma nova instância do comando generate
  GenerateCommand(this._logger);

  /// Logger para output do comando
  final Logger _logger;

  @override
  ArgParser build() => ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
    ..addFlag('version', abbr: 'v', help: 'Mostra a versão do CLI')
    ..addOption('module', abbr: 'm', help: 'Nome do módulo onde gerar o componente')
    ..addOption('feature', abbr: 'f', help: 'Nome da feature (para módulos com múltiplas features)')
    ..addFlag('json', abbr: 'j', help: 'JSON para geração de DTO');

  @override
  Future<void> run(final ArgResults command) async {
    if (command['help'] as bool) {
      _showHelp();
      return;
    }

    if (command['version'] as bool) {
      _logger.info(PubspecUtils.getVersion());
      return;
    }

    final args = command.arguments;

    if (args.isEmpty) {
      _showHelp();
      return;
    }

    final type = args.first.toLowerCase();
    final restArgs = args.skip(1).toList();
    final moduleOption = command['module'] as String?;
    final featureOption = command['feature'] as String?;
    final jsonOption = command['json'] as bool;

    if (!['page', 'controller', 'repository', 'dto', 'model', 'binding'].contains(type)) {
      _logger.err('❌ Tipo desconhecido: $type');
      _showHelp();
      return;
    }

    if (!await _isFlutterProject()) {
      return;
    }

    final moduleInfo = await _detectModuleStructure(moduleOption);
    if (moduleInfo == null) {
      return;
    }

    switch (type) {
      case 'page':
        await _generatePage(restArgs, moduleInfo, featureOption);
        break;
      case 'controller':
        await _generateController(restArgs, moduleInfo, featureOption);
        break;
      case 'repository':
        await _generateRepository(restArgs, moduleInfo, featureOption);
        break;
      case 'dto':
        await _generateDto(restArgs, moduleInfo, featureOption, jsonOption);
        break;
      case 'model':
        await _generateModel(restArgs, moduleInfo, featureOption);
        break;
      case 'binding':
        await _generateBinding(restArgs, moduleInfo, featureOption);
        break;
    }
  }

  Future<bool> _isFlutterProject() async {
    if (!File('pubspec.yaml').existsSync()) {
      _logger
        ..err('❌ Não é um projeto Flutter')
        ..info('Execute este comando dentro de um projeto Flutter');
      return false;
    }
    return true;
  }

  /// Mostra informações de ajuda do comando generate
  void _showHelp() {
    _logger
      ..info('')
      ..info('⚡ Comando GENERATE - Gerar elementos do projeto')
      ..info('')
      ..info('Uso: stmr generate <tipo> <nome> [flags]')
      ..info('')
      ..info('Tipos:')
      ..info('  page        Gera uma página')
      ..info('  controller  Gera um controller')
      ..info('  repository  Gera um repository')
      ..info('  dto         Gera um DTO a partir de JSON')
      ..info('')
      ..info('Flags:')
      ..info('  --module, -m  Especificar módulo')
      ..info('  --json, -j    JSON para geração de DTO')
      ..info('  --help, -h    Mostrar esta ajuda')
      ..info('')
      ..info('Exemplos:')
      ..info('  stmr generate page home')
      ..info('  stmr generate controller user --module auth')
      ..info('  stmr generate dto user --json \'{"name":"string","age":number}\'')
      ..info('');
  }

  Future<ModuleInfo?> _detectModuleStructure(final String? moduleOption) async => ModuleInfo(
        name: moduleOption ?? 'default',
        path: 'lib/app/modules/${moduleOption ?? 'default'}',
        hasFeatures: false,
      );

  Future<void> _generatePage(final List<String> args, final ModuleInfo moduleInfo, final String? featureOption) async {
    // Implementação básica
    _logger.info('Gerando page...');
  }

  Future<void> _generateController(
      final List<String> args, final ModuleInfo moduleInfo, final String? featureOption) async {
    // Implementação básica
    _logger.info('Gerando controller...');
  }

  Future<void> _generateRepository(
      final List<String> args, final ModuleInfo moduleInfo, final String? featureOption) async {
    // Implementação básica
    _logger.info('Gerando repository...');
  }

  Future<void> _generateDto(final List<String> args, final ModuleInfo moduleInfo, final String? featureOption,
          final bool jsonOption) async =>
      _logger.info('Gerando DTO...');

  Future<void> _generateModel(final List<String> args, final ModuleInfo moduleInfo, final String? featureOption) async {
    // Implementação básica
    _logger.info('Gerando model...');
  }

  Future<void> _generateBinding(
      final List<String> args, final ModuleInfo moduleInfo, final String? featureOption) async {
    // Implementação básica
    _logger.info('Gerando binding...');
  }
}

/// Informações sobre a estrutura do módulo
class ModuleInfo {
  /// Cria informações sobre um módulo
  const ModuleInfo({
    required this.name,
    required this.path,
    required this.hasFeatures,
  });

  /// Nome do módulo
  final String name;

  /// Caminho completo do módulo
  final String path;

  /// Se o módulo tem estrutura de features múltiplas
  final bool hasFeatures;
}
