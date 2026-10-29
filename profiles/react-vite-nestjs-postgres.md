# Stack del proyecto — perfil React (Vite) + NestJS + PostgreSQL

> Perfil de ejemplo del kit. Se instala como `docs/standards/stack.md`; ajustá lo que difiera en tu proyecto.

## 1. Tecnologías

| Capa | Tecnología y versión | Notas |
|---|---|---|
| Frontend: framework | React 18/19 + Vite, React Router | SPA |
| Frontend: lenguaje | TypeScript estricto | |
| Frontend: estilos | Tailwind + `cva` (o CSS Modules) | |
| Frontend: UI kit base | Propio en `src/components/ui/` | |
| Backend: framework | NestJS | |
| Backend: lenguaje | TypeScript estricto (Node LTS) | |
| Base de datos | PostgreSQL 16 | RLS: opcional (si no, filtro por organización obligatorio en cada repository) |
| Acceso a datos | Prisma o TypeORM | |
| Migraciones | Prisma Migrate / migraciones de TypeORM | |
| Autenticación | JWT (proveedor externo o Passport) | |
| Almacenamiento de archivos | S3 compatible | |
| Contenedores | Docker Compose | |
| Gestor de paquetes | `pnpm` (nunca `npm` ni `npx`: `pnpm exec`, `pnpm dlx`), front y back | `minimumReleaseAge` y scripts de instalación bloqueados (security.md §8) |
| Antigüedad mínima de una versión nueva | 7 días | Paquetes e imágenes de Docker |

## 2. Carpetas

| Qué | Ruta |
|---|---|
| App frontend | `<frontend>/` |
| App backend | `<backend>/` |
| UI kit | `<frontend>/src/components/ui/` |
| Features del frontend | `<frontend>/src/features/<mod>/` |
| Módulos del backend | `<backend>/src/modules/<mod>/` |
| Archivo de tema | `<frontend>/src/theme/theme.config.ts` |
| Migraciones | `<backend>/prisma/migrations/` (o `src/migrations/`) |
| Seeders | `<backend>/prisma/seed.ts` (o `src/seeds/`) |
| Tests | `<backend>/src/**/*.spec.ts` (unitarios) · `<backend>/test/*.e2e-spec.ts` (integración) |

## 3. Equivalencias de los patrones

| Norma | En este proyecto |
|---|---|
| Vista sin lógica + lógica aparte | `X.tsx` + `useX.ts` (+ `X.types.ts`, `X.styles.ts`, `parts/`, `index.ts`) |
| Service del frontend | `features/<mod>/services/<mod>.service.ts` sobre un `ApiClient` (fetch o axios) |
| Router / controller | `<mod>.controller.ts` |
| Service | `<mod>.service.ts` (`@Injectable`) |
| Repository / DAO | `<mod>.repository.ts` (sobre Prisma/TypeORM) |
| DTO | `dto/*.dto.ts` con `class-validator` |
| Inyección de dependencias | Módulos y providers de Nest |
| Errores de dominio → HTTP | `DomainError` + `ExceptionFilter` global |
| Puerto + adaptador | `integrations/<capacidad>/<capacidad>.port.ts` + adaptadores + provider por configuración |
| Fakes | Repositories en memoria inyectados con `Test.createTestingModule` |

## 4. Comandos de verificación

| Qué | Comando |
|---|---|
| Formato | `pnpm exec prettier --write <archivos>` |
| Lint | `pnpm exec eslint <archivos>` (regla `max-lines: 200`) |
| Tipos | `pnpm exec tsc --noEmit -p .` |
| Tests unitarios | `pnpm run test` |
| Integración de un módulo | `pnpm run test:e2e -- <mod>` |
| Suite completa | `pnpm run test && pnpm run test:e2e` |
| SQL de una migración | `pnpm exec prisma migrate diff …` / `pnpm exec prisma migrate dev --create-only` |
| Levantar el entorno | `docker compose up -d` |
| Versión de la base (última migración) | `select migration_name, finished_at from _prisma_migrations order by finished_at desc limit 1;` |
| Auditoría de dependencias | `pnpm audit --prod` · `docker scout cves <imagen>` (procedimiento `std-dependency-audit`) |
| Fecha de publicación de una versión | `pnpm view <paquete>@<versión> time --json` |

## 5. Particularidades del stack

- Las variables `VITE_*` se incrustan al compilar y llegan al navegador: nunca secretos.
- Sin RLS en la base, el filtro por organización en el repository es la **única** barrera: cubrirlo con tests de aislamiento.
- Docker: después de reconstruir una imagen, recrear el contenedor.

## 6. Idioma

- Documentación, commits y textos visibles: `<idioma del equipo>`.
- Identificadores: inglés.
