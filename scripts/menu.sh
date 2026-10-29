#!/usr/bin/env sh
# Menú interactivo del kit: pregunta qué instalar y llama a scripts/install.sh con esas opciones.
# Primero muestra la simulación y recién instala si se confirma. No usa red ni privilegios.
# Uso: sh install.sh (en la raíz del kit) o sh scripts/menu.sh
set -eu

KIT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
INSTALLER="$KIT_DIR/scripts/install.sh"
KIT_VERSION=$(cat "$KIT_DIR/VERSION" 2>/dev/null || echo "?")
ALL_TOOLS="agents claude cursor copilot windsurf cline gemini"

print_title() {
  echo ""
  echo "=================================================="
  echo "  dev-standards-kit $KIT_VERSION · $1"
  echo "=================================================="
}

ask() {  # ask "pregunta" "valor por defecto" -> deja la respuesta en ANSWER
  printf '%s' "$1"
  [ -n "$2" ] && printf ' [%s]' "$2"
  printf ': '
  IFS= read -r ANSWER || ANSWER=""
  [ -z "$ANSWER" ] && ANSWER="$2"
  return 0
}

list_skills() {
  for skill_dir in "$KIT_DIR"/skills/*/; do basename -- "$skill_dir"; done
}

read_skill_summary() {  # primera oración de la descripción del SKILL.md
  sed -n 's/^description: //p' "$KIT_DIR/skills/$1/SKILL.md" | sed 's/\. .*//' | cut -c1-95
}

show_skills() {
  print_title "skills (procedimientos)"
  skill_number=0
  for skill_name in $(list_skills); do
    skill_number=$((skill_number + 1))
    printf '  %2d. %-24s %s\n' "$skill_number" "$skill_name" "$(read_skill_summary "$skill_name")"
  done
}

