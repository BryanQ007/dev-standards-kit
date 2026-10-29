# Normas de desarrollo — índice

Punto de entrada **único y neutral**. Son archivos Markdown planos: los lee cualquier persona o herramienta (Claude Code, Cursor, Copilot, Codex, Windsurf, Cline, Gemini…). Los archivos propios de cada herramienta (`CLAUDE.md`, `AGENTS.md`, `.cursor/rules/`, `.github/copilot-instructions.md`…) **no copian** estas normas: solo apuntan acá.

> **Procedimientos paso a paso:** en [skills/](skills/) (`<procedimiento>/SKILL.md`): empezar o cerrar un hito, crear un componente, un módulo o una migración, documentar un flujo, revisar cambios. Son Markdown plano y no dependen de ninguna herramienta: un asistente los sigue cuando la tarea coincide, y una persona también.

> Se instalan en el proyecto como `docs/standards/`. Las normas son **independientes de la tecnología**: cada proyecto declara su stack (frontend, backend, base, carpetas, comandos) en [stack.md](stack.md), y las normas y skills lo leen de ahí. Las rutas de ejemplo usan `<frontend>/` y `<backend>/`.

## Normas por área

| Área | Archivo | Leer cuando… |
|---|---|---|
| **Stack del proyecto** | [stack.md](stack.md) | **siempre primero**: tecnologías de front y back, carpetas, comandos y equivalencias de cada patrón |
| Arquitectura | [architecture.md](architecture.md) | se arma un proyecto nuevo o se agrega un módulo o una integración |
| Frontend | [frontend.md](frontend.md) | se crean o modifican componentes, páginas, hooks, tipos o services del frontend |
| Responsive | [responsive.md](responsive.md) | se toca cualquier pantalla, layout o componente visual |
| Sistema de diseño | [design-system.md](design-system.md) | se tocan colores, tipografía, dark mode, charts o el UI kit |
| Backend | [backend.md](backend.md) | se crean o modifican módulos, endpoints, services, repositories, DAOs o integraciones |
| Base de datos | [database.md](database.md) | se diseñan tablas, catálogos, históricos, RLS, migraciones o seeders |
| Tests | [testing.md](testing.md) | se crean o modifican tests, o se cierra un hito |
| Flujos | [flows.md](flows.md) | se documenta o cambia un comportamiento en `docs/flows/` (estados, pantallas, pasos función → HTTP → base, diagramas) |
| Nombres | [naming.md](naming.md) | siempre: aplica a todo el código |
| Seguridad | [security.md](security.md) | siempre: secretos, datos personales, permisos y acciones críticas |
| Proceso de trabajo | [workflow.md](workflow.md) | se planifica, se cierra un hito o se hace un commit |

## Reglas transversales (aplican siempre)

1. **Ningún archivo de código supera 200 líneas.** Al acercarse a 150, se modulariza.
2. **Una responsabilidad por archivo, clase o componente.**
3. **Las reglas de negocio viven en los services del backend**, nunca en la UI. Se documentan y se citan por código (`RN-xx`).
4. **Los colores y tokens visuales viven en un solo archivo de tema.**
5. **Multi-tenant:** todo acceso a datos se resuelve por la organización (o el tenant) de la sesión.
6. **Bajas lógicas:** nada de negocio se borra físicamente; se da de baja con motivo y queda en el historial.
7. **Sin datos inventados ni personales** en código, tests o seeders. Nunca credenciales en el repositorio.
8. **Nombres compuestos y descriptivos**: verbo + objeto en funciones, sustantivo compuesto en variables, `is_/has_` en booleanos ([naming.md](naming.md)).
9. **Responsive, mobile first:** de 360 px a escritorio, sin scroll horizontal de la página ([responsive.md](responsive.md)).
10. **Primero la especificación, después el código** ([workflow.md](workflow.md)).
11. **Idioma:** documentación, mensajes de commit y respuestas en el idioma del equipo; identificadores de código en inglés.
12. **Integraciones enchufables, sin éxitos falsos:**
    - toda capacidad externa (mensajería, firma, pagos, IA) va detrás de un puerto, con un adaptador de prueba solo para desarrollo;
    - sin proveedor real, responde **"no configurado"**;
    - nunca simula un envío, una firma ni un cobro ([architecture.md §7](architecture.md)).
13. **Cadena de suministro segura** ([security.md §8](security.md)):
    - **pnpm** en lugar de npm;
    - lockfile versionado;
    - **ninguna versión de paquete, runtime o imagen con menos de N días publicada** (`stack.md`, por defecto 7);
    - rutina de verificación con auditoría y búsqueda de compromisos (`std-dependency-audit`).

## Reglas de trabajo por hito (resumen)

- **Un hito = un commit = máx. 8 archivos:** hasta **5 de trabajo** + **3 de seguimiento** (plan, changelog, estado actual).
- **La documentación no cuenta para el límite y va siempre en el mismo commit:** reglas, modelo de datos, arquitectura, flujos, specs y normas. Los 5 de trabajo son código, tests, migraciones, SQL y configuración.
- Si un hito necesita más de 5 archivos de trabajo, se parte **antes** de empezar.
- Un solo hito por vez en el árbol de trabajo, con un identificador que no exista en el plan.
- Cada entrada del changelog termina con **"Comandos ejecutados"**, sin secretos (`<oculto>`), y lleva **"Cómo se usa"** cuando cambia algo para quien usa el sistema.

Detalle: [workflow.md](workflow.md).

## Antes de empezar cualquier tarea

0. Si `stack.md` tiene marcadores `<…>` sin completar, completarlo primero (skill `std-stack-setup`).
1. Leer el estado actual y el hito en el plan.
2. Revisar el flujo y las reglas de negocio afectadas.
3. Leer la norma del área que se va a tocar.
