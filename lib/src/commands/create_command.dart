import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/lib.dart';

/// Comando responsável por criar um novo projeto Flutter
class CreateCommand implements ICommand {
  /// Construtor que recebe o logger para output
  CreateCommand(this._logger);

  final Logger _logger;

  @override
  ArgParser build() => ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Mostra informações de ajuda')
    ..addFlag('version', abbr: 'v', help: 'Mostra a versão do CLI')
    ..addOption('name', help: 'Nome do projeto (substitui "skeleton" nos arquivos)')
    ..addOption('org', help: 'Organização do projeto (substitui "tech.stmr" nos arquivos)', defaultsTo: 'tech.stmr');

  @override
  Future<void> run(final ArgResults command) async {
    // Verificar se é pedido de ajuda
    if (command['help'] as bool) {
      _showHelp();
      return;
    }

    final args = command.rest;
    final projectName = command['name'] as String?;
    final organization = command['org'] as String? ?? 'tech.stmr';

    // Determinar o nome do projeto
    String finalProjectName;
    String projectDir;

    if (args.isNotEmpty) {
      projectDir = args.first;
      finalProjectName = projectName ?? args.first;
    } else {
      _logger
        ..err('❌ Nome do projeto é obrigatório')
        ..info('Uso: stmr create <nome_do_projeto> [--name nome] [--org organizacao]')
        ..info('Exemplo: stmr create meu_app --name "Meu App" --org com.minhaempresa');
      return;
    }

    final projectNameSnake = finalProjectName.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');

    if (Directory(projectDir).existsSync()) {
      _logger.err('❌ Diretório já existe: $projectDir');
      return;
    }

    _logger
      ..info('🚀 Criando projeto $finalProjectName...')
      ..info('📁 Diretório: $projectDir')
      ..info('🏢 Organização: $organization');

    try {
      // Clonar o skeleton do GitHub
      await _cloneSkeleton(projectDir);

      // Fazer as substituições necessárias
      await _replaceProjectValues(projectDir, finalProjectName, projectNameSnake, organization);

      // Limpar arquivos desnecessários
      await _cleanupProject(projectDir);

      _logger
        ..success('✅ Projeto $finalProjectName criado com sucesso!')
        ..info('')
        ..info('Próximos passos:')
        ..info('  1. cd $projectDir')
        ..info('  2. flutter pub get')
        ..info('  3. stmr feature <nome_do_modulo>');
    } catch (e) {
      _logger.err('❌ Erro ao criar projeto: $e');

      // Limpar diretório em caso de erro
      if (Directory(projectDir).existsSync()) {
        try {
          await Directory(projectDir).delete(recursive: true);
          _logger.info('🧹 Diretório limpo após erro');
        } catch (cleanupError) {
          _logger.warn('⚠️  Não foi possível limpar o diretório: $cleanupError');
        }
      }
    }
  }

  /// Clona o skeleton do GitHub
  Future<void> _cloneSkeleton(final String projectDir) async {
    _logger.info('📥 Clonando skeleton do GitHub...');

    final result = await Process.run(
      'git',
      ['clone', 'https://github.com/moreirawebmaster/skeleton.git', projectDir],
    );

    if (result.exitCode != 0) {
      throw Exception('Erro ao clonar skeleton: ${result.stderr}');
    }

    _logger.success('✅ Skeleton clonado com sucesso!');
  }

  /// Substitui os valores do projeto nos arquivos
  Future<void> _replaceProjectValues(
    final String projectDir,
    final String projectName,
    final String projectNameSnake,
    final String organization,
  ) async {
    _logger.info('🔄 Substituindo valores do projeto...');

    // Lista de arquivos para processar
    final filesToProcess = [
      'pubspec.yaml',
      'lib/main.dart',
      'android/app/build.gradle',
      'android/app/build.gradle.kts',
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner/Info.plist',
      'ios/Runner.xcodeproj/project.pbxproj',
    ];

    // Processar arquivos Kotlin dinamicamente
    await _processKotlinFiles(projectDir, organization);

    // Processar todos os arquivos Dart recursivamente
    await _processDartFiles(projectDir, projectNameSnake, projectName);

    for (final filePath in filesToProcess) {
      final file = File('$projectDir/$filePath');
      if (file.existsSync()) {
        try {
          var content = await file.readAsString();

          // Substituir "skeleton" pelo nome do projeto
          content = content.replaceAll('skeleton', projectNameSnake);
          content = content.replaceAll('Skeleton', projectName);
          content = content.replaceAll('SKELETON', projectName.toUpperCase());

          // Substituir organização
          content = content.replaceAll('tech.stmr', organization);

          await file.writeAsString(content);
          _logger.info('  ✅ $filePath atualizado');
        } catch (e) {
          _logger.warn('  ⚠️  Erro ao processar $filePath: $e');
        }
      }
    }

    _logger.success('✅ Substituições concluídas!');
  }

  /// Limpa arquivos desnecessários do projeto
  Future<void> _cleanupProject(final String projectDir) async {
    _logger.info('🧹 Limpando arquivos desnecessários...');

    // Remover diretório .git
    final gitDir = Directory('$projectDir/.git');
    if (gitDir.existsSync()) {
      await gitDir.delete(recursive: true);
      _logger.info('  ✅ Diretório .git removido');
    }

    // Remover arquivos desnecessários
    final filesToRemove = [
      'README.md',
      '.gitignore.bak',
    ];

    for (final fileName in filesToRemove) {
      final file = File('$projectDir/$fileName');
      if (file.existsSync()) {
        await file.delete();
        _logger.info('  ✅ $fileName removido');
      }
    }

    _logger.success('✅ Limpeza concluída!');
  }

