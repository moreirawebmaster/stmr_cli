import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:stmr_cli/lib.dart';

/// Comando responsável por gerar diversos elementos como pages, controllers, repositories e DTOs
class GenerateCommand implements Command {
  /// Construtor que recebe o logger para output
  GenerateCommand(this._logger);

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
      _logger.err('❌ Especifique o que deseja gerar: page, controller, repository, dto');
      _logger.info('Uso: stmr generate <tipo> <nome> [opções]');
      _logger.info('\nTipos disponíveis:');
      _logger.info('  page       - Gera uma nova page com controller');
      _logger.info('  controller - Gera um novo controller');
      _logger.info('  repository - Gera um novo repository com interface');
      _logger.info('  dto        - Gera um novo DTO baseado em JSON');
      return;
    }

    final type = args.first.toLowerCase();
    final restArgs = args.skip(1).toList();

    // Validar se o tipo é válido
    if (!['page', 'controller', 'repository', 'dto'].contains(type)) {
      _logger.err('❌ Tipo desconhecido: $type');
      _logger.info('Tipos disponíveis: page, controller, repository, dto');
      return;
    }

    // Verificar se estamos em um projeto Flutter
    if (!await _isFlutterProject()) {
      return;
    }

    // Verificar se o módulo existe
    final moduleName = await _getModuleName();
    if (moduleName == null) {
      return;
    }

    switch (type) {
      case 'page':
        await _generatePage(restArgs, moduleName);
        break;
      case 'controller':
        await _generateController(restArgs, moduleName);
        break;
      case 'repository':
        await _generateRepository(restArgs, moduleName);
        break;
      case 'dto':
        await _generateDto(restArgs, moduleName);
        break;
    }
  }

  Future<void> _generatePage(List<String> args, String moduleName) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome da page é obrigatório');
      _logger.info('Uso: stmr generate page <nome_da_page>');
      return;
    }

    final pageName = args.first;
    final pageNamePascal = ReCase(pageName).pascalCase;
    final pageNameSnake = ReCase(pageName).snakeCase;
    final moduleNameSnake = ReCase(moduleName).snakeCase;

    final pagePath = path.join(
      'lib',
      'modules',
      moduleNameSnake,
      'presentations',
      'pages',
      '${pageNameSnake}_page.dart',
    );

    if (File(pagePath).existsSync()) {
      _logger.err('❌ Page já existe: $pagePath');
      return;
    }

    _logger.info('🚀 Gerando page $pageNamePascal...');

    try {
      // Criar diretório se não existir
      await FileUtils.createDirectoryRecursive(path.dirname(pagePath));

      // Criar arquivo da page
      await _createFile(
        pagePath,
        GenerateTemplates.page(pageNamePascal, pageNameSnake, moduleNameSnake),
      );

      // Gerar controller automaticamente se não existir
      final controllerPath = path.join(
        'lib',
        'modules',
        moduleNameSnake,
        'presentations',
        'controllers',
        '${pageNameSnake}_controller.dart',
      );

      if (!File(controllerPath).existsSync()) {
        await _generateController([pageName], moduleName);
      }

      _logger.success('✅ Page $pageNamePascal gerada com sucesso!');
      _logger.info('');
      _logger.info('Arquivos criados:');
      _logger.info('  📄 $pagePath');
      _logger.info('  📄 $controllerPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar page: $e');
    }
  }

  Future<void> _generateController(List<String> args, String moduleName) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome do controller é obrigatório');
      _logger.info('Uso: stmr generate controller <nome_do_controller>');
      return;
    }

    final controllerName = args.first;
    final controllerNamePascal = ReCase(controllerName).pascalCase;
    final controllerNameSnake = ReCase(controllerName).snakeCase;
    final moduleNameSnake = ReCase(moduleName).snakeCase;

    final controllerPath = path.join(
      'lib',
      'modules',
      moduleNameSnake,
      'presentations',
      'controllers',
      '${controllerNameSnake}_controller.dart',
    );

    if (File(controllerPath).existsSync()) {
      _logger.err('❌ Controller já existe: $controllerPath');
      return;
    }

    _logger.info('🚀 Gerando controller $controllerNamePascal...');

    try {
      // Criar diretório se não existir
      await FileUtils.createDirectoryRecursive(path.dirname(controllerPath));

      // Criar arquivo do controller
      await _createFile(
        controllerPath,
        GenerateTemplates.controller(controllerNamePascal, controllerNameSnake, moduleNameSnake),
      );

      _logger.success('✅ Controller $controllerNamePascal gerado com sucesso!');
      _logger.info('');
      _logger.info('Arquivo criado:');
      _logger.info('  📄 $controllerPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar controller: $e');
    }
  }

  Future<void> _generateRepository(List<String> args, String moduleName) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome do repository é obrigatório');
      _logger.info('Uso: stmr generate repository <nome_do_repository>');
      return;
    }

    final repositoryName = args.first;
    final repositoryNamePascal = ReCase(repositoryName).pascalCase;
    final repositoryNameSnake = ReCase(repositoryName).snakeCase;
    final moduleNameSnake = ReCase(moduleName).snakeCase;

    final repositoryPath = path.join(
      'lib',
      'modules',
      moduleNameSnake,
      'repositories',
      '${repositoryNameSnake}_repository.dart',
    );

    if (File(repositoryPath).existsSync()) {
      _logger.err('❌ Repository já existe: $repositoryPath');
      return;
    }

    _logger.info('🚀 Gerando repository $repositoryNamePascal...');

    try {
      // Criar diretório se não existir
      await FileUtils.createDirectoryRecursive(path.dirname(repositoryPath));

      // Criar arquivo do repository
      await _createFile(
        repositoryPath,
        GenerateTemplates.repository(repositoryNamePascal, repositoryNameSnake, moduleNameSnake),
      );

      _logger.success('✅ Repository $repositoryNamePascal gerado com sucesso!');
      _logger.info('');
      _logger.info('Arquivo criado:');
      _logger.info('  📄 $repositoryPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar repository: $e');
    }
  }

  Future<void> _generateDto(List<String> args, String moduleName) async {
    if (args.length < 2) {
      _logger.err('❌ Nome do DTO e JSON são obrigatórios');
      _logger.info('Uso: stmr generate dto <nome_do_dto> <json>');
      _logger.info('Exemplo: stmr generate dto user \'{"id": 1, "name": "John"}\'');
      return;
    }

    final dtoName = args.first;
    final dtoNamePascal = ReCase(dtoName).pascalCase;
    final dtoNameSnake = ReCase(dtoName).snakeCase;
    final jsonString = args[1];
    final moduleNameSnake = ReCase(moduleName).snakeCase;

    Map<String, dynamic> jsonData;
    try {
      jsonData = json.decode(jsonString);
    } catch (e) {
      _logger.err('❌ JSON inválido: $e');
      return;
    }

    final dtoPath = path.join(
      'lib',
      'modules',
      moduleNameSnake,
      'repositories',
      'dtos',
      'responses',
      '${dtoNameSnake}_response_dto.dart',
    );

    if (File(dtoPath).existsSync()) {
      _logger.err('❌ DTO já existe: $dtoPath');
      return;
    }

    _logger.info('🚀 Gerando DTO $dtoNamePascal...');

    try {
      // Criar diretório se não existir
      await FileUtils.createDirectoryRecursive(path.dirname(dtoPath));

      // Criar arquivo do DTO
      await _createFile(
        dtoPath,
        GenerateTemplates.dto(dtoNamePascal, dtoNameSnake, jsonData),
      );

      _logger.success('✅ DTO $dtoNamePascal gerado com sucesso!');
      _logger.info('');
      _logger.info('Arquivo criado:');
      _logger.info('  📄 $dtoPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar DTO: $e');
    }
  }

  Future<bool> _isFlutterProject() async {
    if (!File('pubspec.yaml').existsSync()) {
      _logger.err('❌ Não é um projeto Flutter');
      _logger.info('Execute este comando dentro de um projeto Flutter');
      return false;
    }
    return true;
  }

  Future<String?> _getModuleName() async {
    final modulesDir = Directory('lib/modules');
    if (!modulesDir.existsSync()) {
      _logger.err('❌ Diretório de módulos não encontrado');
      _logger.info('Execute este comando dentro de um módulo válido');
      return null;
    }

    final currentDir = Directory.current.path;
    final moduleName = path.basename(currentDir);

    if (!Directory(path.join('lib/modules', moduleName)).existsSync()) {
      _logger.err('❌ Módulo não encontrado: $moduleName');
      _logger.info('Execute este comando dentro de um módulo válido');
      return null;
    }

    return moduleName;
  }

  Future<void> _createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
