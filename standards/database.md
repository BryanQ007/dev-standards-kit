# Normas de base de datos (relacional)

> **Aplica a:** el esquema, las migraciones y los seeders. El motor, la herramienta de migraciones y los comandos están en [stack.md](stack.md). Los ejemplos son de PostgreSQL; las secciones de RLS y triggers aplican si el motor los tiene (si no, ver la alternativa en cada punto).
> Relacionadas: [backend.md](backend.md) · [security.md](security.md)

## 1. Reglas duras

1. **Normalizado:** cada concepto en su tabla, unida por FK. Sin listas en texto, columnas repetidas ni derivados guardados sin motivo.
2. **Sin enums de la base ni del ORM, ni `check (x in (...))`, para valores de negocio:** todo valor categórico (estados, tipos, modos, planes, roles, monedas, medios) es una **tabla catálogo** con FK.
3. **Histórico obligatorio:** toda tabla con movimiento tiene su histórico, alimentado por **trigger**. Los históricos no se editan ni se borran.
4. **Multi-tenant:** toda tabla de negocio tiene `organization_id` FK y RLS habilitada (si el motor no tiene RLS, el filtro en el DAO es obligatorio y se prueba).
5. **Solo migraciones:** todo cambio de esquema es una migración de la herramienta del stack. Nunca se edita a mano en la base.
6. **Bajas lógicas:** el rol de usuario nunca tiene `delete` sobre tablas de negocio (ni grant ni política; sin RLS, el DAO base no expone borrado). La baja es `is_active = false` o un estado terminal, auditada con motivo. Solo el rol de sistema borra, y solo en tareas de sistema (limpieza de tests, supresión legal por anonimización).
7. **Un dato, un lugar:** lo derivable no se guarda (el nombre de un catálogo se lee por su código). Si por rendimiento se guarda un derivado, se documenta el motivo y quién lo mantiene.
8. **Migración aplicada = inmutable:** una migración o un seeder ya corridos en un entorno **no se editan**; el cambio va en el número siguiente.

## 2. Nombres

| Elemento | Convención | Ejemplo |
|---|---|---|
| Tabla | `snake_case`, plural | `projects`, `project_statuses` |
| PK de negocio | `id uuid default gen_random_uuid()` | |
| PK de catálogo | `id smallint` + `code text unique` | `project_statuses.code = 'active'` |
| FK | `<entidad_singular>_id` | `project_id`, `status_id` |
| Estado actual | `status_id` FK a `<entidad>_statuses` | `invoices.status_id` |
| Histórico de estado | `<entidad>_status_history` | `invoice_status_history` |
| Otro histórico | `<entidad>_<concepto>_history` | `asset_ownership_history` |
| Índice / unique | `ix_<tabla>_<cols>` / `uq_<tabla>_<cols>` | `uq_invoices_project_id_period` |
| Migración | `NNNN_descripcion` (numerada, según la herramienta) | `0004_invoices` |

## 3. Columnas estándar

- **Negocio:** `id`, `organization_id`, `created_at`, `updated_at`, `created_by`, `updated_by`, `is_active`.
- **Catálogo:** `id`, `code`, `name`, `description`, `sort_order`, `is_active` (+ `is_terminal` si es de estados).
- **Montos:** entero (`bigint`) en la unidad mínima de la moneda + `currency_id`. Nunca `float`.
- **Período mensual:** `text` con `check (period ~ '^\d{4}-(0[1-9]|1[0-2])$')`.
- `on delete restrict` por defecto; `cascade` solo para hijas puras.
- **Código de referencia legible** (`ABC-2026-0001`): columna `reference_code` llenada por trigger con contador por organización; no se repite ni se cambia.

## 4. Catálogos

- Globales (sin `organization_id`), lectura para usuarios autenticados, escritos solo por migración o seed.
- La aplicación compara por `code`, nunca por `id` numérico.
- Las condiciones guardadas por el usuario (reglas, filtros) referencian ids o códigos de catálogo, no nombres visibles.

## 5. Históricos y versiones

```sql
create table invoice_status_history (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id),
  invoice_id uuid not null references invoices(id),
  previous_status_id smallint references invoice_statuses(id),
  status_id smallint not null references invoice_statuses(id),
  changed_by uuid references profiles(id),
  changed_at timestamptz not null default now(),
  reason text
);
```

- Trigger `AFTER INSERT OR UPDATE OF status_id`. `changed_by` sale de la identidad de la sesión o de una variable fijada por la función RPC. Si el motor no permite triggers con esa información, el histórico lo escribe **un único punto** del DAO base, nunca cada service.
- El motivo llega por cabecera de la petición o por variable de sesión dentro de la RPC.
- **Valores versionados** (condiciones que cambian con el tiempo): `valid_from` / `valid_to` + índice único parcial `where valid_to is null` (una sola vigente).
- Altas, ediciones y bajas: tabla de auditoría (entidad, id, acción, antes → después en `jsonb`, usuario, fecha, motivo) por trigger.
- Documentos emitidos: copia congelada + huella (`sha256`); un trigger rechaza modificarlos una vez confirmados.

## 6. RLS

- `enable row level security` en todas las tablas de negocio e históricos.
- Políticas por organización (`organization_id = <función que devuelve la organización del usuario>`) y, si aplica, por sub-ámbito (sucursal, equipo).
- Históricos y auditoría: solo política de `select`; la escritura llega por trigger `security definer`.
- Vistas con `security_invoker` para que respeten la RLS.
- Funciones `security definer` con `search_path` fijo y validación explícita de la organización.

## 7. Migraciones y seeders

- Cada migración tiene subida y bajada. El SQL largo vive en un archivo aparte para respetar las 200 líneas.
- **Si la base se actualiza a mano** (p. ej. desde un editor SQL del proveedor), en el mismo hito se genera el `.sql` incremental de la migración (comando en [stack.md §4](stack.md)) y se entrega la lista **en orden** de archivos a ejecutar, con la versión que debe tener la base antes, y se verifica después. Si se aplica por pipeline, se documenta el comando.
- **Probar en una base descartable** (contenedor `postgres` efímero) sobre una base nueva **y** sobre la versión anterior con datos, antes de entregar.
- Un cambio que no toca la base se aclara como tal: "no hay SQL que ejecutar".
- **Compatibilidad del orden de despliegue:** si el código nuevo lee una columna que agrega una migración, ese código se publica **después** de correrla (o se parte el hito).
- Seeders: SQL separado del esquema, **idempotentes**, en un solo bloque transaccional; solo datos ficticios de demostración, nunca personales reales. Avisan con un resumen al final.

## 8. Checklist

- [ ] Sin enums ni `check (x in (...))` de negocio.
- [ ] Sin `delete` para el rol de usuario; baja lógica.
- [ ] Ningún derivado guardado sin motivo documentado.
- [ ] Cada tabla con estado o movimiento tiene histórico y trigger.
- [ ] RLS habilitada y probada (la organización A no ve la B).
- [ ] FKs con índice; uniques de negocio declarados.
- [ ] Documentación del modelo actualizada.
- [ ] `.sql` incremental generado, esquema regenerado y lista en orden entregada.
