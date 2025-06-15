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
      ..addFlag('version', abbr: 'v', help: 'Mostra a versão do CLI')
      ..addFlag('multiple', abbr: 'm', help: 'Criar estrutura para múltiplas features')
      ..addOption('features', help: 'Lista de features separadas por vírgula (ex: login,register,recovery)');
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

    final moduleName = args.first;
    final moduleNamePascal = ReCase(moduleName).pascalCase;
    final moduleNameSnake = ReCase(moduleName).snakeCase;
    final isMultiple = command['multiple'] as bool;
    final featuresOption = command['features'] as String?;

    // Verificar se estamos em um projeto Flutter
    if (!await _isFlutterProject()) {
      return;
    }

    final modulePath = path.join('lib', 'app', 'modules', moduleNameSnake);

    if (Directory(modulePath).existsSync()) {
      _logger.err('❌ Módulo já existe: $moduleNameSnake');
      return;
    }

    _logger.info('🚀 Criando módulo $moduleNamePascal...');

    try {
      if (isMultiple || featuresOption != null) {
        // Estrutura com múltiplas features
        final features = featuresOption?.split(',').map((e) => e.trim()).toList() ?? [];
        await _createMultipleFeaturesStructure(modulePath, moduleNamePascal, moduleNameSnake, features);
      } else {
        // Estrutura de módulo simples
        await _createSimpleModuleStructure(modulePath, moduleNamePascal, moduleNameSnake);
      }

      _logger.success('✅ Módulo $moduleNamePascal criado com sucesso!');
      _logger.info('');
      if (isMultiple || featuresOption != null) {
        _logger.info('Estrutura criada com múltiplas features:');
        _logger.info('  lib/app/modules/$moduleNameSnake/features/');
      } else {
        _logger.info('Estrutura criada como módulo simples:');
        _logger.info('  lib/app/modules/$moduleNameSnake/');
      }
      _logger.info('');
      _logger.info('Próximos passos:');
      _logger.info('  1. Adicione o módulo ao roteamento');
      _logger.info('  2. stmr generate page <nome_da_page>');
    } catch (e) {
      _logger.err('❌ Erro ao criar módulo: $e');
    }
  }

  /// Cria estrutura de módulo simples
  Future<void> _createSimpleModuleStructure(String modulePath, String moduleNamePascal, String moduleNameSnake) async {
    // Criar estrutura de diretórios
    final directories = [
      path.join(modulePath, 'presentations', 'controllers'),
      path.join(modulePath, 'presentations', 'pages'),
      path.join(modulePath, 'models'),
      path.join(modulePath, 'bindings'),
      path.join(modulePath, 'keys'),
      path.join(modulePath, 'repositories', 'dtos', 'requests'),
      path.join(modulePath, 'repositories', 'dtos', 'responses'),
    ];

    for (final dir in directories) {
      await Directory(dir).create(recursive: true);
    }

    // Criar arquivos do módulo
    await _createModuleFiles(modulePath, moduleNamePascal, moduleNameSnake);
  }

  /// Cria estrutura com múltiplas features
  Future<void> _createMultipleFeaturesStructure(
    String modulePath,
    String moduleNamePascal,
    String moduleNameSnake,
    List<String> features,
  ) async {
    if (features.isEmpty) {
      // Se não especificou features, criar uma estrutura base
      features = ['main'];
    }

    // Criar estrutura base do módulo
    await Directory(path.join(modulePath, 'features')).create(recursive: true);

    // Criar cada feature
    for (final feature in features) {
      final featureNamePascal = ReCase(feature).pascalCase;
      final featureNameSnake = ReCase(feature).snakeCase;
      final featurePath = path.join(modulePath, 'features', featureNameSnake);

      final directories = [
        path.join(featurePath, 'presentations', 'controllers'),
        path.join(featurePath, 'presentations', 'pages'),
        path.join(featurePath, 'models'),
        path.join(featurePath, 'bindings'),
        path.join(featurePath, 'keys'),
        path.join(featurePath, 'repositories', 'dtos', 'requests'),
        path.join(featurePath, 'repositories', 'dtos', 'responses'),
      ];

      for (final dir in directories) {
        await Directory(dir).create(recursive: true);
      }

      // Criar arquivos da feature
      await _createFeatureFiles(featurePath, featureNamePascal, featureNameSnake, moduleNameSnake);
    }
  }

  /// Cria arquivos para módulo simples
  Future<void> _createModuleFiles(String modulePath, String moduleNamePascal, String moduleNameSnake) async {
    // Criar arquivo de binding
    await _createFile(
      path.join(modulePath, 'bindings', '${moduleNameSnake}_binding.dart'),
      FeatureTemplates.binding(moduleNamePascal, moduleNameSnake),
    );

    // Criar arquivo de model
    await _createFile(
      path.join(modulePath, 'models', '${moduleNameSnake}_model.dart'),
      FeatureTemplates.model(moduleNamePascal, moduleNameSnake),
    );

    // Criar arquivo de keys
    await _createFile(
      path.join(modulePath, 'keys', '${moduleNameSnake}_keys.dart'),
      FeatureTemplates.keys(moduleNamePascal, moduleNameSnake),
    );

    // Criar arquivo de tradução
    await _createFile(
      path.join(modulePath, 'keys', '${moduleNameSnake}_translate.dart'),
      FeatureTemplates.translate(moduleNamePascal, moduleNameSnake),
    );

    // Criar controller inicial
    await _createFile(
      path.join(modulePath, 'presentations', 'controllers', '${moduleNameSnake}_controller.dart'),
      FeatureTemplates.controller(moduleNamePascal, moduleNameSnake),
    );

    // Criar page inicial
    await _createFile(
      path.join(modulePath, 'presentations', 'pages', '${moduleNameSnake}_page.dart'),
      FeatureTemplates.page(moduleNamePascal, moduleNameSnake),
    );

    // Criar repository
    await _createFile(
      path.join(modulePath, 'repositories', '${moduleNameSnake}_repository.dart'),
      FeatureTemplates.repository(moduleNamePascal, moduleNameSnake),
    );
  }

  /// Cria arquivos para feature específica
  Future<void> _createFeatureFiles(
    String featurePath,
    String featureNamePascal,
    String featureNameSnake,
    String moduleNameSnake,
  ) async {
    // Criar arquivo de binding
    await _createFile(
      path.join(featurePath, 'bindings', '${featureNameSnake}_binding.dart'),
      FeatureTemplates.binding(featureNamePascal, featureNameSnake),
    );

    // Criar arquivo de model
    await _createFile(
      path.join(featurePath, 'models', '${featureNameSnake}_model.dart'),
      FeatureTemplates.model(featureNamePascal, featureNameSnake),
    );

    // Criar arquivo de keys
    await _createFile(
      path.join(featurePath, 'keys', '${featureNameSnake}_keys.dart'),
      FeatureTemplates.keys(featureNamePascal, featureNameSnake),
    );

    // Criar arquivo de tradução
    await _createFile(
      path.join(featurePath, 'keys', '${featureNameSnake}_translate.dart'),
      FeatureTemplates.translate(featureNamePascal, featureNameSnake),
    );

    // Criar controller inicial
    await _createFile(
      path.join(featurePath, 'presentations', 'controllers', '${featureNameSnake}_controller.dart'),
      FeatureTemplates.controller(featureNamePascal, featureNameSnake),
    );

    // Criar page inicial
    await _createFile(
      path.join(featurePath, 'presentations', 'pages', '${featureNameSnake}_page.dart'),
      FeatureTemplates.page(featureNamePascal, featureNameSnake),
    );

    // Criar repository
    await _createFile(
      path.join(featurePath, 'repositories', '${featureNameSnake}_repository.dart'),
      FeatureTemplates.repository(featureNamePascal, featureNameSnake),
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

  /// Mostra informações de ajuda do comando feature
  void _showHelp() {
    _logger.info('Comando para criar um novo módulo no projeto');
    _logger.info('');
    _logger.info('Uso: stmr feature <nome_do_modulo> [opções]');
    _logger.info('');
    _logger.info('Opções:');
    _logger.info('  -m, --multiple              Criar estrutura para múltiplas features');
    _logger.info('  --features <lista>          Lista de features separadas por vírgula');
    _logger.info('');
    _logger.info('Descrição:');
    _logger.info('  Cria uma estrutura completa de módulo seguindo Clean Architecture:');
    _logger.info('  - presentations/ (controllers/, pages/)');
    _logger.info('  - models/');
    _logger.info('  - bindings/');
    _logger.info('  - keys/ (chaves e traduções)');
    _logger.info('  - repositories/ (com dtos/requests e dtos/responses)');
    _logger.info('');
    _logger.info('Exemplos:');
    _logger.info('  stmr feature auth                           # Módulo simples');
    _logger.info('  stmr feature auth --multiple                # Módulo com estrutura para múltiplas features');
    _logger.info('  stmr feature auth --features login,register,recovery  # Múltiplas features específicas');
    _logger.info('');
    _logger.info('Estrutura Módulo Simples:');
    _logger.info('  lib/app/modules/<modulo>/');
    _logger.info('  ├── presentations/');
    _logger.info('  │   ├── controllers/');
    _logger.info('  │   └── pages/');
    _logger.info('  ├── models/');
    _logger.info('  ├── bindings/');
    _logger.info('  ├── keys/');
    _logger.info('  └── repositories/');
    _logger.info('      └── dtos/');
    _logger.info('          ├── requests/');
    _logger.info('          └── responses/');
    _logger.info('');
    _logger.info('Estrutura Múltiplas Features:');
    _logger.info('  lib/app/modules/<modulo>/');
    _logger.info('  └── features/');
    _logger.info('      ├── <feature1>/');
    _logger.info('      │   ├── presentations/');
    _logger.info('      │   ├── models/');
    _logger.info('      │   ├── bindings/');
    _logger.info('      │   ├── keys/');
    _logger.info('      │   └── repositories/');
    _logger.info('      └── <feature2>/');
    _logger.info('          └── ...');
    _logger.info('');
    _logger.info('Flags:');
    _logger.info('  -h, --help     Mostra esta ajuda');
    _logger.info('  -v, --version  Mostra a versão');
  }
}
