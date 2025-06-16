import 'package:recase/recase.dart';

/// Templates para geração de arquivos de features
class FeatureTemplates {
  /// Gera o template do binding da feature
  static String binding(final String featureNamePascal, final String featureNameSnake) => '''import 'package:engine/lib.dart';
import '../presentations/controllers/${featureNameSnake}_controller.dart';
import '../repositories/${featureNameSnake}_repository.dart';

class ${featureNamePascal}Binding extends EngineBaseBinding {
  @override
  void dependencies() {
    register.lazyPut<I${featureNamePascal}Repository>(() => ${featureNamePascal}Repository());
    register.lazyPut<${featureNamePascal}Controller>(() => ${featureNamePascal}Controller());
  }
}''';

  /// Gera o template do model da feature
  static String model(final String featureNamePascal, final String featureNameSnake) => '''import 'package:equatable/equatable.dart';

class ${featureNamePascal}Model extends Equatable {
  const ${featureNamePascal}Model({
    this.id,
    this.name,
    this.isActive = true,
  });

  final String? id;
  final String? name;
  final bool isActive;

  factory ${featureNamePascal}Model.fromJson(Map<String, dynamic> json) {
    return ${featureNamePascal}Model(
      id: json['id'] as String?,
      name: json['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive,
    };
  }

  ${featureNamePascal}Model copyWith({
    String? id,
    String? name,
    bool? isActive,
  }) {
    return ${featureNamePascal}Model(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, isActive];
}''';

  /// Gera o template do controller da feature
  static String controller(final String featureNamePascal, final String featureNameSnake) => '''import 'package:engine/lib.dart';
import '../models/${featureNameSnake}_model.dart';
import '../repositories/${featureNameSnake}_repository.dart';
import '../keys/${featureNameSnake}_keys.dart';

class ${featureNamePascal}Controller extends EngineBaseController {
  final I${featureNamePascal}Repository _repository = Get.find();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<${featureNamePascal}Model> model = ${featureNamePascal}Model().obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Carrega os dados iniciais
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final result = await _repository.getData();
      
      result.fold(
        onFailure: (error) {
          hasError.value = true;
          errorMessage.value = error;
        },
        onSuccess: (data) {
          model.value = ${featureNamePascal}Model.fromJson(data);
        },
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Erro interno: \$e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza os dados
  Future<void> refresh() async {
    await loadData();
  }

  /// Exibe mensagem de erro
  void showError(String message) {
    Get.snackbar(
      ${featureNamePascal}Keys.errorTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Exibe mensagem de sucesso
  void showSuccess(String message) {
    Get.snackbar(
      ${featureNamePascal}Keys.successTitle,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}''';

  /// Gera o template da page da feature
  static String page(final String featureNamePascal, final String featureNameSnake) => '''import 'package:flutter/material.dart';
import 'package:engine/lib.dart';
import '../controllers/${featureNameSnake}_controller.dart';
import '../keys/${featureNameSnake}_keys.dart';

class ${featureNamePascal}Page extends EngineBasePage<${featureNamePascal}Controller> {
  const ${featureNamePascal}Page({super.key});

  @override
  String get title => ${featureNamePascal}Keys.pageTitle;

  @override
  Widget body(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (controller.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.errorMessage.value,
                key: ${featureNamePascal}Keys.errorText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: ${featureNamePascal}Keys.retryButton,
                onPressed: controller.refresh,
                child: Text(${featureNamePascal}Keys.retryButtonText),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ${featureNamePascal}Keys.welcomeMessage,
              key: ${featureNamePascal}Keys.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              key: ${featureNamePascal}Keys.loadDataButton,
              onPressed: controller.loadData,
              child: Text(${featureNamePascal}Keys.loadDataButtonText),
            ),
          ],
        ),
      );
    });
  }
}''';

  /// Gera o template do repository da feature
  static String repository(final String featureNamePascal, final String featureNameSnake) => '''import 'package:engine/lib.dart';

/// Interface para o repositório $featureNamePascal
abstract class I${featureNamePascal}Repository {
  /// Obtém os dados
  Future<EngineResult<String, Map<String, dynamic>>> getData();
  
  /// Envia dados
  Future<EngineResult<String, bool>> sendData(Map<String, dynamic> data);
  
  /// Atualiza dados
  Future<EngineResult<String, bool>> updateData(String id, Map<String, dynamic> data);
  
  /// Remove dados
  Future<EngineResult<String, bool>> deleteData(String id);
}

/// Implementação do repositório $featureNamePascal
class ${featureNamePascal}Repository extends EngineBaseRepository implements I${featureNamePascal}Repository {
  final String _basePath = '/api/$featureNameSnake';

  @override
  Future<EngineResult<String, Map<String, dynamic>>> getData() async {
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

  /// Gera o template das keys da feature
  static String keys(final String featureNamePascal, final String featureNameSnake) => '''import 'package:flutter/material.dart';

class ${featureNamePascal}Keys {
  static const String _prefix = '$featureNameSnake';
  
  static const Key appBar = Key('\${_prefix}_app_bar');
  static const Key title = Key('\${_prefix}_title');
  static const Key loadDataButton = Key('\${_prefix}_load_data_button');
  static const Key retryButton = Key('\${_prefix}_retry_button');
  static const Key errorText = Key('\${_prefix}_error_text');
  
