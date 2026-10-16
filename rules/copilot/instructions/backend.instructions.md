---
applyTo: "**/*.py,**/*.java,**/*.kt,**/*.php,**/*.go,**/*.cs,**/*.rb"
---

# Backend

Normas: `docs/standards/backend.md`, `testing.md`. Framework, equivalencias y comandos: `docs/standards/stack.md`. Ajustá `applyTo` al lenguaje del backend (si es TypeScript, limitá por carpeta: `<backend>/**/*.ts`).

- `router → service → repository → DAO`; el router no tiene lógica; el DAO filtra siempre por organización.
- Reglas `RN-xx` en el service, con errores de dominio y `code` propio.
- Acción crítica → `require_app_action("<recurso>.<accion>", change_reason)` primero.
- Sin borrado de negocio; baja con `is_active = false` y motivo.
- Tests `<qué>_<condición>`; fakes con la misma firma que el repository; datos sintéticos.
