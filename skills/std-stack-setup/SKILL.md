---
name: std-stack-setup
description: Define o cambia las tecnologías del proyecto (frontend, backend, base de datos, migraciones, auth, almacenamiento, tests) completando docs/standards/stack.md con carpetas, equivalencias de patrones y comandos de verificación. Usar al iniciar un proyecto, cuando stack.md tiene marcadores <…> sin completar, cuando el usuario diga qué tecnologías va a usar o cuando cambie una tecnología.
---

# Definir el stack del proyecto

Las normas de `docs/standards/` son independientes de la tecnología; **`docs/standards/stack.md`** dice con qué se implementan. Esta skill lo completa.

## Procedimiento

1. **Leer** `docs/standards/stack.md` (plantilla o versión actual) y `docs/standards/architecture.md`.
2. **Detectar lo que ya existe** en el repo, sin suponer: `package.json`, `pyproject.toml` / `requirements.txt`, `composer.json`, `pom.xml` / `build.gradle`, `go.mod`, `docker-compose*.yml`, carpetas de migraciones, configuración de linters y de tests. Anotar versiones reales.
3. **Preguntar solo lo que falte o sea una decisión** (framework de front y de back, base, ORM o cliente, herramienta de migraciones, auth, almacenamiento, idioma). Si el usuario no tiene preferencia, proponer una opción con su porqué, en una línea.
4. **Completar las 6 secciones** de `stack.md`:
   1. tecnologías y versiones;
   2. carpetas reales;
   3. **equivalencia de cada patrón** de las normas (vista + lógica, service del front, router, service, repository/DAO, DTO, inyección, errores → HTTP, puerto + adaptador, fakes). Si una norma no tiene equivalencia directa, proponer cómo cumplirla y anotarlo;
   4. comandos de verificación **probados** (correrlos si el entorno lo permite y anotar el resultado);
   5. particularidades conocidas de esas herramientas;
   6. idioma, locale y moneda.
   Si hay un perfil parecido en `profiles/` del kit, partir de él.
5. **Ajustar los puentes de las herramientas** si las extensiones cambian: los `globs` de `.cursor/rules/*.mdc`, los `applyTo` de `.github/instructions/*.instructions.md` y los de `.windsurf/rules/`.
6. **No escribir código de la app** en este paso. Si el cambio es de una tecnología ya usada, es un hito propio: actualizar `stack.md`, revisar qué normas cambian de equivalencia y planificar la migración.
7. **Informar** qué quedó definido, qué comandos se probaron y qué quedó como decisión pendiente.
