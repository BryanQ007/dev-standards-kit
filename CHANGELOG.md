# Changelog

## 1.3.0 — 2026-10-29

**Menú de instalación por consola**
- **Puntos de entrada en la raíz del kit**, lo primero que se corre después de clonar (git no ejecuta nada al clonar, por seguridad):
  - `install.sh` (macOS, Linux, Git Bash);
  - `install.ps1` (PowerShell);
  - `install.cmd` (doble clic en Windows).
- `scripts/menu.sh` y `scripts/menu.ps1`, con el mismo flujo:
  - **opciones:** 1. todo el kit · 2. elegir skills y herramientas · 3. adoptar en un proyecto ya creado · 4. ver qué hace cada skill · 5. ver los perfiles de stack · 0. salir;
  - **preguntas:** la ruta (que exista), el stack (perfil o plantilla), las skills por número (o `todas`) y las herramientas por número (`todas` o `ninguna`);
  - **resumen y simulación siempre**, y se instala solo con `s`.
- Instaladores: opciones nuevas **`--skills a,b` / `-Skills`**, que instala solo esas skills con el nombre validado, y **`--list-skills` / `-ListSkills`**.
- **Probado:**
  - `sh` y PowerShell con respuestas simuladas (opción 2 con 2 skills y 1 herramienta, "N" → no copia nada);
  - `sh` en modo adopción sin herramientas, con "s" → 26 archivos: normas, skills e informe;
  - los scripts de PowerShell, guardados con BOM para que PowerShell 5.1 lea bien los acentos.
- README: **Tutorial 0, instalar con el menú**, el árbol de contenidos y la seguridad del menú.

**El kit fuera del repo del proyecto y sin vínculo de subida**
- README, sección nueva **"Dónde poner el kit"**:
  - el kit no se pega en el proyecto: el instalador copia archivos y **nunca copia `.git`**;
  - **Forma A:** carpeta propia, con `git remote remove origin` para que no se pueda hacer push al kit;
  - **Forma B:** ZIP o clon sin `.git`;
  - **Forma C:** dentro del proyecto, pero en el `.gitignore` y sin `.git`, con la verificación `git check-ignore`;
  - **Forma D:** de una sola vez, en una carpeta temporal;
  - qué queda en el proyecto con cualquiera de las cuatro.
- El menú (sh y PowerShell) **avisa** si el kit está dentro del proyecto y git no lo ignora, y si el kit sigue conectado a su repositorio por `.git`. Probado con un repo temporal: avisa sin `.gitignore` y no avisa con él.

## 1.2.0 — 2026-10-29

Reglas aprendidas en el uso real del kit. Todo es genérico: nada depende de un proyecto ni de una herramienta.

**Proceso (`workflow.md`, `std-milestone`)**
- **La documentación no cuenta para el límite de 5 archivos de trabajo y va siempre en el mismo commit:** reglas, modelo, arquitectura, flujos, specs y normas. Los 5 de trabajo son código, tests, migraciones, SQL y configuración.
- Cada flujo, spec o regla marca qué está **construido** y qué es **diseño**.
- Un solo hito por vez en el árbol de trabajo; antes de empezar, confirmar que el anterior está commiteado.
- Identificador de hito único: se busca en el plan antes de nombrarlo.
- Archivo que pasa las 200 líneas durante el hito: se extrae en ese hito; si eso supera el límite, se mueve lo no esencial al siguiente.
- Changelog con la sección **"Cómo se usa"** cuando cambia algo para quien usa el sistema, incluido lo que todavía no funciona.
- Commits: sin coautores ni atribuciones si así se pidió; si no hay autorización, stage + mensaje listo para copiar.

**Seguridad (`security.md`)**
- Motivo **solo cuando aporta**: obligatorio en excepciones y reversiones, comentario opcional en los pasos normales, según el catálogo de acciones.
- Sección nueva: **enlaces públicos y códigos de un solo uso** (solo la huella, el mismo 410, código con huella atada al enlace, lo de un solo uso se gasta al final, `noindex` y sin *referrer*).
- Asistentes: verificar sin tocar datos compartidos; no abrir aplicaciones de la persona por su cuenta.
- Sección nueva **§7 Auditoría de seguridad**:
  - la skill externa `security-audit` de Cloudflare (`pnpm dlx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit`);
  - cuándo correrla y qué hacer con los hallazgos;
  - los cuidados por ser de un tercero: la instala la persona, se revisa antes y se fija la versión.
  - La usan `std-code-review` y `std-milestone`, y figura en `AGENTS.md` y en el README.
  - **No** la instalan los instaladores del kit.
  - "Asistentes de IA" pasa a §9.
