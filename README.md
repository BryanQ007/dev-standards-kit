# dev-standards-kit

Normas de programación, procedimientos paso a paso (**skills**) y **reglas** para asistentes de código, listas para instalar en cualquier proyecto, con **cualquier stack**, en cualquier IDE y con cualquier herramienta (o ninguna).

El kit es un estándar técnico: no trae reglas de negocio ni datos de ninguna aplicación, y **no fija tecnologías**. Las normas describen principios: capas, patrones, multi-tenant, bajas lógicas, base de datos normalizada, seguridad, cadena de suministro, responsive, tests y trabajo por hitos. Cada proyecto declara con qué los implementa en **`stack.md`**.

---

## Contenido

```text
dev-standards-kit/
├─ standards/        LA FUENTE DE VERDAD (Markdown neutral) → se instala en docs/standards/
│  ├─ README.md         índice + reglas transversales
│  ├─ stack.md          plantilla: tecnologías, carpetas, equivalencias, comandos
│  ├─ architecture.md   capas, patrones, SOLID, contrato HTTP, integraciones enchufables
│  ├─ frontend.md · responsive.md · design-system.md
│  ├─ backend.md · database.md (normalización, patrón State, versión de la base)
│  ├─ security.md       secretos, permisos, enlaces públicos, auditoría, cadena de suministro (pnpm)
│  ├─ testing.md · flows.md · naming.md · workflow.md (hitos, documentación, commits)
├─ profiles/         stacks listos para usar como stack.md
│  ├─ nextjs-fastapi-postgres.md · react-vite-nestjs-postgres.md · vue-nuxt-django-postgres.md
├─ skills/           procedimientos paso a paso (SKILL.md) → docs/standards/skills/
│  ├─ std-stack-setup/          define o cambia el stack
│  ├─ std-project-adoption/     audita un proyecto existente y arma el plan para adaptarlo
│  ├─ std-milestone/            empezar, partir y cerrar hitos
│  ├─ std-commit-handoff/       stage + mensaje de commit recomendado, a nombre de la persona
│  ├─ std-frontend-component/ · std-responsive/ · std-backend-module/ · std-backend-tests/
│  ├─ std-database-migration/ · std-flow-design/ · std-code-review/
│  └─ std-dependency-audit/     rutina de paquetes, Docker y runtimes
├─ rules/            un puente por herramienta: resumen corto que apunta a docs/standards/
│  ├─ agents/AGENTS.md · claude/CLAUDE.md · gemini/GEMINI.md
│  ├─ cursor/rules/*.mdc · copilot/… · windsurf/rules/*.md · cline/*.md
├─ templates/adoption_report.md       plantilla del informe de adopción (la deja --adopt)
├─ install.sh · install.ps1 · install.cmd   ★ abren el menú de instalación (Tutorial 0)
└─ scripts/
   ├─ menu.sh · menu.ps1               el menú: pregunta, muestra la simulación y confirma
   └─ install.sh · install.ps1         instaladores sin menú (simulación por defecto; --adopt, --skills)
```

Las normas existen **una sola vez**, en `docs/standards/`. Los archivos de cada herramienta no las copian: resumen lo indispensable y apuntan ahí.
- Para cambiar una norma, se edita `standards/`.
- Para cambiar de tecnología, se edita `stack.md`.
- Los procedimientos (`docs/standards/skills/`) son Markdown plano: los sigue cualquier asistente o una persona.

---

## Requisitos

