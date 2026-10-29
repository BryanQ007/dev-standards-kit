# Normas del proyecto (Cline)

Fuente de verdad: `docs/standards/README.md`. Primero `docs/standards/stack.md` (tecnologías de front y back, carpetas, equivalencias y comandos); después la norma del área:

- Frontend: `docs/standards/frontend.md`, `responsive.md`, `design-system.md`
- Backend: `docs/standards/backend.md`, `architecture.md`
- Base de datos: `docs/standards/database.md`
- Tests: `docs/standards/testing.md`
- Siempre: `naming.md`, `security.md`, `workflow.md`

Reglas que no se negocian:
- usar solo las tecnologías de `stack.md`;
- archivos ≤ 200 líneas;
- capas sin saltos;
- todo filtrado por organización;
- bajas lógicas;
- acciones críticas con confirmación, y motivo cuando el catálogo lo exige;
- integraciones sin éxitos simulados ("no configurado");
- sin secretos ni datos personales, ni destinos o códigos en los logs;
- nombres descriptivos en inglés;
- hitos de máx. 5 archivos de trabajo + 3 de seguimiento. La documentación de `docs/` va en el mismo commit y no cuenta;
- un hito por vez en el árbol;
- no commitear sin autorización (sin coautores si así se pidió).

- Procedimientos paso a paso (hito, componente, módulo, migración, flujo, revisión): `docs/standards/skills/<procedimiento>/SKILL.md`, para cualquier herramienta.
- Dependencias: **pnpm** (nunca npm/npx), lockfile versionado, ninguna versión con menos de N días publicada; rutina `std-dependency-audit` con auditoría y búsqueda de compromisos (`security.md §8`).
- Proyecto ya existente: auditarlo y adaptarlo por hitos con el procedimiento `std-project-adoption`.
- Commits a nombre de la persona: el asistente no commitea ni deja rastro de agente (ni coautor, ni "Generated with", ni cambia el usuario de git); al terminar cada hito deja stage y entrega el mensaje `Hx.y: descripción` con el código y orden del hito (`std-commit-handoff`).
