# Arquitectura de referencia

> Independiente de la tecnología. **Con qué se implementa cada pieza se declara en [stack.md](stack.md)** (frameworks, lenguajes, base, carpetas, comandos y equivalencias de patrones).

## 1. Visión general

```text
 Navegador / app
    │
    ▼
 <frontend> ─────────────────────────────── proveedor de Auth (sesión, token)
    │  cliente HTTP único + token del usuario
    ▼
 <backend>  (API: capas router → service → repository → DAO)
    │  acceso a datos con la identidad del usuario · credenciales de sistema solo en tareas de sistema
    ▼
 Base de datos relacional: aislamiento por organización, catálogos, históricos por trigger, funciones atómicas
    ▲
    └── integraciones: pagos · mensajería · firma · IA · almacenamiento (puertos + adaptadores)
```

Las tecnologías concretas de cada caja están en [stack.md §1](stack.md).

### Repositorio

```text
<proyecto>/
├─ docs/               documentación compartida (contexto, reglas, flujos, specs, plan)
│  └─ standards/       estas normas + stack.md
├─ <frontend>/         app cliente
├─ <backend>/          API (puede vivir en su propio repo)
├─ CLAUDE.md · AGENTS.md · .cursor/ · .github/ …   puentes por herramienta → docs/standards/
└─ entorno local (p. ej. docker-compose)
```

Frontend y backend se comunican **solo** por el contrato HTTP (§4). El tipo de los datos del frontend se genera desde la especificación del API (OpenAPI u otra) cuando el stack lo permite.

## 2. Backend

Estructura por módulo de negocio (los nombres de archivo según [stack.md §3](stack.md)):

```text
core/                      configuración (una instancia), seguridad (token), errores, envelope de respuesta
db/                        clientes de datos: de sistema (uno por proceso) y de usuario (uno por petición)
shared/                    DAO base, repository base, contexto de organización, permisos, listados
modules/<modulo>/          DTOs · DAO · repository · service · router/controller
integrations/<capacidad>/  puerto (interfaz) · adaptadores · fábrica por configuración
migraciones · seeders · scripts · tests (unitarios + integración)
```

**Flujo de una petición:** `router → service → repository → DAO → base`.

| Capa | Hace | No hace |
|---|---|---|
| Router / controller | HTTP, valida DTOs, inyecta dependencias, devuelve el envelope | Reglas de negocio, acceso a datos |
| Service | Reglas de negocio y orquestación; lanza errores de dominio | Conocer HTTP o el cliente de datos |
| Repository | Vista de dominio de un agregado; compone DAOs | Reglas de negocio |
| DAO | Acceso a **una** tabla o función, siempre filtrado por organización | Combinar tablas de otros agregados |

Las operaciones atómicas de varios pasos van en una **transacción**: función SQL creada por migración, o transacción del ORM si el stack la ofrece, siempre en el DAO o el repository, nunca en el service.

## 3. Patrones y SOLID

| Patrón | Para qué |
|---|---|
| Singleton | Configuración y cliente de sistema: uno por proceso |
| Factory | Un cliente de datos por petición con la identidad del usuario |
| DAO / Repository | Aislar el acceso a tablas y exponer agregados |
| Dependency Injection | Services y repositories reciben sus dependencias; nadie las crea |
| DTO | Contratos de entrada/salida separados de las filas |
| Strategy + Adapter + Factory | Proveedores intercambiables por configuración |
| App Factory | App configurable y testeable |
| Container / Presentational | Frontend: lógica en un hook/composable/servicio, vista sin estado |
| Service layer + Facade | Frontend: services por feature sobre un único cliente HTTP |

- **S:** DAO, Repository, Service y Router separados.
- **O:** un proveedor nuevo es un Adapter nuevo; los services no cambian.
- **L:** todos los adapters de un Port son intercambiables.
- **I:** Ports pequeños por capacidad (`PaymentGateway`, `MessageSender`, `FileStoragePort`…).
- **D:** los services dependen de abstracciones inyectadas.

## 4. Contrato HTTP

