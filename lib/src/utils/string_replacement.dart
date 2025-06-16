/// Representa uma substituição de string com padrão e substituição
class StringReplacement {
  /// Cria uma nova substituição de string
  const StringReplacement({
    required this.pattern,
    required this.replacement,
  });

  /// Padrão a ser substituído
  final String pattern;

  /// Texto que substituirá o padrão
  final String replacement;
}
