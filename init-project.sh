#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Collaborative Project Initializer
# Creates a multi-dev project from template with PAUL, CARL, and team memory.
# ============================================================================
#
# Usage:
#   ./init-project.sh "Mon Projet" carldomain "keyword1,keyword2" "alice,bob"
#
# Arguments:
#   $1 — Project name (display name, used in file headers)
#   $2 — CARL domain name (lowercase, no dashes, e.g. "monprojetworkflow")
#   $3 — CARL recall keywords (comma-separated, triggers domain loading)
#   $4 — Dev names (comma-separated, creates one MEMORY-{dev}.md per dev)
#
# What it does:
#   1. Creates project directory with full collaborative structure
#   2. Copies 3 skills (context-manager-team, pre-flight, team-sync)
#   3. Generates CLAUDE.md, MEMORY-shared.md, MEMORY-{dev}.md for each dev
#   4. Generates .carl/manifest and .carl/{domain} from templates
#   5. Creates handoffs/, docs/solutions/, src/ subdirectories
#   6. Optionally copies .devcontainer/ for containerized development
#
# After running:
#   - Fill in {{PLACEHOLDER}} values in CLAUDE.md
#   - Add project-specific CARL rules in .carl/{domain}
#   - Install PAUL: npx paul-framework (or npm install -g paul-framework)
#   - Each dev should review their MEMORY-{dev}.md

TEMPLATE_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="${WORKSPACE_DIR:-$(dirname "$TEMPLATE_DIR")}"

if [ $# -lt 4 ]; then
    echo "Usage: $0 \"Project Name\" carl_domain \"keyword1,keyword2\" \"dev1,dev2\""
    echo ""
    echo "Example:"
    echo "  $0 \"Mon SaaS\" saasworkflow \"saas,api,stripe\" \"alice,bob\""
    echo "  $0 \"E-Commerce\" ecomworkflow \"ecom,shop,payment\" \"alice,bob,charlie\""
    exit 1
fi

PROJECT_NAME="$1"
CARL_DOMAIN="$2"
RECALL_KEYWORDS="$3"
DEV_NAMES="$4"
CARL_DOMAIN_UPPER=$(echo "$CARL_DOMAIN" | tr '[:lower:]' '[:upper:]')
PROJECT_DIR="${WORKSPACE}/${PROJECT_NAME}"
TODAY=$(date +%Y-%m-%d)

# Parse dev names into array
IFS=',' read -ra DEVS <<< "$DEV_NAMES"

echo "═══════════════════════════════════════════"
echo "  Collaborative Project Initializer"
echo "═══════════════════════════════════════════"
echo ""
echo "  Project:    ${PROJECT_NAME}"
echo "  Directory:  ${PROJECT_DIR}"
echo "  CARL:       ${CARL_DOMAIN} (${CARL_DOMAIN_UPPER})"
echo "  Keywords:   ${RECALL_KEYWORDS}"
echo "  Team:       ${DEV_NAMES} (${#DEVS[@]} devs)"
echo ""

# Check if project already exists
if [ -d "$PROJECT_DIR" ]; then
    echo "ERROR: Directory already exists: ${PROJECT_DIR}"
    exit 1
fi

# Create directory structure
echo "→ Creating directory structure..."
mkdir -p "${PROJECT_DIR}/.claude/skills/context-manager-team"
mkdir -p "${PROJECT_DIR}/.claude/skills/pre-flight"
mkdir -p "${PROJECT_DIR}/.claude/skills/team-sync"
mkdir -p "${PROJECT_DIR}/.carl"
mkdir -p "${PROJECT_DIR}/.paul/phases"
mkdir -p "${PROJECT_DIR}/docs/solutions"
mkdir -p "${PROJECT_DIR}/docs/plans"
mkdir -p "${PROJECT_DIR}/docs/brainstorms"
mkdir -p "${PROJECT_DIR}/memory"
mkdir -p "${PROJECT_DIR}/handoffs"
mkdir -p "${PROJECT_DIR}/todos"
mkdir -p "${PROJECT_DIR}/src"

# Copy skills
echo "→ Installing skills..."
cp "${TEMPLATE_DIR}/.claude/skills/context-manager-team/SKILL.md" \
   "${PROJECT_DIR}/.claude/skills/context-manager-team/SKILL.md"
cp "${TEMPLATE_DIR}/.claude/skills/pre-flight/SKILL.md" \
   "${PROJECT_DIR}/.claude/skills/pre-flight/SKILL.md"
cp "${TEMPLATE_DIR}/.claude/skills/team-sync/SKILL.md" \
   "${PROJECT_DIR}/.claude/skills/team-sync/SKILL.md"

# Copy devcontainer if present
if [ -d "${TEMPLATE_DIR}/.devcontainer" ]; then
    echo "→ Copying .devcontainer..."
    mkdir -p "${PROJECT_DIR}/.devcontainer"
    cp "${TEMPLATE_DIR}/.devcontainer/Dockerfile" "${PROJECT_DIR}/.devcontainer/"
    cp "${TEMPLATE_DIR}/.devcontainer/devcontainer.json" "${PROJECT_DIR}/.devcontainer/"
    cp "${TEMPLATE_DIR}/.devcontainer/init-firewall.sh" "${PROJECT_DIR}/.devcontainer/"
    chmod +x "${PROJECT_DIR}/.devcontainer/init-firewall.sh"
fi

# Build dev names list for CLAUDE.md
DEV_LIST=""
for dev in "${DEVS[@]}"; do
    dev=$(echo "$dev" | xargs)
    if [ -z "$DEV_LIST" ]; then
        DEV_LIST="${dev}"
    else
        DEV_LIST="${DEV_LIST}, ${dev}"
    fi
done

# Generate CLAUDE.md from template
echo "→ Generating CLAUDE.md..."
sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
    -e "s|{{CARL_DOMAIN}}|${CARL_DOMAIN}|g" \
    -e "s|{{DATE}}|${TODAY}|g" \
    -e "s|{{DEV_NAMES}}|${DEV_LIST}|g" \
    "${TEMPLATE_DIR}/CLAUDE.md.template" > "${PROJECT_DIR}/CLAUDE.md"

# Replace team table placeholder with generated rows
TEAM_TABLE_FILE=$(mktemp)
for dev in "${DEVS[@]}"; do
    dev=$(echo "$dev" | xargs)
    echo "| ${dev} | memory/MEMORY-${dev}.md | — |" >> "$TEAM_TABLE_FILE"
done
# Use sed with read to replace placeholder with file contents
sed -i '' -e "/{{TEAM_TABLE}}/{
r ${TEAM_TABLE_FILE}
d
}" "${PROJECT_DIR}/CLAUDE.md"
rm -f "$TEAM_TABLE_FILE"

