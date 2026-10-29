---
applyTo: "**/alembic/**,**/migrations/**,**/prisma/**,**/sql/**,**/seeds/**,**/*.sql"
---

# Base de datos

Norma: `docs/standards/database.md`. Motor y herramienta de migraciones: `docs/standards/stack.md`.

- Catálogos en tablas (`id`, `code`, `name`), nunca enums ni `check (x in (...))`.
- Estado con `status_id` + histórico por trigger; aislamiento por organización; sin borrado para el rol de usuario.
- No editar migraciones ni seeders ya aplicados: el cambio va en el número siguiente.
- Seeders idempotentes y con datos ficticios.
- Una migración no depende de valores que carga un seeder: los inserta ella misma (idempotente) y se prueba también en una base nueva.
- Normalizar al máximo (3FN): muchos a muchos con tabla intermedia, sin listas ni datos copiados; estados con patrón State (`<entidad>_status_transitions` + trigger); cada migración registra su versión en la tabla de control (`database.md §4, §6, §9.1`).
