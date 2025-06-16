import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/stmr_cli.dart';

void main(final List<String> args) async {
  final logger = Logger();
  final runner = CliRunner(logger: logger);
  await runner.run(args);
}