# Generate MEMORY-shared.md
echo "→ Generating memory/MEMORY-shared.md..."
sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
    -e "s|{{DATE}}|${TODAY}|g" \
    "${TEMPLATE_DIR}/memory/MEMORY-shared.md.template" > "${PROJECT_DIR}/memory/MEMORY-shared.md"

# Generate MEMORY-{dev}.md for each dev
echo "→ Generating per-dev MEMORY files..."
for dev in "${DEVS[@]}"; do
    dev=$(echo "$dev" | xargs)
    echo "  • MEMORY-${dev}.md"
    sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
        -e "s|{{DEV_NAME}}|${dev}|g" \
        -e "s|{{DATE}}|${TODAY}|g" \
        "${TEMPLATE_DIR}/memory/MEMORY-dev.md.template" > "${PROJECT_DIR}/memory/MEMORY-${dev}.md"
done

# Generate CARL manifest
echo "→ Generating .carl/manifest..."
sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
    -e "s|{{DOMAIN_NAME}}|${CARL_DOMAIN}|g" \
    "${TEMPLATE_DIR}/.carl/manifest.template" > "${PROJECT_DIR}/.carl/manifest"

# Generate CARL domain file
echo "→ Generating .carl/${CARL_DOMAIN}..."
sed -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
    -e "s|{{DOMAIN_NAME}}|${CARL_DOMAIN_UPPER}|g" \
    -e "s|{{KEYWORDS}}|${RECALL_KEYWORDS}|g" \
    -e "s|{{DESCRIPTION}}|Rules for ${PROJECT_NAME} collaborative development.|g" \
    -e "s|{{PATTERN_DESCRIPTION}}|Standard patterns for ${PROJECT_NAME}.|g" \
    -e "s|{{CONSTRAINT_DESCRIPTION}}|Constraints specific to ${PROJECT_NAME}.|g" \
    "${TEMPLATE_DIR}/.carl/domain.template" > "${PROJECT_DIR}/.carl/${CARL_DOMAIN}"

# Add .gitkeep files for empty directories
touch "${PROJECT_DIR}/docs/solutions/.gitkeep"
touch "${PROJECT_DIR}/docs/plans/.gitkeep"
touch "${PROJECT_DIR}/docs/brainstorms/.gitkeep"
touch "${PROJECT_DIR}/handoffs/.gitkeep"
touch "${PROJECT_DIR}/todos/.gitkeep"
touch "${PROJECT_DIR}/src/.gitkeep"
touch "${PROJECT_DIR}/.paul/phases/.gitkeep"

# Create .gitignore
cat > "${PROJECT_DIR}/.gitignore" << 'GITIGNORE'
.env
.env.*
node_modules/
.DS_Store
*.log
GITIGNORE

echo ""
echo "✓ Project initialized successfully!"
echo ""
echo "  Created:"
echo "    • CLAUDE.md                                   (edit: Stack, MCP, Skills)"
echo "    • memory/MEMORY-shared.md                     (team decisions)"
for dev in "${DEVS[@]}"; do
    dev=$(echo "$dev" | xargs)
    echo "    • memory/MEMORY-${dev}.md                     (${dev}'s session state)"
done
echo "    • .claude/skills/context-manager-team/         (ready)"
echo "    • .claude/skills/pre-flight/                   (ready)"
echo "    • .claude/skills/team-sync/                    (ready)"
echo "    • .carl/manifest + .carl/${CARL_DOMAIN}       (add rules)"
echo "    • .paul/                                       (PAUL framework)"
echo "    • handoffs/                                    (dev handoff files)"
if [ -d "${PROJECT_DIR}/.devcontainer" ]; then
    echo "    • .devcontainer/                               (Docker env)"
fi
echo "    • docs/ + todos/ + src/                        (empty, ready)"
echo ""
echo "  Next steps:"
echo "    1. cd \"${PROJECT_DIR}\""
echo "    2. Replace remaining {{PLACEHOLDER}} values in CLAUDE.md"
echo "    3. Add project-specific CARL rules in .carl/${CARL_DOMAIN}"
echo "    4. Install PAUL:  npx paul-framework"
echo "    5. git init && git add -A && git commit -m \"Initial project setup\""
echo "    6. Each dev creates their branch: git checkout -b phase-{N}-{name}"
echo ""
