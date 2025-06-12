# 🚀 Skeleton - Projeto Base Flutter STMR

## 📋 Índice

- [📖 Sobre o Projeto](#-sobre-o-projeto)
- [🏗️ Arquitetura](#️-arquitetura)
  - [Clean Architecture](#clean-architecture)
  - [Padrão MVVM](#padrão-mvvm)
- [📁 Estrutura de Pastas](#-estrutura-de-pastas)
  - [📂 /lib](#-lib)
  - [📂 /lib/core](#-libcore)
  - [📂 /lib/modules](#-libmodules)
  - [📂 /lib/data](#-libdata)
  - [📂 /lib/routes](#-libroutes)
- [🔧 Dependências](#-dependências)
- [🏃‍♂️ Como Executar](#️-como-executar)
- [📋 Padrões e Convenções](#-padrões-e-convenções)
- [🧪 Testes](#-testes)
- [🤝 Contribuição](#-contribuição)

## 📖 Sobre o Projeto

Este projeto é um **skeleton** (esqueleto) base para desenvolvimento de aplicações Flutter na empresa STMR. Foi criado seguindo as melhores práticas de arquitetura limpa e padrões de desenvolvimento, servindo como template para novos projetos.

### ✨ Características Principais

- ✅ Clean Architecture implementada
- ✅ Padrão MVVM com GetX
- ✅ Injeção de dependências
- ✅ Gerenciamento de estado reativo
- ✅ Sistema de roteamento modular
- ✅ Design System personalizado
- ✅ Engine customizada para recursos comuns
- ✅ Internacionalização preparada
- ✅ Logging estruturado
- ✅ Tratamento de erros centralizado

## 🏗️ Arquitetura

### Clean Architecture

O projeto segue os princípios da **Clean Architecture** de Robert C. Martin, organizando o código em camadas bem definidas:

```
┌─────────────────────────────────────┐
│           PRESENTATION              │ ← UI/Controllers/Pages
├─────────────────────────────────────┤
│            USE CASES                │ ← Regras de Negócio
├─────────────────────────────────────┤
│           REPOSITORIES              │ ← Contratos de Dados
└─────────────────────────────────────┘
```

### Padrão MVVM

O projeto utiliza o padrão **MVVM (Model-View-ViewModel)** implementado com GetX:

- **Model**: Model => Representação dos dados que irá ser apresentado a Page e validadores de formulários
- **View**: Pages => Interface do usuário
- **ViewModel**: Controllers => Que fazem a ponte entre View e Model

## 📁 Estrutura de Pastas

### 📂 /lib

Pasta principal contendo todo o código-fonte da aplicação.

```
lib/
├── main.dart             # Ponto de entrada da aplicação
├── lib.dart              # Barrel file principal
├── core/                 # Recursos compartilhados
├── modules/              # Módulos funcionais
├── data/                 # Camada de dados
└── routes/               # Sistema de roteamento
```

### 📂 /lib/core

Contém todos os recursos compartilhados e infraestrutura da aplicação:

```
core/
├── components/           # Componentes reutilizáveis
├── settings/             # Configurações globais
├── middlewares/          # Middlewares de rota globais
├── bindings/             # Injeção de dependências globais
├── helpers/              # Funções auxiliares
├── extensions/           # Extensions do Dart/Flutter
└── services/             # Serviços com regras de negócio compartilhadas
```

#### Responsabilidades:

- **components/**: Componentes customizados reutilizáveis em toda aplicação
- **settings/**: Configurações do Firebase, aplicação
- **middlewares/**: Interceptadores para rotas
- **bindings/**: Configuração da injeção de dependências com Engine(GetX)
- **helpers/**: Funções utilitárias e helpers
- **extensions/**: Extensões para classes nativas do Dart/Flutter
- **services/**: Serviços com regras de négocio transversais (UserService, AppLinkService, etc.)

### 📂 /lib/modules

Organização modular por funcionalidades da aplicação:

```
modules/
├── login/                # Módulo de autenticação
│   ├── bindings/         # DI específica do módulo
│   ├── models/           # Modelo que servirá para validação e auxiliar a Controller com Page
│   ├── presentations/    # Controllers e Pages
│   ├── use_cases/        # Regras de negócio
│   └── keys/             # Chaves para testes e traduções
└── [outros_modulos]/     # Novos módulos seguem mesma estrutura
```

#### Estrutura de um Módulo:

- **bindings/**: Injeção de dependências específicas do módulo
- **models/**: Entidades e objetos de valor do domínio
- **presentations/**: 
  - Controllers (ViewModels)
  - Pages (Views)
  - Components (Componentes específicos) 
- **use_cases/**: Casos de uso contendo regras de negócio
- **repositories/**: Contendo em um unico arquivo o repositorio e interface(abstract, exemplo: IUserRepository, UserRepository)
- **repositories/dtos/requests**: requests para as chamadas apis normalmente usadas em post, put, patch
- **repositories/dtos/responses**: Conversão do json de retorno da api para o dart
- **keys/**: Chaves para identificação em testes e Tradução

### 📂 /lib/data

Camada responsável pelo gerenciamento de dados:

```
data/
├── translations/         # Arquivos de internacionalização
├── themes/               # Temas da aplicação
├── repositories/         # Implementações de repositórios
├── models/               # Modelo global que será utilizado em todo app
├── enums/                # Enumerações
└── constants/            # Constantes da aplicação
```

#### Responsabilidades:

- **translations/**: Arquivos JSON/ARB para i18n
- **themes/**: Definições de temas claro/escuro
- **repositories/**: Implementações concretas dos contratos
- **models/**: Modelo global que será utilizado em todo app
- **enums/**: Enumerações compartilhadas
- **constants/**: Constantes globais da aplicação

### 📂 /lib/routes

Sistema de roteamento modular e organizado:

```
routes/
├── app_routes.dart       # Rotas principais da aplicação
├── login_routes.dart     # Rotas específicas do módulo login
└── [modulo]_routes.dart  # Rotas de outros módulos
```

#### Características:

- Roteamento modular por funcionalidade
- Integração com Engine(GetX) para navegação
- Suporte a middlewares de autenticação
- Tipagem forte para parâmetros de rota

## 🔧 Dependências

### Dependências Principais

- **flutter**: SDK principal
- **design_system**: Sistema de design customizado da STMR
- **engine**: Engine customizada com recursos comuns

### Dependências da Engine

A engine customizada inclui:

- GetX para gerenciamento de estado
- HTTP client configurado
- Logging estruturado
- Tratamento de erros
- Serviços de autenticação
- Firebase integration
- Crash tracking

## 🏃‍♂️ Como Executar

### Pré-requisitos

- Flutter SDK >= 3.32.2
- IDE (VSCode, Android Studio)

### Passos

1. **Clone o repositório**
```bash
git clone [url-do-repositorio]
cd skeleton
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute a aplicação**
```bash
flutter run
```

### Ambientes

```bash
# Desenvolvimento
flutter run --flavor dev -t lib/main_dev.dart

# Produção
flutter run --flavor prod -t lib/main_prod.dart
```

## 📋 Padrões e Convenções

### Nomenclatura

- **Classes**: PascalCase (`LoginController`)
- **Enums**: PascalCase (`StatusType`)
- **Arquivos**: snake_case (`login_controller.dart`)
- **Variáveis**: camelCase (`userName`)
- **Constantes**: camelCase (`apiUrl`)

### Estrutura de Arquivos

- Cada módulo deve seguir a estrutura padrão
- Um arquivo por classe/widget
- Barrel files (`*.dart`) para exportar módulos
- Separação clara entre camadas

### Gerenciamento de Estado

- Use Engine(GetX) para reatividade
- Controllers extendem `EngineBaseController`
- Estados observáveis com `.obs`
- Injeção de dependências com `register.put()`/`register.lazyPut()`

### Tratamento de Erros

```dart
// Use o EngineResult para operações que podem falhar
Future<EngineResult<String, UserModel>> getUser() async {
  try {
    final user = await get('/api/user');
    return Successful(user);
  } catch (e) {
    return Failure('Erro ao buscar usuário');
  }
}
```

## 🧪 Testes

### Estrutura de Testes

```
test/
├── unit/                 # Testes unitários
├── components/           # Testes de components
├── integration/          # Testes de integração
└── mocks/                # Mocks e fakes
```

### Executar Testes

```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/unit/login_test.dart

# Com coverage
flutter test --coverage
```

## 🤝 Contribuição

### Fluxo de Desenvolvimento

1. Crie uma branch feature: `git checkout -b feature/nova-funcionalidade`
2. Desenvolva seguindo os padrões estabelecidos
3. Adicione testes para novas funcionalidades
4. Execute os testes: `flutter test`
5. Faça commit das mudanças: `git commit -m 'feat: adiciona nova funcionalidade'`
6. Push para a branch: `git push origin feature/nova-funcionalidade`
7. Abra um Pull Request

### Padrões de Commit

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` nova funcionalidade
- `fix:` correção de bug
- `docs:` documentação
- `style:` formatação
- `refactor:` refatoração
- `test:` testes
- `chore:` tarefas de build/CI

---

**Desenvolvido pela equipe STMR** 🚀

Para dúvidas ou sugestões, entre em contato com a equipe de desenvolvimento.