- Toda respuesta: `{ "data": T | null, "error": { "code", "message", "details"? } | null }`.
- Errores de dominio → HTTP: NotFound 404 · Conflict 409 · Forbidden 403 · Validation 400/422 · Unauthorized 401.
- El `code` es estable y en `snake_case` (`reason_required`, `duplicate_document`): el cliente decide por él, no por el texto.
- Rutas versionadas (`/api/v1/<recurso>`), recursos en plural y kebab-case.
- El cliente web llama al API en su mismo origen (proxy o reenvío) siempre que el stack lo permita: sin IPs fijas ni CORS por entorno.

## 5. Seguridad multi-tenant

1. El backend valida el token con las claves públicas del proveedor de Auth.
2. Resuelve `usuario → perfil → organización` (contexto de la petición).
3. Si la base tiene RLS, los accesos de usuario usan su propia identidad: la base es la segunda barrera.
4. Todo DAO filtra por organización; ningún acceso solo por `id`. Sin RLS, este filtro es la única barrera y se cubre con tests de aislamiento.
5. Las credenciales de sistema solo se usan en tareas de sistema y nunca salen del backend.

## 6. Capa de gestión transversal

Lo que todo registro de negocio tiene "de fábrica":

| Capacidad | Dónde se garantiza |
|---|---|
| Actividad (antes → después, quién, cuándo, motivo) | Trigger de auditoría en la base (o, si el stack no lo permite, un único punto del DAO base) |
| Histórico de estados | Trigger por tabla de estado |
| Código de referencia legible (`ABC-2026-0001`) | Trigger + contador con bloqueo de fila |
| Documentos confirmados inalterables | Trigger que rechaza `update` |
| Permisos por acción y motivo obligatorio en acciones críticas | Guardia común en el backend + catálogo de acciones |
| Listados paginados, ordenados y filtrados | Contrato común backend + tabla de datos común en el frontend |

## 7. Integraciones

- Cada capacidad externa es un **Port** con uno o más **Adapters**; la elección es por configuración.
- Las credenciales de proveedores van solo en variables de entorno del backend.
- Un adaptador "de prueba" permite desarrollar sin el proveedor real.
- Archivos: se guarda solo lo que no se puede regenerar; claves por organización y por huella (`sha256`), sin sobrescribir ni borrar.

### 7.1 Notificaciones y eventos: cuándo hace falta un broker o Redis

Tener notificaciones **no** implica Kafka ni Redis. Se decide por necesidad, y la decisión se escribe en [stack.md](stack.md):

| Si la entrega es… | Usar |
|---|---|
| de bajo volumen, por uno o dos canales, sin orden estricto, con reintentos simples | **outbox + worker + adaptador del proveedor** (el punto de partida por defecto) |
| de alto volumen; con fan-out a varios consumidores o canales (email, push, WhatsApp, webhooks); con reintentos y cola de errores (DLQ), replay, backpressure u orden por clave | un **broker o bus de eventos** (Kafka o un equivalente: RabbitMQ, NATS, una cola gestionada), alimentado desde el outbox |

- **Outbox:**
  - el evento se inserta en una tabla `outbox` **en la misma transacción** que el cambio de negocio;
  - un worker lo entrega y marca el resultado;
  - la entrega es idempotente (clave de deduplicación) y se reintenta con espera creciente;
  - si no se puede entregar, termina en un estado final de error visible, nunca en un descarte silencioso.
- **Redis es un complemento, no la fuente de verdad:**
  - sirve para caché, rate limiting, deduplicación, locks o elección de líder, pub/sub o una cola liviana;
  - lo que se tiene que entregar vive en la base (outbox), no solo en Redis.
- **En un proyecto chico o mediano no se agregan broker y Redis desde el inicio:**
  - se empieza por el outbox;
  - cada pieza se suma cuando aparece la necesidad que la justifica, en un hito propio (migración, `stack.md` y flujo).

## 8. Elegir o cambiar el stack

- El stack se declara en [stack.md](stack.md) **antes** de escribir código, con sus equivalencias de patrones y sus comandos.
- Cambiar una tecnología es un hito propio: se actualiza `stack.md`, y se verifica que cada norma siga teniendo su equivalencia.
