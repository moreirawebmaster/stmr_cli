# 🚀 STMR CLI

CLI oficial para projetos Flutter da STMR, baseado na arquitetura limpa e padrões estabelecidos.

## ✨ Funcionalidades

- 🏗️ **Criar projetos** completos baseados no skeleton STMR
- 📦 **Criar módulos** com arquitetura limpa 
- 🔧 **Gerar componentes** individuais (pages, controllers, repositories, DTOs)
- 🔄 **Auto-update** integrado
- 💡 **Sistema de help** completo para todos os comandos

## 📦 Instalação

### Via Pub Global (Recomendado)

```bash
dart pub global activate --source git https://github.com/moreirawebmaster/stmr_cli.git
```

### Via Clone Local

```bash
git clone https://github.com/moreirawebmaster/stmr_cli.git
cd stmr_cli
dart pub global activate --source path .
```

## 🛠️ Setup para Desenvolvedores

### 📋 Pré-requisitos

- **Dart SDK** >= 3.0.0
- **Flutter** >= 3.10.0
- **Node.js** >= 16.0.0 (para Husky)
- **Git** configurado

### 🚀 Setup Inicial (Novos Desenvolvedores)

```bash
# 1. Clone o repositório
git clone https://github.com/moreirawebmaster/stmr_cli.git
cd stmr_cli

# 2. Instalar dependências Dart
dart pub get

# 3. Instalar dependências Node.js (para Husky)
npm install

# 4. Configurar Husky (hooks automáticos)
npm run prepare

# 5. Verificar se tudo está funcionando
dart analyze
dart test
```

### 🔧 Configuração de Hooks

O projeto usa **Husky** para hooks automáticos que garantem qualidade de código:

#### 🛡️ Pre-commit Hook
- **Localização**: `.husky/pre-commit`
- **Função**: Valida qualidade do código antes de cada commit
- **Verificações**:
  - ✅ `dart analyze` - Análise estática
  - ❌ Bloqueia commits com problemas de lint

#### 📤 Pre-push Hook  
- **Localização**: `.husky/pre-push`
- **Status**: Desabilitado (versionamento delegado para CI/CD)
- **Função**: Apenas informa sobre a mudança de responsabilidade

### 🔄 Fluxo de Desenvolvimento

```bash
# 1. Criar branch para feature
git checkout -b feature/nova-funcionalidade

# 2. Fazer alterações no código
# ... desenvolvimento ...

# 3. Verificar qualidade (opcional - hook fará automaticamente)
dart analyze
dart test

# 4. Commit (hook pre-commit validará automaticamente)
git add .
git commit -m "feat: adiciona nova funcionalidade"
# ✅ Hook pre-commit: dart analyze executado automaticamente

# 5. Push (sem validações extras - pipeline CI/CD assumiu)
git push origin feature/nova-funcionalidade
# ✅ Pipeline CI/CD executará testes e validações

# 6. Criar Pull Request
# ✅ Pipeline de PR validará código automaticamente
```

### 🚨 Troubleshooting

#### Hook Pre-commit Falhando
```bash
# Ver problemas específicos
dart analyze

# Corrigir automaticamente (quando possível)
dart fix --apply

# Tentar commit novamente
git commit -m "sua mensagem"
```

#### Husky Não Funcionando
```bash
# Reinstalar Husky
rm -rf node_modules
npm install
npm run prepare

# Verificar permissões
chmod +x .husky/pre-commit
chmod +x .husky/pre-push
```

#### Problemas de Dependências
```bash
# Limpar cache Dart
dart pub cache clean
dart pub get

# Limpar cache Node
npm cache clean --force
npm install
```

### 📊 Pipeline CI/CD

O projeto possui pipeline automatizada que:

#### 🧪 Para Pull Requests:
- Executa `dart analyze`
- Executa `dart test`
- Comenta automaticamente no PR com resultados

#### 🚀 Para Push na Main:
- Executa testes completos
- **Versionamento automático** (bump patch)
- Atualiza `pubspec.yaml` e `lib/src/version.dart`
- Cria **tag** automaticamente
- Cria **release** no GitHub

### 🎯 Comandos Úteis para Desenvolvimento

```bash
# Executar CLI localmente
dart run bin/stmr.dart --help

# Executar testes
dart test

# Análise de código
dart analyze

# Corrigir problemas automaticamente
dart fix --apply

# Sincronização manual (opcional)
dart run tool/push_and_sync.dart

# Verificar versão atual
grep "version:" pubspec.yaml
```

### 📁 Estrutura do Projeto

```
stmr_cli/
├── .github/workflows/     # Pipeline CI/CD
│   ├── auto-release.yml   # Pipeline principal
│   └── pr-validation.yml  # Validação de PRs
├── .husky/               # Hooks do Husky
│   ├── pre-commit        # Validação de lint
│   └── pre-push          # Desabilitado
├── .githooks/            # Hooks alternativos (Git nativo)
│   └── pre-commit        # Backup do hook de lint
├── bin/                  # Executável principal
├── lib/                  # Código fonte
├── test/                 # Testes
├── tool/                 # Ferramentas auxiliares
├── package.json          # Configuração Node.js/Husky
└── pubspec.yaml          # Configuração Dart
```

## 🛠️ Comandos Disponíveis

### 🎯 Ajuda

Obtenha ajuda sobre qualquer comando:

