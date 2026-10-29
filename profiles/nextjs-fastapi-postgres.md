# Stack del proyecto — perfil Next.js + FastAPI + PostgreSQL (Supabase)

> Perfil de ejemplo del kit. Se instala como `docs/standards/stack.md`; ajustá lo que difiera en tu proyecto.

## 1. Tecnologías

| Capa | Tecnología y versión | Notas |
|---|---|---|
| Frontend: framework | Next.js 15 (App Router), React 19 | |
| Frontend: lenguaje | TypeScript estricto | |
| Frontend: estilos | Tailwind 3 + `cva` | |
| Frontend: UI kit base | Propio en `components/ui/` | |
| Backend: framework | FastAPI | |
| Backend: lenguaje | Python 3.12, Pydantic v2, pydantic-settings | |
| Base de datos | PostgreSQL (Supabase) | RLS: sí |
| Acceso a datos | `supabase-py` (API de Supabase); RPC para lo atómico | sin conexión directa a Postgres |
| Migraciones | Alembic → SQL incremental para el SQL Editor | |
| Autenticación | Supabase Auth (JWT, verificado con JWKS) | |
| Almacenamiento de archivos | S3 compatible (SeaweedFS local / Supabase Storage) | |
| Contenedores | Docker Compose | |
| Gestor de paquetes JS | `pnpm` (nunca `npm` ni `npx`: `pnpm exec`, `pnpm dlx`) | Con `minimumReleaseAge` y scripts de instalación bloqueados (security.md §8) |
| Gestor de paquetes del backend | `uv` (lockfile `uv.lock`) | Antigüedad mínima con `exclude-newer` |
| Antigüedad mínima de una versión nueva | 7 días | Paquetes e imágenes de Docker |

## 2. Carpetas

| Qué | Ruta |
|---|---|
| App frontend | `<frontend>/` |
| App backend | `<backend>/` |
| UI kit | `<frontend>/src/components/ui/` |
| Features del frontend | `<frontend>/src/features/<mod>/` |
| Módulos del backend | `<backend>/app/modules/<mod>/` |
| Archivo de tema | `<frontend>/src/theme/theme.config.ts` |
| Migraciones | `<backend>/alembic/versions/` (+ `sql/migrations/*.sql` generados) |
| Seeders | `<backend>/sql/seeds/` |
| Tests | `<backend>/tests/unit/` (unitarios) · `<backend>/tests/` (integración) |

## 3. Equivalencias de los patrones

| Norma | En este proyecto |
|---|---|
| Vista sin lógica + lógica aparte | `X.tsx` + `useX.ts` (+ `X.types.ts`, `X.styles.ts`, `parts/`, `index.ts`) |
| Service del frontend | `features/<mod>/services/<mod>.service.ts` sobre `lib/http/ApiClient` |
| Router / controller | `app/modules/<mod>/router.py` |
| Service | `service.py` (`XService`) |
| Repository / DAO | `repository.py` (`BaseRepository`) · `dao.py` (`BaseDAO`) |
| DTO | Pydantic en `schemas.py` |
| Inyección de dependencias | `Depends` de FastAPI |
| Errores de dominio → HTTP | `DomainError` + `exception_handlers.py` |
| Puerto + adaptador | `app/integrations/<capacidad>/port.py` + adaptadores + `factory.py` |
| Fakes | `tests/unit/fakes/fake_<mod>_repository.py`, base `FakeAppActionGuard` |

## 4. Comandos de verificación

| Qué | Comando |
|---|---|
| Formato frontend | `pnpm exec prettier --write <archivos>` |
| Lint frontend | `pnpm exec eslint <archivos>` |
| Tipos frontend | `pnpm exec tsc --noEmit -p .` |
| Lint backend | `docker compose run --rm backend ruff check app tests` |
| Límite de 200 líneas | `python scripts/check_max_lines.py` (back) · ESLint `max-lines` (front) |
| Tests unitarios | `docker compose run --rm backend pytest tests/unit -q` |
| Integración de un módulo | `docker compose run --rm backend pytest tests/test_<mod>.py -q` |
| Suite completa | `docker compose run --rm backend pytest` |
| SQL de una migración | `docker compose run --rm backend sh scripts/export_migration_sql.sh NNNN` |
| Levantar el entorno | `docker compose up -d` |
| Versión de la base (última migración) | `select version_num from alembic_version;` |
| Auditoría de dependencias | `pnpm audit --prod` (frontend) · `docker compose run --rm backend uv run pip-audit` · `docker scout cves <imagen>` (procedimiento `std-dependency-audit`) |
| Fecha de publicación de una versión | `pnpm view <paquete>@<versión> time --json` · `https://pypi.org/pypi/<paquete>/<versión>/json` (`upload_time`) |

## 5. Particularidades del stack

- **Nunca** `next build` con `next dev` activo: comparten `.next/` y se rompe el JS del cliente.
- El navegador llama a `/api/v1` en el mismo origen y Next lo reenvía al backend (rewrites). Si hay middleware, subir `experimental.middlewareClientMaxBodySize` para cargas de archivos.
- Las variables `NEXT_PUBLIC_*` se incrustan al compilar: si cambian, recompilar.
- Supabase devuelve como máximo 1000 filas por consulta: leer en páginas.
- La API de Supabase no abre transacciones entre llamadas: lo atómico va en funciones SQL (RPC).
- Docker: después de reconstruir una imagen, `docker compose up -d <servicio>` para recrear el contenedor.
- En Git Bash (Windows), los volúmenes de Docker necesitan `MSYS_NO_PATHCONV=1`.

## 6. Idioma

- Documentación, commits y textos visibles: español.
- Identificadores: inglés. Locale y moneda: `es-AR` / `ARS`.
