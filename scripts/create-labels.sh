#!/bin/bash
# create-labels.sh - Crea labels necesarios para Feature AutoMerge

set -e

echo "🏷️  Creando labels para Feature AutoMerge..."

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar que gh CLI está instalado
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ Error: gh CLI no está instalado${NC}"
    echo "Instala desde: https://cli.github.com/"
    exit 1
fi

# Labels de control de merge
echo -e "${GREEN}📝 Creando labels de control de merge...${NC}"

gh label create "ready-to-merge" \
    --color "0e8a16" \
    --description "Ready for automatic merge" \
    --force 2>/dev/null && echo "  ✅ ready-to-merge" || echo "  ⚠️  ready-to-merge (ya existe)"

gh label create "do-not-merge" \
    --color "b60205" \
    --description "Block automatic merge" \
    --force 2>/dev/null && echo "  ✅ do-not-merge" || echo "  ⚠️  do-not-merge (ya existe)"

gh label create "breaking-change" \
    --color "d73a4a" \
    --description "Breaking changes that require major version bump" \
    --force 2>/dev/null && echo "  ✅ breaking-change" || echo "  ⚠️  breaking-change (ya existe)"

gh label create "needs-review" \
    --color "fbca04" \
    --description "Requires additional code review" \
    --force 2>/dev/null && echo "  ✅ needs-review" || echo "  ⚠️  needs-review (ya existe)"

# Labels de categoría
echo -e "\n${GREEN}📂 Creando labels de categoría...${NC}"

gh label create "documentation" \
    --color "0075ca" \
    --description "Documentation changes" \
    --force 2>/dev/null && echo "  ✅ documentation" || echo "  ⚠️  documentation (ya existe)"

gh label create "dependencies" \
    --color "0366d6" \
    --description "Dependency updates" \
    --force 2>/dev/null && echo "  ✅ dependencies" || echo "  ⚠️  dependencies (ya existe)"

gh label create "ci/cd" \
    --color "1d76db" \
    --description "CI/CD workflow changes" \
    --force 2>/dev/null && echo "  ✅ ci/cd" || echo "  ⚠️  ci/cd (ya existe)"

gh label create "frontend" \
    --color "5319e7" \
    --description "Frontend/UI changes" \
    --force 2>/dev/null && echo "  ✅ frontend" || echo "  ⚠️  frontend (ya existe)"

gh label create "config" \
    --color "006b75" \
    --description "Configuration changes" \
    --force 2>/dev/null && echo "  ✅ config" || echo "  ⚠️  config (ya existe)"

# Labels de tamaño
echo -e "\n${GREEN}📏 Creando labels de tamaño...${NC}"

gh label create "size/xs" \
    --color "c2e0c6" \
    --description "Extra small PR (< 10 lines)" \
    --force 2>/dev/null && echo "  ✅ size/xs" || echo "  ⚠️  size/xs (ya existe)"

gh label create "size/s" \
    --color "91cf97" \
    --description "Small PR (< 100 lines)" \
    --force 2>/dev/null && echo "  ✅ size/s" || echo "  ⚠️  size/s (ya existe)"

gh label create "size/m" \
    --color "59be6c" \
    --description "Medium PR (< 500 lines)" \
    --force 2>/dev/null && echo "  ✅ size/m" || echo "  ⚠️  size/m (ya existe)"

gh label create "size/l" \
    --color "35ad4d" \
    --description "Large PR (< 1000 lines)" \
    --force 2>/dev/null && echo "  ✅ size/l" || echo "  ⚠️  size/l (ya existe)"

gh label create "size/xl" \
    --color "0e8a16" \
    --description "Extra large PR (≥ 1000 lines)" \
    --force 2>/dev/null && echo "  ✅ size/xl" || echo "  ⚠️  size/xl (ya existe)"

echo -e "\n${GREEN}✅ Labels creados exitosamente!${NC}"
echo ""
echo "📝 Puedes ver todos los labels con:"
echo "   gh label list"
echo ""
echo "🔗 Siguiente paso: Configurar branch protection en GitHub"
echo "   Settings > Branches > Add branch protection rule"
