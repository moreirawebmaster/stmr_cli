/// Templates para geração de pages, controllers, repositories e DTOs
class GenerateTemplates {
  /// Gera o template de uma page que extende EngineBasePage
  static String page(String pageNamePascal, String pageNameSnake, String moduleNameSnake) {
    return '''import 'package:engine/lib.dart';
import 'package:flutter/material.dart';
import 'package:design_system/lib.dart';

import '../controllers/${pageNameSnake}_controller.dart';

/// Página $pageNamePascal
class ${pageNamePascal}Page extends EngineBasePage<${pageNamePascal}Controller> {
  /// Construtor
  const ${pageNamePascal}Page({super.key});

  @override
  String get title => '$pageNamePascal';

  @override
  Widget body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DSText(
            'Página $pageNamePascal',
            type: DSTextType.heading2,
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.loading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (controller.error.value != null) {
              return Center(
                child: DSText(
                  controller.error.value!,
                  type: DSTextType.body1,
                  color: DSColors.error,
                ),
              );
            }

            return const Center(
              child: Text('Conteúdo da página'),
            );
          }),
        ],
      ),
    );
  }
}''';
  }

  /// Gera o template de um controller que extende EngineBaseController
  static String controller(String controllerNamePascal, String controllerNameSnake, String moduleNameSnake) {
    return '''import 'package:engine/lib.dart';

/// Controller para $controllerNamePascal
class ${controllerNamePascal}Controller extends EngineBaseController {
  // Dependências e serviços aqui
  // final _repository = Get.find<I${controllerNamePascal}Repository>();
  
  // Observáveis
  final data = <String, dynamic>{}.obs;
  final error = RxnString();

  @override
  void onInit() {
    // Inicialização do controller
    super.onInit();
  }

  @override
  void onReady() {
    // Carregamento inicial dos dados
    _loadData();
    super.onReady();
  }

  @override
  void onClose() {
    // Limpeza de recursos
    super.onClose();
  }

  /// Carrega os dados iniciais
  Future<void> _loadData() async {
    loading.value = true;
    error.value = null;
    
    try {
      // Implementar carregamento de dados
      await Future.delayed(const Duration(seconds: 1)); // Simulação
      
      // Atualizar dados
      data.value = {'message': 'Dados carregados com sucesso'};
    } catch (e) {
      error.value = 'Erro ao carregar dados: \$e';
      showError(error.value!);
    } finally {
      loading.value = false;
    }
  }

  /// Atualiza os dados
  Future<void> refresh() async {
    await _loadData();
  }
}''';
  }

  /// Gera o template de um repository com interface e implementação
  static String repository(String repositoryNamePascal, String repositoryNameSnake, String moduleNameSnake) {
    return '''import 'package:engine/lib.dart';

/// Interface para o repositório $repositoryNamePascal
abstract class I${repositoryNamePascal}Repository {
  /// Obtém os dados
  Future<EngineResult<String, dynamic>> getData();
  
  /// Envia dados
  Future<EngineResult<String, bool>> sendData(Map<String, dynamic> data);
  
  /// Atualiza dados
  Future<EngineResult<String, bool>> updateData(String id, Map<String, dynamic> data);
  
  /// Remove dados
  Future<EngineResult<String, bool>> deleteData(String id);
}

/// Implementação do repositório $repositoryNamePascal
class ${repositoryNamePascal}Repository extends EngineBaseRepository implements I${repositoryNamePascal}Repository {
  final String _basePath = '/api/$repositoryNameSnake';
  
  @override
  void onInit() {
    // Inicialização do repositório
    super.onInit();
  }

  @override
  Future<EngineResult<String, dynamic>> getData() async {
    try {
      final response = await get('\$_basePath');
      
      if (response.isSuccess) {
        return Successful(response.data);
      } else {
        return Failure(response.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      return Failure('Erro ao obter dados: \$e');
    }
  }

  @override
  Future<EngineResult<String, bool>> sendData(Map<String, dynamic> data) async {
    try {
      final response = await post('\$_basePath', data);
      
      if (response.isSuccess) {
        return Successful(true);
      } else {
        return Failure(response.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      return Failure('Erro ao enviar dados: \$e');
    }
  }

  @override
  Future<EngineResult<String, bool>> updateData(String id, Map<String, dynamic> data) async {
    try {
      final response = await put('\$_basePath/\$id', data);
      
      if (response.isSuccess) {
        return Successful(true);
      } else {
        return Failure(response.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      return Failure('Erro ao atualizar dados: \$e');
    }
  }

  @override
  Future<EngineResult<String, bool>> deleteData(String id) async {
    try {
      final response = await delete('\$_basePath/\$id');
      
      if (response.isSuccess) {
        return Successful(true);
      } else {
        return Failure(response.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      return Failure('Erro ao remover dados: \$e');
    }
  }
}''';
  }

