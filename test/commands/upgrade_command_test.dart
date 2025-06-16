import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stmr_cli/src/commands/upgrade_command.dart';
import 'package:test/test.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  group('UpgradeCommand', () {
    late Logger logger;
    late UpgradeCommand command;

    setUp(() {
      logger = MockLogger();
      command = UpgradeCommand(logger);

      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.success(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);
      when(() => logger.warn(any())).thenReturn(null);
    });

    test('build() retorna um ArgParser com as flags corretas', () {
      final parser = command.build();

      expect(parser.options, contains('help'));

      final helpOption = parser.options['help'];
      expect(helpOption!.help, contains('Mostra'));
    });
  });
}
