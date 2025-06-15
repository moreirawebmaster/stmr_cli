# 🚀 Sistema de Versionamento Automático

O STMR CLI utiliza **Husky** para automatizar o versionamento a cada push na branch `main`.

## 🔧 Como Funciona

### 1. **Trigger Automático**
- **Quando**: A cada `git push` na branch `main`
- **Ação**: Incrementa automaticamente a versão patch (+0.0.1)
- **Commit**: Cria commit automático com a nova versão

### 2. **Fluxo de Execução**
```bash
git push origin main
    ↓
🔍 Husky detecta push na main
    ↓
📦 Executa tool/auto_version.dart
    ↓
🚀 Incrementa versão (1.0.4 → 1.0.5)
    ↓
✅ Cria commit automático
    ↓
🎯 Push completo com nova versão
```

## 📁 Arquivos do Sistema

### 1. **`tool/auto_version.dart`**
Script principal que:
- ✅ Verifica se está na branch `main`
- ✅ Lê versão atual do `pubspec.yaml`
- ✅ Incrementa versão patch
- ✅ Atualiza `pubspec.yaml`
- ✅ Cria commit com `[skip ci]`

### 2. **`.husky/pre-push`**
Hook do Git que:
- ✅ Executa antes de cada push
- ✅ Chama o script Dart
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

### ✅ **Automação Total**
- Sem intervenção manual necessária
- Versionamento consistente
- Zero esquecimento de incrementar versão

### ✅ **Apenas na Main**
- Branches de feature não são afetadas
- Versionamento controlado na branch principal

### ✅ **Integração CI/CD**
- Flag `[skip ci]` evita builds desnecessários
- Compatível com GitHub Actions, GitLab CI, etc.

### ✅ **Histórico Limpo**
- Commits de versionamento padronizados
- Fácil rastreamento de releases

## 🔄 Tipos de Versionamento

### **Automático (Patch)**
```bash
1.0.4 → 1.0.5 → 1.0.6
```
- Executado automaticamente no push
- Para correções e melhorias pequenas

### **Manual (Minor/Major)**
```bash
# Minor: 1.0.6 → 1.1.0
vim pubspec.yaml # Alterar manualmente
git add pubspec.yaml
git commit -m "chore: bump to 1.1.0 - new features"

# Major: 1.1.0 → 2.0.0  
vim pubspec.yaml # Alterar manualmente
git add pubspec.yaml
git commit -m "chore: bump to 2.0.0 - breaking changes"
```

## 🛠️ Comandos Úteis

### **Testar Versionamento**
```bash
# Executa o script manualmente
dart tool/auto_version.dart

# Ou via npm
npm run version:auto
```

### **Verificar Versão**
```bash
# No pubspec.yaml
grep "version:" pubspec.yaml

# No CLI
dart run bin/stmr.dart --version
```

### **Ver Histórico de Versões**
```bash
# Últimos commits de versionamento
git log --oneline --grep="bump version"

# Todas as tags
git tag -l
```

## 🚨 Troubleshooting

### **Hook não executando?**
```bash
# Verificar se Husky está instalado
npx husky --version

# Reinstalar hooks
npm run prepare
```

### **Script com erro?**
```bash
# Verificar permissões
chmod +x tool/auto_version.dart
chmod +x .husky/pre-push

# Testar script isoladamente
dart tool/auto_version.dart
```

### **Versão não incrementando?**
```bash
# Verificar branch
git branch --show-current

# Deve ser 'main' para funcionar
git checkout main
```

## 📊 Exemplo de Uso

```bash
# Desenvolvimento normal
git add .
git commit -m "feat: nova funcionalidade"
git push origin main

# Resultado automático:
# 1. Push do seu commit
# 2. Husky detecta push na main  
# 3. Versão incrementa: 1.0.5 → 1.0.6
# 4. Commit automático criado
# 5. Versão atualizada no repositório
```

## 🎉 Benefícios

- **🔄 Automático**: Zero trabalho manual
- **📈 Consistente**: Sempre incrementa corretamente  
- **🎯 Controlado**: Apenas na branch main
- **🚀 Rápido**: Sem overhead no desenvolvimento
- **📋 Rastreável**: Histórico completo de versões

---

**Este sistema garante que toda release tenha uma versão única e incrementada automaticamente!** 🚀 