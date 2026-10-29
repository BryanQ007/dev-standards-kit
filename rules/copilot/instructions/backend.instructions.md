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
- Integraciones: Port + Adapter; por defecto "ninguno", adaptador de prueba solo fuera de producción, "no configurado" sin proveedor, nunca un éxito simulado; logs sin destinos ni códigos (`architecture.md §7`).
- Endpoints públicos por token: solo la huella guardada, el mismo 410 para todo enlace que no sirve, lo de un solo uso se gasta al final, cliente de sistema filtrado por la organización del token (`security.md §6`).
- Dockerfiles: imagen base con versión exacta (o digest) y antigüedad mínima; `pnpm install --frozen-lockfile`, sin `npm` (`security.md §8.2`).
