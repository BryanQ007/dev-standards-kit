---
applyTo: "**/alembic/**,**/migrations/**,**/prisma/**,**/sql/**,**/seeds/**,**/*.sql"
---

# Base de datos

Norma: `docs/standards/database.md`. Motor y herramienta de migraciones: `docs/standards/stack.md`.

- Catálogos en tablas (`id`, `code`, `name`), nunca enums ni `check (x in (...))`.
- Estado con `status_id` + histórico por trigger; aislamiento por organización; sin borrado para el rol de usuario.
- No editar migraciones ni seeders ya aplicados: el cambio va en el número siguiente.
- Seeders idempotentes y con datos ficticios.
