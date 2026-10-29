---
name: std-database-migration
description: Diseña tablas, catálogos, históricos, triggers, RLS, funciones, migraciones y seeders según la norma (sin enums, histórico por trigger, multi-tenant, bajas lógicas, migración aplicada inmutable, SQL incremental entregado en orden), con la herramienta de migraciones declarada en stack.md. Usar al cambiar el esquema, crear un seeder o cuando el usuario pida una tabla, un estado o un catálogo.
---

# Base de datos: migraciones y seeders

La norma es **`docs/standards/database.md`** (y `security.md`). El motor, la herramienta de migraciones y sus comandos están en **`docs/standards/stack.md`**. Esta skill no copia la norma: la aplica.

## Procedimiento

1. **Leer** la norma, `stack.md` (§1 motor y migraciones, §4 comandos), el modelo vigente (`docs/database.md`) y la última migración. Confirmar qué versión tiene cada entorno.
2. **Diseñar** antes de escribir:
   - **normalizar al máximo (3FN)**: cada concepto en su tabla; nada de listas en columnas, columnas repetidas ni datos copiados (`database.md §4`);
   - **muchos a muchos → tabla intermedia** con las dos FK, `unique` del par y las columnas propias de la relación (rol, porcentaje, desde/hasta);
   - nada de FK polimórficas sin validación ni JSON para datos que se consultan;
   - valores categóricos → tabla catálogo (`id`, `code`, `name`, `sort_order`, `is_active`);
   - entidad con ciclo de vida → **patrón State** (`database.md §6`): catálogo de estados con terminales, `<entidad>_status_transitions` y trigger que rechaza saltos no permitidos;
   - tabla de negocio con columnas estándar, `organization_id`, `is_active`;
   - estado → `status_id` + `<entidad>_status_history` por trigger (o por el punto único del DAO base si el motor no lo permite);
   - valores que cambian en el tiempo → versiones con `valid_from` / `valid_to` y una sola vigente;
   - aislamiento por organización (RLS si el motor lo tiene); sin borrado para el rol de usuario;
   - nada derivable guardado sin motivo.
3. **Nunca editar** una migración o un seeder ya aplicados: el cambio va en el número siguiente.
4. **Escribir** la migración con la herramienta del stack, con subida y bajada; el SQL largo en un archivo aparte para respetar las 200 líneas.
   - **Versión en la tabla de control** (`database.md §9.1`): la de la herramienta, o `schema_migrations` si no hay.
   - El `.sql` incremental comprueba al principio que la base esté en la versión anterior y registra la nueva al final, en la misma transacción.
5. **No depender de los seeders:** si la migración necesita un valor de catálogo, lo inserta ella misma (idempotente). Las búsquedas por código que podrían no encontrar nada van con subconsultas, no con funciones que fallan.
6. **Probar** en una base descartable (contenedor efímero del mismo motor). Esperar a que el motor acepte conexiones antes de correr el script.
   - **Las dos bases:**
     - base nueva completa (esquema → catálogos → demo);
     - versión anterior con datos de demo + la migración nueva.
   - **Qué cubrir:** altas, rechazos esperados (con su código de error), aislamiento entre organizaciones, históricos, que el rol de usuario **no** pueda escribir lo que solo escribe una función, y que no quede ninguna tabla sin seguridad de filas.
   - **Cómo:** los controles van dentro de una transacción con `rollback`, para repetirlos.
7. **Entregar** según cómo se aplica en el proyecto:
   - a mano: el `.sql` incremental (comando de `stack.md §4`) y la lista **en orden** con la consulta de versión previa, los archivos y una consulta de verificación;
   - por pipeline: el comando y lo que verifica.
   Aclarar si es seguro aplicarla antes de publicar el código. Después de que la persona la aplica, comprobar la versión del entorno (solo lectura) antes del hito que la usa.
8. **Seeders:** idempotentes, en un solo bloque transaccional, datos ficticios, con aviso y resumen al final. Probarlos dos veces (la segunda no cambia nada).
9. **Documentar** el modelo (`docs/database.md`) en el mismo commit (la documentación no cuenta para el límite de archivos). Si no hubo cambio de esquema, decir "no hay SQL que ejecutar".
