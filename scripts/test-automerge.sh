#!/bin/bash
# test-automerge.sh - Feature Auto-Merge Test Script

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Feature Auto-Merge Test Script               ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "src/app/package.json" ]; then
  echo -e "${RED}❌ Error: No se encuentra src/app/package.json${NC}"
  echo "   Ejecuta este script desde el directorio AutoMergeFeature/"
  exit 1
fi

# Verificar gh CLI
if ! command -v gh &> /dev/null; then
  echo -e "${RED}❌ Error: GitHub CLI (gh) no está instalado${NC}"
  echo "   Instala con: sudo apt install gh (Linux) o brew install gh (macOS)"
  exit 1
fi

# Obtener repositorio actual
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
  echo -e "${RED}❌ Error: No se pudo obtener el repositorio${NC}"
  echo "   Asegúrate de estar en un repo de GitHub y autenticado con 'gh auth login'"
  exit 1
fi

echo -e "${GREEN}📁 Repositorio: $REPO${NC}"
echo ""

echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Configuración del Test${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""

# Obtener rama actual
CURRENT_BRANCH=$(git branch --show-current)
echo -e "Rama actual: ${YELLOW}$CURRENT_BRANCH${NC}"

# Verificar si hay cambios sin commit
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  echo -e "${YELLOW}⚠️  Tienes cambios sin commit${NC}"
  git status --short
  echo ""
  read -p "¿Quieres hacer stash de estos cambios? (y/n): " DO_STASH
  if [ "$DO_STASH" = "y" ] || [ "$DO_STASH" = "Y" ]; then
    git stash
    echo -e "${GREEN}✅ Cambios guardados en stash${NC}"
  fi
fi

echo ""
echo "Selecciona el tipo de test:"
echo "  1) Test simple - Agregar constante en config.ts"
echo "  2) Test con componente - Crear nuevo componente React"
echo "  3) Test de documentación - Actualizar README"

read -p "Opción (1-3): " TEST_TYPE

# Generar nombre de rama
TIMESTAMP=$(date +%s)
case $TEST_TYPE in
  1)
    BRANCH_NAME="feature/test-config-$TIMESTAMP"
    TEST_FILE="src/app/config.ts"
    TEST_DESCRIPTION="Add test configuration constant"
    ;;
  2)
    BRANCH_NAME="feature/test-component-$TIMESTAMP"
    TEST_FILE="src/app/components/TestButton.tsx"
    TEST_DESCRIPTION="Add test button component"
    ;;
  3)
    BRANCH_NAME="docs/test-readme-$TIMESTAMP"
    TEST_FILE="src/app/README.md"
    TEST_DESCRIPTION="Update README with test information"
    ;;
  *)
    echo -e "${RED}❌ Opción inválida${NC}"
    exit 1
    ;;
esac

echo ""
echo -e "${BLUE}📝 Detalles del test:${NC}"
echo "  Rama: $BRANCH_NAME"
echo "  Archivo: $TEST_FILE"
echo "  Descripción: $TEST_DESCRIPTION"
echo ""

read -p "¿Continuar? (y/n): " CONTINUE
if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
  echo "Test cancelado"
  exit 0
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Ejecutando Test${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""

# Paso 1: Asegurar que estamos en main
echo -e "${BLUE}1️⃣  Actualizando rama main...${NC}"
git checkout main 2>/dev/null || git checkout -b main
git pull origin main 2>/dev/null || echo "  (Primera vez en este repo)"

# Paso 2: Crear nueva rama
echo -e "${BLUE}2️⃣  Creando rama $BRANCH_NAME...${NC}"
git checkout -b $BRANCH_NAME

# Paso 3: Crear/modificar archivo según tipo de test
echo -e "${BLUE}3️⃣  Creando cambios de prueba...${NC}"

case $TEST_TYPE in
  1)
    # Test simple: config.ts
    mkdir -p src/app
    cat > $TEST_FILE << 'EOF'
// Configuration file for feature auto-merge testing

export const APP_CONFIG = {
  name: 'AutoMerge Feature Test',
  version: '1.0.0',
  environment: process.env.NODE_ENV || 'development',
  features: {
    autoMerge: true,
    ciValidation: true,
  },
  testTimestamp: Date.now(),
};

