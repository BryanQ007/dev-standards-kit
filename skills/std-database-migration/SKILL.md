---
name: std-database-migration
description: Diseña tablas, catálogos, históricos, triggers, RLS, funciones, migraciones y seeders según la norma (sin enums, histórico por trigger, multi-tenant, bajas lógicas, migración aplicada inmutable, SQL incremental entregado en orden), con la herramienta de migraciones declarada en stack.md. Usar al cambiar el esquema, crear un seeder o cuando el usuario pida una tabla, un estado o un catálogo.
---

# Base de datos: migraciones y seeders

La norma es **`docs/standards/database.md`** (y `security.md`). El motor, la herramienta de migraciones y sus comandos están en **`docs/standards/stack.md`**. Esta skill no copia la norma: la aplica.

## Procedimiento

1. **Leer** la norma, `stack.md` (§1 motor y migraciones, §4 comandos), el modelo vigente (`docs/database.md`) y la última migración. Confirmar qué versión tiene cada entorno.
2. **Diseñar** antes de escribir:
   - valores categóricos → tabla catálogo (`id`, `code`, `name`, `sort_order`, `is_active`);
   - tabla de negocio con columnas estándar, `organization_id`, `is_active`;
   - estado → `status_id` + `<entidad>_status_history` por trigger (o por el punto único del DAO base si el motor no lo permite);
   - valores que cambian en el tiempo → versiones con `valid_from` / `valid_to` y una sola vigente;
   - aislamiento por organización (RLS si el motor lo tiene); sin borrado para el rol de usuario;
   - nada derivable guardado sin motivo.
3. **Nunca editar** una migración o un seeder ya aplicados: el cambio va en el número siguiente.
4. **Escribir** la migración con la herramienta del stack, con subida y bajada; el SQL largo en un archivo aparte para respetar las 200 líneas.
5. **Probar** en una base descartable (contenedor efímero del mismo motor): base nueva completa **y** versión anterior con datos de demo + la migración nueva. Cubrir altas, rechazos esperados, aislamiento entre organizaciones e históricos.
6. **Entregar** según cómo se aplica en el proyecto:
   - a mano: el `.sql` incremental (comando de `stack.md §4`) y la lista **en orden** con la consulta de versión previa, los archivos y una consulta de verificación;
   - por pipeline: el comando y lo que verifica.
   Aclarar si es seguro aplicarla antes de publicar el código.
7. **Seeders:** idempotentes, en un solo bloque transaccional, datos ficticios, con aviso y resumen al final. Probarlos dos veces (la segunda no cambia nada).
8. **Documentar** el modelo (`docs/database.md`) en el mismo hito. Si no hubo cambio de esquema, decir "no hay SQL que ejecutar".
