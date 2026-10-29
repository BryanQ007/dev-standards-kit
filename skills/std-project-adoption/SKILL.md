---
name: std-project-adoption
description: Audita un proyecto ya existente contra todo el kit de normas (stack, arquitectura, frontend, backend, base de datos, seguridad, dependencias, tests, flujos, proceso) y arma un plan por hitos para adaptarlo sin romperlo. Usar al instalar el kit en un proyecto establecido, cuando el usuario pida "revisá el proyecto", "auditalo contra las normas", "adaptalo al estándar", o como revisión periódica de cumplimiento.
---

# Adopción del estándar en un proyecto existente

Las normas están en **`docs/standards/`** (empezando por `README.md` y `stack.md`). Esta skill no las copia: las usa como lista de control y propone cómo llegar a cumplirlas, de a poco y sin romper lo que funciona.

## Reglas de esta revisión

- **Primero se mira, después se cambia.** La auditoría es **solo lectura**: no se edita código, no se corren migraciones y no se instalan paquetes.
- **El plan de adaptación lo aprueba la persona**, y se ejecuta por hitos (`std-milestone`). Nada se rehace de una vez.
- **Sin romper el entorno en vivo:**
  - los cambios de base van por migraciones nuevas, nunca editando las ya corridas;
  - lo que cambia comportamiento lleva tests antes de tocarlo.
- **Seguridad primero:** si aparece un secreto versionado, una dependencia comprometida o un dato personal real, se **avisa enseguida**, antes del informe completo.

## Procedimiento

1. **Stack** (`std-stack-setup`): detectar tecnologías, versiones, carpetas y comandos reales, y completar o corregir `docs/standards/stack.md`. Probar que los comandos de verificación corren.
2. **Línea base**, todo solo lectura:
   - correr lint, tipos y tests;
   - contar archivos de más de 200 líneas;
   - correr la rutina de dependencias (`std-dependency-audit`);
   - si la persona la tiene instalada, la auditoría de seguridad (`security.md §7`).

   Se anotan los resultados tal como salen.
3. **Revisar área por área** contra su norma. Cada hallazgo se anota con su ubicación (`archivo:línea` o tabla), la norma que no cumple y la gravedad:

   | Área | Norma | Qué mirar primero |
   |---|---|---|
   | Seguridad | `security.md` | secretos y `.env` versionados · datos personales en tests, seeders o docs · endpoints públicos · acciones críticas sin permiso ni confirmación · logs con datos |
   | Dependencias | `security.md §8` | npm/npx en vez de pnpm · lockfiles · versiones jóvenes, vulnerables o comprometidas · imágenes `latest` · runtimes sin soporte |
   | Base de datos | `database.md` | **tabla de control de versión** (¿se sabe cuál fue la última migración corrida en cada entorno?) · cambios hechos a mano fuera de migraciones · **normalización** (listas en columnas, columnas repetidas, datos copiados, muchos a muchos sin tabla intermedia, FK polimórficas, JSON con datos relacionales) · enums de negocio · estados sin catálogo, sin transiciones ni histórico · borrados físicos · aislamiento por organización / RLS |
   | Arquitectura y backend | `architecture.md`, `backend.md` | capas salteadas · reglas de negocio fuera de los services · DAO sin filtro de organización · errores sin `code` · integraciones sin puerto o con éxitos simulados |
   | Frontend | `frontend.md`, `design-system.md`, `responsive.md` | lógica o `fetch` en la vista · colores fuera del tema · `*-foreground` sobre fondos tenues · modales anidados · scroll horizontal en 390 px · falta de estados de carga, vacío y error |
   | Tests | `testing.md` | reglas sin test · tests que dependen del `.env` · datos no sintéticos |
   | Nombres | `naming.md` | nombres genéricos (`data`, `res`, `get`) |
   | Documentación y proceso | `workflow.md`, `flows.md` | ¿hay `docs/` con reglas, flujos y specs? ¿plan, changelog y estado actual? ¿la documentación dice qué está construido y qué es diseño? |

4. **Verificar** cada hallazgo antes de anotarlo: leer el contexto y descartar los falsos positivos. Si el proyecto tiene una razón documentada para apartarse de una norma, se respeta y se anota como **excepción aceptada**.
5. **Informe de adopción** en `docs/adoption_report.md`. Si se instaló con `--adopt`, la plantilla ya está ahí y se completa; si no, se crea con la misma estructura (o va en la respuesta, si la persona lo prefiere).
   - **Resumen:**
     - porcentaje aproximado de cumplimiento por área;
     - lo **urgente** (seguridad, datos, dependencias comprometidas);
     - lo que ya cumple, para no tocarlo.
   - **Hallazgos por área**, de más grave a menos grave: ubicación, norma, impacto y corrección propuesta.
   - **Excepciones aceptadas**, con su motivo.
6. **Plan de adaptación por hitos**, que se agrega a `docs/plan.md` como una fase propia, con hitos de ≤ 5 archivos de trabajo. El orden recomendado:
   1. **Urgente:** secretos, datos personales, dependencias comprometidas o vulnerables.
   2. **Red de seguridad:** comandos de verificación que corren, tests de lo que se va a tocar, tabla de control de versión de la base y su consulta.
   3. **Proceso:** `docs/` mínimo (estado actual, plan, changelog, reglas), pnpm y lockfiles.
   4. **Base de datos:** normalización y estados, con migraciones nuevas que mueven los datos sin perderlos (bajas lógicas e historial).
   5. **Capas y frontend:** de a un módulo por vez, empezando por el que más cambia.
   6. **Lo cosmético:** nombres, tamaño de archivos y estilos, cuando se toca cada archivo por otro motivo.
7. **Rutinas:** dejar anotadas en el plan, o en el estado actual, las rutinas que siguen después de la adopción:
   - dependencias semanal (`std-dependency-audit`);
   - auditoría de seguridad antes de cada publicación;
   - esta misma revisión de cumplimiento al cerrar cada fase.
8. **Responder** con el resumen y lo urgente arriba, el enlace o la ruta al informe, y la pregunta concreta de por dónde empezar.
