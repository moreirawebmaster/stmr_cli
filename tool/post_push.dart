#!/usr/bin/env dart

import 'dart:io';

import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  try {
    // Verifica se está na branch main
    final branchResult = await Process.run('git', ['branch', '--show-current']);
    final currentBranch = branchResult.stdout.toString().trim();

    if (currentBranch != 'main') {
      _log('⚠️  Post-push actions apenas na branch main. Branch atual: $currentBranch');
      exit(0);
    }

    // Lê a versão atual do pubspec.yaml
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _log('❌ Arquivo pubspec.yaml não encontrado');
      exit(1);
    }

    final pubspecContent = await pubspecFile.readAsString();
    final yaml = loadYaml(pubspecContent) as Map<dynamic, dynamic>;

    final currentVersion = yaml['version'] as String?;
    if (currentVersion == null) {
      _log('❌ Versão não encontrada no pubspec.yaml');
      exit(1);
    }

    _log('🚀 Executando ações pós-push para versão $currentVersion');

    // 1. Criar tag da versão
    await _createTag(currentVersion);

    // 2. Criar release no GitHub com release notes
    await _createGitHubRelease(currentVersion);

    _log('✅ Todas as ações pós-push concluídas com sucesso!');
  } catch (e) {
    _log('❌ Erro nas ações pós-push: $e');
    exit(1);
  }
}

/// Cria tag da versão atual
Future<void> _createTag(String version) async {
  _log('🏷️  Criando tag v$version...');

  // Verifica se a tag já existe
  final tagCheckResult = await Process.run('git', ['tag', '-l', 'v$version']);

  if (tagCheckResult.stdout.toString().trim().isNotEmpty) {
    _log('⚠️  Tag v$version já existe, pulando criação');
    return;
  }

  // Cria a tag
  final tagResult = await Process.run('git', [
    'tag',
    '-a',
    'v$version',
    '-m',
    'Release v$version',
  ]);

  if (tagResult.exitCode == 0) {
    _log('✅ Tag v$version criada localmente');

    // Push da tag
    final pushTagResult = await Process.run('git', ['push', 'origin', 'v$version']);

    if (pushTagResult.exitCode == 0) {
      _log('✅ Tag v$version enviada para o repositório');
    } else {
      _log('❌ Erro ao enviar tag: ${pushTagResult.stderr}');
    }
  } else {
    _log('❌ Erro ao criar tag: ${tagResult.stderr}');
  }
}

/// Cria release no GitHub com release notes automáticas
Future<void> _createGitHubRelease(String version) async {
  _log('📋 Criando release no GitHub com release notes automáticas...');

  // Verifica se GitHub CLI está disponível
  final ghCheckResult = await Process.run('which', ['gh']);

  if (ghCheckResult.exitCode != 0) {
    _log('⚠️  GitHub CLI (gh) não encontrado. Instale com: brew install gh');
    _log('📝 Criação de release pulada - tag v$version está disponível');
    return;
  }

  // Verifica se está autenticado
  final authResult = await Process.run('gh', ['auth', 'status']);

  if (authResult.exitCode != 0) {
    _log('⚠️  GitHub CLI não autenticado. Execute: gh auth login');
    _log('📝 Criação de release pulada - tag v$version está disponível');
    return;
  }

  // Cria release com release notes automáticas
  final releaseResult = await Process.run('gh', [
    'release',
    'create',
    'v$version',
    '--title',
    'Release v$version',
    '--generate-notes',
    '--latest',
  ]);

  if (releaseResult.exitCode == 0) {
    _log('✅ Release v$version criado no GitHub com release notes automáticas');
    _log('🔗 Confira em: https://github.com/moreirawebmaster/stmr_cli/releases/tag/v$version');
  } else {
    _log('❌ Erro ao criar release: ${releaseResult.stderr}');
    _log('📝 Tag v$version ainda está disponível para release manual');
  }
}

/// Log helper para evitar warnings de lint
void _log(String message) {
  // ignore: avoid_print
  print(message);
}
