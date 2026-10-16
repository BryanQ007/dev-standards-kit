---
trigger: always_on
---

# Normas transversales

Fuente de verdad: `docs/standards/README.md`. Este archivo solo resume y apunta.

- **Stack:** tecnologías de front y back, carpetas, equivalencias de patrones y comandos en `docs/standards/stack.md`. Leerlo antes de tocar código; no agregar tecnologías sin acordarlo.
- Ningún archivo de código supera 200 líneas; una responsabilidad por archivo.
- Backend: `router → service → repository → DAO`; reglas de negocio solo en services; todo filtrado por organización (`backend.md`).
- Frontend: vista sin lógica, `lógica → service → cliente HTTP`, colores del tema, mobile first (`frontend.md`, `responsive.md`, `design-system.md`).
- Base: catálogos en tablas, histórico por trigger, aislamiento por organización, bajas lógicas, migración aplicada inmutable (`database.md`).
- Acciones críticas con permiso y motivo. Nunca secretos ni datos personales (`security.md`).
- Nombres descriptivos en inglés (`naming.md`).
- Un hito = máx. 5 archivos de trabajo + 3 de seguimiento (`workflow.md`).
- Tests según `testing.md`, con los comandos de `stack.md §4`.
