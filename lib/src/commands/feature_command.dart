import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:stmr_cli/lib.dart';

/// Comando responsável por criar um novo módulo no projeto
class FeatureCommand implements ICommand {
  /// Construtor que recebe o logger para output
  FeatureCommand(this._logger);

  final Logger _logger;

  @override
  ArgParser build() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
      ..addFlag('version', abbr: 'v', help: 'Mostra a versão do CLI');
  }

  @override
  Future<void> run(ArgResults command) async {
    final args = command.arguments;

    if (args.isEmpty) {
      _logger.err('❌ Nome do módulo é obrigatório');
      _logger.info('Uso: stmr feature <nome_do_modulo>');
      return;
    }

    final moduleName = args.first;
    final moduleNamePascal = ReCase(moduleName).pascalCase;
    final moduleNameSnake = ReCase(moduleName).snakeCase;

    // Verificar se estamos em um projeto Flutter
    if (!await _isFlutterProject()) {
      return;
    }

    final modulePath = path.join('lib', 'modules', moduleNameSnake);

    if (Directory(modulePath).existsSync()) {
      _logger.err('❌ Módulo já existe: $moduleNameSnake');
      return;
    }

    _logger.info('🚀 Criando módulo $moduleNamePascal...');

    try {
      // Criar estrutura de diretórios
      await _createDirectoryStructure(modulePath);

      // Criar arquivos do módulo
      await _createModuleFiles(modulePath, moduleNamePascal, moduleNameSnake);

      _logger.success('✅ Módulo $moduleNamePascal criado com sucesso!');
      _logger.info('');
      _logger.info('Próximos passos:');
      _logger.info('  1. Adicione o módulo ao roteamento');
      _logger.info('  2. stmr generate page <nome_da_page>');
    } catch (e) {
      _logger.err('❌ Erro ao criar módulo: $e');
    }
  }

  Future<void> _createDirectoryStructure(String modulePath) async {
    final directories = [
      path.join(modulePath, 'presentations', 'pages'),
      path.join(modulePath, 'presentations', 'controllers'),
      path.join(modulePath, 'repositories', 'dtos', 'requests'),
      path.join(modulePath, 'repositories', 'dtos', 'responses'),
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }
  }

  Future<void> _createModuleFiles(
    String modulePath,
    String moduleNamePascal,
    String moduleNameSnake,
  ) async {
    // Criar arquivo de rotas
    await _createFile(
      path.join(modulePath, '${moduleNameSnake}_routes.dart'),
      FeatureTemplates.routes(moduleNamePascal, moduleNameSnake),
    );

    // Criar arquivo de bindings
    await _createFile(
      path.join(modulePath, '${moduleNameSnake}_bindings.dart'),
      FeatureTemplates.bindings(moduleNamePascal, moduleNameSnake),
    );

    // Criar arquivo de constantes
    await _createFile(
      path.join(modulePath, '${moduleNameSnake}_constants.dart'),
      FeatureTemplates.constants(moduleNamePascal),
    );
  }

  Future<bool> _isFlutterProject() async {
    if (!File('pubspec.yaml').existsSync()) {
      _logger.err('❌ Não é um projeto Flutter');
      _logger.info('Execute este comando dentro de um projeto Flutter');
      return false;
    }
    return true;
  }

  Future<void> _createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
