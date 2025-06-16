#!/usr/bin/env dart

import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

void main() async {
  final logger = Logger();

  if (!await _isMainBranch()) {
    logger.warn('Post-push apenas na branch main');
    return;
  }

  final version = await _getCurrentVersion();
  if (version == null) {
    logger.err('Versão não encontrada no pubspec.yaml');
    return;
  }

  logger.info('🏷️  Versão detectada: $version');

  await _createAndPushTag(logger, version);
  await _createGitHubRelease(logger, version);

  logger.info('🎉 Post-push concluído com sucesso!');
}

Future<void> _createAndPushTag(final Logger logger, final String version) async {
  final tagName = 'v$version';

  final existingTags = await Process.run('git', ['tag', '-l', tagName]);
  if (existingTags.stdout.toString().trim().isNotEmpty) {
    logger.warn('Tag $tagName já existe, pulando criação');
    return;
  }

  logger
    ..info('🚀 Auto-versioning and publishing...')
    ..info('🏷️  Criando tag $tagName...');

  final createTagResult = await Process.run('git', [
    'tag',
    '-a',
    tagName,
    '-m',
    'Versão $version',
  ]);

  if (createTagResult.exitCode != 0) {
    logger.err('Erro ao criar tag: ${createTagResult.stderr}');
    return;
  }

  final pushTagResult = await Process.run('git', ['push', 'origin', tagName]);
  if (pushTagResult.exitCode != 0) {
    logger.err('Erro ao fazer push da tag: ${pushTagResult.stderr}');
    return;
  }

  logger.info('✅ Tag $tagName criada e enviada com sucesso!');
}

Future<void> _createGitHubRelease(final Logger logger, final String version) async {
  final tagName = 'v$version';

  final ghAvailable = await Process.run('which', ['gh']);
  if (ghAvailable.exitCode != 0) {
    logger.warn('GitHub CLI não disponível, pulando criação de release');
    return;
  }

  final ghAuth = await Process.run('gh', ['auth', 'status']);
  if (ghAuth.exitCode != 0) {
    logger.warn('GitHub CLI não autenticado, pulando criação de release');
    return;
  }

  logger.info('📦 Criando release no GitHub...');

  final result = await Process.run('gh', [
    'release',
    'create',
    tagName,
    '--title',
    'Versão $version',
    '--notes',
    'Release automático da versão $version',
  ]);

  if (result.exitCode == 0) {
    logger
      ..info('✅ Release criado com sucesso!')
      ..info('🔗 https://github.com/moreirawebmaster/stmr_cli/releases/tag/$tagName');
  } else {
    logger.warn('Erro ao criar release: ${result.stderr}');
  }
}

Future<String?> _getCurrentVersion() async {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return null;
  }

  final content = await pubspecFile.readAsString();
  final versionMatch = RegExp(r'version: (\d+\.\d+\.\d+)').firstMatch(content);

  return versionMatch?.group(1);
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
