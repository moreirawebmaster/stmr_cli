# 🚀 Sistema de Versionamento Automático

O STMR CLI utiliza **Husky** para automatizar o versionamento a cada commit na branch `main`.

## 🔧 Como Funciona

### 1. **Trigger Automático**
- **Quando**: A cada `git commit` na branch `main`
- **Ação**: Incrementa automaticamente a versão patch (+0.0.1)
- **Inclusão**: Adiciona os arquivos atualizados ao commit atual

### 2. **Fluxo de Execução**
```bash
git commit -m "feat: nova funcionalidade"
    ↓
🔍 Husky detecta commit na main (pre-commit hook)
    ↓
📦 Executa tool/auto_version.dart
    ↓
🚀 Incrementa versão (1.0.8 → 1.0.9)
    ↓
📄 Atualiza pubspec.yaml E version.dart
    ↓
✅ Adiciona arquivos ao commit atual
    ↓
🎯 Um único commit com versão incrementada
```

## 📁 Arquivos do Sistema

### 1. **`tool/auto_version.dart`**
Script principal que:
- ✅ Verifica se está na branch `main`
- ✅ Lê versão atual do `pubspec.yaml`
- ✅ Incrementa versão patch
- ✅ **Atualiza `pubspec.yaml` E `lib/src/version.dart`**
- ✅ **NÃO cria commits** (inclui no commit atual)

### 2. **`.husky/pre-commit`**
Hook do Git que:
- ✅ Executa **antes** do commit finalizar
- ✅ Chama o script Dart
- ✅ Adiciona arquivos atualizados ao commit
- ✅ Opera apenas na branch `main`

### 3. **`package.json`**
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

### ✅ **Um Único Commit**
- **PROBLEMA RESOLVIDO**: Não cria mais commits duplos
- Versão incrementada incluída no commit original
- Histórico limpo sem commits de versionamento separados

### ✅ **Sincronização Dupla**
- **PROBLEMA RESOLVIDO**: `version.dart` sempre sincronizado
- `pubspec.yaml` e `lib/src/version.dart` sempre iguais
- CLI sempre mostra versão correta

### ✅ **Apenas na Main**
- Branches de feature não são afetadas
- Versionamento controlado na branch principal

### ✅ **Integração CI/CD**
- Sem commits extras desnecessários
- Compatível com GitHub Actions, GitLab CI, etc.

## 🔄 Exemplo de Funcionamento

### **Antes (Problemático):**
```bash
git commit -m "feat: nova funcionalidade"    # Commit 1
# Hook criava automaticamente...
git commit -m "chore: bump version to 1.0.5" # Commit 2 ❌
```

### **Agora (Corrigido):**
```bash
git commit -m "feat: nova funcionalidade"    # Commit único ✅
# Versão incrementada incluída no mesmo commit
# pubspec.yaml: 1.0.8 → 1.0.9
# version.dart: 1.0.8 → 1.0.9
```

## 🛠️ Comandos Úteis

### **Testar Versionamento**
```bash
# Executa o script manualmente
dart tool/auto_version.dart

# Ou via npm
npm run version:auto
```

### **Verificar Sincronização**
```bash
# Ambos devem ter a mesma versão
grep "version:" pubspec.yaml
grep "cliVersion" lib/src/version.dart

# No CLI
dart run bin/stmr.dart --version
```

### **Ver Histórico de Versões**
```bash
# Últimos commits (agora sem commits duplos)
git log --oneline -5

# Verificar que versão está no commit
git show --stat HEAD
```

## 🚨 Troubleshooting

### **Hook não executando?**
```bash
# Verificar se Husky está instalado
npx husky --version

# Reinstalar hooks
npm run prepare

# Verificar permissões
chmod +x .husky/pre-commit
```

### **Versões desincronizadas?**
```bash
# Executar manualmente para sincronizar
dart tool/auto_version.dart

# Verificar se ambos foram atualizados
grep -A1 -B1 "version\|cliVersion" pubspec.yaml lib/src/version.dart
```

### **Versionamento não funcionando?**
```bash
# Verificar branch
git branch --show-current

# Deve ser 'main' para funcionar
git checkout main
```

## 📊 Exemplo Completo

```bash
# Desenvolvimento normal
git add .
git commit -m "feat: nova funcionalidade incrível"

# Output automático:
# 🔍 Verificando se precisa incrementar versão...
# 📦 Executando auto-versionamento na branch main...
# 🚀 Versão incrementada: 1.0.8 → 1.0.9
# 📄 Arquivos atualizados: pubspec.yaml, lib/src/version.dart
# ✅ Versionamento automático concluído

# Resultado:
# ✅ UM commit com sua funcionalidade + versão incrementada
# ✅ pubspec.yaml e version.dart sincronizados
# ✅ CLI funciona com versão correta
```

## 🎉 Correções Implementadas

### ❌ **Problemas Anteriores:**
1. **Commits duplos**: Hook `pre-push` criava commit separado
2. **version.dart desatualizado**: Só atualizava pubspec.yaml
3. **Push duplo**: Commit de versionamento gerava segundo push

### ✅ **Soluções Implementadas:**
1. **Hook `pre-commit`**: Executa antes do commit finalizar
2. **Dupla sincronização**: Atualiza ambos os arquivos
3. **Inclusão automática**: `git add` dos arquivos no commit atual
4. **Sem commits extras**: Tudo em um único commit

---

**Sistema agora é 100% funcional e resolve todos os problemas de versionamento automático!** 🚀 