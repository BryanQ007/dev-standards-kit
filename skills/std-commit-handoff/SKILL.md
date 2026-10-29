---
name: std-commit-handoff
description: Al terminar cada hito, deja el trabajo en stage y entrega el mensaje de commit recomendado, con el código y el orden del hito, para que la persona lo suba a su nombre. Ningún commit queda como hecho por un agente o asistente (sin autoría, coautoría ni líneas de atribución de la herramienta). Usar al cerrar cualquier hito, cuando el usuario pida "el commit", "dame el mensaje" o "subilo", y antes de cualquier git commit.
---

# Entrega del commit a la persona

La norma es **`docs/standards/workflow.md §3`**. Esta skill no la copia: la aplica.

## Reglas

1. **El commit es de la persona.** Lo hace ella, con su usuario de git, salvo que haya autorizado explícitamente que el asistente commitee, y en ese caso también con su usuario.
2. **Nada en la historia dice que lo hizo un agente:**
   - no se cambia `user.name` ni `user.email` de git;
   - no se usa `--author`;
   - no se agregan líneas `Co-Authored-By:`, `Generated with …`, `Signed-off-by` de una herramienta, ni emojis o enlaces de la herramienta en el mensaje ni en la descripción de un PR;
   - si la herramienta agrega esas líneas por defecto, se quitan.
3. **Un hito, un commit.** En el árbol de trabajo hay **un solo hito por vez**. No se empieza el siguiente hasta que la persona commitee el anterior (comprobarlo con `git log -1`).
4. **No se commitea ni se hace push** por cuenta propia. Tampoco se hacen `amend` ni `rebase` de commits de la persona.

## Al terminar el hito

1. **Verificar** que el hito está completo (`std-milestone`): verificación en verde y documentación y seguimiento al día.
2. **Dejar todo en stage:** `git add -A` (o la lista exacta si la persona no commitea el árbol completo).
3. **Revisar el stage:**
   - `git status --short`: que estén solo los archivos del hito;
   - que no entre ningún secreto ni `.env`;
   - el conteo: ≤ 5 de trabajo + 3 de seguimiento, más la documentación.
4. **Entregar el mensaje recomendado**, listo para copiar, en un bloque de código:

   ```text
   Hx.y: descripción breve en el idioma del equipo (qué cambia para quien usa el sistema)
   ```

   - **Código del hito** tal como figura en el plan (`H7.16a`, `H5D.32f2`, `H7.16d2+e` si se juntaron dos). Nunca se inventa ni se reutiliza.
   - **Orden:** el código va siempre primero, y los hitos se entregan en el orden del plan. Si quedaron partidos (`a`, `b`), se commitean en ese orden.
   - **La descripción:** una línea en presente, sin punto final, de hasta ~100 caracteres, con lo que cambia (no "arreglos varios").
   - **El cuerpo** es opcional, si la persona lo usa: el porqué, en 2 o 3 líneas, sin atribuciones.
5. **Decir en una línea qué sigue** después del commit (el próximo hito) y esperar.

## Si la persona commitea algo distinto

- **Si commitea el árbol con otro hito mezclado**, no se reescribe su historia. En el hito siguiente se completa el seguimiento que faltó y se anota en el changelog.
- **Si pide cambiar el mensaje**, se entrega el nuevo mensaje. No se hace `amend` por ella.
