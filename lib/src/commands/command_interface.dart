import 'package:args/args.dart';

/// Interface que todos os comandos devem implementar
abstract class Command {
  /// Constrói o parser de argumentos para o comando
  ArgParser build();

  /// Executa o comando com os argumentos fornecidos
  Future<void> run(ArgResults command);
}
