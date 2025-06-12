# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.0.0] - 2024-12-19

### Adicionado
- CLI básico com comando `stmr`
- Comando `create project` para gerar projetos Flutter baseados no skeleton STMR
- Comando `feature` para gerar features completas com arquitetura limpa
- Templates automáticos para:
  - Binding (injeção de dependências)
  - Controller (ViewModel)
  - Model (entidades de dados)
  - Page (interface do usuário)
  - UseCase (regras de negócio)
  - Repository (camada de dados)
  - Keys (identificadores para testes e traduções)
- Registro automático de rotas
- Substituição automática de nomes de projeto
- Configuração automática de package names Android/iOS
- Documentação completa
- Suporte para Clean Architecture
- Padrão MVVM com GetX

### Funcionalidades
- ✅ Clonagem automática do skeleton do GitHub
- ✅ Substituição inteligente de nomes e namespaces
- ✅ Criação de estrutura modular por features
- ✅ Registro automático de rotas no sistema de navegação
- ✅ Templates seguindo boas práticas da STMR
- ✅ Instalação automática de dependências Flutter
- ✅ Limpeza automática em caso de erro

### Comandos Disponíveis
- `stmr create project <nome>` - Cria novo projeto
- `stmr feature <nome>` - Cria nova feature
- `stmr --help` - Mostra ajuda
- `stmr --version` - Mostra versão

### Estrutura de Arquivos
```
lib/
├── src/
│   ├── cli_runner.dart        # Runner principal
│   ├── commands/              # Comandos do CLI
│   │   ├── create_command.dart
│   │   └── feature_command.dart
│   ├── templates/             # Templates de código
│   │   └── feature_templates.dart
│   └── utils/                 # Utilitários
│       ├── file_utils.dart
│       └── string_replacement.dart
└── stmr_cli.dart             # Biblioteca principal
``` 