  /// Gera o template de um DTO baseado em um JSON
  static String dto(String dtoNamePascal, String dtoNameSnake, Map<String, dynamic> jsonData) {
    final constructorParams = _generateDtoConstructorParams(jsonData);
    final fromMapBody = _generateDtoFromMap(jsonData);
    final toMapBody = _generateDtoToMap(jsonData);
    final copyWithParams = _generateDtoCopyWithParams(jsonData);
    final copyWithBody = _generateDtoCopyWithBody(jsonData);
    final properties = _generateDtoProperties(jsonData);

    return '''/// DTO para resposta de $dtoNamePascal
class ${dtoNamePascal}ResponseDto {
  // Construtor
  ${dtoNamePascal}ResponseDto({
$constructorParams
  });

  // Factories
  factory ${dtoNamePascal}ResponseDto.fromMap(Map<String, dynamic> map) => ${dtoNamePascal}ResponseDto(
$fromMapBody
      );

  factory ${dtoNamePascal}ResponseDto.empty() => ${dtoNamePascal}ResponseDto(
${_generateEmptyFactoryParams(jsonData)}
      );

  // Methods
  Map<String, dynamic> toMap() => {
$toMapBody
      };

  ${dtoNamePascal}ResponseDto copyWith({
$copyWithParams
  }) {
    return ${dtoNamePascal}ResponseDto(
$copyWithBody
    );
  }

  // Properties
$properties
}''';
  }

  /// Gera as propriedades do DTO baseado no JSON
  static String _generateDtoProperties(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();

    jsonData.forEach((key, value) {
      final type = _getDartType(value);
      buffer.writeln('  /// $key');
      buffer.writeln('  final $type $key;');
      buffer.writeln();
    });

    return buffer.toString();
  }

  /// Gera os parâmetros do construtor do DTO
  static String _generateDtoConstructorParams(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();

    jsonData.forEach((key, value) {
      buffer.writeln('    required this.$key,');
    });

    return buffer.toString();
  }

  /// Gera o código para o método fromMap
  static String _generateDtoFromMap(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();

    jsonData.forEach((key, value) {
      final dartType = _getDartType(value);
      final defaultValue = _getDefaultValue(value);

      if (value is Map) {
        buffer.writeln('        $key: Map<String, dynamic>.from(map[\'$key\'] ?? {}),');
      } else if (value is List) {
        if (value.isNotEmpty && value.first is Map) {
          buffer.writeln('        $key: List<Map<String, dynamic>>.from(map[\'$key\'] ?? []),');
        } else {
          final listType = _getListType(value);
          buffer.writeln('        $key: List<$listType>.from(map[\'$key\'] ?? []),');
        }
      } else if (dartType == 'int') {
        buffer.writeln('        $key: map[\'$key\']?.toInt() ?? $defaultValue,');
      } else if (dartType == 'double') {
        buffer.writeln('        $key: map[\'$key\']?.toDouble() ?? $defaultValue,');
      } else {
        buffer.writeln('        $key: map[\'$key\'] ?? $defaultValue,');
      }
    });

    return buffer.toString();
  }

  /// Gera o código para o método toMap
  static String _generateDtoToMap(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();

    jsonData.forEach((key, value) {
      buffer.writeln('        \'$key\': $key,');
    });

    return buffer.toString();
  }

  /// Gera os parâmetros para o factory empty
  static String _generateEmptyFactoryParams(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();

    jsonData.forEach((key, value) {
      final defaultValue = _getDefaultValue(value);
      buffer.writeln('        $key: $defaultValue,');
    });

    return buffer.toString();
  }

  /// Gera os parâmetros do método copyWith
  static String _generateDtoCopyWithParams(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();

    jsonData.forEach((key, value) {
      final type = _getDartType(value);
      buffer.writeln('    $type? $key,');
    });

    return buffer.toString();
  }

  /// Gera o corpo do método copyWith
  static String _generateDtoCopyWithBody(Map<String, dynamic> jsonData) {
    final buffer = StringBuffer();

    jsonData.forEach((key, value) {
      buffer.writeln('      $key: $key ?? this.$key,');
    });

    return buffer.toString();
  }

  /// Retorna o tipo Dart correspondente ao valor
  static String _getDartType(dynamic value) {
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      return 'List<${_getDartType(value.first)}>';
    }
    if (value is Map) return 'Map<String, dynamic>';
    return 'dynamic';
  }

  /// Retorna o tipo da lista
  static String _getListType(List<dynamic> list) {
    if (list.isEmpty) return 'dynamic';
    return _getDartType(list.first);
  }

  /// Retorna o valor padrão para um tipo
  static String _getDefaultValue(dynamic value) {
    if (value is String) return "''";
    if (value is int) return '0';
    if (value is double) return '0.0';
    if (value is bool) return 'false';
    if (value is List) return '[]';
    if (value is Map) return '{}';
    return 'null';
  }
}
