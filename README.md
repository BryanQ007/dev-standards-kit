# dev-standards-kit

Normas de programación, **skills** y **reglas** para asistentes de IA, listas para instalar en cualquier proyecto, con **cualquier stack** y en cualquier IDE.

Es un estándar técnico: no tiene reglas de negocio ni datos de ninguna aplicación, y **no fija tecnologías**. Las normas describen principios (capas, patrones, SOLID, multi-tenant, bajas lógicas, responsive, tests, proceso por hitos). Cada proyecto declara con qué los implementa en un archivo **`stack.md`**: frameworks y lenguajes de frontend y backend, base de datos, carpetas, equivalencias de cada patrón y comandos de verificación.

## Qué trae

```text
dev-standards-kit/
├─ standards/        LA FUENTE DE VERDAD (Markdown neutral) → se instala en docs/standards/
│  ├─ README.md         índice + reglas transversales
│  ├─ stack.md          ★ plantilla: tecnologías de front y back, carpetas, equivalencias, comandos
│  ├─ architecture.md   capas, patrones, SOLID, contrato HTTP, multi-tenant
│  ├─ frontend.md       componentes, regla de alcance, filtros, formularios
│  ├─ responsive.md     mobile first, 360 px a escritorio
│  ├─ design-system.md  tema en un solo archivo, tokens, UI kit
│  ├─ backend.md        router → service → repository → DAO, errores, listados
│  ├─ database.md       catálogos, históricos, aislamiento, migraciones, seeders
│  ├─ testing.md        unitarios con fakes + integración
│  ├─ flows.md          flujos: estados, matriz de UI, pasos función → HTTP → base, Mermaid
│  ├─ naming.md         nombres compuestos y descriptivos
│  ├─ security.md       secretos, datos personales, permisos, acciones críticas
│  └─ workflow.md       spec primero, hitos 5 + 3, changelog con comandos, git
├─ profiles/         stacks listos para usar como stack.md
│  ├─ nextjs-fastapi-postgres.md
│  ├─ react-vite-nestjs-postgres.md
│  └─ vue-nuxt-django-postgres.md
├─ skills/           Agent Skills (SKILL.md) → .claude/skills/ o ~/.claude/skills/
│  ├─ std-stack-setup/          ★ define o cambia el stack (completa stack.md)
│  ├─ std-frontend-component/   std-responsive/   std-backend-module/
│  ├─ std-database-migration/   std-backend-tests/   std-flow-design/
│  └─ std-milestone/            std-code-review/
├─ rules/            puentes por herramienta: resumen corto + "la fuente es docs/standards/"
│  ├─ claude/CLAUDE.md          agents/AGENTS.md          gemini/GEMINI.md
│  ├─ cursor/rules/*.mdc        copilot/…                 windsurf/rules/*.md
│  └─ cline/*.md
└─ scripts/install.sh · install.ps1    instaladores seguros (simulación por defecto)
```

**Principio:** las normas viven una sola vez en `docs/standards/`. Los archivos de cada herramienta **no las copian**: resumen lo indispensable y apuntan ahí. Para cambiar una norma se edita solo `standards/`; para cambiar de tecnología, solo `stack.md`.

## Elegir las tecnologías

Tres caminos:

1. **Un perfil listo:** `--stack nextjs-fastapi-postgres` (ver todos con `--list-stacks`). Se instala como `docs/standards/stack.md`; después se ajusta lo que difiera.
2. **Plantilla en blanco** (sin `--stack`): se instala `stack.md` con marcadores `<…>`. Completalo a mano o pedile al asistente *"definí el stack del proyecto"*: la skill **`std-stack-setup`** detecta lo que ya hay en el repo (`package.json`, `pyproject.toml`, `pom.xml`, `docker-compose`…), te pregunta solo lo que falta y completa tecnologías, carpetas, equivalencias y comandos probados.
3. **Perfil propio:** copiá `standards/stack.md` a `profiles/<frontend>-<backend>-<base>.md`, completalo y usalo con `--stack` en todos tus proyectos con ese stack.

Qué define `stack.md`:

| Sección | Contenido |
|---|---|
| 1. Tecnologías | Framework, lenguaje y estilos del frontend · framework y lenguaje del backend · base, acceso a datos, migraciones, auth, almacenamiento, contenedores |
| 2. Carpetas | Dónde va cada cosa (UI kit, features, módulos, tema, migraciones, tests) |
| 3. Equivalencias | Cómo se llama cada patrón de las normas en ese stack (p. ej. "vista + lógica" = `X.tsx + useX.ts` en React, `X.vue + composable` en Vue) |
| 4. Comandos | Formato, lint, tipos, límite de líneas, tests, SQL de migraciones, entorno |
| 5. Particularidades | Advertencias propias de esas herramientas |
| 6. Idioma | Idioma de documentación, locale y moneda |

## Instalación rápida (cualquier IDE)

Desde la carpeta del kit:

```bash
# macOS / Linux / Git Bash
sh scripts/install.sh --list-stacks                                       # perfiles disponibles
sh scripts/install.sh --target ../mi-proyecto --stack nextjs-fastapi-postgres   # 1) simulación
sh scripts/install.sh --target ../mi-proyecto --stack nextjs-fastapi-postgres --apply   # 2) instala
sh scripts/install.sh --target ../mi-proyecto --apply                     # stack.md en blanco, para completar
sh scripts/install.sh --target ../mi-proyecto --tools claude,agents,cursor --apply      # solo algunas herramientas
```

