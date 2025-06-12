# 🚀 STMR CLI

CLI oficial para projetos Flutter da STMR, baseado na arquitetura limpa e padrões estabelecidos.

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

## 🛠️ Comandos Disponíveis

### Criar Projeto

Cria um novo projeto Flutter baseado no skeleton STMR:

```bash
stmr create project meu_app
```

O comando irá:
- Clonar o [skeleton STMR](https://github.com/moreirawebmaster/skeleton.git)
- Substituir nomes do projeto automaticamente
- Configurar package names no Android/iOS
- Instalar dependencies

### Criar Feature

Cria uma nova feature com estrutura completa seguindo a arquitetura limpa:

```bash
stmr feature login
stmr feature dashboard
stmr feature user_profile
```

O comando irá criar:
- 📁 Estrutura de pastas completa
- 📄 Binding, Controller, Model, Page
- 🔧 UseCase e Repository
- 🗝️ Keys para testes e traduções
- 🛣️ Rotas registradas automaticamente

## 📁 Estrutura Gerada

### Projeto

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

### Feature

```
modules/login/
├── bindings/              # Injeção de dependências
├── models/                # Modelos de dados
├── presentations/         
│   ├── controllers/       # ViewModels (Controllers)
│   ├── pages/             # Views (Pages)
│   └── components/        # Componentes específicos
├── use_cases/             # Regras de negócio
├── repositories/          # Camada de dados
│   └── dtos/              # DTOs de request/response
└── keys/                  # Keys para testes/traduções
```

## 🏗️ Arquitetura

O CLI gera código seguindo a **Clean Architecture**:

- **Presentation**: Controllers + Pages
- **Domain**: Use Cases + Models  
- **Data**: Repositories + DTOs

Padrão **MVVM** com GetX:
- **Model**: Validação e representação de dados
- **View**: Interface do usuário (Pages)
- **ViewModel**: Lógica de apresentação (Controllers)

## ⚙️ Configuração

O CLI respeita configurações no `pubspec.yaml`:

```yaml
stmr_cli:
  separator: "."           # Separador de arquivos
  sub_folder: false        # Estrutura de pastas plana
```

## 🧪 Exemplos de Uso

### Criar projeto completo

```bash
# Criar novo projeto
stmr create project loja_virtual

# Navegar para o projeto
cd loja_virtual

# Criar features
stmr feature auth
stmr feature products
stmr feature cart
stmr feature profile

# Executar projeto
flutter run
```

### Estrutura final

```
loja_virtual/
├── lib/
│   └── modules/
│       ├── auth/          # Feature de autenticação
│       ├── products/      # Feature de produtos
│       ├── cart/          # Feature de carrinho
│       └── profile/       # Feature de perfil
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