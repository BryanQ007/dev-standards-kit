#!/usr/bin/env sh
# Instala el kit de normas en un proyecto: copia archivos de texto, nada más.
# Seguro por diseño: sin red, sin sudo, no ejecuta lo que copia, simulación por defecto,
# no sobrescribe (salvo --force, que deja un respaldo .bak).
#
# Uso:
#   sh scripts/install.sh --target ../mi-proyecto                       # simulación: muestra qué haría
#   sh scripts/install.sh --target ../mi-proyecto --apply               # copia
#   sh scripts/install.sh --target ../mi-proyecto --tools claude,cursor --apply
#   sh scripts/install.sh --target ../mi-proyecto --stack nextjs-fastapi-postgres --apply   # stack.md desde un perfil
#   sh scripts/install.sh --list-stacks                                 # perfiles disponibles
#   sh scripts/install.sh --personal-skills --apply                     # skills en ~/.claude/skills
# Herramientas: claude, cursor, copilot, windsurf, cline, agents, gemini (por defecto: all)
# Sin --stack, docs/standards/stack.md queda como plantilla para completar (skill std-stack-setup).
set -eu

KIT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TARGET_DIR=""
SELECTED_TOOLS="all"
SELECTED_STACK=""
IS_APPLY=0
IS_FORCE=0
IS_PERSONAL_SKILLS=0

while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET_DIR="$2"; shift 2 ;;
    --tools) SELECTED_TOOLS="$2"; shift 2 ;;
    --stack) SELECTED_STACK="$2"; shift 2 ;;
    --list-stacks)
      for profile_file in "$KIT_DIR"/profiles/*.md; do basename -- "$profile_file" .md; done
      exit 0 ;;
    --apply) IS_APPLY=1; shift ;;
    --force) IS_FORCE=1; shift ;;
    --personal-skills) IS_PERSONAL_SKILLS=1; shift ;;
    -h|--help) sed -n '2,17p' "$0"; exit 0 ;;
    *) echo "Opción desconocida: $1" >&2; exit 2 ;;
  esac
done

if [ -n "$SELECTED_STACK" ]; then
  case "$SELECTED_STACK" in
    *[!a-z0-9-]*) echo "Nombre de perfil inválido: $SELECTED_STACK" >&2; exit 2 ;;
  esac
  if [ ! -f "$KIT_DIR/profiles/$SELECTED_STACK.md" ]; then
    echo "No existe el perfil '$SELECTED_STACK'. Disponibles:" >&2
    for profile_file in "$KIT_DIR"/profiles/*.md; do basename -- "$profile_file" .md >&2; done
    exit 2
  fi
fi

is_tool_selected() {
  [ "$SELECTED_TOOLS" = "all" ] && return 0
  case ",$SELECTED_TOOLS," in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

copy_kit_file() {
  source_file="$KIT_DIR/$1"
  destination_file="$2"
  if [ ! -f "$source_file" ]; then echo "  ! falta en el kit: $1" >&2; return 1; fi
  if [ -e "$destination_file" ] && [ "$IS_FORCE" -eq 0 ]; then
    echo "  = ya existe, no se toca: $destination_file (combinalo a mano o usá --force)"
    return 0
  fi
  if [ "$IS_APPLY" -eq 0 ]; then echo "  + copiaría: $1 -> $destination_file"; return 0; fi
  mkdir -p "$(dirname -- "$destination_file")"
  if [ -e "$destination_file" ]; then
    cp -p "$destination_file" "$destination_file.bak"
    echo "  ~ respaldo: $destination_file.bak"
  fi
  cp "$source_file" "$destination_file"
  echo "  + copiado: $destination_file"
}

copy_kit_folder() {
  for kit_file in "$KIT_DIR/$1"/*; do
    [ -f "$kit_file" ] || continue
    copy_kit_file "$1/$(basename -- "$kit_file")" "$2/$(basename -- "$kit_file")"
  done
}

copy_standards_into() {
  for kit_file in "$KIT_DIR"/standards/*; do
    [ -f "$kit_file" ] || continue
    standard_name=$(basename -- "$kit_file")
    if [ "$standard_name" = "stack.md" ] && [ -n "$SELECTED_STACK" ]; then
      copy_kit_file "profiles/$SELECTED_STACK.md" "$1/stack.md"
    else
      copy_kit_file "standards/$standard_name" "$1/$standard_name"
    fi
  done
}

copy_skills_into() {
  for skill_dir in "$KIT_DIR"/skills/*/; do
    skill_name=$(basename -- "$skill_dir")
    copy_kit_file "skills/$skill_name/SKILL.md" "$1/$skill_name/SKILL.md"
  done
}

[ "$IS_APPLY" -eq 0 ] && echo "SIMULACIÓN (no se copia nada). Agregá --apply para instalar."

if [ "$IS_PERSONAL_SKILLS" -eq 1 ]; then
  echo "Skills personales de Claude Code -> $HOME/.claude/skills"
  copy_skills_into "$HOME/.claude/skills"
  [ -z "$TARGET_DIR" ] && exit 0
fi

if [ -z "$TARGET_DIR" ] || [ ! -d "$TARGET_DIR" ]; then
  echo "Indicá un proyecto existente con --target <carpeta>." >&2; exit 2
fi
TARGET_DIR=$(CDPATH= cd -- "$TARGET_DIR" && pwd)
if [ "$TARGET_DIR" = "$KIT_DIR" ]; then echo "El destino no puede ser el propio kit." >&2; exit 2; fi
echo "Proyecto: $TARGET_DIR"

echo "Normas -> docs/standards/ (stack: ${SELECTED_STACK:-plantilla para completar})"
copy_standards_into "$TARGET_DIR/docs/standards"

if is_tool_selected claude; then
  echo "Claude Code"
  copy_kit_file "rules/claude/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  [ "$IS_PERSONAL_SKILLS" -eq 1 ] || copy_skills_into "$TARGET_DIR/.claude/skills"
fi
if is_tool_selected agents; then
  echo "AGENTS.md (Codex, Cursor, Jules, Zed, Aider…)"
  copy_kit_file "rules/agents/AGENTS.md" "$TARGET_DIR/AGENTS.md"
fi
if is_tool_selected cursor; then
  echo "Cursor"; copy_kit_folder "rules/cursor/rules" "$TARGET_DIR/.cursor/rules"
fi
if is_tool_selected copilot; then
  echo "GitHub Copilot"
  copy_kit_file "rules/copilot/copilot-instructions.md" "$TARGET_DIR/.github/copilot-instructions.md"
  copy_kit_folder "rules/copilot/instructions" "$TARGET_DIR/.github/instructions"
fi
if is_tool_selected windsurf; then
  echo "Windsurf"; copy_kit_folder "rules/windsurf/rules" "$TARGET_DIR/.windsurf/rules"
fi
if is_tool_selected cline; then
  echo "Cline"; copy_kit_folder "rules/cline" "$TARGET_DIR/.clinerules"
fi
if is_tool_selected gemini; then
  echo "Gemini CLI"
  copy_kit_file "rules/gemini/GEMINI.md" "$TARGET_DIR/GEMINI.md"
  is_tool_selected agents || echo "  ! GEMINI.md apunta a AGENTS.md: instalá también 'agents'."
fi

[ -z "$SELECTED_STACK" ] && echo "Pendiente: completá docs/standards/stack.md (a mano o con la skill std-stack-setup)."
echo "Listo. Revisá los archivos copiados y commitealos en el proyecto si corresponde."