export default APP_CONFIG;
EOF
    echo -e "  ${GREEN}✅${NC} Creado $TEST_FILE"
    ;;
    
  2)
    # Test con componente
    mkdir -p src/app/components
    cat > $TEST_FILE << 'EOF'
import React from 'react';

interface TestButtonProps {
  label?: string;
  onClick?: () => void;
}

/**
 * TestButton - Componente de prueba para validar auto-merge
 */
export default function TestButton({ 
  label = 'Test Auto-Merge', 
  onClick 
}: TestButtonProps) {
  const handleClick = () => {
    console.log('🎉 Auto-merge test button clicked!');
    onClick?.();
  };

  return (
    <button
      onClick={handleClick}
      className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
    >
      {label}
    </button>
  );
}
EOF
    echo -e "  ${GREEN}✅${NC} Creado $TEST_FILE"
    ;;
    
  3)
    # Test de documentación
    cat > $TEST_FILE << 'EOF'
# Next.js Application - Feature Auto-Merge Test

This is a test application for validating the native GitHub Auto-Merge functionality.

## Test Information

- **Purpose**: Validate native GitHub auto-merge workflow
- **Strategy**: Branch protection + CI validation + manual auto-merge activation
- **CI Checks**: Lint, Build, Security Scan

## How to Test

1. Create feature branch
2. Make changes
3. Create PR and wait for CI
4. Get approval from reviewer
5. Enable auto-merge: `gh pr merge --auto --squash <PR>`
6. GitHub merges automatically when all conditions met

## Expected Behavior

- ✅ CI runs automatically on PR creation
- ✅ Branch protection enforces reviews and checks
- ✅ Auto-merge enables when manually activated
- ✅ PR merges when checks pass + approval + branch updated

---

*Test generated at: $(date)*
EOF
    echo -e "  ${GREEN}✅${NC} Creado $TEST_FILE"
    ;;
esac

# Paso 4: Commit
echo -e "${BLUE}4️⃣  Haciendo commit...${NC}"
git add $TEST_FILE
COMMIT_MSG="feat: $TEST_DESCRIPTION

This is a test commit to validate the native GitHub Auto-Merge functionality.

- Tests CI validation (lint, build, security)
- Tests branch protection enforcement
- Tests native auto-merge activation
"
git commit -m "$COMMIT_MSG"
echo -e "  ${GREEN}✅${NC} Commit creado"

# Paso 5: Push
echo -e "${BLUE}5️⃣  Pusheando rama...${NC}"
git push -u origin $BRANCH_NAME
echo -e "  ${GREEN}✅${NC} Rama pusheada"

# Paso 6: Crear PR
echo -e "${BLUE}6️⃣  Creando Pull Request...${NC}"

PR_BODY="## 🧪 Test de Auto-Merge Nativo

Este PR fue creado automáticamente para probar la funcionalidad nativa de auto-merge de GitHub.

### Cambios
- $TEST_DESCRIPTION

### Validaciones Esperadas
- [x] CI ejecuta automáticamente
- [ ] Todos los checks pasan  
- [ ] Reviewer aprueba el PR
- [ ] **Auto-merge nativo se habilita**
- [ ] GitHub fusiona automáticamente cuando todo pase

