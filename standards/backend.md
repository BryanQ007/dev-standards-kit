# Normas de backend

> **Aplica a:** `<backend>/`. Independiente del framework: los nombres de archivo, el mecanismo de inyección y los comandos están en [stack.md](stack.md). Los ejemplos usan Python; en otro lenguaje se aplica la equivalencia de [stack.md §3](stack.md).
> Relacionadas: [architecture.md](architecture.md) · [database.md](database.md) · [testing.md](testing.md) · [security.md](security.md)

## 1. Reglas duras

- **Máximo 200 líneas por archivo** (script o regla de lint en CI y antes de cada commit). Un módulo grande se parte en archivos por responsabilidad (`create_service`, `review_service`…).
- **Flujo único:** `router → service → repository → DAO → cliente de datos`. Ninguna capa se salta a otra.
- **Acceso a datos con la identidad del usuario** cuando la base tiene RLS. El cliente de sistema (sin RLS) solo en tareas de sistema: registro, jobs, catálogos; ahí se filtra siempre a mano.
- **Operaciones atómicas de varios pasos** en una transacción (función SQL o transacción del ORM), dentro del DAO o el repository.
- **Multi-tenant siempre:** todo DAO filtra por la organización del contexto; nunca solo por `id`.
- **Sin capturas genéricas de excepciones en los routers:** los services lanzan errores de dominio y un handler global los traduce.
- Tipado completo y linter limpio.

## 2. Estructura de un módulo

```text
modules/<modulo>/
  DTOs          <X>Create, <X>Update, <X>Read
  DAO           <X>DAO: UNA tabla (o función)
  repository    <X>Repository: agregado, compone DAOs
  service       <X>Service: reglas de negocio (cita RN-xx en la documentación del método)
  router        endpoints: solo HTTP + inyección
```

Los nombres de archivo exactos del stack están en [stack.md §3](stack.md).

## 3. Responsabilidad por capa

| Capa                | Hace                                                            | No hace                            |
| ------------------- | --------------------------------------------------------------- | ---------------------------------- |
| Router / controller | Valida DTOs, inyecta dependencias, devuelve el envelope         | Lógica de negocio, acceso a datos  |
| Service             | Reglas de negocio, orquestación, lanza errores de dominio       | HTTP, cliente de datos directo     |
| Repository          | Expone el agregado (ej. registro + versión vigente + histórico) | Reglas de negocio                  |
| DAO                 | CRUD y filtros de una tabla, scoped por organización            | Combinar tablas de otros agregados |

## 4. Patrones obligatorios

| Patrón                       | Implementación                                                                                                                                                                                                    |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Singleton                    | Configuración y cliente de sistema                                                                                                                                                                                |
| Factory                      | Cliente de datos por petición con la identidad del usuario                                                                                                                                                        |
| DAO base                     | Atributos `table_name`, `is_organization_scoped`, `default_order_column`; métodos `get_record_by_id`, `list_records`, `list_records_page`, `create_record`, `update_record(..., change_reason)` — **sin** borrado |
| Repository base              | Reutiliza sus DAOs; resuelve catálogos por código (`resolve_catalog_id`)                                                                                                                                          |
| Guardia de acciones          | `require_app_action(action_code, change_reason)`: permiso del rol + motivo en acciones críticas                                                                                                                   |
| Dependency Injection         | El router recibe el service; el service recibe repositories y ports                                                                                                                                               |
| DTO                          | Las filas crudas no salen del DAO/repository                                                                                                                                                                      |
| Strategy + Adapter + Factory | Port por capacidad, adaptadores, fábrica por configuración                                                                                                                                                        |
| App Factory                  | Una función crea la app y registra routers, handlers y middlewares                                                                                                                                                |

## 5. Errores y respuestas

```python
class DomainError(Exception): code = "domain_error"; status = 400
class NotFoundError(DomainError): code = "not_found"; status = 404
class ConflictError(DomainError): code = "conflict"; status = 409
class ForbiddenError(DomainError): code = "forbidden"; status = 403
class ValidationError(DomainError): code = "validation_error"; status = 400
```

