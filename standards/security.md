# Seguridad

> **Aplica a:** todo el repositorio, a las personas y a los asistentes de IA que trabajen en él.

## 1. Secretos

- **Nunca** se versionan `.env`, llaves, certificados ni archivos de credenciales. Solo `.env.example`, con valores vacíos o de ejemplo.
- `.gitignore` de la raíz cubre: `.env`, `.env.*` (salvo `!.env.example`), `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.crt`, `*.cer`, `service-account*.json`, `credentials*.json`, `secrets*.json`, y los ajustes locales de cada editor o asistente (p. ej. `.vscode/*`, `.idea/`, y los archivos de ajustes locales de la herramienta de IA que se use).
- **Nunca** se muestran, copian ni pegan valores de secretos en respuestas, changelogs, logs, tests ni commits. Donde haría falta, se escribe `<oculto>`.
- Las credenciales de sistema (rol que ignora RLS, claves de proveedores) viven solo en el backend.
- Las variables públicas del frontend (las que llegan al navegador) **nunca** contienen secretos.
- Las imágenes de Docker no incluyen archivos `.env`; los secretos de compilación entran como secretos de build, no como capas.

## 2. Datos personales

- Sin datos personales reales en código, tests, seeders, ejemplos ni documentación.
- Seeders de demostración: datos **ficticios**, marcados como tales.
- Tests: datos **sintéticos** (`uuid4()`, textos genéricos), nunca nombres, documentos, correos o teléfonos, aunque parezcan inventados.
- Ante duda sobre si un dato es sensible, se trata como sensible.
- Datos sensibles de un tenant nunca aparecen en el contexto de otro.

## 3. Acceso a datos

- Multi-tenant por organización, con RLS como segunda barrera.
- Un recurso ajeno responde 404 (no se revela su existencia).
- Los archivos se sirven por un endpoint que verifica el acceso; el almacenamiento no queda expuesto ni con URLs públicas permanentes.
- Validación de entrada siempre en el backend (DTOs), aunque el frontend ya valide.
- Archivos subidos: lista blanca de tipos MIME y tamaño máximo; nunca se ejecutan ni se interpretan.

## 4. Permisos y acciones críticas

- Catálogo de acciones de la app (`<recurso>.<acción>`), con marca de **crítica**.
- Cada organización elige qué roles hacen cada acción; el rol dueño siempre puede; un rol no puede darse más permisos de los que tiene.
- Toda acción crítica pide **confirmación** con un resumen de qué cambia (antes → después).
- **El motivo es obligatorio solo cuando aporta:**
  - **lleva motivo obligatorio** (≥ 3 caracteres) en excepciones, reversiones y bajas: dar de baja, anular, rescindir, revocar, retirar;
  - **lleva comentario opcional** en los pasos normales del circuito: crear, confirmar, finalizar lo vencido, registrar una firma;
  - lo decide el catálogo (una marca "requiere motivo" por acción), no la pantalla;
  - si viene, el texto queda en la auditoría junto con quién y cuándo.
- El frontend muestra los botones según los permisos que informa el backend, pero **quien decide es el backend**.

## 5. Operaciones destructivas

- Nada de negocio se borra físicamente (bajas lógicas).
- Antes de una operación difícil de revertir (borrar contenedores o volúmenes, `git reset --hard`, `push --force`, correr SQL en un entorno compartido) se confirma con la persona responsable.
- Las migraciones y los seeders ya aplicados no se editan.

## 6. Enlaces públicos y códigos de un solo uso

Para lo que se abre **sin cuenta** (firmar desde el celular, pagar, aprobar):

**El enlace**
- **El token:** aleatorio, de ≥ 256 bits. La base guarda **solo su huella** (SHA-256). El token en claro se muestra **una sola vez**, al crearlo.
- **La validez:** tiene vencimiento, que nunca se extiende, y una cantidad máxima de usos, que solo suben. Se puede **revocar** con motivo, y la revocación no se deshace.
- **Si no sirve** (vencido, usado, revocado o inexistente), la respuesta es **siempre la misma** (p. ej. 410). No revela cuál de esos casos es.

**El código**
- 6 dígitos, que vencen en minutos, con un máximo de intentos y verificables **una sola vez**.
- La huella va **atada al enlace** (`sha256("{id_del_enlace}:{código}")`): un espacio de 10⁶ códigos no se protege con su hash suelto.
- Pedir otro código reemplaza al anterior.

