---
name: std-backend-module
description: Crea o modifica módulos, endpoints, services, repositories, DAOs e integraciones del backend con las capas router → service → repository → DAO, inyección de dependencias, errores de dominio, multi-tenant, acciones críticas con motivo y bajas lógicas, en el framework declarado en stack.md. Usar al tocar el backend o cuando el usuario pida una API, una regla de negocio o una integración.
---

# Módulos del backend

La norma es **`docs/standards/backend.md`** (y `architecture.md`, `security.md`, `naming.md`). Las tecnologías, carpetas, equivalencias y comandos están en **`docs/standards/stack.md`**. Esta skill no copia las normas: las aplica.

## Procedimiento

1. **Leer** la norma, `stack.md` (§2 carpetas, §3 equivalencias), la regla de negocio (`docs/business_rules.md`, `RN-xx`) y la spec del módulo (`docs/specs/backend/<mod>.md`). Si la regla no está escrita, escribirla primero (o pedirla).
2. **Ubicar** cada pieza en la carpeta del módulo, con los nombres de archivo de `stack.md §3`:
   - DTOs `XCreate` / `XUpdate` / `XRead`, con validaciones de forma;
   - DAO: una tabla o función, siempre filtrado por organización;
   - repository: el agregado, compone DAOs, resuelve catálogos por código;
   - service: las reglas, citando `RN-xx`; lanza errores de dominio con `code` propio;
   - router/controller: solo HTTP + inyección, envelope `{data, error}`, nombre de handler verbo + recurso.
     Si un archivo pasa de ~150 líneas, partir por responsabilidad.
3. **Reglas transversales:**
   - acción crítica → guardia `require_app_action("<recurso>.<accion>", change_reason)` antes que cualquier otra regla;
   - sin `DELETE`: baja lógica con motivo;
   - listados con el contrato común (`search`, `order_by`, `page`…);
   - lo atómico en varias tablas → transacción (ver `std-database-migration`);
   - integraciones como Port + Adapter elegido por configuración;
   - notificaciones o eventos → outbox en la misma transacción + worker; un broker o Redis solo si `architecture.md §7.1` lo justifica;
4. **Registrar** el router en la App Factory si es nuevo.
5. **Tests** con `std-backend-tests`: unitario con fakes por cada regla, integración del endpoint.
6. **Verificar** con los comandos de `stack.md §4`: lint, límite de 200 líneas, unitarios e integración del módulo.
7. **Cuidar el entorno en vivo:** si el código lee columnas o tablas de una migración que todavía no se aplicó, no publicarlo hasta aplicarla (partir el hito).
8. **Actualizar** la spec y las reglas en el mismo hito, e informar archivos, comandos y resultados.
