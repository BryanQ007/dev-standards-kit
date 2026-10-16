---
name: std-milestone
description: Planifica, parte y cierra hitos con el límite de 5 archivos de trabajo + 3 de seguimiento (plan, changelog con "Comandos ejecutados" y estado actual), verificación y mensaje de commit. Usar al empezar o terminar una tarea, cuando el usuario diga "sigamos con el próximo hito", "cerrá el hito" o pida un commit.
---

# Hitos y cierre

La norma es **`docs/standards/workflow.md`** (y `security.md`). Esta skill no la copia: la aplica.

## Al empezar

1. Leer `docs/current_stage.md`, el hito en `docs/plan.md` y `docs/standards/stack.md` (si tiene marcadores `<…>`, completarlo antes con `std-stack-setup`).
2. Revisar flujo, reglas y spec afectados; leer la norma del área.
3. **Contar archivos de trabajo.** Si son más de 5, partir el hito (`Hx.ya`, `Hx.yb`) y anotarlo en el plan **antes** de empezar.
4. Si depende de una migración que todavía no se corrió en el entorno en vivo, ordenar los hitos para no romperlo.

## Al cerrar

1. **Verificar** según el área con los comandos de `docs/standards/stack.md §4` (lint, tipos, límite de líneas, tests, migración probada, contenedor recreado). Si algo falla, informarlo con la salida y no cerrar.
2. **Actualizar la documentación funcional** tocada (reglas, flujos, specs, modelo) dentro de los 5 de trabajo.
3. **Seguimiento:**
   - `plan.md`: `[x]` en el hito;
   - `changelog.md`: entrada arriba, `## AAAA-MM-DD — Hx.y · Título`, cambios y **"Comandos ejecutados"** con el resultado, sin secretos (`<oculto>`);
   - `current_stage.md`: reescribir resumen, qué se hizo y por qué, tabla de archivos, cómo probarlo, SQL a ejecutar (en orden), próximos pasos y avisos.
4. `git diff --stat` → ≤ 8 archivos (≤ 5 de trabajo).
5. **Commit** solo si la persona lo autorizó y como ella lo pide (autoría, sin coautores si así lo indicó). Si no, dejar en stage (`git add`) y sugerir: `Hx.y: descripción`.
6. **Responder** en corto: qué cambió para quien usa el sistema, qué tiene que hacer la persona (si algo) y cuál es el próximo hito.