- Sección nueva **§8 Cadena de suministro** (regla transversal 13):
  - **pnpm en lugar de npm**, con `minimumReleaseAge`, `onlyBuiltDependencies`, `--frozen-lockfile` y cómo mudar (`pnpm import`);
  - Python con lockfile (`uv`, `exclude-newer`);
  - imágenes de Docker con versión exacta o digest;
  - **antigüedad mínima de N días** (por defecto 7) para paquetes, runtimes e imágenes;
  - **rutina de verificación** semanal, por fase y antes de desplegar. Cubre: inventario de `package.json`, dependencias del backend y Dockerfiles; antigüedad; auditorías; **búsqueda web de compromisos** de Node.js, Python, imágenes y cada dependencia directa; señales de alerta.
- Skill nueva **`std-dependency-audit`**, con el informe por paquete: versión, fecha, estado y acción.
- `stack.md` y los tres perfiles:
  - el gestor de paquetes (pnpm), el gestor del backend y la antigüedad mínima;
  - los comandos de auditoría y de fecha de publicación;
  - todos los `npx`/`npm run` pasan a `pnpm exec`/`pnpm run`, y `npx skills add` pasa a `pnpm dlx skills add`.
- **Dónde más se usa:**
  - `std-milestone`: la rutina al empezar una fase y la versión con antigüedad al agregar un paquete;
  - `std-code-review`: la fila "Dependencias";
  - `std-stack-setup`: pnpm por defecto y la antigüedad de 7 días;
  - las reglas de todas las herramientas y el checklist de `workflow.md`.
- Asistentes: no instalan ni actualizan dependencias sin seguir §8. Las búsquedas web llevan solo nombres y versiones públicas.

**Commits a nombre de la persona**
- Skill nueva **`std-commit-handoff`**:
  - el asistente no commitea ni deja rastro de agente en la historia (sin cambiar el usuario de git, sin `--author`, sin `Co-Authored-By` ni "Generated with");
  - al terminar cada hito deja el stage y entrega el mensaje recomendado `Hx.y: descripción`, con el código y el orden del hito;
  - qué hacer si la persona commitea algo distinto.
- `workflow.md §3`, `std-milestone`, `AGENTS.md`, el README (Tutorial 4) y las reglas de cada herramienta al día.

**Adopción en proyectos existentes**
- Skill nueva **`std-project-adoption`**:
  - auditoría de solo lectura de un proyecto establecido contra todo el kit (stack, línea base, seguridad, dependencias, base de datos, capas, frontend, tests, nombres y documentación);
  - el informe `docs/adoption_report.md`, con lo urgente arriba;
  - un plan por hitos, en orden: urgente → red de seguridad → proceso → base → capas → cosmético;
  - las rutinas que siguen después.
- Figura en `AGENTS.md` y en las reglas de cada herramienta.
- **Modo adopción en los instaladores** (`--adopt` / `-Adopt`), para proyectos ya creados:
  - nunca pisa nada: no se combina con `--force`, y el aviso de "ya existe" no sugiere forzar;
  - instala las normas y los procedimientos;
  - deja la plantilla `templates/adoption_report.md` en `docs/adoption_report.md`;
  - imprime los 5 pasos siguientes.
- Probado en sh y PowerShell: respeta un `AGENTS.md` existente y rechaza `--force`.
- README, Tutorial 2, reescrito con el modo adopción.

**Base de datos (`database.md`, reorganizada)**
- **§4 Normalización y relaciones (nueva):**
  - 1FN, 2FN y 3FN con ejemplos;
  - una tabla por tipo de relación;
  - **muchos a muchos siempre con tabla intermedia** (`unique` del par y columnas propias);
  - FK polimórficas solo validadas;
  - JSON solo para documentos;
  - desnormalizar solo con motivo medido.
