---
name: std-milestone
description: Planifica, parte y cierra hitos con el límite de 5 archivos de trabajo (la documentación de docs/ no cuenta y va en el mismo commit) + 3 de seguimiento (plan, changelog con "Cómo se usa" y "Comandos ejecutados", estado actual), verificación y mensaje de commit. Usar al empezar o terminar una tarea, cuando el usuario diga "sigamos", "sigue", "cerrá el hito" o pida un commit.
---

# Hitos y cierre

La norma es **`docs/standards/workflow.md`** (y `security.md`). Esta skill no la copia: la aplica.

## Al empezar

1. **¿El hito anterior ya está commiteado?** (`git status` y `git log -1`). Si el árbol tiene otro hito sin commitear y quien commitea toma todo el árbol, no escribir código: leer y diseñar, y pedir el commit.
2. Leer `docs/current_stage.md`, el hito en `docs/plan.md` y `docs/standards/stack.md` (si tiene marcadores `<…>`, completarlo antes con `std-stack-setup`).
3. Revisar flujo, reglas y spec afectados; leer la norma del área.
4. **Identificador:** si es un pedido nuevo, buscar en el plan que el código (`Hx.yz`) no exista.
5. **Contar archivos de trabajo** (código, tests, migraciones, SQL, configuración; la documentación no cuenta). Si son más de 5, partir el hito (`Hx.ya`, `Hx.yb`) y anotarlo en el plan **antes** de empezar.
6. Si depende de una migración que todavía no se corrió en el entorno en vivo, ordenar los hitos para no romperlo.
7. Si hay una decisión que es de la persona (un valor de negocio, una opción de diseño), preguntarla antes, con una opción recomendada.
8. **Dependencias:**
   - si el hito empieza una fase, o pasó una semana desde la última revisión, correr `std-dependency-audit`;
   - si el hito necesita un paquete, un runtime o una imagen nuevos, elegir una versión con la antigüedad mínima, instalarla con **pnpm** (o el gestor del backend con lockfile) e informarla con su fecha y su motivo.

## Al cerrar

1. **Verificar** según el área con los comandos de `docs/standards/stack.md §4` (lint, tipos, límite de líneas, tests, migración probada, contenedor recreado). Si algo falla, informarlo con la salida y no cerrar.
   - Si el hito toca seguridad (auth, permisos, endpoints públicos, enlaces o códigos, secretos, archivos, datos personales, integraciones), correr la auditoría `security-audit` (`docs/standards/security.md §7`) y anotar el resultado en "Comandos ejecutados".
2. **Actualizar la documentación funcional** tocada (reglas, modelo, arquitectura, flujos, specs, índice, normas) **en el mismo commit**. No cuenta para el límite, así que nunca se deja para después. Marcar "construido" lo que se construyó y anotar lo que falta.
3. **Lo que se encontró en el camino** (un error ajeno, una herramienta que falta): se arregla si entra, o se anota como hito nuevo en el plan y se avisa.
4. **Seguimiento:**
   - `plan.md`: `[x]` en el hito;
   - `changelog.md`: entrada arriba, `## AAAA-MM-DD — Hx.y · Título`, con:
     - los cambios;
     - **"Cómo se usa"**, si cambia algo para quien usa el sistema: dónde, pasos, permisos, qué configurar en desarrollo y qué todavía no funciona;
     - **"Comandos ejecutados"**, con el resultado y sin secretos (`<oculto>`);
   - `current_stage.md`: reescribir resumen, qué se hizo y por qué, tabla de archivos (la documentación en una fila aparte, "no cuenta"), cómo probarlo, SQL a ejecutar (en orden), próximos pasos y avisos.
5. `git diff --stat` → ≤ 5 de trabajo + 3 de seguimiento, más la documentación.
6. **Entrega del commit** con `std-commit-handoff`:
   - dejar en stage;
   - **entregar el mensaje recomendado** `Hx.y: descripción`, con el código y el orden del hito;
   - **no commitear ni dejar rastro de agente** en la historia: sin autoría, coautoría ni atribuciones de la herramienta.
7. **Responder** en corto:
   - qué cambió para quien usa el sistema;
   - qué se verificó y qué **no**, por ejemplo porque necesita la sesión de la persona;
   - qué tiene que hacer la persona (si algo);
   - cuál es el próximo hito.
