import 'package:recase/recase.dart';

/// Templates para geração de arquivos de features
class FeatureTemplates {
  /// Gera o template do binding da feature
  static String binding(String featureNamePascal, String featureNameSnake) {
    return '''import 'package:engine/lib.dart';
import '../presentations/controllers/${featureNameSnake}_controller.dart';
import '../use_cases/${featureNameSnake}_use_case.dart';
import '../repositories/${featureNameSnake}_repository.dart';

class ${featureNamePascal}Binding extends EngineBaseBinding {
  @override
  void dependencies() {
    register.lazyPut<I${featureNamePascal}Repository>(() => ${featureNamePascal}Repository());
    register.lazyPut<${featureNamePascal}UseCase>(() => ${featureNamePascal}UseCase(register.find()));
    register.lazyPut<${featureNamePascal}Controller>(() => ${featureNamePascal}Controller(register.find()));
  }
}''';
  }

  /// Gera o template do model da feature
  static String model(String featureNamePascal, String featureNameSnake) {
    return '''import 'package:engine/lib.dart';

class ${featureNamePascal}Model extends EngineBaseModel {
  // Adicione suas propriedades aqui
  
  ${featureNamePascal}Model();

  @override
  Map<String, dynamic> toJson() {
    return {
      // Implementar serialização
    };
  }

  factory ${featureNamePascal}Model.fromJson(Map<String, dynamic> json) {
    return ${featureNamePascal}Model(
      // Implementar deserialização
    );
  }

  @override
  List<Object?> get props => [
    // Adicionar propriedades para comparação
  ];
}''';
  }

  /// Gera o template do controller da feature
  static String controller(String featureNamePascal, String featureNameSnake) {
    return '''import 'package:engine/lib.dart';
import '../use_cases/${featureNameSnake}_use_case.dart';
import '../models/${featureNameSnake}_model.dart';

class ${featureNamePascal}Controller extends EngineBaseController {
  final ${featureNamePascal}UseCase _useCase;

  ${featureNamePascal}Controller(this._useCase);

  final model = ${featureNamePascal}Model().obs;

  @override
  void onInit() {
    // Inicialização da controller
    super.onInit();
  }

  @override
  void onReady() {
    // Executado quando a página está pronta
    super.onReady();
  }

  @override
  void onClose() {
    // Limpeza de recursos
    super.onClose();
  }

  // Adicione seus métodos aqui
  Future<void> loadData() async {
    loading.value = true;
    
    try {
      final result = await _useCase.execute();
      
      result.fold(
        onFailure: (error) {
          showError(error);
        },
        onSuccess: (data) {
          // Processar dados recebidos
        },
      );
    } finally {
      loading.value = false;
    }
  }
}''';
  }

  /// Gera o template da page da feature
  static String page(String featureNamePascal, String featureNameSnake) {
    return '''import 'package:flutter/material.dart';
import 'package:engine/lib.dart';
import '../controllers/${featureNameSnake}_controller.dart';
import '../keys/${featureNameSnake}_keys.dart';

class ${featureNamePascal}Page extends GetView<${featureNamePascal}Controller> {
  const ${featureNamePascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ReCase(featureNamePascal).titleCase),
        key: ${featureNamePascal}Keys.appBar,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Implementar interface aqui
              Text(
                'Página \${ReCase(featureNamePascal).titleCase}',
                key: ${featureNamePascal}Keys.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                key: ${featureNamePascal}Keys.loadDataButton,
                onPressed: controller.loadData,
                child: const Text('Carregar Dados'),
              ),
            ],
          ),
        );
      }),
    );
  }
}''';
  }

  /// Gera o template do use case da feature
  static String useCase(String featureNamePascal, String featureNameSnake) {
    return '''import 'package:engine/lib.dart';
import '../repositories/${featureNameSnake}_repository.dart';

class ${featureNamePascal}UseCase {
  final I${featureNamePascal}Repository _repository;

  ${featureNamePascal}UseCase(this._repository);

  Future<EngineResult<String, dynamic>> execute() async {
    try {
      // Implementar lógica de negócio aqui
      final result = await _repository.getData();
      
      return result.fold(
        onFailure: (error) => Failure(error),
        onSuccess: (data) {
          // Processar dados se necessário
          return Successful(data);
        },
      );
    } catch (e) {
      return Failure('Erro interno: \$e');
    }
  }
}''';
  }

