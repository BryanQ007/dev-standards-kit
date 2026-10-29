# CLAUDE.md

Este archivo solo conecta Claude Code con las normas del proyecto. **La fuente de verdad es [docs/standards/](docs/standards/README.md)**; no se copian reglas acá.

- Idioma: respuestas, documentación y commits en el idioma del equipo; identificadores de código en inglés.
- Commits: a nombre de la persona. No commitear ni dejar rastro de agente (sin coautores, sin "Generated with", sin cambiar el usuario de git). Al terminar cada hito, dejarlo en stage y entregar el mensaje `Hx.y: descripción` con el código y el orden del hito (skill `std-commit-handoff`).
- Un hito por vez en el árbol de trabajo. La documentación de `docs/` va en el mismo commit y no cuenta para el límite de archivos (`docs/standards/workflow.md`).

## Normas y stack (se cargan automáticamente)

@docs/standards/README.md

@docs/standards/stack.md

Si `stack.md` tiene marcadores `<…>`, completarlo primero con la skill `std-stack-setup`.

Según el área que se toque, leer además (o usar la skill correspondiente):
- Frontend: [docs/standards/frontend.md](docs/standards/frontend.md) · skill `std-frontend-component`
- Responsive: [docs/standards/responsive.md](docs/standards/responsive.md) · skill `std-responsive`
- Sistema de diseño: [docs/standards/design-system.md](docs/standards/design-system.md)
- Backend: [docs/standards/backend.md](docs/standards/backend.md) · skill `std-backend-module`
- Base de datos: [docs/standards/database.md](docs/standards/database.md) · skill `std-database-migration`
- Tests: [docs/standards/testing.md](docs/standards/testing.md) · skill `std-backend-tests`
- Flujos: [docs/standards/flows.md](docs/standards/flows.md) · skill `std-flow-design`
- Hitos y commits: [docs/standards/workflow.md](docs/standards/workflow.md) · skill `std-milestone`
- Revisión: skill `std-code-review`

## Estado actual

@docs/current_stage.md
