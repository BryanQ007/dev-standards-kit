# AGENTS.md

Instrucciones para asistentes de código (Codex, Cursor, Jules, Zed, Aider, Gemini CLI y cualquier herramienta que lea `AGENTS.md`).

**La fuente de verdad son las normas de [docs/standards/](docs/standards/README.md).** Este archivo no las copia: las resume y apunta.

## Antes de tocar código

1. Leer **`docs/standards/stack.md`**: tecnologías de frontend y backend, carpetas, equivalencias de cada patrón y comandos de verificación. Si tiene marcadores `<…>` sin completar, completarlo primero con la persona.
2. Leer `docs/current_stage.md` y el hito en `docs/plan.md` (si existen).
3. Leer la norma del área:
   - frontend → `docs/standards/frontend.md`, `responsive.md`, `design-system.md`
   - backend → `docs/standards/backend.md`, `architecture.md`
   - base de datos → `docs/standards/database.md`
   - tests → `docs/standards/testing.md`
   - flujos (`docs/flows/`) → `docs/standards/flows.md`
   - siempre → `naming.md`, `security.md`, `workflow.md`

## Procedimientos paso a paso

En **`docs/standards/skills/<procedimiento>/SKILL.md`** hay procedimientos en Markdown plano, que sirven para cualquier herramienta. Cuando la tarea coincide, se lee el procedimiento y se sigue:

| Tarea | Procedimiento |
|---|---|
| Definir o cambiar el stack | `std-stack-setup` |
| Adoptar el estándar en un proyecto que ya existe, o revisar el cumplimiento | `std-project-adoption` |
| Empezar, partir o cerrar un hito | `std-milestone` |
| Terminar un hito: stage y mensaje de commit recomendado, a nombre de la persona | `std-commit-handoff` |
| Pantalla, formulario o componente | `std-frontend-component` · `std-responsive` |
| Endpoint, regla o integración | `std-backend-module` · `std-backend-tests` |
| Tabla, catálogo, migración o seeder | `std-database-migration` |
| Documentar o cambiar un flujo | `std-flow-design` |
| Revisar cambios contra las normas | `std-code-review` |
| Revisar dependencias, Docker y runtimes (rutina semanal, cada fase, antes de desplegar, al agregar o actualizar un paquete) | `std-dependency-audit` |
| Auditoría de seguridad (auth, endpoints públicos, secretos, archivos, integraciones, antes de publicar) | `security-audit`: skill externa de Cloudflare. La instala la persona (`docs/standards/security.md §7`) |

## Reglas que no se negocian

- Ningún archivo de código supera **200 líneas**; una responsabilidad por archivo.
- No se agregan tecnologías ni dependencias que no estén en `stack.md` sin acordarlo y actualizarlo.
- Backend: `router → service → repository → DAO`; reglas de negocio solo en services; todo filtrado por organización.
- Frontend: vista sin lógica + lógica aparte, `lógica → service → cliente HTTP`, colores solo del tema, mobile first.
- Base:
  - normalizada (3FN, muchos a muchos con tabla intermedia);
  - catálogos en tablas (sin enums) y estados con el patrón State (transiciones en tabla);
  - histórico por trigger;
  - aislamiento por organización;
  - **bajas lógicas**;
  - migración aplicada **inmutable** y versión registrada en una tabla de control.
- Acciones críticas con permiso y confirmación. El **motivo** es obligatorio en excepciones y reversiones, y opcional en los pasos normales, según el catálogo de acciones (`security.md §4`).
- Integraciones detrás de un puerto: sin proveedor real responden "no configurado" y **nunca** simulan un envío, una firma ni un cobro (`architecture.md §7`).
- Enlaces públicos y códigos de un solo uso: solo la huella en la base, el mismo mensaje para cualquier enlace que no sirve, y lo de un solo uso se gasta al final (`security.md §6`).
- **Nunca** secretos, valores del `.env` ni datos personales en código, tests, seeders, logs o respuestas (`<oculto>`).
- **Dependencias** (`security.md §8`):
  - **pnpm**, nunca `npm` ni `npx` (`pnpm exec` / `pnpm dlx`);
  - lockfile versionado;
  - ninguna versión de paquete, runtime o imagen con menos de N días publicada (`stack.md`);
  - antes de agregar o actualizar, revisar el paquete y buscar si la versión está comprometida.
- Nombres compuestos y descriptivos, en inglés; documentación en el idioma del equipo.
- Un hito = máx. 5 archivos de trabajo + 3 de seguimiento (plan, changelog con "Cómo se usa" y "Comandos ejecutados", estado actual).
- **La documentación de `docs/` va en el mismo commit y no cuenta para el límite**: reglas, modelo, arquitectura, flujos, specs y normas.
- Un solo hito por vez en el árbol de trabajo, con un identificador que no exista en el plan.
- **Los commits son de la persona, a su nombre:**
  - no commitear ni hacer push;
  - ningún rastro de agente en la historia: sin cambiar el usuario de git, sin `--author`, sin `Co-Authored-By` ni líneas "Generated with";
  - al terminar cada hito: stage y **mensaje recomendado** `Hx.y: descripción`, con el código y el orden del hito (`std-commit-handoff`).
- Confirmar antes de operaciones destructivas. Verificar sin tocar datos compartidos: organizaciones de prueba que se borran, o respuestas simuladas.

## Verificación

- Con los comandos de `docs/standards/stack.md §4` (lint, tipos, límite de líneas, tests) y revisando la pantalla en 390 / 768 / 1280 px.
- Respetar las advertencias de `docs/standards/stack.md §5`.
- Si algo falla, informar con la salida y no dar la tarea por hecha.