  static const String pageTitle = '${ReCase(featureNamePascal).titleCase}';
  static const String welcomeMessage = 'Bem-vindo à página ${ReCase(featureNamePascal).titleCase}';
  static const String loadDataButtonText = 'Carregar Dados';
  static const String retryButtonText = 'Tentar Novamente';
  static const String errorTitle = 'Erro';
  static const String successTitle = 'Sucesso';
  
  static const String pageTitleKey = '\${_prefix}_page_title';
  static const String welcomeMessageKey = '\${_prefix}_welcome_message';
  static const String loadDataButtonKey = '\${_prefix}_load_data_button';
  static const String retryButtonKey = '\${_prefix}_retry_button';
  static const String errorTitleKey = '\${_prefix}_error_title';
  static const String successTitleKey = '\${_prefix}_success_title';
}''';

  /// Gera o template das traduções da feature
  static String translate(final String featureNamePascal, final String featureNameSnake) => '''/// Traduções para a feature $featureNamePascal
class ${featureNamePascal}Translate {
  static const String _prefix = '$featureNameSnake';
  
  /// Traduções em Português
  static const Map<String, String> ptBR = {
    '\${_prefix}_page_title': '${ReCase(featureNamePascal).titleCase}',
    '\${_prefix}_welcome_message': 'Bem-vindo à página ${ReCase(featureNamePascal).titleCase}',
    '\${_prefix}_load_data_button': 'Carregar Dados',
    '\${_prefix}_retry_button': 'Tentar Novamente',
    '\${_prefix}_error_title': 'Erro',
    '\${_prefix}_success_title': 'Sucesso',
    '\${_prefix}_loading_message': 'Carregando...',
    '\${_prefix}_empty_message': 'Nenhum dado encontrado',
    '\${_prefix}_network_error': 'Erro de conexão. Verifique sua internet.',
    '\${_prefix}_generic_error': 'Ocorreu um erro. Tente novamente.',
  };

  /// Traduções em Inglês
  static const Map<String, String> enUS = {
    '\${_prefix}_page_title': '${ReCase(featureNamePascal).titleCase}',
    '\${_prefix}_welcome_message': 'Welcome to ${ReCase(featureNamePascal).titleCase} page',
    '\${_prefix}_load_data_button': 'Load Data',
    '\${_prefix}_retry_button': 'Try Again',
    '\${_prefix}_error_title': 'Error',
    '\${_prefix}_success_title': 'Success',
    '\${_prefix}_loading_message': 'Loading...',
    '\${_prefix}_empty_message': 'No data found',
    '\${_prefix}_network_error': 'Connection error. Check your internet.',
    '\${_prefix}_generic_error': 'An error occurred. Please try again.',
  };

  /// Traduções em Espanhol
  static const Map<String, String> esES = {
    '\${_prefix}_page_title': '${ReCase(featureNamePascal).titleCase}',
    '\${_prefix}_welcome_message': 'Bienvenido a la página ${ReCase(featureNamePascal).titleCase}',
    '\${_prefix}_load_data_button': 'Cargar Datos',
    '\${_prefix}_retry_button': 'Intentar de Nuevo',
    '\${_prefix}_error_title': 'Error',
    '\${_prefix}_success_title': 'Éxito',
    '\${_prefix}_loading_message': 'Cargando...',
    '\${_prefix}_empty_message': 'No se encontraron datos',
    '\${_prefix}_network_error': 'Error de conexión. Verifica tu internet.',
    '\${_prefix}_generic_error': 'Ocurrió un error. Inténtalo de nuevo.',
  };

  /// Retorna todas as traduções organizadas por idioma
  static Map<String, Map<String, String>> get translations => {
    'pt_BR': ptBR,
    'en_US': enUS,
    'es_ES': esES,
  };
}''';

  /// Gera o template do arquivo de rotas para módulos
  static String routes(final String moduleNamePascal, final String moduleNameSnake) => '''import 'package:engine/lib.dart';
import 'presentations/pages/${moduleNameSnake}_page.dart';
import 'bindings/${moduleNameSnake}_binding.dart';

/// Rotas do módulo $moduleNamePascal
class ${moduleNamePascal}Routes {
  static const String $moduleNameSnake = '/$moduleNameSnake';

  /// Lista de rotas do módulo
  static final routes = [
    GetPage(
      name: $moduleNameSnake,
      page: () => const ${moduleNamePascal}Page(),
      binding: ${moduleNamePascal}Binding(),
    ),
  ];
}''';

  /// Gera o template do arquivo de bindings
  static String bindings(final String moduleNamePascal, final String moduleNameSnake) => '''import 'package:engine/lib.dart';
import 'presentations/controllers/${moduleNameSnake}_controller.dart';

/// Bindings do módulo $moduleNamePascal
class ${moduleNamePascal}Bindings extends EngineBaseBinding {
  @override
  void dependencies() {
    register.lazyPut<${moduleNamePascal}Controller>(
      () => ${moduleNamePascal}Controller(),
    );
  }
}''';

  /// Gera o template do arquivo de constantes
  static String constants(final String moduleNamePascal) => '''/// Constantes do módulo $moduleNamePascal
class ${moduleNamePascal}Constants {
  const ${moduleNamePascal}Constants._();

  static const String storageKey = '${moduleNamePascal.toLowerCase()}_storage';
  static const String errorMessage = 'Erro ao carregar dados';
  static const String successMessage = 'Operação realizada com sucesso';
  static const String loadingMessage = 'Carregando...';
  static const String emptyMessage = 'Nenhum dado encontrado';
  static const String baseUrl = '/api/${moduleNamePascal.toLowerCase()}';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
}''';
}
