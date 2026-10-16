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
| Todas | archivo > 200 líneas · nombres genéricos (`data`, `res`, `get`, `run`) · más de 5 archivos de trabajo en el hito |
| Seguridad | secretos o valores de `.env` · datos personales en tests o seeders · `.env` versionado |
| Backend | capa salteada · lógica en el router · DAO sin filtro de organización · `DELETE` de negocio · acción crítica sin `require_app_action` · `except` genérico · error sin `code` |
| Base | enum o `check in (...)` de negocio · tabla con estado sin histórico · sin RLS · `delete` para el rol de usuario · migración aplicada editada · seeder no idempotente |
| Frontend | estado o `fetch` en la vista · `fetch` fuera de un service · tipo o hook en el nivel equivocado · catálogo escrito a mano · falta estado de carga/vacío/error |
| Diseño | color literal o clase de paleta cruda · monto o fecha formateado a mano |
| Responsive | patrones de `responsive.md` §2 |
| Tests | regla sin test · fake con otra firma · acción crítica sin caso sin motivo · comprobación solo del estado HTTP |
| Stack | tecnología o dependencia nueva que no figura en `stack.md` · patrón implementado distinto de su equivalencia declarada |
| Seguimiento | plan, changelog con comandos o estado actual sin actualizar · docs funcionales desactualizadas |

3. **Verificar** cada hallazgo antes de informarlo (leer el contexto; descartar falsos positivos).
4. **Informar** ordenado de más grave a menos grave, con la corrección propuesta. Si no hay hallazgos, decirlo.
