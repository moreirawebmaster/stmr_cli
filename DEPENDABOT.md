# 🤖 Dependabot - Atualizações Automáticas

Este projeto usa o **Dependabot** para manter todas as dependências atualizadas automaticamente, garantindo segurança e compatibilidade.

## 📋 Configuração

### 🎯 Ecosistemas Monitorados

#### 1. **Dart/Flutter** (`pubspec.yaml`)
- **Frequência**: Semanal (segundas 09:00 BRT)
- **Dependências**: Diretas e indiretas
- **Limite**: 5 PRs simultâneos
- **Labels**: `dependencies`, `dart`, `automated`

#### 2. **Node.js** (`package.json`)
- **Frequência**: Semanal (segundas 10:00 BRT)
- **Dependências**: Husky e ferramentas
- **Limite**: 3 PRs simultâneos
- **Labels**: `dependencies`, `nodejs`, `automated`

#### 3. **GitHub Actions** (`.github/workflows/`)
- **Frequência**: Semanal (segundas 11:00 BRT)
- **Actions**: Todas as actions usadas
- **Limite**: 3 PRs simultâneos
- **Labels**: `dependencies`, `github-actions`, `automated`

## 🔄 Fluxo de Atualizações

### ✅ **Auto-merge (Patch/Minor)**

```
1. Dependabot cria PR
   ↓
2. Workflow executa testes
   ✅ dart analyze
   ✅ dart test
   ↓
3. Se patch/minor → Auto-approve
   ↓
4. Auto-merge com squash
   ↓
5. Branch deletada automaticamente
```

### ⚠️ **Review Manual (Major)**

```
1. Dependabot cria PR
   ↓
2. Workflow executa testes
   ✅ dart analyze
   ✅ dart test
   ↓
3. Se major → Adiciona comentário
   ↓
4. Label: needs-review
   ↓
5. Aguarda review manual
```

## 📊 Tipos de Updates

### 🟢 **Patch Updates** (Auto-merge)
- `1.0.1` → `1.0.2`
- Correções de bugs
- Patches de segurança
- **Risco**: Baixo

### 🟡 **Minor Updates** (Auto-merge)
- `1.0.0` → `1.1.0`
- Novas funcionalidades
- Backward compatible
- **Risco**: Baixo/Médio

### 🔴 **Major Updates** (Review Manual)
- `1.0.0` → `2.0.0`
- Breaking changes
- API changes
- **Risco**: Alto

## 🛡️ Configurações de Segurança

### Ignorar Updates Perigosos
```yaml
ignore:
  - dependency-name: "*"
    update-types: ["version-update:semver-major"]
```

### Limites de PRs
- **Dart**: 5 PRs máximo
- **Node.js**: 3 PRs máximo
- **Actions**: 3 PRs máximo

### Reviewers Automáticos
- `moreirawebmaster` sempre assignado
- Review obrigatório para major updates

## 📅 Cronograma

| Horário | Ecosistema | Ação |
|---------|------------|------|
| 09:00 | Dart/Flutter | Verificar `pubspec.yaml` |
| 10:00 | Node.js | Verificar `package.json` |
| 11:00 | GitHub Actions | Verificar workflows |

**Timezone**: America/Sao_Paulo (BRT)

## 🏷️ Labels Automáticas

### Por Ecosistema
- `dependencies` - Todas as atualizações
- `dart` - Dependências Dart/Flutter
- `nodejs` - Dependências Node.js
- `github-actions` - Actions workflows

### Por Status
- `automated` - PR criado automaticamente
- `auto-merged` - Merged automaticamente
- `needs-review` - Requer review manual

## 🔧 Comandos Úteis

### Verificar Status
```bash
# Ver PRs do Dependabot
gh pr list --author "dependabot[bot]"

# Ver PRs com label dependencies
gh pr list --label "dependencies"
```

### Merge Manual
```bash
# Aprovar PR do Dependabot
gh pr review <PR_NUMBER> --approve

# Merge com squash
gh pr merge <PR_NUMBER> --squash --delete-branch
```

### Reexecutar Dependabot
```bash
# Via GitHub CLI (se disponível)
gh api repos/:owner/:repo/dependabot/updates -X POST
```

## 🚨 Troubleshooting

### PR do Dependabot Falhando

**1. Verificar logs do workflow:**
```bash
gh run list --workflow="dependabot-auto-merge.yml"
gh run view <RUN_ID>
```

**2. Problemas comuns:**
- Conflitos de merge
- Testes falhando
- Dependências incompatíveis

**3. Soluções:**
```bash
# Rebase PR do Dependabot
gh pr comment <PR_NUMBER> --body "@dependabot rebase"

# Recriar PR
gh pr comment <PR_NUMBER> --body "@dependabot recreate"
```

### Auto-merge Não Funcionando

**Verificar:**
1. Branch protection rules configuradas
2. Required status checks passando
3. Permissões do workflow

**Configurar branch protection:**
```
Settings → Branches → main
☑️ Require status checks to pass
☑️ Require branches to be up to date
☑️ Allow auto-merge
```

### Muitos PRs Abertos

**Configurar limites:**
```yaml
open-pull-requests-limit: 3  # Reduzir limite
```

**Fechar PRs desnecessários:**
```bash
# Fechar PRs antigos do Dependabot
gh pr list --author "dependabot[bot]" --state open | \
  grep "days ago" | \
  awk '{print $1}' | \
  xargs -I {} gh pr close {}
```

## 📈 Benefícios

### 🛡️ **Segurança**
- Patches de segurança aplicados automaticamente
- Vulnerabilidades conhecidas corrigidas
- Dependências sempre atualizadas

### ⚡ **Produtividade**
- Zero esforço manual para updates seguros
- Tempo focado em desenvolvimento
- Menos debt técnico

### 🔄 **Qualidade**
- Testes automáticos antes do merge
- Compatibilidade verificada
- Rollback fácil se necessário

## 📋 Checklist de Configuração

- [x] `.github/dependabot.yml` configurado
- [x] Workflow auto-merge criado
- [x] Branch protection configurada
- [x] Labels criadas no repositório
- [x] Reviewers configurados
- [x] Timezone configurado (BRT)
- [x] Limites de PRs definidos
- [x] Ignorar major updates configurado

---

**🤖 O Dependabot mantém seu projeto seguro e atualizado automaticamente!** 