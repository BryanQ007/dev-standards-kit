---
trigger: always_on
---

# Normas transversales

Fuente de verdad: `docs/standards/README.md`. Este archivo solo resume y apunta.

- **Stack:** tecnologías de front y back, carpetas, equivalencias de patrones y comandos en `docs/standards/stack.md`. Leerlo antes de tocar código; no agregar tecnologías sin acordarlo.
- Ningún archivo de código supera 200 líneas; una responsabilidad por archivo.
- Backend: `router → service → repository → DAO`; reglas de negocio solo en services; todo filtrado por organización (`backend.md`).
- Frontend: vista sin lógica, `lógica → service → cliente HTTP`, colores del tema, mobile first (`frontend.md`, `responsive.md`, `design-system.md`).
- Base: normalizada (3FN, muchos a muchos con tabla intermedia), catálogos en tablas, estados con patrón State, histórico por trigger, aislamiento por organización, bajas lógicas, migración aplicada inmutable y versión en tabla de control (`database.md`).
- Acciones críticas con permiso y confirmación; motivo cuando el catálogo lo exige. Nunca secretos ni datos personales (`security.md`).
- Integraciones detrás de un puerto, sin éxitos simulados: "no configurado" (`architecture.md §7`).
- Nombres descriptivos en inglés (`naming.md`).
- Un hito = máx. 5 archivos de trabajo + 3 de seguimiento. La documentación de `docs/` va en el mismo commit y no cuenta; un hito por vez en el árbol (`workflow.md`).
- Tests según `testing.md`, con los comandos de `stack.md §4`.
- Procedimientos paso a paso (hito, componente, módulo, migración, flujo, revisión): `docs/standards/skills/<procedimiento>/SKILL.md`, para cualquier herramienta.
- Dependencias: **pnpm** (nunca npm/npx), lockfile versionado, ninguna versión con menos de N días publicada; rutina `std-dependency-audit` con auditoría y búsqueda de compromisos (`security.md §8`).
- Proyecto ya existente: auditarlo y adaptarlo por hitos con el procedimiento `std-project-adoption`.
- Commits a nombre de la persona: el asistente no commitea ni deja rastro de agente (ni coautor, ni "Generated with", ni cambia el usuario de git); al terminar cada hito deja stage y entrega el mensaje `Hx.y: descripción` con el código y orden del hito (`std-commit-handoff`).