**El orden al usarlos**
- Primero se valida lo barato, que no gasta nada (el formato de la imagen, el documento vigente). Recién después se gasta lo de un solo uso (el código, el enlace).
- El enlace se consume al final, cuando la operación quedó registrada.

**El backend y la página**
- **El backend:** usa el cliente de sistema **filtrado por la organización del enlace**, y no devuelve ids internos ni datos de otras personas.
- **La página pública:** no se indexa (`noindex`), no manda *referrer* y no está protegida por la sesión.

## 7. Auditoría de seguridad

La revisión de seguridad se hace con la skill **`security-audit`** de Cloudflare (repositorio público [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill)), instalada con la CLI abierta de skills:

```sh
pnpm dlx skills add https://github.com/cloudflare/security-audit-skill --skill security-audit
```

**Cuándo se usa**
- Antes de publicar una versión o desplegar a un entorno compartido.
- Al cerrar un hito que toca autenticación, permisos o acciones críticas.
- Al cerrar un hito que agrega endpoints públicos (sin sesión), enlaces o códigos de un solo uso.
- Al cerrar un hito que maneja secretos, subida de archivos o datos personales.
- Al cerrar un hito que conecta una integración externa.
- Cuando la persona pide una revisión de seguridad.

**Cómo se usa**
- Se corre sobre el cambio del hito (o la rama) y se complementa con el checklist de este archivo y la revisión `std-code-review`. No los reemplaza.
- **Hallazgos confirmados:** se corrigen en el mismo hito si entran; si no, se anotan como hito propio en el plan, con la gravedad.
- **En el changelog:** se anota que se corrió, con el resultado resumido, en "Comandos ejecutados".

**Es código de un tercero**
- **Instalarlo es decisión de la persona responsable del repo:** un asistente no lo instala por su cuenta.
- **Antes de instalar:** leer el `SKILL.md` y los archivos que trae. Si incluye scripts, hooks o servidores MCP, revisarlos antes de habilitarlos.
- **Fijar la versión** (un commit o una etiqueta del repositorio) y revisar el cambio antes de actualizarlo: una skill modificada cambia el comportamiento del asistente.
- **Qué ve:** la skill trabaja sobre el código del proyecto y no recibe secretos. Si una auditoría necesita mirar configuración, se usa `.env.example`, nunca el `.env`.
- **Cobertura:** la CLI instala la skill para el asistente que se use. Si una herramienta no lee skills, se sigue su `SKILL.md` como procedimiento, igual que los de `docs/standards/skills/`.

## 8. Cadena de suministro: dependencias, runtimes e imágenes

Un paquete comprometido entra por una instalación normal. Por eso las dependencias se tratan como código de terceros.

### 8.1 pnpm en lugar de npm

- **JavaScript/TypeScript:** se usa **`pnpm`**, nunca `npm` ni `npx`.
  - Para correr herramientas del proyecto: `pnpm exec <herramienta>`.
  - Para correr una herramienta de una sola vez: `pnpm dlx <paquete>`.
- **Por qué:**
  - `node_modules` estricto: un paquete no puede usar dependencias que no declaró;
  - un solo almacén con verificación de integridad;
  - **no corre los scripts de instalación** de las dependencias salvo los aprobados;
  - **antigüedad mínima** de las versiones.
- **Configuración** (en `pnpm-workspace.yaml` o `.npmrc` del proyecto):
  - `minimumReleaseAge`: los minutos de la antigüedad mínima. Por ejemplo, `10080` = 7 días; el valor está en `stack.md`;
  - `onlyBuiltDependencies`: la lista explícita de las pocas dependencias que pueden correr scripts de instalación (`postinstall`). Todo lo demás queda bloqueado.
- **Lockfile:** `pnpm-lock.yaml` se versiona. Las instalaciones de CI y de Docker usan `pnpm install --frozen-lockfile`. Nunca se borra el lockfile para "arreglar" una instalación.
- **Mudar un proyecto de npm:** `pnpm import` (convierte `package-lock.json`), borrar `package-lock.json` y `node_modules`, y actualizar los Dockerfiles y los comandos de `stack.md`.

### 8.2 Otros ecosistemas

- **Python:** gestor con lockfile (`uv` con `uv.lock`, o `pip` con `--require-hashes`).
  - Antigüedad mínima con `uv … --exclude-newer <fecha>` (hoy menos la antigüedad de `stack.md`).
  - Nada de `pip install` sueltos fuera del lockfile.
