import 'package:mason_logger/mason_logger.dart';
import 'package:stmr_cli/src/cli_runner.dart';

void main(List<String> args) async {
  final logger = Logger();
  final runner = CliRunner(logger);
  await runner.run(args);
}
