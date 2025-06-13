import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stmr_cli/src/commands/upgrade_command.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

class MockProcess extends Mock implements Process {
  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding,
    Encoding? stderrEncoding,
  }) async {
    return ProcessResult(0, 0, '', '');
  }
}

void main() {
  late Logger logger;
  late UpgradeCommand command;
  late ProcessResult processResult;
  late ArgParser parser;

  setUp(() {
    logger = MockLogger();
    command = UpgradeCommand(logger);
    processResult = ProcessResult(0, 0, '', '');
    parser = ArgParser()..addFlag('force');

    // Mock do logger
    when(() => logger.info(any())).thenReturn(null);
    when(() => logger.success(any())).thenReturn(null);
    when(() => logger.err(any())).thenReturn(null);
  });

  group('UpgradeCommand', () {
    test('build() retorna um ArgParser com as flags corretas', () {
      final parser = command.build();
      expect(parser.options, contains('help'));
      expect(parser.options, contains('force'));
    });

    test('run() mostra mensagem de erro quando não consegue obter versão atual', () async {
      final errorResult = ProcessResult(1, 0, '', 'Erro ao executar comando');

      // Mock do Process.run para simular erro
      final mockProcess = MockProcess();
      when(() => mockProcess.run(any(), any())).thenAnswer((_) async => errorResult);

      await command.run(parser.parse([]));

      verify(() => logger.err(any())).called(1);
    });

    test('run() mostra mensagem de erro quando não consegue obter última versão', () async {
      // Mock do Process.run para simular sucesso na versão atual
      final mockProcess = MockProcess();
      when(() => mockProcess.run(any(), any())).thenAnswer((_) async {
        final args = _.positionalArguments[1] as List<String>;
        if (args.contains('--version')) {
          return ProcessResult(0, 0, '1.0.0', '');
        }
        // Simula erro ao clonar repositório
        return ProcessResult(1, 0, '', 'Erro ao clonar repositório');
      });

      await command.run(parser.parse([]));

      verify(() => logger.err(any())).called(1);
    });

    test('run() mostra mensagem de sucesso quando já está na última versão', () async {
      // Mock do Process.run para simular versões iguais
      final mockProcess = MockProcess();
      when(() => mockProcess.run(any(), any())).thenAnswer((_) async {
        final args = _.positionalArguments[1] as List<String>;
        if (args.contains('--version')) {
          return ProcessResult(0, 0, '1.0.0', '');
        } else if (args.contains('describe')) {
          return ProcessResult(0, 0, '1.0.0', '');
        }
        return ProcessResult(0, 0, '', '');
      });

      await command.run(parser.parse([]));

      verify(() => logger.success(any())).called(1);
    });

    test('run() faz upgrade quando há uma versão mais nova', () async {
      // Mock do Process.run para simular versão atual menor que a do GitHub
      final mockProcess = MockProcess();
      when(() => mockProcess.run(any(), any())).thenAnswer((_) async {
        final args = _.positionalArguments[1] as List<String>;
        if (args.contains('--version')) {
          return ProcessResult(0, 0, '1.0.0', '');
        } else if (args.contains('describe')) {
          return ProcessResult(0, 0, '1.0.1', '');
        }
        return ProcessResult(0, 0, '', '');
      });

      await command.run(parser.parse([]));

      verify(() => logger.success(any())).called(1);
    });

    test('run() força upgrade quando flag force é true', () async {
      // Mock do Process.run para simular versões iguais
      final mockProcess = MockProcess();
      when(() => mockProcess.run(any(), any())).thenAnswer((_) async {
        final args = _.positionalArguments[1] as List<String>;
        if (args.contains('--version')) {
          return ProcessResult(0, 0, '1.0.0', '');
        } else if (args.contains('describe')) {
          return ProcessResult(0, 0, '1.0.0', '');
        }
        return ProcessResult(0, 0, '', '');
      });

      await command.run(parser.parse(['--force']));

      verify(() => logger.success(any())).called(1);
    });
  });
}
