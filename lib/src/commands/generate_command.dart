import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:stmr_cli/lib.dart';

/// Comando responsável por gerar diversos elementos como pages, controllers, repositories e DTOs
class GenerateCommand implements ICommand {
  /// Construtor que recebe o logger para output
  GenerateCommand(this._logger);

  final Logger _logger;

  @override
  ArgParser build() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
      ..addFlag('version', abbr: 'v', help: 'Mostra a versão do CLI')
      ..addOption('module', abbr: 'm', help: 'Nome do módulo onde gerar o componente')
      ..addOption('feature', abbr: 'f', help: 'Nome da feature (para módulos com múltiplas features)');
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

    final args = command.arguments;

    if (args.isEmpty) {
      _showHelp();
      return;
    }

    final type = args.first.toLowerCase();
    final restArgs = args.skip(1).toList();
    final moduleOption = command['module'] as String?;
    final featureOption = command['feature'] as String?;

    // Validar se o tipo é válido
    if (!['page', 'controller', 'repository', 'dto', 'model', 'binding'].contains(type)) {
      _logger.err('❌ Tipo desconhecido: $type');
      _showHelp();
      return;
    }

    // Verificar se estamos em um projeto Flutter
    if (!await _isFlutterProject()) {
      return;
    }

    // Detectar estrutura do projeto
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
        await _generateDto(restArgs, moduleInfo, featureOption);
        break;
      case 'model':
        await _generateModel(restArgs, moduleInfo, featureOption);
        break;
      case 'binding':
        await _generateBinding(restArgs, moduleInfo, featureOption);
        break;
    }
  }

  /// Detecta a estrutura do módulo (simples ou com features)
  Future<ModuleInfo?> _detectModuleStructure(String? moduleOption) async {
    final modulesDir = Directory('lib/app/modules');
    if (!modulesDir.existsSync()) {
      _logger.err('❌ Diretório de módulos não encontrado: lib/app/modules');
      _logger.info('Execute "stmr feature <nome>" para criar um módulo primeiro');
      return null;
    }

    String? moduleName;

    if (moduleOption != null) {
      // Usar módulo especificado
      moduleName = moduleOption;
    } else {
      // Tentar detectar módulo atual
      final currentDir = Directory.current.path;
      final segments = currentDir.split(path.separator);
      final moduleIndex = segments.lastIndexOf('modules');

      if (moduleIndex != -1 && moduleIndex < segments.length - 1) {
        moduleName = segments[moduleIndex + 1];
      }
    }

    if (moduleName == null) {
      // Listar módulos disponíveis
      final modules = await _listAvailableModules();
      if (modules.isEmpty) {
        _logger.err('❌ Nenhum módulo encontrado');
        _logger.info('Execute "stmr feature <nome>" para criar um módulo');
        return null;
      }

      _logger.err('❌ Módulo não especificado');
      _logger.info('Use a flag --module ou execute dentro de um módulo válido');
      _logger.info('');
      _logger.info('Módulos disponíveis:');
      for (final module in modules) {
        _logger.info('  - $module');
      }
      return null;
    }

    final moduleNameSnake = ReCase(moduleName).snakeCase;
    final modulePath = path.join('lib', 'app', 'modules', moduleNameSnake);

    if (!Directory(modulePath).existsSync()) {
      _logger.err('❌ Módulo não encontrado: $moduleNameSnake');
      final modules = await _listAvailableModules();
      if (modules.isNotEmpty) {
        _logger.info('Módulos disponíveis:');
        for (final module in modules) {
          _logger.info('  - $module');
        }
      }
      return null;
    }

    // Verificar se é módulo simples ou com features
    final featuresDir = Directory(path.join(modulePath, 'features'));
    final hasFeatures = featuresDir.existsSync();

    return ModuleInfo(
      name: moduleName,
      path: modulePath,
      hasFeatures: hasFeatures,
    );
  }

  /// Lista módulos disponíveis
  Future<List<String>> _listAvailableModules() async {
    final modulesDir = Directory('lib/app/modules');
    if (!modulesDir.existsSync()) return [];

    final modules = <String>[];
    await for (final entity in modulesDir.list()) {
      if (entity is Directory) {
        modules.add(path.basename(entity.path));
      }
    }
    return modules;
  }

  /// Gera uma page
  Future<void> _generatePage(List<String> args, ModuleInfo moduleInfo, String? featureOption) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome da page é obrigatório');
      _logger.info('Uso: stmr generate page <nome_da_page>');
      return;
    }

    final pageName = args.first;
    final pageNamePascal = ReCase(pageName).pascalCase;
    final pageNameSnake = ReCase(pageName).snakeCase;

    String targetPath;
    if (moduleInfo.hasFeatures) {
      if (featureOption == null) {
        final features = await _listFeatures(moduleInfo.path);
        if (features.isEmpty) {
          _logger.err('❌ Nenhuma feature encontrada no módulo');
          return;
        }
        _logger.err('❌ Feature é obrigatória para módulos com múltiplas features');
        _logger.info('Use a flag --feature ou especifique a feature');
        _logger.info('Features disponíveis:');
        for (final feature in features) {
          _logger.info('  - $feature');
        }
        return;
      }

      final featureNameSnake = ReCase(featureOption).snakeCase;
      targetPath = path.join(moduleInfo.path, 'features', featureNameSnake);

      if (!Directory(targetPath).existsSync()) {
        _logger.err('❌ Feature não encontrada: $featureNameSnake');
        return;
      }
    } else {
      targetPath = moduleInfo.path;
    }

    final pagePath = path.join(targetPath, 'presentations', 'pages', '${pageNameSnake}_page.dart');

    if (File(pagePath).existsSync()) {
      _logger.err('❌ Page já existe: $pagePath');
      return;
    }

    _logger.info('🚀 Gerando page $pageNamePascal...');

    try {
      // Criar diretório se não existir
      await Directory(path.dirname(pagePath)).create(recursive: true);

      // Criar arquivo da page usando o template adequado
      await _createFile(
        pagePath,
        FeatureTemplates.page(pageNamePascal, pageNameSnake),
      );

      // Gerar controller automaticamente se não existir
      final controllerPath = path.join(targetPath, 'presentations', 'controllers', '${pageNameSnake}_controller.dart');

      if (!File(controllerPath).existsSync()) {
        await Directory(path.dirname(controllerPath)).create(recursive: true);
        await _createFile(
          controllerPath,
          FeatureTemplates.controller(pageNamePascal, pageNameSnake),
        );
      }

      _logger.success('✅ Page $pageNamePascal gerada com sucesso!');
      _logger.info('');
      _logger.info('Arquivos criados:');
      _logger.info('  📄 $pagePath');
      if (!File(controllerPath).existsSync()) {
        _logger.info('  📄 $controllerPath');
      }
    } catch (e) {
      _logger.err('❌ Erro ao gerar page: $e');
    }
  }

  /// Gera um controller
  Future<void> _generateController(List<String> args, ModuleInfo moduleInfo, String? featureOption) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome do controller é obrigatório');
      _logger.info('Uso: stmr generate controller <nome_do_controller>');
      return;
    }

    final controllerName = args.first;
    final controllerNamePascal = ReCase(controllerName).pascalCase;
    final controllerNameSnake = ReCase(controllerName).snakeCase;

    String targetPath;
    if (moduleInfo.hasFeatures) {
      if (featureOption == null) {
        final features = await _listFeatures(moduleInfo.path);
        _logger.err('❌ Feature é obrigatória para módulos com múltiplas features');
        _logger.info('Features disponíveis:');
        for (final feature in features) {
          _logger.info('  - $feature');
        }
        return;
      }

      final featureNameSnake = ReCase(featureOption).snakeCase;
      targetPath = path.join(moduleInfo.path, 'features', featureNameSnake);
    } else {
      targetPath = moduleInfo.path;
    }

    final controllerPath =
        path.join(targetPath, 'presentations', 'controllers', '${controllerNameSnake}_controller.dart');

    if (File(controllerPath).existsSync()) {
      _logger.err('❌ Controller já existe: $controllerPath');
      return;
    }

    _logger.info('🚀 Gerando controller $controllerNamePascal...');

    try {
      await Directory(path.dirname(controllerPath)).create(recursive: true);

      await _createFile(
        controllerPath,
        FeatureTemplates.controller(controllerNamePascal, controllerNameSnake),
      );

      _logger.success('✅ Controller $controllerNamePascal gerado com sucesso!');
      _logger.info('');
      _logger.info('Arquivo criado:');
      _logger.info('  📄 $controllerPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar controller: $e');
    }
  }

  /// Gera um repository
  Future<void> _generateRepository(List<String> args, ModuleInfo moduleInfo, String? featureOption) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome do repository é obrigatório');
      _logger.info('Uso: stmr generate repository <nome_do_repository>');
      return;
    }

    final repositoryName = args.first;
    final repositoryNamePascal = ReCase(repositoryName).pascalCase;
    final repositoryNameSnake = ReCase(repositoryName).snakeCase;

    String targetPath;
    if (moduleInfo.hasFeatures) {
      if (featureOption == null) {
        final features = await _listFeatures(moduleInfo.path);
        _logger.err('❌ Feature é obrigatória para módulos com múltiplas features');
        _logger.info('Features disponíveis:');
        for (final feature in features) {
          _logger.info('  - $feature');
        }
        return;
      }

      final featureNameSnake = ReCase(featureOption).snakeCase;
      targetPath = path.join(moduleInfo.path, 'features', featureNameSnake);
    } else {
      targetPath = moduleInfo.path;
    }

    final repositoryPath = path.join(targetPath, 'repositories', '${repositoryNameSnake}_repository.dart');

    if (File(repositoryPath).existsSync()) {
      _logger.err('❌ Repository já existe: $repositoryPath');
      return;
    }

    _logger.info('🚀 Gerando repository $repositoryNamePascal...');

    try {
      await Directory(path.dirname(repositoryPath)).create(recursive: true);

      await _createFile(
        repositoryPath,
        FeatureTemplates.repository(repositoryNamePascal, repositoryNameSnake),
      );

      _logger.success('✅ Repository $repositoryNamePascal gerado com sucesso!');
      _logger.info('');
      _logger.info('Arquivo criado:');
      _logger.info('  📄 $repositoryPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar repository: $e');
    }
  }

  /// Gera um DTO
  Future<void> _generateDto(List<String> args, ModuleInfo moduleInfo, String? featureOption) async {
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

    Map<String, dynamic> jsonData;
    try {
      jsonData = json.decode(jsonString);
    } catch (e) {
      _logger.err('❌ JSON inválido: $e');
      return;
    }

    String targetPath;
    if (moduleInfo.hasFeatures) {
      if (featureOption == null) {
        final features = await _listFeatures(moduleInfo.path);
        _logger.err('❌ Feature é obrigatória para módulos com múltiplas features');
        _logger.info('Features disponíveis:');
        for (final feature in features) {
          _logger.info('  - $feature');
        }
        return;
      }

      final featureNameSnake = ReCase(featureOption).snakeCase;
      targetPath = path.join(moduleInfo.path, 'features', featureNameSnake);
    } else {
      targetPath = moduleInfo.path;
    }

    // Gerar request e response DTOs
    final requestPath = path.join(targetPath, 'repositories', 'dtos', 'requests', '${dtoNameSnake}_request.dart');
    final responsePath = path.join(targetPath, 'repositories', 'dtos', 'responses', '${dtoNameSnake}_response.dart');

    _logger.info('🚀 Gerando DTOs $dtoNamePascal...');

    try {
      // Criar diretórios
      await Directory(path.dirname(requestPath)).create(recursive: true);
      await Directory(path.dirname(responsePath)).create(recursive: true);

      // Criar request DTO
      await _createFile(
        requestPath,
        GenerateTemplates.dto('${dtoNamePascal}Request', '${dtoNameSnake}_request', jsonData),
      );

      // Criar response DTO
      await _createFile(
        responsePath,
        GenerateTemplates.dto('${dtoNamePascal}Response', '${dtoNameSnake}_response', jsonData),
      );

      _logger.success('✅ DTOs $dtoNamePascal gerados com sucesso!');
      _logger.info('');
      _logger.info('Arquivos criados:');
      _logger.info('  📄 $requestPath');
      _logger.info('  📄 $responsePath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar DTOs: $e');
    }
  }

  /// Gera um model
  Future<void> _generateModel(List<String> args, ModuleInfo moduleInfo, String? featureOption) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome do model é obrigatório');
      _logger.info('Uso: stmr generate model <nome_do_model>');
      return;
    }

    final modelName = args.first;
    final modelNamePascal = ReCase(modelName).pascalCase;
    final modelNameSnake = ReCase(modelName).snakeCase;

    String targetPath;
    if (moduleInfo.hasFeatures) {
      if (featureOption == null) {
        final features = await _listFeatures(moduleInfo.path);
        _logger.err('❌ Feature é obrigatória para módulos com múltiplas features');
        _logger.info('Features disponíveis:');
        for (final feature in features) {
          _logger.info('  - $feature');
        }
        return;
      }

      final featureNameSnake = ReCase(featureOption).snakeCase;
      targetPath = path.join(moduleInfo.path, 'features', featureNameSnake);
    } else {
      targetPath = moduleInfo.path;
    }

    final modelPath = path.join(targetPath, 'models', '${modelNameSnake}_model.dart');

    if (File(modelPath).existsSync()) {
      _logger.err('❌ Model já existe: $modelPath');
      return;
    }

    _logger.info('🚀 Gerando model $modelNamePascal...');

    try {
      await Directory(path.dirname(modelPath)).create(recursive: true);

      await _createFile(
        modelPath,
        FeatureTemplates.model(modelNamePascal, modelNameSnake),
      );

      _logger.success('✅ Model $modelNamePascal gerado com sucesso!');
      _logger.info('');
      _logger.info('Arquivo criado:');
      _logger.info('  📄 $modelPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar model: $e');
    }
  }

  /// Gera um binding
  Future<void> _generateBinding(List<String> args, ModuleInfo moduleInfo, String? featureOption) async {
    if (args.isEmpty) {
      _logger.err('❌ Nome do binding é obrigatório');
      _logger.info('Uso: stmr generate binding <nome_do_binding>');
      return;
    }

    final bindingName = args.first;
    final bindingNamePascal = ReCase(bindingName).pascalCase;
    final bindingNameSnake = ReCase(bindingName).snakeCase;

    String targetPath;
    if (moduleInfo.hasFeatures) {
      if (featureOption == null) {
        final features = await _listFeatures(moduleInfo.path);
        _logger.err('❌ Feature é obrigatória para módulos com múltiplas features');
        _logger.info('Features disponíveis:');
        for (final feature in features) {
          _logger.info('  - $feature');
        }
        return;
      }

      final featureNameSnake = ReCase(featureOption).snakeCase;
      targetPath = path.join(moduleInfo.path, 'features', featureNameSnake);
    } else {
      targetPath = moduleInfo.path;
    }

    final bindingPath = path.join(targetPath, 'bindings', '${bindingNameSnake}_binding.dart');

    if (File(bindingPath).existsSync()) {
      _logger.err('❌ Binding já existe: $bindingPath');
      return;
    }

    _logger.info('🚀 Gerando binding $bindingNamePascal...');

    try {
      await Directory(path.dirname(bindingPath)).create(recursive: true);

      await _createFile(
        bindingPath,
        FeatureTemplates.binding(bindingNamePascal, bindingNameSnake),
      );

      _logger.success('✅ Binding $bindingNamePascal gerado com sucesso!');
      _logger.info('');
      _logger.info('Arquivo criado:');
      _logger.info('  📄 $bindingPath');
    } catch (e) {
      _logger.err('❌ Erro ao gerar binding: $e');
    }
  }

  /// Lista features disponíveis em um módulo
  Future<List<String>> _listFeatures(String modulePath) async {
    final featuresDir = Directory(path.join(modulePath, 'features'));
    if (!featuresDir.existsSync()) return [];

    final features = <String>[];
    await for (final entity in featuresDir.list()) {
      if (entity is Directory) {
        features.add(path.basename(entity.path));
      }
    }
    return features;
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

  /// Mostra informações de ajuda do comando generate
  void _showHelp() {
    _logger.info('Comando para gerar diversos elementos do projeto');
    _logger.info('');
    _logger.info('Uso: stmr generate <tipo> <nome> [opções]');
    _logger.info('');
    _logger.info('Opções:');
    _logger.info('  -m, --module <módulo>    Nome do módulo onde gerar o componente');
    _logger.info('  -f, --feature <feature>  Nome da feature (para módulos com múltiplas features)');
    _logger.info('');
    _logger.info('Tipos disponíveis:');
    _logger.info('  page       - Gera uma nova page com controller automaticamente');
    _logger.info('  controller - Gera um novo controller');
    _logger.info('  repository - Gera um novo repository com interface');
    _logger.info('  dto        - Gera DTOs baseados em JSON (request e response)');
    _logger.info('  model      - Gera um novo model');
    _logger.info('  binding    - Gera um novo binding');
    _logger.info('');
    _logger.info('Exemplos:');
    _logger.info('  # Módulo simples');
    _logger.info('  stmr generate page login --module auth');
    _logger.info('  stmr generate controller user --module profile');
    _logger.info('  stmr generate repository api --module auth');
    _logger.info('');
    _logger.info('  # Módulo com features');
    _logger.info('  stmr generate page login --module auth --feature login');
    _logger.info('  stmr generate controller recovery --module auth --feature recovery');
    _logger.info('');
    _logger.info('  # DTO a partir de JSON');
    _logger.info('  stmr generate dto user \'{"id": 1, "name": "John"}\' --module auth');
    _logger.info('');
    _logger.info('Estrutura de arquivos:');
    _logger.info('  Módulo Simples: lib/app/modules/<módulo>/');
    _logger.info('  Múltiplas Features: lib/app/modules/<módulo>/features/<feature>/');
    _logger.info('');
    _logger.info('Flags:');
    _logger.info('  -h, --help     Mostra esta ajuda');
    _logger.info('  -v, --version  Mostra a versão');
  }
}

/// Informações sobre a estrutura do módulo
class ModuleInfo {
  const ModuleInfo({
    required this.name,
    required this.path,
    required this.hasFeatures,
  });

  final String name;
  final String path;
  final bool hasFeatures;
}
