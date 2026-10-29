---
name: std-dependency-audit
description: Revisa la cadena de suministro del proyecto - package.json y lockfiles, dependencias del backend, Dockerfiles y docker-compose, runtimes (Node.js, Python) - con pnpm, antigüedad mínima de cada versión, auditorías de vulnerabilidades y búsqueda web de compromisos recientes. Usar como rutina (cada fase, antes de desplegar, al menos semanal), al agregar o actualizar una dependencia o una imagen, o cuando el usuario pida revisar paquetes, dependencias, Docker o "si algo está comprometido".
---

# Auditoría de dependencias y cadena de suministro

La norma es **`docs/standards/security.md §8`**. Los comandos, el gestor de paquetes y la antigüedad mínima (N días) están en **`docs/standards/stack.md`** (§1 y §4). Esta skill no copia la norma: la aplica.

## Procedimiento

1. **Inventario** (solo lectura):
   - cada `package.json` con su lockfile. Si hay `package-lock.json` o `yarn.lock`, anotar que hay que mudar a pnpm (`security.md §8.1`);
   - los archivos de dependencias del backend (`pyproject.toml`, `uv.lock`, `requirements*.txt`, u otros según el stack);
   - cada `Dockerfile` y `docker-compose*.yml`: imagen base, versión, digest y qué gestor usa al instalar;
   - los runtimes: versión de Node.js, Python o el que corresponda, en el stack y en las imágenes.
2. **Configuración de pnpm:**
   - `minimumReleaseAge` acorde a `stack.md`;
   - `onlyBuiltDependencies` con la lista mínima;
   - `pnpm-lock.yaml` versionado;
   - `--frozen-lockfile` en Docker y CI;
   - ningún `npm`/`npx` en scripts, Dockerfiles ni documentación.
3. **Antigüedad** de cada versión instalada o propuesta. Se mira la fecha de publicación con el comando de `stack.md §4`, por ejemplo `pnpm view <paquete>@<versión> time --json` o la API JSON de PyPI. **Menos de N días** → proponer la versión anterior que cumpla, o esperar. La excepción es un parche de seguridad urgente: se anota el motivo.
4. **Vulnerabilidades conocidas**, con los comandos de `stack.md §4`:
   - `pnpm audit --prod`;
   - el auditor del backend;
   - el escáner de imágenes.

   Se anotan la gravedad y la versión que lo corrige.
5. **Búsqueda web de compromisos** para cada runtime, imagen base y **dependencia directa**, en la versión exacta. Ejemplos de búsqueda:
   - `"<paquete>" "<versión>" malicious OR compromised OR "supply chain"`;
   - avisos del proyecto (blog o página de seguridad de Node.js, Python, la imagen base);
   - GitHub Advisory Database, OSV.

   Solo se buscan nombres y versiones públicas. Se citan las fuentes con enlace.
6. **Señales de alerta** en dependencias nuevas o recién actualizadas:
   - el nombre parecido a otro conocido (*typosquatting*);
   - pocas descargas, un repositorio vacío o inexistente;
   - un cambio reciente de mantenedor;
   - scripts de instalación nuevos;
   - código ofuscado;
   - un salto de versión sin *changelog*.
7. **Informe**, corto y ordenado por gravedad:

   | Qué | Versión | Publicada | Estado | Acción |
   |---|---|---|---|---|
   | `<paquete o imagen>` | `x.y.z` | `AAAA-MM-DD` (N días) | ✅ / ⚠ joven / ❌ vulnerable / 🚨 comprometido | mantener · bajar a `x.y.w` · actualizar a `x.y.v` · quitar |

   - Con un **compromiso confirmado**: avisar primero, en el inicio de la respuesta. No instalar ni actualizar nada, y proponer la versión segura con su fuente.
   - **Los cambios a dependencias** se proponen y se aplican **solo con el acuerdo de la persona**, como un hito: lockfile, Dockerfile y `stack.md`, con la verificación del stack.
8. **Registrar** en "Comandos ejecutados" del changelog los comandos corridos y el resultado resumido.
