# Engine - Plugin Flutter para Desenvolvimento Avançado

## 🚀 Visão Geral

O **Engine** é um plugin Flutter abrangente e robusto, desenvolvido para abstrair bibliotecas externas e fornecer uma base sólida para aplicações Flutter complexas. Este plugin atua como uma camada de abstração que permite aos desenvolvedores criarem aplicações mais robustas, testáveis e escaláveis.

## 📋 Índice

- [Importância do Plugin](#-importância-do-plugin)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Dependências](#-dependências)
- [Instalação](#-instalação)
- [Arquitetura](#-arquitetura)
- [Funcionalidades Principais](#-funcionalidades-principais)
- [Como Usar](#-como-usar)
- [Testes](#-testes)
- [Contribuição](#-contribuição)

## 🎯 Importância do Plugin

O **Engine** é essencial para projetos Flutter complexos pois:

### ✅ **Abstração de Dependências Externas**
- Encapsula bibliotecas como Firebase, GetX, Get Storage e outras
- Fornece interfaces consistentes independentemente da implementação subjacente
- Facilita a migração e atualização de dependências

### ✅ **Base Sólida para Desenvolvimento**
- Arquitetura bem definida seguindo princípios SOLID
- Padrões de design implementados (Repository, Service Layer, etc.)
- Estrutura modular que promove reutilização de código

### ✅ **Aplicações Mais Robustas**
- Sistema centralizado de gerenciamento de erros
- Logging avançado para debugging e monitoramento
- Interceptadores HTTP para controle de requisições

### ✅ **Maior Testabilidade**
- Abstrações que facilitam a criação de mocks
- Separação clara de responsabilidades
- Interfaces bem definidas para injeção de dependência

### ✅ **Produtividade Aumentada**
- Componentes reutilizáveis pré-construídos
- Configurações automáticas para funcionalidades comuns
- Redução significativa de código boilerplate

## 🏗️ Estrutura do Projeto

```
engine/
├── lib/
│   ├── core/                          # Núcleo principal do Engine
│   │   ├── apps/                      # Configuração de aplicações
│   │   │   ├── engine_core.dart              # Core principal
│   │   │   ├── engine_core_dependency.dart   # Gerenciamento de dependências
│   │   │   ├── engine_material_app.dart      # Widget principal da aplicação
│   │   │   └── engine_route_core.dart        # Gerenciamento de rotas
│   │   ├── bases/                     # Classes base abstratas
│   │   │   ├── engine_base_binding.dart      # Binding base
│   │   │   ├── engine_base_controller.dart   # Controller base
│   │   │   ├── engine_base_initializer.dart  # Inicializador base
│   │   │   ├── engine_base_model.dart        # Model base
│   │   │   ├── engine_base_page.dart         # Page base
│   │   │   ├── engine_base_repository.dart   # Repository base
│   │   │   ├── engine_base_service.dart      # Service base
│   │   │   ├── engine_base_state.dart        # State base
│   │   │   ├── engine_base_transalation.dart # Translation base
│   │   │   └── engine_base_validator.dart    # Validator base
│   │   ├── bindings/                  # Configurações de injeção de dependência
│   │   │   └── engine_binding.dart           # Binding principal
│   │   ├── extensions/                # Extensões de funcionalidades
│   │   │   ├── map_extension.dart            # Extensões para Map
│   │   │   └── string.dart                   # Extensões para String
│   │   ├── helpers/                   # Utilitários e helpers
│   │   │   ├── engine_bottomsheet.dart       # Helper para bottom sheets
│   │   │   ├── engine_bug_tracking.dart      # Rastreamento de bugs
│   │   │   ├── engine_feature_flag.dart      # Gerenciamento de feature flags
│   │   │   ├── engine_firebase.dart          # Helper Firebase
│   │   │   ├── engine_log.dart               # Sistema de logs
│   │   │   ├── engine_message.dart           # Sistema de mensagens
│   │   │   └── engine_theme.dart             # Gerenciamento de temas
│   │   ├── http/                      # Camada de comunicação HTTP
│   │   │   ├── engine_form_data.dart         # Manipulação de form data
│   │   │   ├── engine_http_exception.dart    # Exceções HTTP
│   │   │   ├── engine_http_interceptor.dart  # Interceptador base
│   │   │   ├── engine_http_interceptor_logger.dart # Logger de requisições
│   │   │   ├── engine_http_request.dart      # Wrapper para requisições
│   │   │   ├── engine_http_response.dart     # Wrapper para respostas
│   │   │   ├── engine_http_result.dart       # Resultado de operações HTTP
│   │   │   └── engine_jwt.dart               # Manipulação de JWT
│   │   ├── initializers/              # Inicializadores de módulos
│   │   │   ├── engine_bug_tracking_initializer.dart # Init bug tracking
│   │   │   ├── engine_feature_flag_initializer.dart # Init feature flags
│   │   │   ├── engine_firebase_initializer.dart     # Init Firebase
│   │   │   └── engine_initializer.dart               # Inicializador base
│   │   ├── language/                  # Sistema de internacionalização
│   │   │   └── engine_form_validator_language.dart  # Validações i18n
│   │   ├── observers/                 # Observadores de eventos
│   │   │   └── engine_route_observer.dart            # Observer de rotas
│   │   ├── repositories/              # Camada de repositórios
│   │   │   ├── dtos/                         # Data Transfer Objects
│   │   │   │   ├── requests/                 # DTOs de requisições
│   │   │   │   └── responses/                # DTOs de respostas
│   │   │   ├── engine_token_repository.dart  # Repositório de tokens
│   │   │   └── i_engine_token_repository.dart # Interface do repositório
│   │   ├── routes/                    # Sistema de roteamento
│   │   │   ├── engine_middleware.dart        # Middleware de rotas
│   │   │   └── engine_page_route.dart        # Configuração de rotas
│   │   ├── services/                  # Camada de serviços
│   │   │   ├── engine_analytics_service.dart    # Serviço de analytics
│   │   │   ├── engine_check_status_service.dart # Verificação de status
│   │   │   ├── engine_locale_service.dart       # Serviço de localização
│   │   │   ├── engine_navigation_service.dart   # Serviço de navegação
│   │   │   ├── engine_token_service.dart        # Gerenciamento de tokens
│   │   │   └── engine_user_service.dart         # Serviço de usuário
│   │   ├── settings/                  # Configurações da aplicação
│   │   │   └── engine_app_settings.dart      # Settings principais
│   │   └── typedefs/                  # Definições de tipos
│   │       └── engine_typedef.dart           # Tipos customizados
│   └── data/                          # Camada de dados
│       ├── constants/                 # Constantes da aplicação
│       │   └── engine_constant.dart          # Constantes do Engine
│       ├── enums/                     # Enumerações
│       │   ├── engine_environment.dart      # Ambientes de execução
│       │   ├── engine_http_method.dart      # Métodos HTTP
│   │   │   ├── engine_log_level.dart        # Níveis de log
│   │   │   └── engine_translation_type_enum.dart # Tipos de tradução
│       ├── extensions/                # Extensões de dados
│       │   └── engine_result_extension.dart # Extensões para resultados
│       ├── models/                    # Modelos de dados
│       │   ├── engine_bug_tracking_model.dart # Model de bug tracking
│       │   ├── engine_credential_token_model.dart # Model de credenciais
│       │   ├── engine_firebase_model.dart         # Model Firebase
│       │   ├── engine_token_model.dart             # Model de token
│       │   ├── engine_update_info_model.dart       # Model de atualização
│       │   └── engine_user_model.dart              # Model de usuário
│       ├── repositories/              # Implementações de repositórios
│       │   └── engine_local_storage/         # Repositório de storage local
│       │       ├── engine_local_storage_get_storage_repository.dart
│       │       └── i_engine_local_storage_repository.dart
│       └── translations/              # Traduções
│           └── engine_transalarion.dart      # Sistema de traduções
├── engine.dart                        # Ponto de entrada principal
├── pubspec.yaml                       # Configurações e dependências
└── README.md                          # Este arquivo
```

## 📦 Dependências

### **Dependências Principais**
- `flutter` - Framework principal
- `get` ^4.7.2 - Gerenciamento de estado e navegação
- `get_storage` ^2.1.1 - Armazenamento local
- `firebase_analytics` ^11.5.0 - Analytics
- `firebase_core` ^3.14.0 - Core do Firebase
- `firebase_crashlytics` ^4.3.7 - Rastreamento de erros
- `firebase_messaging` ^15.2.7 - Push notifications
- `firebase_remote_config` ^5.4.5 - Configuração remota
- `lucid_validation` ^1.3.1 - Validação de formulários
- `intl` ^0.20.2 - Internacionalização
- `package_info_plus` ^8.3.0 - Informações do app
- `url_launcher` ^6.3.1 - Launcher de URLs
- `internet_connection_checker_plus` ^2.7.2 - Verificação de conectividade

### **Design System**
- `design_system` - Sistema de design customizado (repositório externo)

### **Dependências de Desenvolvimento**
- `flutter_test` - Testes
- `flutter_lints` ^6.0.0 - Linting

## 🛠️ Instalação

### 1. Adicione ao `pubspec.yaml`

```yaml
dependencies:
  engine:
    git:
      url: https://github.com/moreirawebmaster/engine.git
```

### 2. Execute o comando

```bash
flutter pub get
```

### 3. Importe no seu projeto

```dart
import 'package:engine/engine.dart';
```

## 🏛️ Arquitetura

O Engine segue uma arquitetura em camadas bem definida:

### **Camada Core** 
Contém as funcionalidades principais e abstrações base

### **Camada Data**
Gerencia modelos, repositórios e fontes de dados

### **Camada Apps**
Configuração e inicialização da aplicação

### **Padrões Utilizados**
- **Repository Pattern** - Para abstração de dados
- **Service Layer** - Para lógica de negócio
- **Dependency Injection** - Para inversão de controle
- **Observer Pattern** - Para monitoramento de eventos

## ⚡ Funcionalidades Principais

### 🔧 **Sistema de Configuração**
- Configuração centralizada da aplicação
- Gerenciamento de ambientes (dev, prod, staging)
- Feature flags dinâmicas

### 🌐 **Comunicação HTTP**
- Cliente HTTP configurado com interceptadores
- Gerenciamento automático de tokens
- Retry automático para falhas
- Logging detalhado de requisições

### 🏪 **Armazenamento Local**
- Abstração para differentes providers de storage
- Implementação com GetStorage
- Interface consistente para dados locais

### 🌍 **Internacionalização**
- Sistema completo de traduções
- Validações localizadas
- Suporte a múltiplos idiomas

### 📊 **Analytics e Monitoramento**
- Integração com Firebase Analytics
- Crash reporting automático
- Feature flags remotas

### 🎯 **Navegação Avançada**
- Sistema de rotas tipado
- Middleware para controle de acesso
- Observadores de navegação

## 📱 Como Usar

### **1. Configuração Inicial**

```dart
Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await EngineMaterialApp.initialize(
      firebaseModel: DefaultFirebaseOptionsConfig.currentPlatform,
      bugTrackingModel: EngineBugTrackingModel(crashlyticsEnabled: true),
      themeMode: ThemeMode.light,
    );

    runApp(
      EngineMaterialApp(
        appBinding: AppBindings(),
        debugShowCheckedModeBanner: false,
        title: 'App',
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        initialBinding: AppBindings(),
        translations: AppTranslation(),
      ),
    );
  },
      (final error, final stack) => EngineLog.fatal(
            'Error occurred in runZonedGuarded',
            error: error,
            stackTrace: stack,
          ));
}
```

### **2. Configuração da Aplicação**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EngineMaterialApp(
      appBinding: MyAppBinding(),
      translations: MyTranslations(),
      title: 'Minha Aplicação',
      theme: MyTheme.light,
      darkTheme: MyTheme.dark,
      getPages: AppRoutes.pages,
    );
  }
}
```

### **3. Criando um Repositório**

```dart
abstract class IUserRepository{
 Future<EngineHttpResponse<String,UserResponseDto>> getUser(String id);
}
class UserRepository extends EngineBaseRepository implements IUserRepository {
  final String _pathUser = '/user/data';

  @override
  void onInit() {
    EngineLog.debug('UserRepository has been initialized');
    super.baseUrl = AppSettings().userBaseUrl;
    super.onInit();
  }

  Future<EngineHttpResponse<String, UserResponseDto>> getUser(String id) async {
     try {
      final response = await get('$_pathUser/$id');

      if (response.isOk) {
        try {
          final order = OrderResponseDto.fromMap(response.body);
          return Successful(order);
        } catch (e) {
          return Failure('Failed to parse UserResponseDto: $e');
        }
      }

      return Failure(response.bodyString ?? GlobalTranslation.internalServerErrorServer.tr);
    } catch (e) {
      return Failure(e);
    }
  }
}
```

## 🧪 Testes

### **Status dos Testes**
- ✅ **Implementados:** 228 testes passando (+33 novos para Mensagens!)  
- ✅ **Cobertura:** FASE 1 ✅ + FASE 2A ✅ + FASE 2B ✅ + **FASE 2C ✅ AVANÇANDO**
- ✅ **Módulos testados:** HTTP Result, User Model, Token Model, Map Extensions, String Extensions, **EngineLog**, **EngineMessage**
- 🔄 **Em desenvolvimento:** Repository Base, Modelos Adicionais

### **Estrutura de Testes Implementada**

```
test/
├── unit/                          # Testes unitários
│   ├── core/                     # Testes do core
│   │   ├── extensions/           # ✅ Extensions - 77 testes
│   │   │   ├── map_extension_test.dart          # 41 testes
│   │   │   └── string_extension_test.dart       # 36 testes
│   │   ├── helpers/              # ✅ Helpers - 70 testes
│   │   │   ├── engine_log_test.dart             # 37 testes
│   │   │   └── engine_message_test.dart         # 33 testes
│   │   └── http/                 # ✅ HTTP - 32 testes
│   │       └── engine_http_result_test.dart
│   └── data/                     # Testes da camada de dados
│       └── models/               # ✅ Models - 49 testes
│           ├── engine_user_model_test.dart      # 21 testes
│           └── engine_token_model_test.dart     # 28 testes
├── helpers/                      # ✅ Utilitários de teste
│   ├── test_utils.dart          # Helpers comum
│   └── fixtures/                # Dados de teste
│       ├── user_data.json
│       └── http_responses.json
├── integration/                  # Testes de integração
└── flutter_test_config.dart     # ✅ Configuração global
```

### **Executar Testes**

```bash
# Todos os testes
flutter test

# Testes unitários específicos
flutter test test/unit/

# Com cobertura
flutter test --coverage

# Teste específico
flutter test test/unit/core/http/engine_http_result_test.dart
```

### **Próximos Testes (FASE 2C - Helpers)**
- ✅ EngineLog (sistema de logging crítico) ⭐⭐⭐ - **37 testes implementados**
- ✅ EngineMessage (sistema de mensagens) ⭐⭐ - **33 testes implementados**
- EngineBaseRepository (HTTP methods, interceptors) ⭐⭐⭐
- Additional Models (credential_token, firebase_model) ⭐⭐

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE.md](LICENSE.md) para detalhes.

## 🚀 Versão

**v1.0.0** - Versão inicial com funcionalidades principais implementadas

---

**Desenvolvido com ❤️ por Thiago Moreira**
