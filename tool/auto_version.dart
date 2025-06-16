#!/usr/bin/env dart

import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

void main() async {
  final logger = Logger();

  if (!await _isMainBranch()) {
    logger.warn('Não está na branch main, pulando increment de versão');
    return;
  }

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    logger.err('pubspec.yaml não encontrado');
    return;
  }

  final content = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'version:\s*([0-9]+\.[0-9]+\.[0-9]+)');
  final match = versionRegex.firstMatch(content);

  if (match == null) {
    logger.err('Versão não encontrada no pubspec.yaml');
    return;
  }

  final currentVersion = match.group(1)!;
  final parts = currentVersion.split('.');
  final major = int.parse(parts[0]);
  final minor = int.parse(parts[1]);
  final patch = int.parse(parts[2]);

  final newPatch = patch + 1;
  final newVersion = '$major.$minor.$newPatch';

  final newContent = content.replaceFirst(
    versionRegex,
    'version: $newVersion',
  );

  pubspecFile.writeAsStringSync(newContent);

  File('lib/src/version.dart').writeAsStringSync("const String cliVersion = '$newVersion';\n");

  logger
    ..info('✅ Versão incrementada para $newVersion')
    ..info('📝 Arquivo de versão criado com sucesso!');
}

Future<bool> _isMainBranch() async {
  try {
    final result = await Process.run('git', ['branch', '--show-current']);
    return result.stdout.toString().trim() == 'main';
  } catch (e) {
    Logger()
      ..err('Erro ao verificar branch: $e')
      ..warn('Continuando com verificação padrão...');
    return false;
  }
}
