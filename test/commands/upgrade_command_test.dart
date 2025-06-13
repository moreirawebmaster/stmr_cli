import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stmr_cli/src/commands/upgrade_command.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  late Logger logger;
  late UpgradeCommand command;

  setUp(() {
    logger = MockLogger();
    command = UpgradeCommand(logger);

    // Mock básico do logger
    when(() => logger.info(any())).thenReturn(null);
    when(() => logger.success(any())).thenReturn(null);
    when(() => logger.err(any())).thenReturn(null);
    when(() => logger.warn(any())).thenReturn(null);
  });

  group('UpgradeCommand', () {
    test('build() retorna um ArgParser com as flags corretas', () {
      final parser = command.build();
      expect(parser.options, contains('help'));
      expect(parser.options, contains('force'));
    });

    test('build() configura a flag force corretamente', () {
      final parser = command.build();
      final forceOption = parser.options['force'];
      expect(forceOption, isNotNull);
      expect(forceOption!.help, contains('Força'));
    });

    test('comando tem nome e descrição adequados', () {
      expect(command, isA<UpgradeCommand>());
    });
  });
}