```bash
stmr --help                    # Ajuda geral
stmr create --help             # Ajuda do comando create
stmr feature --help            # Ajuda do comando feature
stmr generate --help           # Ajuda do comando generate
stmr upgrade --help            # Ajuda do comando upgrade
```

### 🏗️ Criar Projeto

Cria um novo projeto Flutter baseado no skeleton STMR:

```bash
stmr create meu_app
stmr create meu_app --name "Meu App" --org com.minhaempresa
```

**Opções:**
- `--name`: Nome do projeto (substitui "skeleton" nos arquivos)
- `--org`: Organização (substitui "tech.stmr") [padrão: tech.stmr]

### 📦 Criar Módulo

Cria uma nova feature com estrutura completa seguindo a arquitetura limpa:

```bash
stmr feature auth              # Módulo de autenticação
stmr feature user              # Módulo de usuário
stmr feature dashboard         # Módulo de dashboard
```

**Estrutura criada:**
```
lib/modules/<modulo>/
├── presentations/
│   ├── pages/
│   └── controllers/
├── repositories/
│   └── dtos/
├── <modulo>_routes.dart
├── <modulo>_bindings.dart
└── <modulo>_constants.dart
```

### 🔧 Gerar Componentes

Gera componentes individuais dentro de módulos existentes:

#### Pages
```bash
stmr generate page login       # Gera LoginPage + LoginController
stmr generate page profile     # Gera ProfilePage + ProfileController
```

#### Controllers
```bash
stmr generate controller user  # Gera UserController
stmr generate controller auth  # Gera AuthController
```

#### Repositories
```bash
stmr generate repository api   # Gera ApiRepository + IApiRepository
stmr generate repository user  # Gera UserRepository + IUserRepository
```

#### DTOs
```bash
stmr generate dto user '{"id": 1, "name": "John", "email": "john@example.com"}'
stmr generate dto product '{"id": 1, "title": "Produto", "price": 99.99, "active": true}'
```

### 🔄 Atualizar CLI

Mantém o CLI sempre atualizado:

```bash
stmr upgrade                   # Atualiza para a versão mais recente
stmr upgrade --check           # Apenas verifica se há atualizações
stmr upgrade --force           # Força a reinstalação
```

## 📁 Estrutura Gerada

### Projeto Completo

```
meu_app/
├── lib/
│   ├── core/              # Recursos compartilhados
│   ├── modules/           # Features modulares
│   ├── data/              # Dados globais
│   └── routes/            # Sistema de rotas
├── android/               # Configuração Android
├── ios/                   # Configuração iOS
└── pubspec.yaml          # Dependencies
```

### Templates Incluídos

Todos os componentes gerados seguem os padrões STMR:

- **Pages**: Extendem `EngineBasePage` com estrutura responsiva
- **Controllers**: Extendem `EngineBaseController` com estados de loading/erro
- **Repositories**: Implementam interfaces e extendem `EngineBaseRepository`
- **DTOs**: Extendem `EngineBaseModel` com `fromJson`, `toJson` e `copyWith`

## 🏗️ Arquitetura

O CLI gera código seguindo a **Clean Architecture**:

- **Presentation**: Controllers + Pages
- **Domain**: Use Cases + Models  
- **Data**: Repositories + DTOs

Padrão **MVVM** com GetX:
- **Model**: Validação e representação de dados
- **View**: Interface do usuário (Pages)
- **ViewModel**: Lógica de apresentação (Controllers)

## 🧪 Exemplo Completo

### Criar projeto e estrutura

```bash
# 1. Criar novo projeto
stmr create loja_virtual --name "Loja Virtual" --org com.minhaempresa

# 2. Navegar para o projeto
cd loja_virtual

# 3. Criar módulos
stmr feature auth
stmr feature products
stmr feature cart

# 4. Gerar componentes específicos
stmr generate page login
stmr generate page register
stmr generate controller user
stmr generate repository api
stmr generate dto product '{"id": 1, "name": "Produto", "price": 99.99}'

# 5. Executar projeto
flutter pub get
flutter run
```

### Estrutura Final

```
loja_virtual/
├── lib/
│   └── modules/
│       ├── auth/
│       │   ├── presentations/
│       │   │   ├── pages/
│       │   │   │   ├── login_page.dart
│       │   │   │   └── register_page.dart
│       │   │   └── controllers/
│       │   │       ├── login_controller.dart
│       │   │       ├── register_controller.dart
│       │   │       └── user_controller.dart
│       │   └── repositories/
│       │       ├── api_repository.dart
│       │       └── dtos/responses/
│       │           └── product_response_dto.dart
│       ├── products/
│       └── cart/
```

## 🔧 Desenvolvimento

### Executar localmente

```bash
git clone https://github.com/moreirawebmaster/stmr_cli.git
cd stmr_cli
dart pub get
dart run bin/stmr.dart --help
```

### Executar testes

```bash
dart test                      # Executar todos os testes
dart analyze                   # Análise estática
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'feat: adiciona nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra um Pull Request

## 📝 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🆘 Suporte

Para suporte e dúvidas:
- 📧 Email: suporte@stmr.com
- 🐛 Issues: [GitHub Issues](https://github.com/moreirawebmaster/stmr_cli/issues)
- 📖 Documentação: [Wiki](https://github.com/moreirawebmaster/stmr_cli/wiki)

---

**Desenvolvido pela equipe STMR** 🚀 