show_stacks() {
  print_title "perfiles de stack"
  stack_number=0
  for profile_file in "$KIT_DIR"/profiles/*.md; do
    stack_number=$((stack_number + 1))
    printf '  %d. %s\n' "$stack_number" "$(basename -- "$profile_file" .md)"
  done
}

pick_from_list() {  # pick_from_list "a b c" "1 3" -> "a,c" (o vacío si nada válido)
  picked=""
  for wanted in $2; do
    position=0
    for item in $1; do
      position=$((position + 1))
      [ "$position" = "$wanted" ] && picked="${picked:+$picked,}$item"
    done
  done
  echo "$picked"
}

ask_target() {
  while :; do
    ask "Ruta del proyecto (carpeta existente)" ""
    if [ -n "$ANSWER" ] && [ -d "$ANSWER" ]; then TARGET_DIR="$ANSWER"; warn_git_link; return 0; fi
    echo "  No existe esa carpeta. Probá de nuevo (o Ctrl+C para salir)."
  done
}

warn_git_link() {  # solo avisa: el instalador nunca copia .git, pero el kit no tiene que subirse con el proyecto
  target_path=$(CDPATH= cd -- "$TARGET_DIR" && pwd)
  case "$KIT_DIR/" in
    "$target_path/"*)
      if ! git -C "$target_path" check-ignore -q "$KIT_DIR" 2>/dev/null; then
        echo "  ⚠ El kit está DENTRO del proyecto y git no lo ignora: se subiría con el proyecto."
        echo "    Agregá su carpeta al .gitignore del proyecto, o mové el kit afuera (README, 'Dónde poner el kit')."
      fi ;;
  esac
  if [ -d "$KIT_DIR/.git" ]; then
    echo "  ⓘ El kit tiene su propio .git (conectado a su repositorio). Lo instalado son copias sin vínculo;"
    echo "    si no vas a modificar el kit, podés desconectarlo borrando $KIT_DIR/.git."
  fi
}

ask_stack() {
  show_stacks
  echo "  0. Plantilla en blanco (completar stack.md después)"
  ask "Elegí el stack" "0"
  STACK_OPTION=""
  [ "$ANSWER" = "0" ] && return 0
  stack_names=$(for profile_file in "$KIT_DIR"/profiles/*.md; do basename -- "$profile_file" .md; done | tr '\n' ' ')
  chosen_stack=$(pick_from_list "$stack_names" "$ANSWER")
  if [ -n "$chosen_stack" ]; then STACK_OPTION="--stack $chosen_stack"; else echo "  Opción no válida: plantilla en blanco."; fi
}

ask_skills() {
  show_skills
  ask "Números de las skills, separados por espacio (o 'todas')" "todas"
  SELECTED_SKILLS="all"
  [ "$ANSWER" = "todas" ] && return 0
  SELECTED_SKILLS=$(pick_from_list "$(list_skills | tr '\n' ' ')" "$ANSWER")
  if [ -z "$SELECTED_SKILLS" ]; then echo "  Ninguna válida: se instalan todas."; SELECTED_SKILLS="all"; fi
}

ask_tools() {
  print_title "herramientas"
  tool_number=0
  for tool_name in $ALL_TOOLS; do
    tool_number=$((tool_number + 1)); printf '  %d. %s\n' "$tool_number" "$tool_name"
  done
  echo "  Las normas y los procedimientos se instalan siempre, uses la herramienta que uses."
  ask "Números de las herramientas, separados por espacio ('todas' o 'ninguna')" "todas"
  SELECTED_TOOLS="all"
  [ "$ANSWER" = "todas" ] && return 0
  if [ "$ANSWER" = "ninguna" ]; then SELECTED_TOOLS="none"; return 0; fi
  SELECTED_TOOLS=$(pick_from_list "$ALL_TOOLS" "$ANSWER")
  if [ -z "$SELECTED_TOOLS" ]; then echo "  Ninguna válida: se instalan todas."; SELECTED_TOOLS="all"; fi
}

run_installation() {  # $1 = opciones extra (p. ej. --adopt)
  print_title "resumen"
  echo "  Proyecto:     $TARGET_DIR"
  echo "  Stack:        ${STACK_OPTION:-plantilla en blanco}"
  echo "  Skills:       $SELECTED_SKILLS"
  echo "  Herramientas: $SELECTED_TOOLS"
  [ -n "$1" ] && echo "  Modo:         adopción (no pisa nada)"
  echo ""
  echo "SIMULACIÓN: esto es lo que se copiaría."
  # shellcheck disable=SC2086
  sh "$INSTALLER" --target "$TARGET_DIR" --skills "$SELECTED_SKILLS" --tools "$SELECTED_TOOLS" $STACK_OPTION $1
  echo ""
  ask "¿Instalar ahora? (s/N)" "N"
  case "$ANSWER" in
    s|S|si|SI|sí|Sí)
      # shellcheck disable=SC2086
      sh "$INSTALLER" --target "$TARGET_DIR" --skills "$SELECTED_SKILLS" --tools "$SELECTED_TOOLS" $STACK_OPTION $1 --apply
      echo ""
      echo "Siguiente paso: revisá lo copiado con 'git diff' en el proyecto y seguí el README del kit (Tutoriales 1 a 4)." ;;
    *) echo "No se instaló nada." ;;
  esac
}

while :; do
  print_title "instalador"
  echo "  1. Instalar todo el kit (normas, todas las skills y las reglas de todas las herramientas)"
  echo "  2. Instalar eligiendo skills y herramientas"
  echo "  3. Adoptar el estándar en un proyecto ya creado (no pisa nada, deja el informe)"
  echo "  4. Ver qué hace cada skill"
  echo "  5. Ver los perfiles de stack"
  echo "  0. Salir"
  ask "Opción" "1"
  SELECTED_SKILLS="all"; SELECTED_TOOLS="all"; STACK_OPTION=""
  case "$ANSWER" in
    1) ask_target; ask_stack; run_installation "" ;;
    2) ask_target; ask_stack; ask_skills; ask_tools; run_installation "" ;;
    3) ask_target; ask_stack; ask_tools; run_installation "--adopt" ;;
    4) show_skills ;;
    5) show_stacks ;;
    0|q|salir) echo "Listo."; exit 0 ;;
    *) echo "  Opción no válida." ;;
  esac
done
