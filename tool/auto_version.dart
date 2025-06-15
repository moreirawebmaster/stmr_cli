#!/usr/bin/env dart

import 'dart:io';

import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  try {
    // Verifica se está na branch main
    final branchResult = await Process.run('git', ['branch', '--show-current']);
    final currentBranch = branchResult.stdout.toString().trim();

    if (currentBranch != 'main') {
      print('⚠️  Auto-versionamento apenas na branch main. Branch atual: $currentBranch');
      exit(0);
    }

    // Lê o pubspec.yaml atual
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('❌ Arquivo pubspec.yaml não encontrado');
      exit(1);
    }

    final pubspecContent = await pubspecFile.readAsString();
    final yaml = loadYaml(pubspecContent);

    final currentVersion = yaml['version'] as String?;
    if (currentVersion == null) {
      print('❌ Versão não encontrada no pubspec.yaml');
      exit(1);
    }

    // Incrementa a versão (patch)
    final newVersion = _incrementVersion(currentVersion);

    // Atualiza o conteúdo do pubspec.yaml
    final updatedContent = pubspecContent.replaceFirst(
      RegExp(r'version:\s*' + RegExp.escape(currentVersion)),
      'version: $newVersion',
    );

    // Escreve o arquivo atualizado
    await pubspecFile.writeAsString(updatedContent);

    print('🚀 Versão incrementada: $currentVersion → $newVersion');

    // Adiciona o arquivo ao commit
    await Process.run('git', ['add', 'pubspec.yaml']);

    // Cria commit com a nova versão
    final commitResult = await Process.run('git', [
      'commit',
      '-m',
      'chore: bump version to $newVersion [skip ci]',
    ]);

    if (commitResult.exitCode == 0) {
      print('✅ Commit automático criado com nova versão');
    }
  } catch (e) {
    print('❌ Erro ao incrementar versão: $e');
    exit(1);
  }
}

/// Incrementa a versão patch (x.y.z -> x.y.z+1)
String _incrementVersion(String version) {
  // Remove qualquer sufixo como +build ou -pre
  final cleanVersion = version.split('+').first.split('-').first;
  final parts = cleanVersion.split('.');

  if (parts.length < 3) {
    throw Exception('Formato de versão inválido: $version');
  }

  final major = int.parse(parts[0]);
  final minor = int.parse(parts[1]);
  final patch = int.parse(parts[2]) + 1;

  return '$major.$minor.$patch';
}
