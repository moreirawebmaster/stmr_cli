import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:stmr_cli/lib.dart';

/// Comando responsável por criar um novo projeto Flutter
class CreateCommand implements Command {
  /// Construtor que recebe o logger para output
  CreateCommand(this._logger);

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
      _logger.err('❌ Nome do projeto é obrigatório');
      _logger.info('Uso: stmr create <nome_do_projeto>');
      return;
    }

    final projectName = args.first;
    final projectNameSnake = projectName.toLowerCase().replaceAll(' ', '_');

    if (Directory(projectNameSnake).existsSync()) {
      _logger.err('❌ Diretório já existe: $projectNameSnake');
      return;
    }

    _logger.info('🚀 Criando projeto $projectName...');

    try {
      // Criar diretório do projeto
      await Directory(projectNameSnake).create();

      // Criar arquivo pubspec.yaml
      await _createFile(
        path.join(projectNameSnake, 'pubspec.yaml'),
        CreateTemplates.pubspec(projectName, projectNameSnake),
      );

      // Criar diretório lib
      await Directory(path.join(projectNameSnake, 'lib')).create();

      // Criar arquivo main.dart
      await _createFile(
        path.join(projectNameSnake, 'lib', 'main.dart'),
        CreateTemplates.main(projectName),
      );

      // Criar diretório de módulos
      await Directory(path.join(projectNameSnake, 'lib', 'modules')).create();

      _logger.success('✅ Projeto $projectName criado com sucesso!');
      _logger.info('');
      _logger.info('Próximos passos:');
      _logger.info('  1. cd $projectNameSnake');
      _logger.info('  2. flutter pub get');
      _logger.info('  3. stmr feature <nome_do_modulo>');
    } catch (e) {
      _logger.err('❌ Erro ao criar projeto: $e');
    }
  }

  Future<void> _createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
