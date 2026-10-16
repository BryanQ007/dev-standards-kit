# Instrucciones para GitHub Copilot

La fuente de verdad son las normas de `docs/standards/` (empezar por `docs/standards/README.md`). **Las tecnologías de frontend y backend, las carpetas y los comandos están en `docs/standards/stack.md`**: usarlas y no agregar otras sin acordarlo. Este archivo solo resume y apunta.

- Ningún archivo de código supera 200 líneas; una responsabilidad por archivo.
- Backend: `router → service → repository → DAO`; reglas de negocio solo en services; todo filtrado por organización; errores de dominio con `code`; sin borrado de negocio (bajas lógicas con motivo); acciones críticas con permiso y motivo.
- Frontend: vista sin lógica + lógica aparte (equivalencia en `stack.md §3`); `lógica → service → cliente HTTP`; colores solo del tema; mobile first (360 px a escritorio).
- Base de datos: catálogos en tablas (sin enums), histórico por trigger, aislamiento por organización, migración aplicada inmutable.
- Nombres compuestos y descriptivos en inglés (`fetchProjectsList`, `is_organization_scoped`); nada de `data`, `res`, `get`, `run`.
- Nunca secretos, valores del `.env` ni datos personales en código, tests o seeders.
- Tests: unitario con fakes de la misma firma + integración; solo datos sintéticos.
- Un hito = máx. 5 archivos de trabajo + 3 de seguimiento (`docs/standards/workflow.md`).