- Toda respuesta: `{"data": T | None, "error": {"code", "message", "details"} | None}`.
- Cada regla rechazada lleva su `code` propio (`reason_required`, `has_active_dependents`, `duplicate_document`).
- Un recurso de otra organización responde **404**, como si no existiera.
- Los errores de la base (constraints, excepciones de triggers) se traducen a errores de dominio en un solo lugar.

## 6. Ejemplo mínimo (Python)

```python
class ProjectService:
    def __init__(self, project_repository: ProjectRepository, organization_context: OrganizationContext) -> None:
        self._project_repository = project_repository
        self._organization_context = organization_context

    async def deactivate_project(self, project_id: UUID, change_reason: str | None) -> ProjectRead:
        """RN-12: un proyecto con tareas abiertas no se da de baja."""
        clean_reason = await self._project_repository.require_app_action("project.deactivate", change_reason)
        if await self._project_repository.has_open_tasks(project_id):
            raise ConflictError("Tiene tareas abiertas", code="has_open_tasks")
        updated_project_row = await self._project_repository.update_project(
            project_id, {"is_active": False}, change_reason=clean_reason
        )
        return ProjectRead.model_validate(updated_project_row)
```

## 7. Convenciones transversales

**Ganchos de ciclo de vida.** El service expone operaciones públicas (`create_*`, `update_*`, `change_*_status`) y, cuando hace falta, métodos privados con estos nombres:

| Gancho                                                                  | Cuándo                       | Para qué                                         |
| ----------------------------------------------------------------------- | ---------------------------- | ------------------------------------------------ |
| `validate_before_save(entity_data, existing_entity)`                    | Antes de crear o editar      | Reglas que dependen de varios campos o registros |
| `after_insert(created_entity)`                                          | Después de crear             | Efectos de negocio                               |
| `on_status_change(entity, previous_status, next_status, change_reason)` | Antes de un cambio de estado | Validar la transición y sus efectos              |

**Lo que NO hace la aplicación:** no escribe auditoría, históricos ni códigos de referencia (lo hacen los triggers). El motivo se envía a la base con `change_reason` (cabecera de la petición o variable de sesión).

**Contrato de listados.** Todo `GET` de colección acepta `search`, `order_by`, `order_direction` (`asc`/`desc`), `page` (desde 1) y `page_size` (máx. 100), más filtros propios, y responde `{items, total_count, page, page_size}`. Se resuelve en un módulo compartido. La búsqueda normaliza (p. ej. documentos con o sin puntos). Si el proveedor limita filas por consulta, se lee en páginas.

**Bajas.** No hay `DELETE` de negocio (responde 405). La baja es `PATCH {is_active: false, change_reason}`; la reactivación, igual.

**Documentos confirmables.** `POST /{recurso}/{id}/confirm`, `/void` (motivo obligatorio) y `/amend`, no un `PATCH` del estado.

**Archivos.** Subida `multipart` con tipo y tamaño validados; se guardan por huella; nunca se exponen URLs internas: se descargan por un endpoint que verifica el acceso.

**Notificaciones y eventos.** El cambio de negocio y el evento a entregar se guardan en la misma transacción (outbox), y la entrega la hace un worker por medio de un adaptador. Cuándo sumar un broker o Redis: [architecture.md §7.1](architecture.md).

**Configuración.** Toda variable en la configuración tipada y en `.env.example` con valor vacío o de ejemplo. Una configuración inválida frena el arranque con un error claro.

## 8. Checklist antes de cerrar un hito

- [ ] Nombres descriptivos ([naming.md](naming.md)).
- [ ] Lint, límite de 200 líneas y tests (unitarios + integración del módulo) pasan ([stack.md §4](stack.md)).
- [ ] Sin SQL fuera de los DAOs ni lógica de negocio en los routers.
- [ ] Todo acceso a datos scoped por organización.
- [ ] Acciones críticas con permiso y motivo; la app no escribe auditoría a mano.
- [ ] La spec del módulo y las reglas `RN-xx` actualizadas.
