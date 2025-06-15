# 🚀 Sistema de Versionamento Automático

O STMR CLI utiliza **Husky** com hooks separados para **qualidade de código** e **versionamento automático**.

## 🔧 Como Funciona

### 1. **Responsabilidades Separadas**
- **pre-commit**: Verifica qualidade do código (`dart analyze`)
- **pre-push**: Incrementa versão automaticamente e amenda ao commit

### 2. **Fluxo de Execução**
```bash
git commit -m "feat: nova funcionalidade"
    ↓
🔍 pre-commit: Executa dart analyze
    ↓
✅ Commit criado (se lint OK)
    ↓
git push origin main
    ↓
🔍 pre-push: Detecta push na main
    ↓
📦 Executa tool/auto_version.dart
    ↓
🚀 Incrementa versão (1.0.9 → 1.0.10)
    ↓
📄 Atualiza pubspec.yaml E version.dart
    ↓
✅ Amenda arquivos ao último commit
    ↓
🎯 Push único com versão incrementada
```

## 📁 Arquivos do Sistema

### 1. **`.husky/pre-commit`**
Hook de qualidade que:
- ✅ Executa `dart analyze`
- ✅ Bloqueia commit se houver issues de lint
- ✅ Sugere `dart fix --apply` para correção automática

### 2. **`.husky/pre-push`**
Hook de versionamento que:
- ✅ Executa apenas na branch `main`
- ✅ Chama o script de bump
- ✅ Amenda versão ao commit atual
- ✅ Permite push prosseguir

### 3. **`tool/auto_version.dart`**
Script principal que:
- ✅ Verifica branch `main`
- ✅ Lê versão atual do `pubspec.yaml`
- ✅ Incrementa versão patch
- ✅ **Atualiza `pubspec.yaml` E `lib/src/version.dart`**
- ✅ **Não cria commits** (usado pelo hook)

### 4. **`package.json`**
Configuração do Husky:
```json
{
  "scripts": {
    "version:auto": "dart tool/auto_version.dart",
    "prepare": "husky"
  },
  "devDependencies": {
    "husky": "^9.0.11"
  }
}
```

## 🎯 Vantagens

### ✅ **Qualidade Garantida**
- **pre-commit**: Código sempre conforme lint antes do commit
- **Bloqueio automático**: Commits inválidos são rejeitados
- **Correção sugerida**: `dart fix --apply` para resolver automaticamente

### ✅ **Versionamento Inteligente**
- **pre-push**: Bump apenas no momento do push
- **Branch-specific**: Apenas na `main`
- **Amend automático**: Versão incluída no commit original

### ✅ **Um Único Commit Final**
- **Sem commits duplos**: Versão amendada ao commit original
- **Histórico limpo**: Cada funcionalidade = um commit com versão
- **Sincronização garantida**: pubspec.yaml + version.dart sempre iguais

### ✅ **Separação de Responsabilidades**
- **Qualidade**: Verificada no commit
- **Versionamento**: Aplicado no push
- **Flexibilidade**: Pode commitar sem fazer push imediato

## 🔄 Exemplo de Funcionamento

### **Fluxo Ideal:**
```bash
# 1. Desenvolve funcionalidade
git add .
git commit -m "feat: nova funcionalidade incrível"

# Output do pre-commit:
# 🔍 Verificando conformidade do código...
# Analyzing stmr_cli... No issues found!
# ✅ Código está em conformidade com o lint

# 2. Faz push quando pronto
git push origin main

# Output do pre-push:
# 🔍 Verificando se precisa incrementar versão antes do push...
# 📦 Executando auto-versionamento na branch main...
# 🚀 Versão incrementada: 1.0.9 → 1.0.10
# 📄 Arquivos atualizados: pubspec.yaml, lib/src/version.dart
# ✅ Versionamento automático concluído
# 🚀 Versão adicionada ao último commit, prosseguindo com push...

# Resultado final:
# ✅ Um commit com funcionalidade + versão incrementada
# ✅ pubspec.yaml: 1.0.10
# ✅ version.dart: 1.0.10
# ✅ CLI: stmr --version → 1.0.10
```

### **Caso de Lint Error:**
```bash
git commit -m "feat: código com problemas"

# Output do pre-commit:
# 🔍 Verificando conformidade do código...
# Analyzing stmr_cli... 3 issues found!
# ❌ Código não está em conformidade com o lint
# Execute 'dart fix --apply' para corrigir automaticamente

# Commit BLOQUEADO até corrigir lint ✅
```

## 🛠️ Comandos Úteis

### **Corrigir Lint Automaticamente**
```bash
# Corrige a maioria dos problemas de lint
dart fix --apply

# Verifica se está tudo OK
dart analyze
```

### **Testar Hooks Manualmente**
```bash
# Testa o pre-commit (lint)
dart analyze

# Testa o versionamento (apenas se na main)
dart tool/auto_version.dart

# Ou via npm
npm run version:auto
```

### **Verificar Sincronização**
```bash
# Todos devem ter a mesma versão
grep "version:" pubspec.yaml
grep "cliVersion" lib/src/version.dart
dart run bin/stmr.dart --version
```

## 🚨 Troubleshooting

### **Lint bloqueando commit?**
```bash
# Corrige automaticamente
dart fix --apply

# Ou corrige manualmente e tenta novamente
git commit -m "sua mensagem"
```

### **Hook não executando?**
```bash
# Reinstalar hooks
npm run prepare

# Verificar permissões
chmod +x .husky/pre-commit .husky/pre-push

# Verificar se Husky está instalado
npx husky --version
```

### **Versionamento não funcionando?**
```bash
# Verificar branch (deve ser main)
git branch --show-current

# Testar manualmente
dart tool/auto_version.dart
```

## 🎉 Benefícios Finais

- **🔍 Qualidade**: Código sempre passa no lint antes do commit
- **🚀 Automação**: Versão incrementada automaticamente no push
- **📦 Único Commit**: Funcionalidade + versão em um commit limpo
- **🎯 Controle**: Apenas branch main é versionada
- **⚡ Performance**: Lint rápido no commit, bump rápido no push
- **🔄 Sincronização**: pubspec.yaml + version.dart sempre iguais

---

**Sistema perfeito: qualidade no commit, versionamento no push!** 🚀 