- **Imágenes de Docker:**
  - la base con versión exacta (`node:22.11-alpine`, nunca `latest`) y, cuando se puede, **fijada por digest** (`@sha256:…`);
  - la versión elegida tiene la antigüedad mínima;
  - dentro del Dockerfile, el mismo gestor y el mismo lockfile que en el proyecto.
- **Runtimes** (Node.js, Python, motor de base): una versión con soporte (LTS o mantenida), declarada en `stack.md` y en las imágenes.

### 8.3 Antigüedad mínima

- **Ninguna versión nueva** (paquete, runtime o imagen) se instala antes de que pasen **N días desde su publicación** (`stack.md`, por defecto **7**). La mayoría de los paquetes maliciosos se detectan y se retiran en los primeros días.
- **Excepción:** un parche de seguridad urgente para una vulnerabilidad conocida se puede instalar antes. Se deja anotado el motivo y se revisa su contenido.

### 8.4 Rutina de verificación (procedimiento `std-dependency-audit`)

**Cuándo**
- Al empezar cada fase.
- Antes de desplegar.
- Al agregar o actualizar una dependencia.
- Al tocar un Dockerfile.
- Como rutina, al menos **una vez por semana** mientras el proyecto está activo.

**Qué se revisa**
1. **Inventario:**
   - los `package.json` y sus lockfiles;
   - los archivos de dependencias del backend (`pyproject.toml`, `uv.lock`, `requirements*.txt`);
   - las imágenes base y los runtimes de cada `Dockerfile` y del `docker-compose`.
2. **Antigüedad:** la fecha de publicación de cada versión instalada o por instalar (`stack.md §4`). Lo que tenga menos de N días se baja a la versión anterior o se espera.
3. **Vulnerabilidades conocidas:**
   - `pnpm audit --prod`;
   - el auditor del backend (`pip-audit` u otro);
   - el escáner de la imagen (p. ej. `docker scout cves`).
4. **Búsqueda en la web de compromisos recientes:** para Node.js, Python (o el runtime que se use), las imágenes base y **cada dependencia directa**, en el número de versión exacto. Se buscan:
   - avisos de seguridad del proyecto;
   - bases de vulnerabilidades (GitHub Advisory Database, OSV);
   - noticias de ataques a la cadena de suministro: paquete secuestrado, versión maliciosa publicada, mantenedor comprometido, *typosquatting*.
5. **Señales de alerta en un paquete nuevo o actualizado:**
   - pocos descargas o un repositorio vacío;
   - un nombre parecido a uno conocido;
   - un cambio reciente de mantenedor;
   - scripts de instalación nuevos;
   - código ofuscado.

**Resultado**
- Un informe corto: qué se revisó, qué está bien, qué hay que actualizar o bajar y por qué, con enlaces a las fuentes.
- Si hay un compromiso confirmado: **se avisa enseguida** a la persona responsable, no se instala nada, y se propone la versión segura.
- **En el changelog:** los comandos y el resultado van en "Comandos ejecutados".

## 9. Asistentes de IA

- Siguen estas normas igual que las personas.
- No ejecutan comandos que envíen datos a servicios externos sin pedido explícito. Las búsquedas web de la rutina de dependencias (§8.4) llevan solo nombres y versiones públicas, nunca código, rutas privadas ni secretos.
- No instalan, actualizan ni quitan dependencias, runtimes ni imágenes sin seguir §8:
  - pnpm;
  - la antigüedad mínima;
  - el lockfile;
  - la revisión del paquete.

  Cada dependencia nueva se informa con su versión, su fecha de publicación y por qué hace falta.
- No commitean ni publican sin la autorización del responsable; respetan cómo quiere firmar sus commits.
- **Verifican sin tocar datos compartidos:**
  - las pruebas de integración crean su propia organización de prueba y la borran;
  - las revisiones de pantalla con datos usan respuestas **simuladas** en el navegador;
  - nunca crean ni cambian registros de la demo o de un entorno de otra persona sin pedirlo.
- No abren ni cierran por su cuenta aplicaciones del equipo de la persona (p. ej. el motor de contenedores): si falta, lo avisan y esperan.
- Las skills y reglas de este kit son texto: no incluyen scripts que se ejecuten solos, hooks ni servidores MCP.