```powershell
# Windows PowerShell
.\scripts\install.ps1 -ListStacks
.\scripts\install.ps1 -Target ..\mi-proyecto -Stack react-vite-nestjs-postgres          # simulación
.\scripts\install.ps1 -Target ..\mi-proyecto -Stack react-vite-nestjs-postgres -Apply
.\scripts\install.ps1 -Target ..\mi-proyecto -Tools claude,cursor -Apply
```

Herramientas: `claude`, `agents`, `cursor`, `copilot`, `windsurf`, `cline`, `gemini` (por defecto, todas). Las normas (`docs/standards/`, con su `stack.md`) se instalan siempre.

Si un archivo ya existe en el proyecto (por ejemplo, un `CLAUDE.md` o un `stack.md` ya completado), **no se toca**: el instalador lo avisa para que lo combines a mano. Con `--force` / `-Force` se reemplaza dejando un respaldo `.bak`.

## Instalación manual por herramienta

Primero, siempre: copiar `standards/` a `docs/standards/` del proyecto, y reemplazar `stack.md` por un perfil o completarlo.

| Herramienta | Qué copiar | Dónde |
|---|---|---|
| **Claude Code** (CLI, VS Code, JetBrains, desktop, web) | `rules/claude/CLAUDE.md` y `skills/*` | `CLAUDE.md` en la raíz · `.claude/skills/<skill>/SKILL.md` (del proyecto) o `~/.claude/skills/<skill>/SKILL.md` (personales) |
| **Codex** (CLI / IDE), **Jules**, **Zed**, **Aider** y otras que leen `AGENTS.md` | `rules/agents/AGENTS.md` | `AGENTS.md` en la raíz |
| **Cursor** | `rules/cursor/rules/*.mdc` (y opcional `AGENTS.md`) | `.cursor/rules/` |
| **GitHub Copilot** (VS Code, Visual Studio, JetBrains, github.com) | `rules/copilot/copilot-instructions.md` y `rules/copilot/instructions/*.instructions.md` | `.github/copilot-instructions.md` · `.github/instructions/` |
| **Windsurf** | `rules/windsurf/rules/*.md` | `.windsurf/rules/` |
| **Cline** | `rules/cline/*.md` | `.clinerules/` |
| **Gemini CLI** / Gemini Code Assist | `rules/gemini/GEMINI.md` + `AGENTS.md` | `GEMINI.md` en la raíz |
| **JetBrains AI Assistant** u otras | apuntar sus reglas de proyecto a `docs/standards/README.md` y `stack.md`, o copiar el texto de `AGENTS.md` | según la herramienta |

Notas:
- **Claude Code:** `CLAUDE.md` importa con `@` el índice de normas y `stack.md`, así están siempre en contexto. Las skills se activan solas por su `description` o se invocan con `/std-stack-setup`, `/std-milestone`, `/std-code-review`, etc. Las skills personales (`--personal-skills`) sirven en todos tus proyectos, pero leen `docs/standards/` de cada proyecto: instalá las normas igual.
- **Cursor, Copilot y Windsurf** activan las reglas por extensión de archivo (`globs` / `applyTo`). Vienen con extensiones comunes de varios lenguajes; ajustalas a tu stack (la skill `std-stack-setup` lo hace). Si front y back usan la misma extensión (p. ej. TypeScript en los dos), limitá por carpeta: `<backend>/**/*.ts`.
- Las rutas internas usan `<frontend>/` y `<backend>/`: en `stack.md §2` se declaran las reales.

## Seguridad

- **Solo texto.** Skills y reglas son Markdown: no incluyen scripts ejecutables, hooks, servidores MCP ni `allowed-tools` que amplíen permisos.
- **Los instaladores** solo copian archivos del kit al proyecto indicado: sin red, sin privilegios, no ejecutan lo que copian, arrancan en **simulación**, no sobrescriben sin `--force` y, si lo hacen, dejan `.bak`. El nombre del perfil se valida (solo `a-z`, `0-9` y `-`, y tiene que existir en `profiles/`), así que no se puede leer nada fuera del kit. Leelos antes de correrlos (son cortos).
- **Sin secretos ni datos**: el kit no contiene credenciales, URLs privadas ni datos personales, y sus normas prohíben agregarlos ([standards/security.md](standards/security.md)). `stack.md` lleva nombres de tecnologías y comandos, **nunca** valores de variables de entorno.
- **Revisá antes de commitear** en tu proyecto lo que se copió (`git diff`), como cualquier cambio.
- Si alguien te pasa una versión modificada del kit, compará con la tuya (`git diff` entre versiones) antes de instalarla: una regla puede cambiar el comportamiento de tu asistente.

## Personalizar

1. Editá `standards/` (y, si cambia algo indispensable, el resumen en `rules/`). Para un stack nuevo, agregá un perfil en `profiles/`.
2. Subí la versión en `VERSION` y anotá el cambio en `CHANGELOG.md`.
3. Reinstalá en cada proyecto con `--force` (deja respaldo) o copiando solo lo que cambió.

## Desactualización en un proyecto

Cada proyecto puede ajustar sus copias de `docs/standards/`. Para comparar con el kit: `diff -r dev-standards-kit/standards mi-proyecto/docs/standards` (la diferencia en `stack.md` es esperable).
