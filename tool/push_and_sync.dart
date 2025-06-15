#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) async {
  try {
    // Verifica se está na branch main
    final branchResult = await Process.run('git', ['branch', '--show-current']);
    final currentBranch = branchResult.stdout.toString().trim();

    _log('🚀 Push and Sync na branch: $currentBranch');

    // 1. Fazer push
    _log('📤 Fazendo push...');
    final pushResult = await Process.run('git', ['push', 'origin', currentBranch]);

    if (pushResult.exitCode != 0) {
      _log('❌ Erro no push: ${pushResult.stderr}');
      exit(1);
    }

    _log('✅ Push concluído com sucesso!');

    // 2. Aguardar alguns segundos para garantir que o remote foi atualizado
    if (currentBranch == 'main') {
      _log('⏳ Aguardando 3 segundos para sincronização...');
      await Future.delayed(Duration(seconds: 3));
    }

    // 3. Fazer pull para sincronizar
    _log('📥 Fazendo pull para sincronizar...');
    final pullResult = await Process.run('git', ['pull', 'origin', currentBranch]);

    if (pullResult.exitCode == 0) {
      _log('✅ Pull concluído - código sincronizado!');
    } else {
      _log('⚠️  Warning no pull: ${pullResult.stderr}');
      _log('💡 Tente executar: git pull origin $currentBranch');
    }

    // 4. Mostrar status final
    if (currentBranch == 'main') {
      _log('🏷️  Verificando se tag foi criada pelo GitHub Actions...');
      await Future.delayed(Duration(seconds: 2));

      final tagsResult = await Process.run('git', ['tag', '--sort=-version:refname']);
      final latestTag = tagsResult.stdout.toString().split('\n').first.trim();

      if (latestTag.isNotEmpty) {
        _log('✅ Latest tag: $latestTag');
        _log('🔗 Release: https://github.com/moreirawebmaster/stmr_cli/releases/tag/$latestTag');
      }
    }

    _log('🎉 Push and Sync concluído com sucesso!');
  } catch (e) {
    _log('❌ Erro no push and sync: $e');
    exit(1);
  }
}

/// Log helper para evitar warnings de lint
void _log(String message) {
  // ignore: avoid_print
  print(message);
}
