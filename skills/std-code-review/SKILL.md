---
name: std-code-review
description: Revisa cambios (diff, rama o archivos) contra las normas del proyecto - capas, 200 líneas, nombres, multi-tenant, bajas lógicas, acciones críticas, tokens del tema, responsive, tests y secretos. Usar cuando el usuario pida revisar código, un PR o "ver si cumple las normas".
---

# Revisión contra las normas

Las normas están en **`docs/standards/`**. Esta skill no las copia: las usa como checklist.

## Procedimiento

1. **Delimitar** qué se revisa (`git diff`, una rama o archivos) y leer las normas de las áreas tocadas y `docs/standards/stack.md` (cómo se llama cada patrón en este stack).
2. **Recorrer** cada archivo y anotar solo hallazgos concretos, con `archivo:línea`:

| Área | Qué buscar |
|---|---|
| Todas | archivo > 200 líneas · nombres genéricos (`data`, `res`, `get`, `run`) · más de 5 archivos de trabajo en el hito (sin contar la documentación) |
| Seguridad | secretos o valores de `.env` · datos personales en tests o seeders · `.env` versionado · token o código guardado en claro · enlace público que responde distinto según por qué no sirve · destino o código en los logs |
| Backend | capa salteada · lógica en el router · DAO sin filtro de organización · `DELETE` de negocio · acción crítica sin `require_app_action` · `except` genérico · error sin `code` · integración que simula un éxito o adaptador de prueba habilitado en producción · credencial de un solo uso gastada antes de validar lo demás |
| Base | enum o `check in (...)` de negocio · tabla con estado sin histórico · sin RLS · `delete` para el rol de usuario · migración aplicada editada · seeder no idempotente · migración que depende de valores de un seeder · lista o ids en una columna de texto/JSON · muchos a muchos sin tabla intermedia · dato copiado de otra tabla · estado sin tabla de transiciones · migración que no registra su versión |
| Frontend | estado o `fetch` en la vista · `fetch` fuera de un service · tipo o hook en el nivel equivocado · catálogo escrito a mano · falta estado de carga/vacío/error · modal encima de otro o confirmación anidada |
| Diseño | color literal o clase de paleta cruda · `*-foreground` sobre un fondo tenue · monto o fecha formateado a mano |
| Responsive | patrones de `responsive.md` §2 |
| Tests | regla sin test · fake con otra firma · acción crítica sin caso sin motivo · comprobación solo del estado HTTP |
| Stack | tecnología o dependencia nueva que no figura en `stack.md` · patrón implementado distinto de su equivalencia declarada |
| Dependencias | `npm`/`npx`/`package-lock.json` en vez de pnpm · lockfile sin actualizar o borrado · versión con menos de N días · rango abierto (`*`, `latest`) · imagen `latest` o sin versión exacta · script de instalación nuevo habilitado sin motivo · `pip install` fuera del lockfile (ver `std-dependency-audit`) |
| Seguimiento | plan, changelog con comandos o estado actual sin actualizar · docs funcionales que no cambiaron en el mismo commit · flujo o spec que sigue diciendo "diseño" en algo construido · identificador de hito repetido |

3. **Seguridad a fondo:** si el cambio toca autenticación, permisos, endpoints públicos, enlaces o códigos, secretos, archivos subidos, datos personales o una integración, correr además la auditoría `security-audit` (`docs/standards/security.md §7`), si está instalada. Si no lo está, recomendar instalarla y no instalarla por cuenta propia.
4. **Verificar** cada hallazgo antes de informarlo (leer el contexto; descartar falsos positivos).
5. **Informar** ordenado de más grave a menos grave, con la corrección propuesta. Si no hay hallazgos, decirlo.
