#!/bin/bash
# test-automerge.sh - Feature Auto-Merge Test Script (Simple)

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Feature Auto-Merge Test - Simple${NC}"
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "src/app/package.json" ]; then
  echo "Error: No se encuentra src/app/package.json"
  echo "Ejecuta este script desde el directorio AutoMergeFeature/"
  exit 1
fi

# Verificar si hay cambios sin commit
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  echo -e "${YELLOW}⚠️  Tienes cambios sin commit${NC}"
  git status --short
  echo ""
  read -p "¿Hacer stash? (y/n): " DO_STASH
  if [ "$DO_STASH" = "y" ]; then
    git stash
    echo -e "${GREEN}✅ Cambios en stash${NC}"
  fi
fi

# Tipo de test
echo ""
echo "Tipo de test:"
echo "  1) Config simple (config.ts)"
echo "  2) Componente React (TestButton.tsx)"
echo "  3) Documentación (README.md)"
echo ""
read -p "Opción (1-3): " TEST_TYPE

# Generar nombre de rama y archivo
TIMESTAMP=$(date +%s)
case $TEST_TYPE in
  1)
    BRANCH_NAME="feature/test-config-$TIMESTAMP"
    TEST_FILE="src/app/config.ts"
    DESCRIPTION="Add test configuration"
    ;;
  2)
    BRANCH_NAME="feature/test-component-$TIMESTAMP"
    TEST_FILE="src/app/components/TestButton.tsx"
    DESCRIPTION="Add test button component"
    ;;
  3)
    BRANCH_NAME="docs/test-readme-$TIMESTAMP"
    TEST_FILE="src/app/README.md"
    DESCRIPTION="Update README"
    ;;
  *)
    echo "Opción inválida"
    exit 1
    ;;
esac

echo ""
echo -e "${BLUE}Rama: $BRANCH_NAME${NC}"
echo -e "${BLUE}Archivo: $TEST_FILE${NC}"
echo ""

# Actualizar main y crear rama
echo -e "${GREEN}1️⃣  Actualizando main...${NC}"
git checkout main 2>/dev/null || git checkout -b main
git pull origin main 2>/dev/null || true

echo -e "${GREEN}2️⃣  Creando rama $BRANCH_NAME...${NC}"
git checkout -b $BRANCH_NAME

# Crear archivo de test
echo -e "${GREEN}3️⃣  Creando cambios...${NC}"

case $TEST_TYPE in
  1)
    mkdir -p src/app
    cat > $TEST_FILE << 'EOF'
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
    ;;
  2)
    mkdir -p src/app/components
    cat > $TEST_FILE << 'EOF'
import React from 'react';

interface TestButtonProps {
  label?: string;
  onClick?: () => void;
}

export default function TestButton({ 
  label = 'Test Auto-Merge', 
  onClick 
}: TestButtonProps) {
  return (
    <button
      onClick={() => {
        console.log('Test button clicked!');
        onClick?.();
      }}
      className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
    >
      {label}
    </button>
  );
}
EOF
    ;;
  3)
    cat > $TEST_FILE << 'EOF'
# Next.js Application - Feature Auto-Merge Test

Test application for validating GitHub Auto-Merge functionality.

## Test Information

- Purpose: Validate native GitHub auto-merge workflow
- CI Checks: Lint, Build, Security Scan

## How to Test

1. Create feature branch
2. Make changes
3. Create PR and wait for CI
4. Get approval
5. Enable auto-merge: `gh pr merge --auto --squash <PR>`

---

*Test generated at: $(date)*
EOF
    ;;
esac

echo -e "  ${GREEN}✅${NC} Creado $TEST_FILE"

# Commit y push
echo -e "${GREEN}4️⃣  Commit...${NC}"
git add $TEST_FILE
git commit -m "feat: $DESCRIPTION"
echo -e "  ${GREEN}✅${NC} Commit creado"

echo -e "${GREEN}5️⃣  Push...${NC}"
git push -u origin $BRANCH_NAME
echo -e "  ${GREEN}✅${NC} Rama pusheada"

echo ""
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Rama lista: $BRANCH_NAME${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo ""
echo "Ahora crea el PR manualmente con:"
echo ""
echo "  gh pr create --base main --head $BRANCH_NAME"
echo ""
