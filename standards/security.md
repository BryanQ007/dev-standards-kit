# Seguridad

> **Aplica a:** todo el repositorio, a las personas y a los asistentes de IA que trabajen en él.

## 1. Secretos

- **Nunca** se versionan `.env`, llaves, certificados ni archivos de credenciales. Solo `.env.example`, con valores vacíos o de ejemplo.
- `.gitignore` de la raíz cubre: `.env`, `.env.*` (salvo `!.env.example`), `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*.crt`, `*.cer`, `service-account*.json`, `credentials*.json`, `secrets*.json`, y los ajustes locales de cada herramienta (`.claude/settings.local.json`, `.vscode/*`, `.idea/`).
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
- Toda acción crítica exige **motivo** (≥ 3 caracteres), que queda en la auditoría junto con quién y cuándo.
- El frontend muestra los botones según los permisos que informa el backend, pero **quien decide es el backend**.

## 5. Operaciones destructivas

- Nada de negocio se borra físicamente (bajas lógicas).
- Antes de una operación difícil de revertir (borrar contenedores o volúmenes, `git reset --hard`, `push --force`, correr SQL en un entorno compartido) se confirma con la persona responsable.
- Las migraciones y los seeders ya aplicados no se editan.

## 6. Asistentes de IA

- Siguen estas normas igual que las personas.
- No ejecutan comandos que envíen datos a servicios externos sin pedido explícito.
- No commitean ni publican sin la autorización del responsable; respetan cómo quiere firmar sus commits.
- Las skills y reglas de este kit son texto: no incluyen scripts que se ejecuten solos, hooks ni servidores MCP.