- **§6 Estados con el patrón State (nueva):** catálogo con terminales, `<entidad>_status_transitions`, trigger que rechaza saltos no permitidos, lo calculado no es un estado, y cambios de varias tablas como función transaccional.
- **§9.1 Control de versión de la base (nueva):**
  - siempre una tabla que dice cuál fue la última migración corrida: la de la herramienta (`alembic_version`, `_prisma_migrations`, `django_migrations`, `flyway_schema_history`…) o `schema_migrations` propia;
  - el `.sql` incremental comprueba la versión anterior y registra la suya;
  - la consulta va en `stack.md §4` y en los perfiles.
- Reglas duras 1, 9 y 10, nombres (tabla intermedia, transiciones, tabla de control) y checklist al día. También `std-database-migration`, `std-code-review` y las reglas de base de cada herramienta.

**README del kit reescrito como tutoriales:**
1. instalar en un proyecto nuevo;
2. adoptar el estándar en uno existente;
3. declarar el stack;
4. trabajar por hitos;
5. rutinas (dependencias y auditoría de seguridad);
6. base de datos: versión, normalización y estados;
7. pasar de npm a pnpm.

Además: instalación manual por herramienta, seguridad del kit, y actualizar y personalizar.

**Arquitectura (`architecture.md`, regla transversal 12)**
- Integraciones enchufables **sin éxitos falsos**: `none` por defecto, adaptador de prueba solo fuera de producción, "no configurado" (503), alternativa manual (copiar), logs sin destinos ni contenidos, forma de ver los mensajes en desarrollo, integradores externos solo por la API.

**Base de datos (`database.md`, `std-database-migration`)**
- Una migración **no depende de valores que carga un seeder** (en una base nueva el esquema corre antes).
- Qué cubre la prueba en la base descartable (rechazos, históricos, permisos, seguridad de filas); operaciones de varias tablas como función transaccional.

**Diseño (`design-system.md`)**
- `*-foreground` solo sobre su color lleno; sobre fondos tenues, `text-foreground` o el color.
- §5.1 `Modal`: columna en la que solo se desplaza el cuerpo; nunca un modal encima de otro; sub-pasos en el mismo modal con "← Volver".

**Responsive (`responsive.md`, `std-responsive`)**
- Verificación con un navegador headless **manejado por su protocolo de depuración** (ancho real emulado, espera en tiempo real, medir `scrollWidth`); respuestas del API simuladas para revisar estados con datos. La captura con reloj virtual no espera la red.

**Tests (`testing.md`, `std-backend-tests`)**
- Adaptadores de prueba activados solo dentro del test; credenciales de un solo uso con todos sus casos; mirar la base (solo lectura) ante un 500 del entorno real.

**Sin dependencia de una herramienta**
- Las skills se instalan **siempre** en `docs/standards/skills/` como procedimientos neutrales; `.claude/skills/` queda solo si se elige esa herramienta.
- `AGENTS.md` lista los procedimientos por tarea; las reglas de Cursor, Copilot, Windsurf, Cline y Gemini apuntan a esa carpeta.
- `security.md` ya no nombra los ajustes locales de una herramienta en particular.
- Reglas por herramienta y skills (`std-code-review`, `std-frontend-component`, `std-backend-module`, `std-flow-design`) al día con todo lo anterior.

## 1.1.0 — 2026-10-15

- **Stack configurable:** las normas pasan a ser independientes de la tecnología. Cada proyecto declara frontend, backend, base, carpetas, equivalencias de patrones y comandos en `standards/stack.md` (plantilla).
- `profiles/`: tres stacks listos (Next.js + FastAPI + PostgreSQL, React/Vite + NestJS + PostgreSQL, Nuxt + Django + PostgreSQL).
- Skill nueva `std-stack-setup`: detecta lo que hay en el repo, pregunta lo que falta y completa `stack.md`.
- Instaladores: `--stack <perfil>` / `-Stack` y `--list-stacks` / `-ListStacks`, con validación del nombre.
- Normas, skills y reglas por herramienta leen comandos y rutas de `stack.md`; `globs` y `applyTo` con extensiones de varios lenguajes.

## 1.0.0 — 2026-10-15

- Primera versión: normas (`standards/`), 7 skills (`skills/`), reglas para Claude Code, AGENTS.md, Cursor, GitHub Copilot, Windsurf, Cline y Gemini CLI (`rules/`), e instaladores seguros para sh y PowerShell (`scripts/`).
