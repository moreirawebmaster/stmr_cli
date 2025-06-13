# 🚀 STMR CLI - Guia de Instalação e Uso

## 📦 Instalação

### Instalação Global (Recomendada)

```bash
# Instalar diretamente do repositório GitHub
dart pub global activate --source git https://github.com/moreirawebmaster/stmr_cli.git

# Verificar se foi instalado corretamente
stmr --version
```

### Instalação Local (Para Desenvolvimento)

```bash
# Clonar o repositório
git clone https://github.com/moreirawebmaster/stmr_cli.git
cd stmr_cli

# Instalar localmente
dart pub global activate --source path .

# Ou executar diretamente
dart run bin/stmr.dart --version
```

## 🛠️ Comandos Disponíveis

### Verificar Versão
```bash
stmr --version
```

### Verificar Atualizações
```bash
# Apenas verificar se há atualizações
stmr upgrade --check

# Verificar e atualizar se disponível
stmr upgrade

# Forçar reinstalação
stmr upgrade --force
```

### Criar Projeto
```bash
stmr create meu_projeto
```

### Criar Feature/Módulo
```bash
stmr feature login
stmr feature dashboard
```

### Gerar Componentes
```bash
# Gerar página com controller
stmr generate page login

# Gerar apenas controller
stmr generate controller user

# Gerar repository
stmr generate repository auth

# Gerar DTO a partir de JSON
stmr generate dto user '{"id": 1, "name": "João", "email": "joao@email.com"}'
```

## 🔧 Resolução de Problemas

### Comando não encontrado
Se o comando `stmr` não for encontrado após a instalação:

```bash
# Verificar se o PATH inclui o diretório do pub global
export PATH="$PATH:$HOME/.pub-cache/bin"

# Adicionar ao seu shell profile (bash_profile, zshrc, etc.)
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Erro ao verificar atualizações
Se receber erro ao executar `stmr upgrade`:

1. Verifique se o git está instalado
2. Verifique sua conexão com a internet
3. Use a flag `--check` para apenas verificar sem atualizar
4. Reinstale o CLI se necessário

### Executar sem instalação global
Se não conseguir instalar globalmente, execute diretamente:

```bash
git clone https://github.com/moreirawebmaster/stmr_cli.git
cd stmr_cli
dart run bin/stmr.dart <comando>
```

## 📝 Exemplos de Uso

### Criar um projeto completo
```bash
# 1. Criar projeto
stmr create meu_app
cd meu_app

# 2. Instalar dependências
flutter pub get

# 3. Criar módulo de autenticação
stmr feature auth

# 4. Gerar página de login
stmr generate page login

# 5. Gerar repository de usuário
stmr generate repository user

# 6. Executar projeto
flutter run
```

### Estrutura gerada
```
meu_app/
├── lib/
│   ├── main.dart
│   └── modules/
│       └── auth/
│           ├── bindings/
│           ├── models/
│           ├── presentations/
│           │   ├── controllers/
│           │   ├── pages/
│           │   └── components/
│           ├── repositories/
│           └── usecases/
```

## 🆘 Suporte

Se encontrar problemas:

1. Verifique se todas as dependências estão instaladas (Dart SDK, Flutter, Git)
2. Execute com `--help` para ver todas as opções
3. Abra uma issue no [repositório GitHub](https://github.com/moreirawebmaster/stmr_cli/issues) 