  /// Gera o template do repository da feature
  static String repository(String featureNamePascal, String featureNameSnake) {
    return '''import 'package:engine/lib.dart';

abstract class I${featureNamePascal}Repository {
  Future<EngineResult<String, dynamic>> getData();
}

class ${featureNamePascal}Repository extends EngineBaseRepository implements I${featureNamePascal}Repository {
  
  @override
  Future<EngineResult<String, dynamic>> getData() async {
    try {
      // Implementar chamada para API ou fonte de dados
      final response = await get('/api/$featureNameSnake');
      
      if (response.isSuccess) {
        return Successful(response.data);
      } else {
        return Failure(response.error ?? 'Erro desconhecido');
      }
    } catch (e) {
      return Failure('Erro de conexão: \$e');
    }
  }
}''';
  }

  /// Gera o template das keys da feature
  static String keys(String featureNamePascal, String featureNameSnake) {
    return '''import 'package:flutter/material.dart';

class ${featureNamePascal}Keys {
  // Keys para testes
  static const Key appBar = Key('${featureNameSnake}_app_bar');
  static const Key title = Key('${featureNameSnake}_title');
  static const Key loadDataButton = Key('${featureNameSnake}_load_data_button');
  
  // Keys para traducão
  static const String titleTranslationKey = '${featureNameSnake}_title';
  static const String loadDataTranslationKey = '${featureNameSnake}_load_data';
}''';
  }

  /// Gera o template das rotas da feature
  static String routes(String featureName, String featureNameSnake) {
    final featureNamePascal = ReCase(featureName).pascalCase;

    return '''import 'package:engine/lib.dart';
import '../presentations/pages/${featureNameSnake}_page.dart';
import '../bindings/${featureNameSnake}_binding.dart';

class ${featureNamePascal}Routes {
  static const String $featureNameSnake = '/$featureNameSnake';

  static final routes = [
    GetPage(
      name: $featureNameSnake,
      page: () => const ${featureNamePascal}Page(),
      binding: ${featureNamePascal}Binding(),
    ),
  ];
}''';
  }

  /// Gera o template do arquivo de rotas para módulos
  static String moduleRoutesTemplate(String moduleNamePascal, String moduleNameSnake) {
    return '''import 'package:engine/lib.dart';

    import 'presentations/pages/${moduleNameSnake}_page.dart';
    import '${moduleNameSnake}_bindings.dart';

    /// Rotas do módulo $moduleNamePascal
    class ${moduleNamePascal}Routes {
      /// Lista de rotas do módulo
      static final routes = [
        GetPage(
          name: '/$moduleNameSnake',
          page: () => const ${moduleNamePascal}Page(),
          binding: ${moduleNamePascal}Bindings(),
        ),
      ];
    }''';
  }

  /// Gera o template do arquivo de bindings
  static String bindings(String moduleNamePascal, String moduleNameSnake) {
    return '''import 'package:engine/lib.dart';

    import 'presentations/controllers/${moduleNameSnake}_controller.dart';

    /// Bindings do módulo $moduleNamePascal
    class ${moduleNamePascal}Bindings extends Bindings {
      @override
      void dependencies() {
        Get.lazyPut<${moduleNamePascal}Controller>(
          () => ${moduleNamePascal}Controller(),
        );
      }
    }''';
  }

  /// Gera o template do arquivo de constantes
  static String constants(String moduleNamePascal) {
    return '''/// Constantes do módulo $moduleNamePascal
    class ${moduleNamePascal}Constants {
      /// Construtor privado
      const ${moduleNamePascal}Constants._();

      /// Chaves de armazenamento
      static const String storageKey = '${moduleNamePascal.toLowerCase()}_storage';

      /// Mensagens
      static const String errorMessage = 'Erro ao carregar dados';
      static const String successMessage = 'Operação realizada com sucesso';
    }''';
  }
}
