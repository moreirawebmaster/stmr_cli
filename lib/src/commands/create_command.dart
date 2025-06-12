import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';
import 'package:recase/recase.dart';

import '../utils/utils.dart';

class CreateCommand {
  final Logger _logger;

  CreateCommand(this._logger);

  Future<void> run(ArgResults command) async {
    final subcommands = command.arguments;

    if (subcommands.isEmpty) {
      _logger.err('Especifique o que deseja criar: project');
      return;
    }

    switch (subcommands.first) {
      case 'project':
        await _createProject(subcommands.skip(1).toList());
        break;
      default:
        _logger.err('Subcomando desconhecido: ${subcommands.first}');
    }
  }

  Future<void> _createProject(List<String> args) async {
    if (args.isEmpty) {
      _logger.err('Nome do projeto é obrigatório');
      _logger.info('Uso: stmr create project <nome_do_projeto>');
      return;
    }

    final projectName = args.first;
    final projectNameSnake = ReCase(projectName).snakeCase;
    final currentDir = Directory.current.path;
    final projectPath = path.join(currentDir, projectNameSnake);

    // Verificar se já existe
    if (Directory(projectPath).existsSync()) {
      _logger.err('Diretório já existe: $projectNameSnake');
      return;
    }

    _logger.info('🚀 Criando projeto $projectName...');

    try {
      // Clone do skeleton
      _logger.info('📥 Clonando template do skeleton...');
      await _cloneSkeleton(projectPath);

      // Substituir nomes no projeto
      _logger.info('🔄 Configurando projeto...');
      await _configureProject(projectPath, projectName);

      // Instalar dependências
      _logger.info('📦 Instalando dependências...');
      await _installDependencies(projectPath);

      _logger.success('✅ Projeto $projectName criado com sucesso!');
      _logger.info('');
      _logger.info('Para executar o projeto:');
      _logger.info('  cd $projectNameSnake');
      _logger.info('  flutter run');
    } catch (e) {
      _logger.err('❌ Erro ao criar projeto: $e');

      // Limpar diretório em caso de erro
      if (Directory(projectPath).existsSync()) {
        await Directory(projectPath).delete(recursive: true);
      }
    }
  }

  Future<void> _cloneSkeleton(String projectPath) async {
    final result = await run('git', ['clone', 'https://github.com/moreirawebmaster/skeleton.git', projectPath]);

    if (result.exitCode != 0) {
      throw Exception('Falha ao clonar o skeleton');
    }

    // Remover .git
    final gitDir = Directory(path.join(projectPath, '.git'));
    if (gitDir.existsSync()) {
      await gitDir.delete(recursive: true);
    }
  }

  Future<void> _configureProject(String projectPath, String projectName) async {
    final projectNameSnake = ReCase(projectName).snakeCase;
    final projectNamePascal = ReCase(projectName).pascalCase;

    // Lista de arquivos para processar
    final filesToProcess = [
      'pubspec.yaml',
      'lib/main.dart',
      'lib/main_dev.dart',
      'lib/main_prod.dart',
      'android/app/build.gradle',
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner/Info.plist',
      'README.md',
    ];

    for (final filePath in filesToProcess) {
      final file = File(path.join(projectPath, filePath));
      if (file.existsSync()) {
        await FileUtils.replaceInFile(file, [
          StringReplacement('skeleton', projectNameSnake),
          StringReplacement('Skeleton', projectNamePascal),
          StringReplacement('tech.stmr', 'com.${projectNameSnake}'),
        ]);
      }
    }

    // Renomear pasta android se necessário
    await _renameAndroidPackage(projectPath, projectNameSnake);
  }

  Future<void> _renameAndroidPackage(String projectPath, String projectName) async {
    final androidMainPath = path.join(projectPath, 'android', 'app', 'src', 'main', 'java');
    final techDir = Directory(path.join(androidMainPath, 'tech'));

    if (techDir.existsSync()) {
      final newPackagePath = path.join(androidMainPath, 'com', projectName);
      await Directory(newPackagePath).create(recursive: true);

      // Mover arquivos
      final stmrDir = Directory(path.join(techDir.path, 'stmr'));
      if (stmrDir.existsSync()) {
        await for (final entity in stmrDir.list()) {
          if (entity is File) {
            final newPath = path.join(newPackagePath, path.basename(entity.path));
            await entity.copy(newPath);

            // Atualizar package declaration
            final newFile = File(newPath);
            await FileUtils.replaceInFile(newFile, [
              StringReplacement('package tech.stmr', 'package com.$projectName'),
            ]);
          }
        }
      }

      // Remover diretório antigo
      await techDir.delete(recursive: true);
    }
  }

  Future<void> _installDependencies(String projectPath) async {
    final result = await run('flutter', ['pub', 'get'], workingDirectory: projectPath);

    if (result.exitCode != 0) {
      throw Exception('Falha ao instalar dependências Flutter');
    }
  }
}
