# 🚀 Sistema de Versionamento Automático

Este projeto usa **Husky** e **GitHub Actions** para versionamento automático, criação de tags e releases.

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

## 🏷️ **GitHub Actions Auto-Release**

### **Trigger**: Push na branch `main`
### **Ações Automáticas**:
1. Verifica se tag da versão já existe
2. Cria tag `v{version}` se não existir
3. Cria GitHub Release com release notes automáticas
4. Marca como latest release

### 🔧 **Script Manual Post-Push** (Opcional)

### **Comando**: `dart tool/post_push.dart`
### **Ações**:
1. **Auto pull**: Mantém código local atualizado
2. **Criar tag**: Tag local + push para origin
3. **GitHub Release**: Com release notes automáticas (requer GitHub CLI)

## 🎯 **Opções de Release**

### **Automático (Recomendado)**
- GitHub Actions detecta push na main
- Cria tag e release automaticamente
- Release notes geradas dos commits e PRs

### **Push and Sync (Recomendado)**
```bash
# Push com sincronização automática
npm run push
# → Push + versionamento + delay + pull + status

# OU comando direto
dart tool/push_and_sync.dart
```

### **Manual (Opcional)**
```bash
# Após o push, execute localmente para ações extras:
dart tool/post_push.dart
# → Tag local + Release (se GitHub CLI configurado)
```

## 📋 **Versionamento**

### **Estratégia**
- **Auto-increment**: Apenas patch version (1.0.0 → 1.0.1)
- **Manual**: Para major/minor, edite `pubspec.yaml` manualmente

### **Arquivos Sincronizados**
- `pubspec.yaml` - Versão principal do projeto
- `lib/src/version.dart` - Versão compilada no código  
- Git tags - Tags `v{version}` no repositório
- GitHub Releases - Releases automáticos com release notes

## 🔍 **Verificação**

### **Testar Versão**
```bash
# Versão compilada no CLI
stmr --version

# Versão no pubspec
grep "version:" pubspec.yaml

# Tags no repositório  
git tag -l

# Releases no GitHub
gh release list  # (se GitHub CLI instalado)
```

### **Status dos Hooks**
```bash
# Listar hooks ativos
ls -la .husky/

# Testar hook pre-commit
# → Faça um commit com código com lint issues

# Testar hook pre-push  
# → Faça push na main branch
```

## 🚨 **Resolução de Problemas**

### **Hook pre-commit falha**
```bash
# Corrigir issues automaticamente
dart fix --apply

# Verificar manualmente
dart analyze
```

### **Hook pre-push falha**
```bash
# Verificar se tool/auto_version.dart funciona
dart tool/auto_version.dart

# Verificar permissões
chmod +x .husky/pre-push
```

### **GitHub Actions falha**
- Verificar se repositório tem permissões para criar releases
- Conferir logs em Actions tab no GitHub
- Tag pode existir mesmo se release falhou

### **Script post-push falha**
```bash
# Verificar GitHub CLI
gh auth status

# Executar manualmente cada etapa
git pull origin main
git tag v1.0.X  
git push origin v1.0.X
gh release create v1.0.X --generate-notes
```

---

## 💡 **Benefícios**

✅ **Automação Completa**: Versão → Tag → Release sem intervenção manual  
✅ **Qualidade Garantida**: Lint obrigatório antes de commits  
✅ **Histórico Limpo**: Um commit por funcionalidade + versão  
✅ **Release Notes**: Geradas automaticamente dos commits/PRs  
✅ **Fallback**: Script manual disponível se GitHub Actions falhar  
✅ **Flexibilidade**: Funciona local (Husky) + remoto (GitHub Actions) 