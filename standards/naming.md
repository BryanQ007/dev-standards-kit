# Nombres (obligatorio, frontend y backend)

El nombre tiene que decir **qué hace** o **qué contiene**, sin leer el cuerpo. Siempre nombres compuestos, **en inglés** en el código.

## 1. Tabla general

Los ejemplos usan camelCase (TypeScript) y snake_case (Python); en otros lenguajes se respeta su convención de mayúsculas, pero no la regla: verbo + objeto, sustantivo compuesto, prefijo de booleano.

| Elemento | Frontend (ej. TS) | Backend (ej. Python) | Prohibido |
|---|---|---|---|
| Función / método | verbo + objeto: `fetchProjectsList()`, `formatCurrencyAmount()` | `list_active_catalog_items()`, `verify_access_token()` | `load()`, `get()`, `run()`, `ok()`, `_one()` |
| Handler de evento | `handle` + acción + objeto: `handleSubmitProjectForm` | endpoint: `list_catalog_items` | `onClick2`, `handler`, `index` |
| Variable / estado | sustantivo compuesto: `selectedProjectId`, `projectTableRows` | `organization_account`, `matching_project_rows` | `data`, `res`, `r`, `x`, `acc`, `rows` |
| Booleano | `is` / `has` / `can` / `should`: `isLoadingProjects` | `is_organization_scoped`, `has_open_tasks` | `loading`, `flag`, `scoped` |
| Hook | `use` + lo que gestiona: `useProjectsTable` | — | `useData`, `useStuff` |
| Componente / clase | sustantivo + rol: `ProjectFormModal` | `CatalogService`, `ProjectRepository`, `ProjectDAO` | `Modal2`, `Manager`, `Helper`, `Utils` |
| Servicio | recurso + `Service`; métodos verbo + objeto: `projectsService.createProject()` | — | `api.post()` directo |
| Constante | MAYÚSCULAS descriptivas: `PROJECT_STATUS_OPTIONS` | `SUPPORTED_JWT_ALGORITHMS` | `OPTS`, `ALGS` |
| Ruta HTTP | — | recurso en plural, kebab-case: `/catalogs/{catalog_name}` | `/getCatalog`, `/cat/{n}` |
| Test | — | `test_<qué>_<condición>` | `test_1`, `test_ok` |
| Código de error | — | `snake_case` estable: `reason_required` | mensajes como código |
| Código de acción (permisos) | — | `<recurso>.<acción>`: `project.deactivate` | `action1` |

## 2. Reglas

- Sin abreviaturas, salvo las estándar: `id`, `url`, `api`, `jwt`, `dto`, `dao`, `db`, `sql`, `pdf`.
- Parámetros con nombre propio cuando hay ambigüedad: `catalog_name: str`, no `name: str`.
- Callbacks y lambdas también: `(loadError) =>`, nunca `(e) =>` salvo en eventos triviales del DOM.
- Base de datos: ver [database.md](database.md) §2.
- Archivos: componentes en `PascalCase`, hooks `useCamelCase.ts`, services `<recurso>.service.ts`, tipos `<recurso>.types.ts`; Python en `snake_case.py` con nombre de responsabilidad (`create_service.py`, `text_snapshot.py`).
- El idioma de los textos visibles, la documentación y los nombres de tests es el del equipo; el de los identificadores, inglés.
