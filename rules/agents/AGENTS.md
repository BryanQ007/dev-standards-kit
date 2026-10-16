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

## Reglas que no se negocian

- Ningún archivo de código supera **200 líneas**; una responsabilidad por archivo.
- No se agregan tecnologías ni dependencias que no estén en `stack.md` sin acordarlo y actualizarlo.
- Backend: `router → service → repository → DAO`; reglas de negocio solo en services; todo filtrado por organización.
- Frontend: vista sin lógica + lógica aparte, `lógica → service → cliente HTTP`, colores solo del tema, mobile first.
- Base: catálogos en tablas (sin enums), histórico por trigger, aislamiento por organización, **bajas lógicas**, migración aplicada **inmutable**.
- Acciones críticas con permiso y **motivo** obligatorio.
- **Nunca** secretos, valores del `.env` ni datos personales en código, tests, seeders, logs o respuestas (`<oculto>`).
- Nombres compuestos y descriptivos, en inglés; documentación en el idioma del equipo.
- Un hito = máx. 5 archivos de trabajo + 3 de seguimiento (plan, changelog con "Comandos ejecutados", estado actual).
- No commitear ni publicar sin autorización; respetar cómo la persona firma sus commits.
- Confirmar antes de operaciones destructivas.

## Verificación

- Con los comandos de `docs/standards/stack.md §4` (lint, tipos, límite de líneas, tests) y revisando la pantalla en 390 / 768 / 1280 px.
- Respetar las advertencias de `docs/standards/stack.md §5`.
- Si algo falla, informar con la salida y no dar la tarea por hecha.