### Instrucciones
1. Espera a que el CI termine
2. Revisa y aprueba este PR
3. Ejecuta: \`gh pr merge --auto --squash $PR_NUMBER\`
4. GitHub fusionará automáticamente cuando todos los checks pasen

---
*Test generado por: \`test-automerge.sh\`*
*Timestamp: $(date)*
"

PR_URL=$(gh pr create \
  --base main \
  --head $BRANCH_NAME \
  --title "🧪 [TEST] $TEST_DESCRIPTION" \
  --body "$PR_BODY")

echo -e "  ${GREEN}✅${NC} PR creado: $PR_URL"

# Obtener número de PR
PR_NUMBER=$(gh pr view $BRANCH_NAME --json number -q .number)

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Test Iniciado Correctamente${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ PR #$PR_NUMBER creado y configurado${NC}"
echo ""
echo -e "${YELLOW}📋 Próximos pasos:${NC}"
echo ""
echo "  1️⃣  Espera a que el CI termine (1-2 minutos)"
echo "      Ver en: $PR_URL/checks"
echo ""
echo "  2️⃣  Aprueba el PR (simula revisión de código)"
echo "      Comando: gh pr review $PR_NUMBER --approve"
echo ""
echo "  3️⃣  Habilita auto-merge nativo"
echo "      Comando: gh pr merge --auto --squash $PR_NUMBER"
echo ""
echo "  4️⃣  GitHub fusionará automáticamente cuando:"
echo "      - Todos los CI checks pasen ✅"
echo "      - Tenga las aprobaciones requeridas ✅"
echo "      - Rama esté actualizada ✅"
echo ""
echo -e "${BLUE}🔍 Comandos útiles para monitorear:${NC}"
echo ""
echo "  # Ver estado actual del PR"
echo "  gh pr view $PR_NUMBER"
echo ""
echo "  # Ver checks en tiempo real"
echo "  gh pr checks $PR_NUMBER --watch"
echo ""
echo "  # Aprobar y habilitar auto-merge (cuando CI pase)"
echo "  gh pr review $PR_NUMBER --approve"
echo "  gh pr merge --auto --squash $PR_NUMBER"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🎉 Test preparado. Visita el PR en:${NC}"
echo "   $PR_URL"
echo ""

# Preguntar si quiere ver el PR en el navegador
read -p "¿Abrir PR en el navegador? (y/n): " OPEN_BROWSER
if [ "$OPEN_BROWSER" = "y" ] || [ "$OPEN_BROWSER" = "Y" ]; then
  gh pr view $PR_NUMBER --web
fi

# Preguntar si quiere aprobar automáticamente
echo ""
read -p "¿Quieres que este script espere y apruebe automáticamente cuando CI pase? (y/n): " AUTO_APPROVE

if [ "$AUTO_APPROVE" = "y" ] || [ "$AUTO_APPROVE" = "Y" ]; then
  echo ""
  echo -e "${BLUE}⏳ Esperando a que CI termine...${NC}"
  echo "   (Verificando cada 15 segundos)"
  
  while true; do
    # Verificar estado de los checks
    CHECK_STATUS=$(gh pr view $PR_NUMBER --json statusCheckRollup -q '.statusCheckRollup[].conclusion' 2>/dev/null | grep -v "^$" || echo "")
    
    # Si hay algún failure, reportar
    if echo "$CHECK_STATUS" | grep -q "FAILURE"; then
      echo -e "${RED}❌ Algunos checks fallaron${NC}"
      gh pr checks $PR_NUMBER
      echo ""
      echo "Puedes revisar los errores y hacer fix si lo deseas."
      echo "O simplemente cerrar este PR de prueba."
      break
    fi
    
    # Si todos son success
    if [ -n "$CHECK_STATUS" ] && ! echo "$CHECK_STATUS" | grep -qE "null|PENDING|IN_PROGRESS"; then
      if echo "$CHECK_STATUS" | grep -q "SUCCESS"; then
        echo -e "${GREEN}✅ Todos los checks pasaron${NC}"
        echo ""
        echo -e "${BLUE}📝 Aprobando PR...${NC}"
        gh pr review $PR_NUMBER --approve --body "✅ LGTM! All CI checks passed. Auto-merge test approved."
        echo -e "${GREEN}✅ PR aprobado${NC}"
        echo ""
        echo -e "${BLUE}🔀 Habilitando auto-merge nativo...${NC}"
        gh pr merge --auto --squash $PR_NUMBER
        echo -e "${GREEN}✅ Auto-merge habilitado${NC}"
        echo ""
        echo -e "${YELLOW}GitHub fusionará el PR automáticamente cuando:${NC}"
        echo "  - ✅ Checks hayan pasado (ya completado)"
        echo "  - ✅ Tenga aprobaciones requeridas (ya completado)"
        echo "  - ✅ Rama esté actualizada"
        echo ""
        echo "  Monitorea el estado con:"
        echo "  gh pr view $PR_NUMBER"
        break
      fi
    fi
    
    # Mostrar progreso
    echo -n "."
    sleep 15
  done
else
  echo ""
  echo -e "${GREEN}✅ Test iniciado. Sigue los pasos manualmente.${NC}"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 Script completado${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════${NC}"