- **sh** (macOS, Linux o Git Bash) o **PowerShell** (Windows) para el instalador.
- **git** en el proyecto destino.
- **pnpm** para JavaScript/TypeScript ([Tutorial 7](#tutorial-7--pasar-de-npm-a-pnpm)).
- Para la base de datos: el motor del proyecto y, para probar migraciones, Docker (una base descartable).

---

## Dónde poner el kit (y cómo queda desconectado de git)

**El kit no se pega dentro del proyecto.** El instalador **copia** archivos de texto desde donde esté el kit hacia el proyecto que le indiques (`--target` o la ruta del menú):
- copia las normas, los procedimientos y los archivos de cada herramienta;
- **nunca copia `.git`** ni nada fuera de esa lista.

Lo que queda en tu proyecto son archivos sueltos, sin vínculo con el repositorio del kit: los commiteás en **tu** repo, y nada viaja al repo del kit.

### Forma A — El kit en su propia carpeta, fuera del proyecto

Sirve para cualquier proyecto, nuevo o ya creado.

```text
~/herramientas/dev-standards-kit    ← el kit (se actualiza con git pull)
~/proyectos/mi-proyecto             ← tu repo (recibe las copias)
```

1. Cloná el kit en una carpeta de herramientas:
   ```bash
   mkdir -p ~/herramientas && cd ~/herramientas
   git clone --depth 1 <url-del-kit> dev-standards-kit
   ```
2. **Para que desde el kit no se pueda subir nada a su repositorio**, quitale el remoto. Sigue funcionando igual, pero `git push` no tiene a dónde ir:
   ```bash
   git -C dev-standards-kit remote remove origin
   ```
   Para actualizarlo más adelante: `git -C dev-standards-kit pull <url-del-kit> main`.
3. Abrí el menú y escribí la ruta de tu proyecto cuando la pida:
   ```bash
   cd dev-standards-kit && sh install.sh        # ruta: ../../proyectos/mi-proyecto
   ```

### Forma B — Sin git: descarga del código

1. Descargá el kit **sin historia ni vínculo**, de una de estas dos maneras:
   - el **ZIP** desde la página del repositorio ("Code → Download ZIP"); un ZIP no trae `.git`;
   - o un clon al que después le borrás el `.git`:
     ```bash
     git clone --depth 1 <url-del-kit> dev-standards-kit
     rm -rf dev-standards-kit/.git              # PowerShell: Remove-Item -Recurse -Force dev-standards-kit\.git
     ```
2. Abrí el menú (`sh install.sh`, `.\install.ps1` o `install.cmd`) e instalalo en tu proyecto.
3. Si no lo vas a usar más, borrá la carpeta del kit. Tu proyecto ya tiene sus copias.

### Forma C — El kit dentro del repo del proyecto (como carpeta de herramientas)

Si preferís tener el kit adentro del proyecto (p. ej. `mi-proyecto/dev-standards-kit/`):

1. Copialo o clonalo adentro, con la Forma B (sin `.git`).
2. **Excluilo del repo del proyecto**, para que no se suba con él:
   ```bash
   echo "dev-standards-kit/" >> .gitignore
   git check-ignore -v dev-standards-kit/README.md     # tiene que mostrar la línea del .gitignore
   ```
3. Abrí el menú desde esa carpeta. Como ruta del proyecto, escribí `..`.

**Qué pasa si no se excluye:**
- si el kit tiene su propio `.git`, git lo trata como un repositorio anidado y lo sube como una referencia rota;
- si no lo tiene, se suben todos sus archivos.

En los dos casos, **el menú avisa**: "el kit está DENTRO del proyecto y git no lo ignora". También avisa si el kit sigue conectado a su repositorio por `.git`.

### Forma D — Instalación de una sola vez, sin dejar nada

```bash
git clone --depth 1 <url-del-kit> /tmp/dev-standards-kit
sh /tmp/dev-standards-kit/install.sh          # ruta: la de tu proyecto
rm -rf /tmp/dev-standards-kit
```

### Qué queda en tu proyecto, con cualquier forma

```text
mi-proyecto/
├─ docs/standards/            normas + stack.md
├─ docs/standards/skills/     procedimientos
├─ docs/adoption_report.md    (solo en modo adopción)
└─ AGENTS.md, .cursor/rules/, .github/…   (solo las herramientas elegidas)
```

Para actualizar esas copias con una versión nueva del kit, corré el instalador otra vez. Con `--force`, reemplaza lo anterior y deja un respaldo `.bak`.

---

## Tutorial 0 — Instalar con el menú

Es la forma más simple: un menú en la consola pregunta qué instalar.

1. Bajá el kit **fuera de tu proyecto** y sin vínculo de subida (ver [Dónde poner el kit](#dónde-poner-el-kit-y-cómo-queda-desconectado-de-git)):
   ```bash
   git clone --depth 1 <url-del-kit> dev-standards-kit
   git -C dev-standards-kit remote remove origin
   cd dev-standards-kit
   ```
2. Abrí el menú. Git no ejecuta nada al clonar, por seguridad, así que este es el primer comando:

   | Sistema | Comando |
   |---|---|
   | macOS, Linux o Git Bash | `sh install.sh` |
   | Windows PowerShell | `.\install.ps1` |
   | Windows, con doble clic | `install.cmd` |

3. Elegí una opción:
   ```text
   ==================================================
     dev-standards-kit 1.3.0 · instalador
   ==================================================
     1. Instalar todo el kit (normas, todas las skills y las reglas de todas las herramientas)
     2. Instalar eligiendo skills y herramientas
     3. Adoptar el estándar en un proyecto ya creado (no pisa nada, deja el informe)
     4. Ver qué hace cada skill
     5. Ver los perfiles de stack
     0. Salir
   ```
4. Respondé lo que pide:
   - **la ruta del proyecto**;
   - **el stack**: un perfil, o `0` para la plantilla en blanco;
   - **en la opción 2, las skills**: sus números separados por espacio, por ejemplo `4 9 12`, o `todas`;
   - **en las opciones 2 y 3, las herramientas**: sus números, `todas` o `ninguna`. Las normas y los procedimientos se instalan siempre.
5. El menú muestra un **resumen** y la **simulación** de lo que copiaría. Respondé `s` para instalar, o `N` para salir sin tocar nada.
6. Revisá lo copiado con `git diff` en el proyecto y seguí con el Tutorial 1 (proyecto nuevo) o el Tutorial 2 (proyecto existente) desde el paso de completar `stack.md`.

Sin menú, para scripts o CI, se usan los instaladores de `scripts/` con opciones, como en los tutoriales siguientes. Para elegir skills: `--skills std-milestone,std-code-review` (PowerShell: `-Skills …`); para verlas todas: `--list-skills`.

---

## Tutorial 1 — Instalar el kit en un proyecto nuevo

1. Abrí una terminal en la carpeta del kit.
2. Mirá los perfiles de stack disponibles:
   ```bash
   sh scripts/install.sh --list-stacks          # PowerShell: .\scripts\install.ps1 -ListStacks
   ```
3. Simulá la instalación. Sin `--apply` no se copia nada: solo se muestra qué haría.
   ```bash
   sh scripts/install.sh --target ../mi-proyecto --stack nextjs-fastapi-postgres
   # PowerShell: .\scripts\install.ps1 -Target ..\mi-proyecto -Stack nextjs-fastapi-postgres
   ```
4. Instalá:
   ```bash
   sh scripts/install.sh --target ../mi-proyecto --stack nextjs-fastapi-postgres --apply
   ```
   - Para instalar solo algunas herramientas, agregá `--tools agents,cursor` (PowerShell: `-Tools agents,cursor`). Las opciones son `claude`, `agents`, `cursor`, `copilot`, `windsurf`, `cline` y `gemini`; por defecto se instalan todas.
   - **Siempre se instalan:** las normas, en `docs/standards/`, y los procedimientos, en `docs/standards/skills/`.
   - **Si un archivo ya existe**, no se toca: el instalador avisa, para que lo combines a mano. Con `--force` (`-Force`) se reemplaza, dejando un respaldo `.bak`.
5. Si no usaste un perfil, completá `docs/standards/stack.md` (ver [Tutorial 3](#tutorial-3--declarar-el-stack)).
6. Creá la base de la documentación del proyecto en `docs/`:
   - `context.md`: qué es el producto y qué entra en la etapa activa;
   - `business_rules.md`: las reglas `RN-xx`;
   - `plan.md`, `changelog.md` y `current_stage.md`: el seguimiento ([Tutorial 4](#tutorial-4--trabajar-por-hitos)).
7. Revisá lo copiado con `git diff` y commitealo en el proyecto.

---

## Tutorial 2 — Adoptar el estándar en un proyecto que ya existe

Para un proyecto ya creado, el instalador tiene un **modo adopción**:
- **nunca pisa nada**, y no se combina con `--force`;
- deja la plantilla del informe en `docs/adoption_report.md`;
- muestra los pasos siguientes.

1. Simulá y después instalá en modo adopción:
   ```bash
   sh scripts/install.sh --target ../proyecto-existente --adopt             # simulación
   sh scripts/install.sh --target ../proyecto-existente --adopt --apply     # instala
   # PowerShell: .\scripts\install.ps1 -Target ..\proyecto-existente -Adopt -Apply
   ```
   Si tu stack coincide con un perfil, agregá `--stack <perfil>`. Si no, `stack.md` queda para completar en el paso 3.
2. Combiná a mano los archivos que el instalador marca como **"ya existe, no se toca"**, por ejemplo tu `AGENTS.md` o tus reglas de Cursor: sumá a los tuyos el resumen y el enlace a `docs/standards/`.
3. Corré el procedimiento **`std-project-adoption`**: pedile a tu asistente *"auditá el proyecto contra docs/standards con el procedimiento std-project-adoption"*, o seguí `docs/standards/skills/std-project-adoption/SKILL.md` a mano. La auditoría es **solo lectura**:
   1. completa `stack.md` con lo que detecta en el repo;
   2. corre lint, tipos y tests como línea base;
   3. revisa dependencias, Docker y runtimes;
   4. revisa área por área: seguridad, base de datos (normalización, estados, tabla de versión), capas, frontend, tests, nombres y documentación.
4. Leé el informe, `docs/adoption_report.md`. Arriba aparece lo **urgente**: secretos versionados, datos personales, dependencias comprometidas. Eso se corrige primero.
5. Aprobá el **plan de adaptación**, que se agrega a `docs/plan.md` como una fase propia, en este orden:
   1. lo urgente;
   2. la red de seguridad: tests y la tabla de versión de la base;
   3. el proceso y pnpm;
   4. la base de datos;
   5. las capas y el frontend, módulo por módulo;
   6. lo cosmético, al pasar.
6. Ejecutá el plan **de a un hito por vez** ([Tutorial 4](#tutorial-4--trabajar-por-hitos)). Nada se rehace de una vez, y los cambios de base van por migraciones nuevas. Si la base no tenía tabla de control de versión, ese es uno de los primeros hitos ([Tutorial 6](#tutorial-6--base-de-datos-versión-normalización-y-estados)).
7. Repetí `std-project-adoption` al cerrar cada fase, para medir el avance.

---

## Tutorial 3 — Declarar el stack

`docs/standards/stack.md` tiene 6 secciones:

| Sección | Qué se completa |
|---|---|
| 1. Tecnologías | Framework y lenguaje de frontend y backend, base, acceso a datos, migraciones, auth, almacenamiento, contenedores. También **gestor de paquetes (pnpm)**, gestor del backend y **antigüedad mínima** de las versiones |
| 2. Carpetas | Dónde va cada cosa: UI kit, features, módulos, tema, migraciones, tests |
| 3. Equivalencias | Cómo se llama cada patrón de las normas en el stack (p. ej. "vista + lógica" = `X.tsx + useX.ts`) |
| 4. Comandos | Formato, lint, tipos, límite de líneas, tests, SQL de migraciones, **versión de la base**, **auditoría de dependencias** y **fecha de publicación** de un paquete |
| 5. Particularidades | Advertencias propias de esas herramientas |
| 6. Idioma | Idioma de la documentación, locale y moneda |

Hay tres formas de completarlo:
1. **Con un perfil:** `--stack <perfil>` al instalar; después se ajusta lo que difiera.
2. **Con el procedimiento `std-stack-setup`:** detecta lo que hay en el repo (`package.json`, `pyproject.toml`, `docker-compose`…), pregunta lo que falta y prueba los comandos.
3. **Con un perfil propio:** copiá `standards/stack.md` a `profiles/<frontend>-<backend>-<base>.md`, completalo y usalo con `--stack` en todos tus proyectos con ese stack.

---

## Tutorial 4 — Trabajar por hitos

El trabajo se hace en **hitos** chicos: un hito = un commit.

1. **Antes de empezar**, confirmá que el hito anterior ya está commiteado (`git log -1`). En el árbol de trabajo va **un solo hito por vez**.
2. **Leé** `docs/current_stage.md`, el hito en `docs/plan.md` y la norma del área.
3. **Contá los archivos de trabajo**: código, tests, migraciones, SQL y configuración. Con más de **5**, partí el hito (`H3.4a`, `H3.4b`) antes de empezar.
   - **La documentación** (`docs/`: reglas, modelo, flujos, specs, normas) **no cuenta** y va en el mismo commit.
   - **El código del hito** tiene que ser único: buscalo en el plan antes de usarlo.
4. **Implementá** con el procedimiento del área: `std-frontend-component`, `std-backend-module`, `std-database-migration`, `std-flow-design`…
5. **Verificá** con los comandos de `stack.md §4`:
   - lint, tipos, límite de 200 líneas y tests;
   - las pantallas, en 390, 768 y 1280 px;
   - las migraciones, en una base descartable.
6. **Actualizá en el mismo commit:**
   - la documentación que cambió, marcando qué está **construido** y qué es **diseño**;
   - `plan.md`: `[x]`;
   - `changelog.md`: los cambios, **"Cómo se usa"** y **"Comandos ejecutados"**, sin secretos;
   - `current_stage.md`: se reescribe.
7. **Commit, a tu nombre:**
   1. el asistente deja el hito en stage (`git add -A`);
   2. te entrega el mensaje recomendado, por ejemplo:
      ```text
      H3.4a: alta de proyectos con su estado inicial
      ```
   3. vos lo commiteás con tu usuario: `git commit -m "H3.4a: alta de proyectos con su estado inicial"`.

   **La historia no muestra ningún agente:** sin coautores, sin "Generated with" y sin cambiar el usuario de git. Si tu herramienta agrega esas líneas, desactivalas en su configuración.

Los procedimientos **`std-milestone`** y **`std-commit-handoff`** hacen estos pasos en orden.

---

## Tutorial 5 — Rutinas

| Rutina | Cuándo | Cómo |
|---|---|---|
| **Dependencias, Docker y runtimes** | Una vez por semana, al empezar cada fase, antes de desplegar, al agregar o actualizar un paquete o una imagen | Procedimiento `std-dependency-audit` |
| **Auditoría de seguridad** | Antes de publicar, y al cerrar hitos que tocan autenticación, endpoints públicos, secretos, archivos o integraciones | Skill externa `security-audit` (más abajo) |
| **Cumplimiento del estándar** | Al cerrar cada fase | Procedimiento `std-project-adoption` |
| **Revisión de cambios** | Antes de mergear una rama o cuando se pide | Procedimiento `std-code-review` |

### 5.1 Rutina de dependencias

1. Pedí *"corré la rutina de dependencias"* o seguí `docs/standards/skills/std-dependency-audit/SKILL.md`.
2. **El inventario:** los `package.json` y lockfiles, las dependencias del backend, los `Dockerfile` y `docker-compose`, y las versiones de Node.js, Python y las imágenes base.
3. **La antigüedad de cada versión:**
   ```bash
   pnpm view <paquete>@<versión> time --json                  # npm registry
   curl -s https://pypi.org/pypi/<paquete>/<versión>/json     # PyPI: upload_time
   ```
   Ninguna versión puede tener **menos de N días** publicada (`stack.md`, por defecto 7).
4. **Las auditorías:**
   ```bash
   pnpm audit --prod
   uv run pip-audit                 # o el auditor del backend
   docker scout cves <imagen>       # o el escáner de imágenes que uses
   ```
5. **La búsqueda en la web** de cada runtime, imagen base y dependencia directa, **en su versión exacta**, para detectar compromisos recientes:
   - avisos del proyecto;
   - GitHub Advisory Database y OSV;
   - noticias de paquetes secuestrados o versiones maliciosas.
6. **El informe:** una tabla con versión, fecha, estado (✅ / ⚠ joven / ❌ vulnerable / 🚨 comprometido) y acción.
   - **Un compromiso confirmado se avisa primero**, y no se instala nada.
   - **Los cambios** a dependencias se hacen como hito propio.

### 5.2 Auditoría de seguridad (skill externa)

1. Leé el repositorio de la skill antes de instalarla, sobre todo si trae scripts o hooks: <https://github.com/cloudflare/security-audit-skill>.
2. Instalala:
   ```bash
   pnpm dlx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit
   ```
3. Fijá la versión (un commit o una etiqueta) y revisá los cambios antes de actualizarla.
4. Correla sobre el cambio del hito o la rama. Los hallazgos confirmados se corrigen en el hito o se anotan en el plan con su gravedad. El detalle está en `security.md §7`.

---

## Tutorial 6 — Base de datos: versión, normalización y estados

### 6.1 Saber cuál fue la última migración corrida

1. **Usá la tabla de control de tu herramienta**: `alembic_version`, `_prisma_migrations`, `django_migrations`, `flyway_schema_history`… Si aplicás SQL a mano, creá `schema_migrations` en la primera migración (`database.md §9.1`).
2. **Anotá la consulta** en `stack.md §4`:
   ```sql
   select version_num from alembic_version;                                            -- Alembic
   select version, name, applied_at from schema_migrations order by applied_at desc limit 1;   -- tabla propia
   ```
3. **Cada `.sql` incremental**:
   - comprueba al principio que la base esté en la versión anterior, y aborta si no;
   - al final, registra la suya, en la misma transacción.
4. **En `docs/current_stage.md`**, anotá en qué versión está cada entorno y cuándo lo comprobaste.

### 6.2 Normalizar

1. **Una columna, un valor:** nada de listas separadas por comas, columnas `telefono1`/`telefono2` ni arrays de ids.
2. **Lo que depende de otra cosa vive en su tabla:** el nombre de un estado está en su catálogo, no copiado.
3. **Muchos a muchos → tabla intermedia:**
   ```sql
   create table project_members (
     id          uuid primary key default gen_random_uuid(),
     organization_id uuid not null references organizations(id),
     project_id  uuid not null references projects(id),
     profile_id  uuid not null references profiles(id),
     role_id     smallint not null references project_member_roles(id),
     joined_on   date not null,
     is_active   boolean not null default true
   );
   create unique index uq_project_members_active on project_members (project_id, profile_id) where is_active;
   ```
4. **JSON solo para documentos en sí** (una copia congelada, la respuesta de un proveedor), nunca para datos que se consultan o relacionan.

### 6.3 Estados con el patrón State

1. **Catálogo de estados**, con los terminales marcados (`is_terminal`).
2. **Tabla de transiciones permitidas** (`<entidad>_status_transitions`), con la acción que habilita cada salto.
3. **Trigger** que rechaza un salto que no está en la tabla.
4. **Histórico** de estados por trigger, con quién, cuándo y por qué.
5. **Lo calculado** (p. ej. "por vencer") no se guarda como estado.

El ejemplo completo está en `database.md §6`.

---

## Tutorial 7 — Pasar de npm a pnpm

1. Instalá pnpm (por ejemplo `corepack enable pnpm`) y comprobá la versión con `pnpm --version`.
2. En la carpeta del frontend, convertí el lockfile:
   ```bash
   pnpm import                 # crea pnpm-lock.yaml desde package-lock.json
   rm package-lock.json && rm -rf node_modules
   pnpm install
   ```
3. Configurá la seguridad en `pnpm-workspace.yaml` (o `.npmrc`):
   ```yaml
   minimumReleaseAge: 10080          # 7 días, en minutos
   onlyBuiltDependencies:            # los únicos paquetes que pueden correr scripts de instalación
     - <paquete-que-lo-necesita>
   ```
4. En los `Dockerfile`, reemplazá `npm ci` por `corepack enable pnpm && pnpm install --frozen-lockfile`, y `npm run` por `pnpm run`.
5. En `stack.md §4`, en los scripts y en la documentación, cambiá `npx` por `pnpm exec` (o `pnpm dlx` para lo de una sola vez).
6. Corré lint, tipos, tests y la construcción de las imágenes. Commiteá el cambio como un hito propio.

---

## Instalación manual por herramienta

Siempre, para cualquier herramienta:
1. Copiá `standards/` a `docs/standards/` y elegí o completá `stack.md`.
2. Copiá `skills/*` a `docs/standards/skills/`.

Después, según la herramienta:

| Herramienta | Qué copiar | Dónde |
|---|---|---|
| **Codex** (CLI / IDE), **Jules**, **Zed**, **Aider** y otras que leen `AGENTS.md` | `rules/agents/AGENTS.md` | `AGENTS.md` en la raíz |
| **Cursor** | `rules/cursor/rules/*.mdc` (y opcional `AGENTS.md`) | `.cursor/rules/` |
| **GitHub Copilot** (VS Code, Visual Studio, JetBrains, github.com) | `rules/copilot/copilot-instructions.md` y `rules/copilot/instructions/*.instructions.md` | `.github/copilot-instructions.md` · `.github/instructions/` |
| **Windsurf** | `rules/windsurf/rules/*.md` | `.windsurf/rules/` |
| **Cline** | `rules/cline/*.md` | `.clinerules/` |
| **Gemini CLI** / Gemini Code Assist | `rules/gemini/GEMINI.md` + `AGENTS.md` | `GEMINI.md` en la raíz |
| **Claude Code** (CLI, VS Code, JetBrains, desktop, web) | `rules/claude/CLAUDE.md` y `skills/*` | `CLAUDE.md` en la raíz · `.claude/skills/<skill>/SKILL.md` (del proyecto) o `~/.claude/skills/<skill>/SKILL.md` (personales, con `--personal-skills`) |
| **JetBrains AI Assistant** u otras | apuntá sus reglas de proyecto a `docs/standards/README.md` y `stack.md`, o copiá el texto de `AGENTS.md` | según la herramienta |

**Cómo carga cada herramienta las reglas:**
- **Cursor, Copilot y Windsurf** activan las reglas por extensión de archivo (`globs` / `applyTo`). Si front y back usan la misma extensión (p. ej. TypeScript en los dos), limitalas por carpeta (`<backend>/**/*.ts`); el procedimiento `std-stack-setup` lo ajusta.
- **Claude Code** importa con `@` el índice de normas y `stack.md`. Las skills se activan por su descripción o con `/std-<nombre>`.
- **Una herramienta sin skills** sigue los procedimientos de `docs/standards/skills/`, que `AGENTS.md` lista por tarea.

---

## Seguridad del kit

- **Solo texto.** Las skills y reglas del kit son Markdown: no incluyen scripts ejecutables, hooks, servidores MCP ni permisos ampliados.
- **El menú** solo pregunta y llama a los instaladores. Siempre muestra primero la simulación, y nada se copia sin una `s` explícita. `install.cmd` usa `-ExecutionPolicy Bypass` solo para ese proceso, sin cambiar la configuración del equipo.
- **Los instaladores** solo copian archivos del kit al proyecto indicado:
  - sin red, sin privilegios, y no ejecutan lo que copian;
  - arrancan en **simulación** y no sobrescriben sin `--force`; si lo hacen, dejan un `.bak`;
  - validan el nombre del perfil, así que no pueden leer fuera del kit.
- **Sin secretos ni datos:** el kit no contiene credenciales, URLs privadas ni datos personales. `stack.md` lleva nombres de tecnologías y comandos, **nunca** valores de variables de entorno.
- **Lo externo se instala aparte:** la skill `security-audit` no viene en el kit ni la instalan los instaladores (Tutorial 5.2).
- **Una versión del kit que te pasa otra persona** se compara con la tuya (`git diff`) antes de instalarla: una regla puede cambiar el comportamiento de tu asistente.

---

## Actualizar y personalizar el kit

1. Editá `standards/`. Si cambia algo indispensable, también el resumen de `rules/`. Para un stack nuevo, agregá un perfil en `profiles/`.
2. Subí la versión en `VERSION` y anotá el cambio en `CHANGELOG.md`.
3. Reinstalá en cada proyecto con `--force` (deja respaldo), o copiá solo lo que cambió.
4. Para comparar un proyecto con el kit:
   ```bash
   diff -r dev-standards-kit/standards mi-proyecto/docs/standards
   ```
   La diferencia en `stack.md` es esperable.
