# Instrucciones para GitHub Copilot

La fuente de verdad son las normas de `docs/standards/` (empezar por `docs/standards/README.md`). **Las tecnologías de frontend y backend, las carpetas y los comandos están en `docs/standards/stack.md`**: usarlas y no agregar otras sin acordarlo. Este archivo solo resume y apunta.

- Ningún archivo de código supera 200 líneas; una responsabilidad por archivo.
- Backend: `router → service → repository → DAO`; reglas de negocio solo en services; todo filtrado por organización; errores de dominio con `code`; sin borrado de negocio (bajas lógicas con motivo); acciones críticas con permiso, confirmación y motivo cuando el catálogo lo exige.
- Frontend: vista sin lógica + lógica aparte (equivalencia en `stack.md §3`); `lógica → service → cliente HTTP`; colores solo del tema; mobile first (360 px a escritorio).
- Base de datos: normalizada (3FN, muchos a muchos con tabla intermedia), catálogos en tablas (sin enums), estados con patrón State, histórico por trigger, aislamiento por organización, migración aplicada inmutable y versión en tabla de control.
- Nombres compuestos y descriptivos en inglés (`fetchProjectsList`, `is_organization_scoped`); nada de `data`, `res`, `get`, `run`.
- Nunca secretos, valores del `.env` ni datos personales en código, tests o seeders.
- Tests: unitario con fakes de la misma firma + integración; solo datos sintéticos.
- Integraciones detrás de un puerto: sin proveedor, "no configurado"; nunca un éxito simulado (`docs/standards/architecture.md §7`).
- Un hito = máx. 5 archivos de trabajo + 3 de seguimiento. La documentación de `docs/` va en el mismo commit y no cuenta (`docs/standards/workflow.md`).
- Procedimientos paso a paso (hito, componente, módulo, migración, flujo, revisión): `docs/standards/skills/<procedimiento>/SKILL.md`, para cualquier herramienta.
- Dependencias: **pnpm** (nunca npm/npx), lockfile versionado, ninguna versión con menos de N días publicada; rutina `std-dependency-audit` con auditoría y búsqueda de compromisos (`security.md §8`).
- Proyecto ya existente: auditarlo y adaptarlo por hitos con el procedimiento `std-project-adoption`.
- Commits a nombre de la persona: el asistente no commitea ni deja rastro de agente (ni coautor, ni "Generated with", ni cambia el usuario de git); al terminar cada hito deja stage y entrega el mensaje `Hx.y: descripción` con el código y orden del hito (`std-commit-handoff`).