  /// Processa todos os arquivos Dart recursivamente substituindo imports e referências
  Future<void> _processDartFiles(
      final String projectDir, final String projectNameSnake, final String projectName) async {
    _logger.info('🔄 Processando arquivos Dart...');

    final libDir = Directory('$projectDir/lib');
    final testDir = Directory('$projectDir/test');
    final integrationTestDir = Directory('$projectDir/integration_test');

    // Processar diretórios se existirem
    for (final dir in [libDir, testDir, integrationTestDir]) {
      if (dir.existsSync()) {
        await _processDartFilesInDirectory(dir, projectNameSnake, projectName);
      }
    }

    _logger.success('✅ Arquivos Dart processados!');
  }

  /// Processa arquivos Dart recursivamente em um diretório
  Future<void> _processDartFilesInDirectory(
      final Directory dir, final String projectNameSnake, final String projectName) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        try {
          var content = await entity.readAsString();
          var changed = false;

          // Substituir imports que usam 'package:skeleton'
          if (content.contains('package:skeleton')) {
            content = content.replaceAll('package:skeleton', 'package:$projectNameSnake');
            changed = true;
          }

          // Substituir outras referências a 'skeleton' em strings e comentários
          if (content.contains('skeleton')) {
            content = content.replaceAll('skeleton', projectNameSnake);
            changed = true;
          }

          // Substituir 'Skeleton' (capitalizado)
          if (content.contains('Skeleton')) {
            content = content.replaceAll('Skeleton', projectName);
            changed = true;
          }

          // Substituir 'SKELETON' (maiúsculo)
          if (content.contains('SKELETON')) {
            content = content.replaceAll('SKELETON', projectName.toUpperCase());
            changed = true;
          }

          if (changed) {
            await entity.writeAsString(content);
            final relativePath = entity.path.replaceFirst('${dir.parent.path}/', '');
            _logger.info('  ✅ $relativePath atualizado');
          }
        } catch (e) {
          _logger.warn('  ⚠️  Erro ao processar ${entity.path}: $e');
        }
      }
    }
  }

  /// Processa arquivos Kotlin e move diretórios conforme a nova organização
  Future<void> _processKotlinFiles(final String projectDir, final String organization) async {
    final kotlinDir = Directory('$projectDir/android/app/src/main/kotlin');
    if (!kotlinDir.existsSync()) {
      return;
    }

    // Encontrar arquivos Kotlin recursivamente
    await for (final entity in kotlinDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.kt')) {
        try {
          var content = await entity.readAsString();

          // Substituir package
          content = content.replaceAll('tech.stmr.skeleton', '$organization.${projectDir.toLowerCase()}');
          content = content.replaceAll('tech.stmr', organization);

          await entity.writeAsString(content);
          _logger.info('  ✅ ${entity.path.split('/').last} atualizado');
        } catch (e) {
          _logger.warn('  ⚠️  Erro ao processar ${entity.path}: $e');
        }
      }
    }

    // Reorganizar estrutura de diretórios Kotlin se necessário
    if (organization != 'tech.stmr') {
      await _reorganizeKotlinDirectories(projectDir, organization);
    }
  }

  /// Reorganiza os diretórios Kotlin conforme a nova organização
  Future<void> _reorganizeKotlinDirectories(final String projectDir, final String organization) async {
    final oldKotlinPath = '$projectDir/android/app/src/main/kotlin/tech/stmr/skeleton';
    final oldDir = Directory(oldKotlinPath);

    if (!oldDir.existsSync()) {
      return;
    }

    // Criar nova estrutura de diretórios
    final orgParts = organization.split('.');
    final newKotlinPath = '$projectDir/android/app/src/main/kotlin/${orgParts.join('/')}/${projectDir.toLowerCase()}';
    final newDir = Directory(newKotlinPath);

    try {
      await newDir.create(recursive: true);

      // Mover arquivos
      await for (final entity in oldDir.list()) {
        if (entity is File) {
          final newFilePath = '${newDir.path}/${entity.path.split('/').last}';
          await entity.copy(newFilePath);
          await entity.delete();
          _logger.info('  ✅ ${entity.path.split('/').last} movido para nova estrutura');
        }
      }

      // Remover diretório antigo
      final techDir = Directory('$projectDir/android/app/src/main/kotlin/tech');
      if (techDir.existsSync()) {
        await techDir.delete(recursive: true);
        _logger.info('  ✅ Estrutura antiga removida');
      }
    } catch (e) {
      _logger.warn('  ⚠️  Erro ao reorganizar diretórios Kotlin: $e');
    }
  }

  void _showHelp() {
    _logger
      ..info('')
      ..info('🚀 Comando CREATE - Criar projeto Flutter')
      ..info('')
      ..info('Uso: stmr create <nome-do-projeto> [flags]')
      ..info('')
      ..info('Flags:')
      ..info('  --module, -m    Criar projeto com módulos específicos')
      ..info('  --path, -p      Especificar diretório de destino')
      ..info('  --features, -f  Lista de features separadas por vírgula')
      ..info('  --force         Sobrescrever projeto existente')
      ..info('  --dry-run       Simular criação sem modificar arquivos')
      ..info('  --help, -h      Mostrar esta ajuda')
      ..info('')
      ..info('Exemplos:')
      ..info('  stmr create meu_app')
      ..info('  stmr create meu_app --path /caminho/destino')
      ..info('  stmr create meu_app --features auth,profile,settings')
      ..info('');
  }
}
