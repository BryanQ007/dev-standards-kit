# Informe de adopción del estándar

> Lo completa el procedimiento `docs/standards/skills/std-project-adoption/SKILL.md` (o una persona, siguiéndolo).
> La auditoría es **solo lectura**: este informe no cambia nada del proyecto.
> Fecha de la revisión: `AAAA-MM-DD` · versión del kit: `x.y.z` (ver `VERSION` del kit)

## 1. Urgente

Secretos versionados, datos personales reales, dependencias comprometidas o vulnerables. Se corrigen antes que todo lo demás.

| Hallazgo | Dónde | Acción |
|---|---|---|
| | | |

## 2. Línea base

| Verificación | Comando (`stack.md §4`) | Resultado |
|---|---|---|
| Lint | | |
| Tipos | | |
| Tests | | |
| Archivos de más de 200 líneas | | |
| Dependencias (`std-dependency-audit`) | | |
| Versión de la base (tabla de control) | | |

## 3. Cumplimiento por área

| Área | Norma | Cumple | Hallazgos principales |
|---|---|---|---|
| Seguridad | `security.md` | % | |
| Dependencias y Docker | `security.md §8` | % | |
| Base de datos: versión | `database.md §9.1` | % | ¿Hay tabla de control? ¿Cuál es la última migración en cada entorno? |
| Base de datos: normalización | `database.md §4` | % | Listas en columnas, muchos a muchos sin tabla intermedia, datos copiados, JSON relacional |
| Base de datos: estados | `database.md §6` | % | Catálogo, transiciones, histórico |
| Arquitectura y backend | `architecture.md`, `backend.md` | % | |
| Frontend y diseño | `frontend.md`, `design-system.md`, `responsive.md` | % | |
| Tests | `testing.md` | % | |
| Nombres | `naming.md` | % | |
| Documentación y proceso | `workflow.md`, `flows.md` | % | |

## 4. Hallazgos

De más grave a menos grave. Cada uno con su ubicación (`archivo:línea` o tabla), la norma, el impacto y la corrección.

1.

## 5. Excepciones aceptadas

Lo que el proyecto hace distinto a propósito, con su motivo, y que no se cambia.

| Norma | Excepción | Motivo |
|---|---|---|
| | | |

## 6. Plan de adaptación

Se agrega a `docs/plan.md` como una fase propia, con hitos de ≤ 5 archivos de trabajo, en este orden:

1. **Urgente.**
2. **Red de seguridad:** comandos de verificación, tests de lo que se va a tocar, tabla de control de versión de la base.
3. **Proceso:** `docs/` mínimo y pnpm.
4. **Base de datos:** normalización y estados, con migraciones nuevas que mueven los datos sin perderlos.
5. **Capas y frontend:** módulo por módulo.
6. **Lo cosmético:** al tocar cada archivo por otro motivo.

## 7. Rutinas desde ahora

- Dependencias, Docker y runtimes: semanal · cada fase · antes de desplegar (`std-dependency-audit`).
- Auditoría de seguridad: antes de publicar (`security.md §7`).
- Esta revisión de cumplimiento: al cerrar cada fase (`std-project-adoption`).
