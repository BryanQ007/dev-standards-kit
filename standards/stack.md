# Stack del proyecto

> **Este archivo lo completa cada proyecto.** Las demás normas son independientes de la tecnología; acá se declara con qué se implementan. Si un dato no aplica, poné `—`. Para completarlo con ayuda: skill `std-stack-setup`, o copiá un perfil de `profiles/` del kit.
>
> Las normas y las skills leen de acá: las carpetas, los comandos de verificación y las equivalencias de cada patrón.

## 1. Tecnologías

| Capa | Tecnología y versión | Notas |
|---|---|---|
| Frontend: framework | `<p. ej. Next.js 15 / React + Vite / Nuxt / Angular>` | |
| Frontend: lenguaje | `<p. ej. TypeScript estricto>` | |
| Frontend: estilos | `<p. ej. Tailwind / CSS Modules / SCSS>` | |
| Frontend: UI kit base | `<propio en components/ui/ · librería>` | |
| Backend: framework | `<p. ej. FastAPI / NestJS / Django / Spring Boot / Laravel>` | |
| Backend: lenguaje | `<p. ej. Python 3.12 / TypeScript / Java 21 / PHP 8.3>` | |
| Base de datos | `<p. ej. PostgreSQL 16 (Supabase) / MySQL 8>` | ¿Tiene RLS? `<sí/no>` |
| Acceso a datos | `<cliente API / ORM / query builder>` | |
| Migraciones | `<Alembic / Prisma / TypeORM / Flyway / Django migrations>` | |
| Autenticación | `<proveedor y formato del token>` | |
| Almacenamiento de archivos | `<S3 compatible / proveedor>` | |
| Notificaciones y eventos | `<outbox + worker / broker (Kafka, RabbitMQ…) / —>` | Redis: `<no / caché · rate limiting · locks>` · criterio: [architecture.md §7.1](architecture.md) |
| Contenedores | `<Docker Compose / —>` | |

## 2. Carpetas

| Qué | Ruta |
|---|---|
| App frontend | `<frontend>/` |
| App backend | `<backend>/` |
| Componentes genéricos (UI kit) | `<frontend>/src/components/ui/` |
| Features del frontend | `<frontend>/src/features/<mod>/` |
| Módulos del backend | `<backend>/app/modules/<mod>/` |
| Archivo de tema (único con colores) | `<frontend>/src/theme/theme.config.ts` |
| Migraciones | `<backend>/…` |
| Seeders | `<backend>/…` |
| Tests unitarios / integración | `<backend>/tests/unit/` · `<backend>/tests/` |

## 3. Equivalencias de los patrones

Cómo se implementa en este stack cada pieza que piden las normas:

| Norma | En este proyecto |
|---|---|
| Vista sin lógica + lógica aparte (frontend) | `<p. ej. X.tsx + useX.ts / X.vue + useX.ts (composable) / componente + servicio>` |
| Service del frontend sobre un cliente HTTP | `<p. ej. features/<mod>/services/*.service.ts + ApiClient>` |
| Router / controller (backend) | `<p. ej. router.py / *.controller.ts / views.py>` |
| Service con reglas de negocio | `<…>` |
| Repository / DAO | `<…>` |
| DTO de entrada y salida | `<Pydantic / class-validator / serializers / records>` |
| Inyección de dependencias | `<Depends / módulos de Nest / constructor + contenedor>` |
| Errores de dominio → HTTP | `<handler global / filter / middleware>` |
| Puerto + adaptador de integraciones | `<…>` |
| Fakes para tests unitarios | `<…>` |

## 4. Comandos de verificación

| Qué | Comando |
|---|---|
| Formato frontend | `<p. ej. npx prettier --write <archivos>>` |
| Lint frontend | `<p. ej. npx eslint <archivos>>` |
| Tipos frontend | `<p. ej. npx tsc --noEmit -p .>` |
| Lint backend | `<p. ej. ruff check app tests>` |
| Límite de 200 líneas | `<p. ej. python scripts/check_max_lines.py / regla max-lines de ESLint>` |
| Tests unitarios | `<…>` |
| Tests de integración de un módulo | `<…>` |
| Suite completa | `<…>` |
| Generar el SQL de una migración | `<…>` |
| Levantar el entorno | `<p. ej. docker compose up -d>` |

## 5. Particularidades del stack

Advertencias propias de estas herramientas (las normas generales no las conocen):

- `<p. ej. no correr el build con el servidor de desarrollo activo si comparten carpeta>`
- `<p. ej. después de reconstruir una imagen, recrear el contenedor>`

## 6. Idioma

- Documentación, commits y textos visibles: `<español / inglés…>`
- Identificadores de código: inglés.
- Locale y moneda por defecto: `<p. ej. es-AR / ARS>`
