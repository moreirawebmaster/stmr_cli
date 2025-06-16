#!/usr/bin/env dart

import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

void main() async {
  final logger = Logger();

  if (!await _isMainBranch()) {
    logger.warn('⚠️  Sincronização apenas permitida na branch main');
    return;
  }

  logger
    ..info('🚀 Iniciando sincronização com repositório remoto...')
    ..info('📤 Fazendo push das mudanças...');

  final pushResult = await Process.run('git', ['push']);
  if (pushResult.exitCode != 0) {
    logger
      ..err('❌ Erro no push:')
      ..err(pushResult.stderr.toString());
    return;
  }

  logger
    ..info('✅ Push realizado com sucesso')
    ..info('🔄 Sincronizando com remote...');

  final pullResult = await Process.run('git', ['pull']);
  if (pullResult.exitCode != 0) {
    logger
      ..err('❌ Erro no pull:')
      ..err(pullResult.stderr.toString());
    return;
  }

  logger
    ..info('✅ Sincronização concluída')
    ..info('📊 Verificando status do repositório...');

  final statusResult = await Process.run('git', ['status', '--porcelain']);
  if (statusResult.stdout.toString().trim().isNotEmpty) {
    logger.warn('⚠️  Existem alterações não commitadas');
  } else {
    logger.info('✅ Repositório está limpo e sincronizado');
  }

  logger.info('🎉 Sincronização completa!');
}

Future<bool> _isMainBranch() async {
  try {
    final result = await Process.run('git', ['branch', '--show-current']);
    return result.stdout.toString().trim() == 'main';
  } catch (e) {
    Logger()
      ..err('❌ Erro ao verificar branch: $e')
      ..warn('⚠️  Continuando com verificação padrão...');
    return false;
  }
}
