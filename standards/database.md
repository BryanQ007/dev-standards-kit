# Normas de base de datos (relacional)

> **Aplica a:** el esquema, las migraciones y los seeders. El motor, la herramienta de migraciones y los comandos están en [stack.md](stack.md). Los ejemplos son de PostgreSQL; las secciones de RLS y triggers aplican si el motor los tiene (si no, ver la alternativa en cada punto).
> Relacionadas: [backend.md](backend.md) · [security.md](security.md)

## 1. Reglas duras

1. **Normalizado al máximo (al menos 3FN):** cada concepto en su tabla, unida por FK. Sin listas en texto, columnas repetidas ni derivados guardados sin motivo. Las relaciones **muchos a muchos** van siempre por una **tabla intermedia** ([§4](#4-normalización-y-relaciones)).
2. **Sin enums de la base ni del ORM, ni `check (x in (...))`, para valores de negocio:** todo valor categórico (estados, tipos, modos, planes, roles, monedas, medios) es una **tabla catálogo** con FK.
3. **Histórico obligatorio:** toda tabla con movimiento tiene su histórico, alimentado por **trigger**. Los históricos no se editan ni se borran.
4. **Multi-tenant:** toda tabla de negocio tiene `organization_id` FK y RLS habilitada (si el motor no tiene RLS, el filtro en el DAO es obligatorio y se prueba).
5. **Solo migraciones:** todo cambio de esquema es una migración de la herramienta del stack. Nunca se edita a mano en la base.
6. **Bajas lógicas:** el rol de usuario nunca tiene `delete` sobre tablas de negocio (ni grant ni política; sin RLS, el DAO base no expone borrado). La baja es `is_active = false` o un estado terminal, auditada con motivo. Solo el rol de sistema borra, y solo en tareas de sistema (limpieza de tests, supresión legal por anonimización).
7. **Un dato, un lugar:** lo derivable no se guarda (el nombre de un catálogo se lee por su código). Si por rendimiento se guarda un derivado, se documenta el motivo y quién lo mantiene.
8. **Migración aplicada = inmutable:** una migración o un seeder ya corridos en un entorno **no se editan**; el cambio va en el número siguiente.
9. **Versión de la base en una tabla:** cada base registra **qué migraciones se corrieron**, en una tabla de control. Así se sabe siempre cuál fue la última, con cualquier motor y cualquier herramienta, y aunque el SQL se aplique a mano ([§9.1](#91-control-de-versión-de-la-base)).
10. **Estados con el patrón State:** catálogo de estados, **transiciones permitidas en una tabla**, y la base rechaza un salto no permitido ([§6](#6-estados-patrón-state-en-la-base)).

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
| Tabla intermedia (muchos a muchos) | `<entidad_a>_<entidad_b>` en plural, o el nombre del concepto si lo tiene | `project_members`, `property_ownership_shares` |
| Transiciones de estado | `<entidad>_status_transitions` | `invoice_status_transitions` |
| Control de versión | `schema_migrations` (o la de la herramienta) | `alembic_version`, `_prisma_migrations` |
| Índice / unique | `ix_<tabla>_<cols>` / `uq_<tabla>_<cols>` | `uq_invoices_project_id_period` |
| Migración | `NNNN_descripcion` (numerada, según la herramienta) | `0004_invoices` |

## 3. Columnas estándar

- **Negocio:** `id`, `organization_id`, `created_at`, `updated_at`, `created_by`, `updated_by`, `is_active`.
- **Catálogo:** `id`, `code`, `name`, `description`, `sort_order`, `is_active` (+ `is_terminal` si es de estados).
- **Montos:** entero (`bigint`) en la unidad mínima de la moneda + `currency_id`. Nunca `float`.
- **Período mensual:** `text` con `check (period ~ '^\d{4}-(0[1-9]|1[0-2])$')`.
- `on delete restrict` por defecto; `cascade` solo para hijas puras.
- **Código de referencia legible** (`ABC-2026-0001`): columna `reference_code` llenada por trigger con contador por organización; no se repite ni se cambia.

## 4. Normalización y relaciones

**Qué cumple el modelo (al menos tercera forma normal):**
- **1FN:**
  - cada columna guarda **un** valor;
  - nada de listas separadas por comas, ni columnas `telefono1`, `telefono2`, `telefono3`;
  - nada de arrays o JSON con ids de otras tablas.
- **2FN:** cada columna depende de **toda** la clave. En una tabla intermedia, lo que es de una sola de las partes va en la tabla de esa parte.
- **3FN:** cada columna depende **solo** de la clave, no de otra columna. Si "nombre del estado" depende de `status_id`, vive en el catálogo y no se copia.

**Cada tipo de relación:**

| Relación | Cómo se modela | Ejemplo |
|---|---|---|
| Uno a muchos | FK en la tabla del lado "muchos" | `invoices.project_id` |
| Uno a uno | FK con `unique` en la tabla dependiente (o la misma PK) | `lease_endings.lease_id unique` |
| **Muchos a muchos** | **Tabla intermedia** con las dos FK, `unique (a_id, b_id)` (o parcial `where is_active`), sus propias columnas de la relación (rol, porcentaje, desde/hasta) y su propio `id` si la relación tiene historia | `project_members (project_id, profile_id, role_id, joined_on)` |
| Jerarquía (árbol) | `parent_id` FK a la misma tabla, con control de ciclos | `categories.parent_id` |
| Relación con datos que cambian en el tiempo | tabla intermedia con `valid_from` / `valid_to` y una sola vigente por par | `property_ownership_shares` |

**Prohibido:**
- **FK polimórficas sin control** (`entity_type` + `entity_id` sin integridad):
  - se usan solo si la tabla es transversal por diseño (auditoría, archivos, comentarios), y con un trigger o función que valide que el registro existe y es de la organización;
  - en cualquier otro caso, una FK por tipo, con un `check` de que solo una tiene valor.
- **JSON para datos que se consultan, filtran o relacionan:** el JSON queda para lo que es un documento en sí (una copia congelada, una respuesta de un proveedor, un diseño).
- **Copiar columnas de otra tabla "por comodidad":** se lee por join o por vista.

**Desnormalizar** solo con motivo medido (rendimiento), documentado en el modelo, y con quién lo mantiene al día (trigger o vista materializada).

## 5. Catálogos

- Globales (sin `organization_id`), lectura para usuarios autenticados, escritos solo por migración o seed.
- La aplicación compara por `code`, nunca por `id` numérico.
- Las condiciones guardadas por el usuario (reglas, filtros) referencian ids o códigos de catálogo, no nombres visibles.

## 6. Estados (patrón State en la base)

Toda entidad con ciclo de vida (borrador → vigente → terminada) usa el patrón State **en la base**, además del service:

```sql
-- 1. Los estados: catálogo, con los terminales marcados
create table invoice_statuses (id smallint primary key, code text unique not null, name text not null,
                               sort_order smallint not null, is_terminal boolean not null default false,
                               is_active boolean not null default true);
-- 2. Las transiciones permitidas: una fila por salto válido (y qué acción lo hace)
create table invoice_status_transitions (
  from_status_id smallint not null references invoice_statuses(id),
  to_status_id   smallint not null references invoice_statuses(id),
  action_code    text,                         -- acción del catálogo de permisos que la habilita
  primary key (from_status_id, to_status_id)
);
-- 3. Un trigger BEFORE UPDATE OF status_id rechaza el salto si no está en la tabla (o si el actual es terminal)
-- 4. El histórico <entidad>_status_history lo escribe otro trigger (§7)
```

- **El service** valida la transición y da un error claro (`<entidad>_invalid_transition`). La base lo repite, así nadie lo saltea.
- **Los estados terminales** no vuelven atrás. Un error se corrige con un estado o un registro nuevo (anular, enmendar), nunca editando el pasado.
- **Lo que se calcula** (p. ej. "por vencer") **no es un estado guardado**: sale de las fechas.
- **Un cambio de estado que mueve varias tablas** (cerrar algo y liberar otra cosa) es **una función transaccional**: registro, estado e histórico juntos.
- **Agregar un estado** es una migración: el catálogo y sus transiciones. Los registros viejos que quedan sin sentido se pasan al estado nuevo con su historial, y el estado viejo queda inactivo, sin borrarse.

## 7. Históricos y versiones

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

## 8. RLS

- `enable row level security` en todas las tablas de negocio e históricos.
- Políticas por organización (`organization_id = <función que devuelve la organización del usuario>`) y, si aplica, por sub-ámbito (sucursal, equipo).
- Históricos y auditoría: solo política de `select`; la escritura llega por trigger `security definer`.
- Vistas con `security_invoker` para que respeten la RLS.
- Funciones `security definer` con `search_path` fijo y validación explícita de la organización.

## 9. Migraciones y seeders

- Cada migración tiene subida y bajada. El SQL largo vive en un archivo aparte para respetar las 200 líneas.
- **Si la base se actualiza a mano** (p. ej. desde un editor SQL del proveedor), en el mismo hito se genera el `.sql` incremental de la migración (comando en [stack.md §4](stack.md)) y se entrega la lista **en orden** de archivos a ejecutar, con la versión que debe tener la base antes, y se verifica después. Si se aplica por pipeline, se documenta el comando.
- **Probar en una base descartable** (contenedor `postgres` efímero) sobre una base nueva **y** sobre la versión anterior con datos, antes de entregar.
- **Una migración no depende de los seeders:**
  - en una base nueva, el esquema corre **antes** que los seeders de catálogos, así que la migración no puede dar por hecho que un valor de catálogo ya existe;
  - los valores que la migración necesita los inserta ella misma, idempotente (`on conflict … do update`);
  - las búsquedas por código que puedan no encontrar nada se hacen con subconsultas que devuelvan vacío, no con funciones que fallen si el código no existe;
  - la prueba en la base nueva lo detecta.
- **La prueba en la base descartable** cubre, además de que la migración corra:
  - los rechazos de las reglas nuevas (con su código de error);
  - el camino feliz con sus históricos;
  - los permisos: que el rol de usuario **no** pueda escribir lo que solo escribe una función;
  - que no quede ninguna tabla sin seguridad de filas.
- Un cambio que no toca la base se aclara como tal: "no hay SQL que ejecutar".
- **Compatibilidad del orden de despliegue:** si el código nuevo lee una columna que agrega una migración, ese código se publica **después** de correrla (o se parte el hito).
- Seeders: SQL separado del esquema, **idempotentes**, en un solo bloque transaccional; solo datos ficticios de demostración, nunca personales reales. Avisan con un resumen al final.

### 9.1 Control de versión de la base

Toda base tiene una **tabla de control de versión**: se mira y se sabe cuál fue la última migración corrida, en cualquier entorno.

- **Si la herramienta ya trae una**, se usa esa, sin crear otra:

  | Herramienta | Tabla |
  |---|---|
  | Alembic | `alembic_version` |
  | Prisma | `_prisma_migrations` |
  | Django | `django_migrations` |
  | Flyway | `flyway_schema_history` |
  | Liquibase | `databasechangelog` |
  | Rails | `schema_migrations` |
  | Knex | `knex_migrations` |
  | TypeORM | `migrations` |

- **Si no hay herramienta, o el SQL se aplica a mano**, se crea la tabla en la primera migración:

  ```sql
  create table schema_migrations (
    version     text primary key,              -- '0044'
    name        text not null,                 -- 'lease_endings'
    applied_at  timestamptz not null default now(),
    applied_by  text not null default current_user,
    checksum    text                           -- sha256 del archivo aplicado
  );
  ```

- **Cada `.sql` incremental** (los que se corren a mano en un editor SQL):
  - **empieza comprobando la versión anterior**: si la base no está en la versión que el archivo requiere, aborta;
  - **termina registrando su versión** en la tabla, en la misma transacción.

  Así no se corre dos veces ni fuera de orden. El generador de SQL incremental lo agrega solo.
- **Para consultar la versión:**
  - `select version_num from alembic_version;` o la consulta equivalente;
  - `select version, name, applied_at from schema_migrations order by applied_at desc limit 1;` si la tabla es propia.

  La consulta va en `stack.md §4` y en cada entrega de SQL ("la base tiene que estar en NNNN").
- **El estado actual del proyecto** (p. ej. `docs/current_stage.md`) dice en qué versión está cada entorno y cuándo se comprobó.
- **Sin acceso de escritura para el rol de usuario:** la tabla de control se lee y se escribe solo con el rol de sistema o por las migraciones.

## 10. Checklist

- [ ] Sin enums ni `check (x in (...))` de negocio.
- [ ] En 3FN: sin listas en columnas, sin columnas repetidas, sin datos copiados de otra tabla.
- [ ] Cada relación muchos a muchos tiene su tabla intermedia con `unique` del par.
- [ ] Sin FK polimórficas sin validación; sin JSON para datos que se consultan o relacionan.
- [ ] Estados con catálogo, tabla de transiciones y trigger que rechaza saltos no permitidos.
- [ ] La migración registra su versión en la tabla de control y el `.sql` incremental comprueba la anterior.
- [ ] Sin `delete` para el rol de usuario; baja lógica.
- [ ] Ningún derivado guardado sin motivo documentado.
- [ ] Cada tabla con estado o movimiento tiene histórico y trigger.
- [ ] RLS habilitada y probada (la organización A no ve la B).
- [ ] FKs con índice; uniques de negocio declarados.
- [ ] Documentación del modelo actualizada.
- [ ] `.sql` incremental generado, esquema regenerado y lista en orden entregada.
- [ ] La migración no depende de valores que carga un seeder (probada en una base nueva).
- [ ] Las operaciones que tocan varias tablas a la vez (p. ej. cerrar algo y cambiar el estado de otra cosa) son **una función transaccional**, con errores de código propio que el backend traduce.
