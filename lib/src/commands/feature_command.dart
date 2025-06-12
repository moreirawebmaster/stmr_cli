import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../templates/templates.dart';
import '../utils/utils.dart';

class FeatureCommand {
  final Logger _logger;

  FeatureCommand(this._logger);

  Future<void> run(ArgResults command) async {
    final args = command.arguments;

    if (args.isEmpty) {
      _logger.err('Nome da feature é obrigatório');
      _logger.info('Uso: stmr feature <nome_da_feature>');
      return;
    }

    final featureName = args.first;
    await _createFeature(featureName);
  }

  Future<void> _createFeature(String featureName) async {
    final featureNameSnake = ReCase(featureName).snakeCase;
    final featureNamePascal = ReCase(featureName).pascalCase;
    final featureNameCamel = ReCase(featureName).camelCase;

    final currentDir = Directory.current.path;

    // Verificar se estamos em um projeto Flutter
    if (!File(path.join(currentDir, 'pubspec.yaml')).existsSync()) {
      _logger.err('❌ Este comando deve ser executado na raiz de um projeto Flutter');
      return;
    }

    final featurePath = path.join(currentDir, 'lib', 'modules', featureNameSnake);

    // Verificar se feature já existe
    if (Directory(featurePath).existsSync()) {
      _logger.err('❌ Feature já existe: $featureNameSnake');
      return;
    }

    _logger.info('🚀 Criando feature $featureName...');

    try {
      // Criar estrutura de pastas
      await _createFeatureStructure(featurePath);

      // Criar arquivos da feature
      await _createFeatureFiles(featurePath, featureName, featureNameSnake, featureNamePascal, featureNameCamel);

      // Registrar rotas
      await _registerRoutes(currentDir, featureName, featureNameSnake);

      _logger.success('✅ Feature $featureName criada com sucesso!');
      _logger.info('');
      _logger.info('Arquivos criados:');
      _logger.info('  📁 lib/modules/$featureNameSnake/');
      _logger.info('  📄 Binding, Controller, Pages, UseCase, Repository');
      _logger.info('  🛣️  Rotas registradas automaticamente');
    } catch (e) {
      _logger.err('❌ Erro ao criar feature: $e');

      // Limpar em caso de erro
      if (Directory(featurePath).existsSync()) {
        await Directory(featurePath).delete(recursive: true);
      }
    }
  }

  Future<void> _createFeatureStructure(String featurePath) async {
    final directories = [
      'bindings',
      'models',
      'presentations/controllers',
      'presentations/pages',
      'presentations/components',
      'use_cases',
      'repositories/dtos/requests',
      'repositories/dtos/responses',
      'keys',
    ];

    for (final dir in directories) {
      await Directory(path.join(featurePath, dir)).create(recursive: true);
    }
  }

  Future<void> _createFeatureFiles(
    String featurePath,
    String featureName,
    String featureNameSnake,
    String featureNamePascal,
    String featureNameCamel,
  ) async {
    // Binding
    await _createFile(
      path.join(featurePath, 'bindings', '${featureNameSnake}_binding.dart'),
      FeatureTemplates.binding(featureNamePascal, featureNameSnake),
    );

    // Model
    await _createFile(
      path.join(featurePath, 'models', '${featureNameSnake}_model.dart'),
      FeatureTemplates.model(featureNamePascal, featureNameSnake),
    );

    // Controller
    await _createFile(
      path.join(featurePath, 'presentations', 'controllers', '${featureNameSnake}_controller.dart'),
      FeatureTemplates.controller(featureNamePascal, featureNameSnake),
    );

    // Page
    await _createFile(
      path.join(featurePath, 'presentations', 'pages', '${featureNameSnake}_page.dart'),
      FeatureTemplates.page(featureNamePascal, featureNameSnake),
    );

    // UseCase
    await _createFile(
      path.join(featurePath, 'use_cases', '${featureNameSnake}_use_case.dart'),
      FeatureTemplates.useCase(featureNamePascal, featureNameSnake),
    );

    // Repository
    await _createFile(
      path.join(featurePath, 'repositories', '${featureNameSnake}_repository.dart'),
      FeatureTemplates.repository(featureNamePascal, featureNameSnake),
    );

    // Keys
    await _createFile(
      path.join(featurePath, 'keys', '${featureNameSnake}_keys.dart'),
      FeatureTemplates.keys(featureNamePascal, featureNameSnake),
    );
  }

  Future<void> _createFile(String filePath, String content) async {
    final file = File(filePath);
    await file.writeAsString(content);
  }

  Future<void> _registerRoutes(String projectPath, String featureName, String featureNameSnake) async {
    final routesPath = path.join(projectPath, 'lib', 'routes');
    final featureRoutesFile = File(path.join(routesPath, '${featureNameSnake}_routes.dart'));
    final appRoutesFile = File(path.join(routesPath, 'app_routes.dart'));

    // Criar arquivo de rotas da feature
    await featureRoutesFile.writeAsString(FeatureTemplates.routes(featureName, featureNameSnake));

    // Adicionar import e rota no app_routes.dart
    if (appRoutesFile.existsSync()) {
      await _updateAppRoutes(appRoutesFile, featureName, featureNameSnake);
    }
  }

  Future<void> _updateAppRoutes(File appRoutesFile, String featureName, String featureNameSnake) async {
    final content = await appRoutesFile.readAsString();

    // Adicionar import se não existir
    final importLine = "import '${featureNameSnake}_routes.dart';";
    if (!content.contains(importLine)) {
      final lines = content.split('\n');
      final lastImportIndex = lines.lastIndexWhere((line) => line.startsWith('import'));
      if (lastImportIndex != -1) {
        lines.insert(lastImportIndex + 1, importLine);
      }

      // Adicionar rotas na lista
      final routesPattern = RegExp(r'static final routes = \[(.*?)\];', dotAll: true);
      final newContent = lines.join('\n').replaceFirstMapped(routesPattern, (match) {
        final routesContent = match.group(1)!;
        return 'static final routes = [$routesContent\n    ...${ReCase(featureName).pascalCase}Routes.routes,\n  ];';
      });

      await appRoutesFile.writeAsString(newContent);
    }
  }
}
