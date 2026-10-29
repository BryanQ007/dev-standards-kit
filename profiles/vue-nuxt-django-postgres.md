# Stack del proyecto — perfil Nuxt (Vue) + Django REST Framework + PostgreSQL

> Perfil de ejemplo del kit. Se instala como `docs/standards/stack.md`; ajustá lo que difiera en tu proyecto.

## 1. Tecnologías

| Capa | Tecnología y versión | Notas |
|---|---|---|
| Frontend: framework | Nuxt 3 (Vue 3, Composition API) | |
| Frontend: lenguaje | TypeScript estricto | |
| Frontend: estilos | Tailwind (o UnoCSS) | |
| Frontend: UI kit base | Propio en `components/ui/` | |
| Backend: framework | Django + Django REST Framework | |
| Backend: lenguaje | Python 3.12 | |
| Base de datos | PostgreSQL 16 | RLS: opcional |
| Acceso a datos | ORM de Django | |
| Migraciones | Migraciones de Django | |
| Autenticación | JWT (SimpleJWT o proveedor externo) | |
| Almacenamiento de archivos | S3 compatible (django-storages) | |
| Contenedores | Docker Compose | |
| Gestor de paquetes JS | `pnpm` (nunca `npm` ni `npx`: `pnpm exec`, `pnpm dlx`) | Con `minimumReleaseAge` y scripts de instalación bloqueados (security.md §8) |
| Gestor de paquetes del backend | `uv` (lockfile `uv.lock`) | Antigüedad mínima con `exclude-newer` |
| Antigüedad mínima de una versión nueva | 7 días | Paquetes e imágenes de Docker |

## 2. Carpetas

| Qué | Ruta |
|---|---|
| App frontend | `<frontend>/` |
| App backend | `<backend>/` |
| UI kit | `<frontend>/components/ui/` |
| Features del frontend | `<frontend>/features/<mod>/` |
| Módulos del backend | `<backend>/apps/<mod>/` |
| Archivo de tema | `<frontend>/theme/theme.config.ts` |
| Migraciones | `<backend>/apps/<mod>/migrations/` |
| Seeders | `<backend>/apps/<mod>/management/commands/seed_*.py` |
| Tests | `<backend>/apps/<mod>/tests/unit/` · `<backend>/apps/<mod>/tests/integration/` |

## 3. Equivalencias de los patrones

| Norma | En este proyecto |
|---|---|
| Vista sin lógica + lógica aparte | `X.vue` (solo template) + `useX.ts` (composable) + `X.types.ts` |
| Service del frontend | `features/<mod>/services/<mod>.service.ts` sobre un `ApiClient` (`$fetch`) |
| Router / controller | `views.py` (ViewSet delgado) + `urls.py` |
| Service | `services.py` (reglas de negocio; nunca en el ViewSet ni en el modelo) |
| Repository / DAO | `repositories.py` (consultas del ORM, siempre filtradas por organización) |
| DTO | `serializers.py` (solo validación y forma) |
| Inyección de dependencias | Constructor del service + fábrica en `dependencies.py` |
| Errores de dominio → HTTP | `DomainError` + `EXCEPTION_HANDLER` de DRF |
| Puerto + adaptador | `integrations/<capacidad>/port.py` + adaptadores + fábrica por settings |
| Fakes | Repositories en memoria pasados al service en el test |

## 4. Comandos de verificación

| Qué | Comando |
|---|---|
| Formato y lint frontend | `pnpm exec prettier --write <archivos> && pnpm exec eslint <archivos>` |
| Tipos frontend | `pnpm exec nuxi typecheck` |
| Lint backend | `ruff check .` |
| Límite de 200 líneas | `python scripts/check_max_lines.py` |
| Tests unitarios | `pytest apps -m unit -q` |
| Integración de un módulo | `pytest apps/<mod>/tests/integration -q` |
| SQL de una migración | `python manage.py sqlmigrate <app> <NNNN>` |
| Levantar el entorno | `docker compose up -d` |
| Versión de la base (última migración) | `select app, name, applied from django_migrations order by applied desc limit 5;` |
| Auditoría de dependencias | `pnpm audit --prod` (frontend) · `docker compose run --rm backend uv run pip-audit` · `docker scout cves <imagen>` (procedimiento `std-dependency-audit`) |
| Fecha de publicación de una versión | `pnpm view <paquete>@<versión> time --json` · `https://pypi.org/pypi/<paquete>/<versión>/json` (`upload_time`) |

## 5. Particularidades del stack

- Las variables públicas de `runtimeConfig.public` llegan al navegador: nunca secretos.
- Sin RLS, el filtro por organización en el repository es la única barrera: tests de aislamiento obligatorios.
- Las migraciones generadas se revisan antes del commit; una aplicada no se edita.

## 6. Idioma

- Documentación, commits y textos visibles: `<idioma del equipo>`.
- Identificadores: inglés.
