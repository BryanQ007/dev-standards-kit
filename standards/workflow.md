# Proceso de trabajo

## 1. Spec-Driven Development

Primero la especificación, después el código. Ni una persona ni una IA implementan reglas de negocio que no estén documentadas.

**Documentos de un proyecto** (en `docs/`), en orden de precedencia (si se contradicen, gana el de más arriba):

1. `context.md` — visión, dominio y alcance de la etapa activa.
2. `roadmap.md` — etapas del producto.
3. `business_rules.md` — reglas de negocio numeradas (`RN-xx`).
4. `systemflowsIndex.md` → `flows/*.md` — comportamiento: entradas, proceso, salidas, validaciones.
5. `database.md` + migraciones — persistencia.
6. `specs/backend/*.md` y `specs/frontend/*.md` — contratos por módulo.
7. `architecture.md` + `standards/` — capas y normas técnicas.
8. Código.

**Ante un cambio de negocio:** reglas → modelo y migración → flujo → specs → alcance → recién entonces código. La documentación funcional se actualiza **en el mismo hito y en el mismo commit** que el código, no solo los archivos de seguimiento, y nunca se deja para un hito de documentación posterior.

**Estado de lo documentado:** cada flujo, spec o regla dice si lo descrito está **construido** o es **diseño**. Al construirlo, en ese mismo commit se cambia la marca y se anota lo que falta.

**Etapa activa:** no se implementan tablas ni pantallas de etapas futuras.

## 2. Hitos

- El plan vive en `docs/plan.md`, por fases y hitos (`Hx.y`, con letras para subdividir: `H3.4a`, `H3.4b`).
- **Identificador único:** antes de nombrar un hito nuevo se busca en el plan que el código no exista. Un pedido nuevo toma la letra siguiente libre, nunca reutiliza una.
- **Un hito = un commit = máx. 8 archivos:** hasta **5 de trabajo** + **3 de seguimiento**.
- **La documentación no cuenta para el límite y va siempre en el mismo commit:**
  - **Qué es documentación:** reglas de negocio, modelo de datos, arquitectura, índice de flujos, `flows/`, `specs/` y las normas.
  - **Qué son los 5 de trabajo:** solo código, tests, migraciones, SQL, seeders y configuración (`.env.example`).
  - **Para qué:** así la documentación nunca queda atrasada por falta de lugar.
- Si necesita más de 5 de trabajo, se parte **antes** de empezar.
- Si un archivo de código pasa las 200 líneas durante el hito, se extrae una parte a un archivo nuevo en ese mismo hito. Si eso supera los 5 de trabajo, se mueve algo **no esencial** (p. ej. un `.env.example`) al hito siguiente y se anota en el plan.
- **Un solo hito por vez en el árbol de trabajo:**
  - si quien commitea toma todo el árbol, no se empieza a escribir el hito siguiente hasta que el anterior esté commiteado;
  - mientras tanto se puede leer y diseñar;
  - lo que haya que apartar se guarda fuera del árbol.
- Excepción: commits de solo renombrado (`git mv`, 100 % de similitud verificada con `git diff -M --stat`).
- Antes de iniciar una fase, sus hitos se desglosan en el plan.
- Si un cambio de backend depende de una migración que todavía no se corrió, el hito se parte para no romper el entorno en vivo.

### Archivos de seguimiento

| Archivo | Contenido | Modo |
|---|---|---|
| `docs/plan.md` | Marcar `[x]` el hito cerrado | Edición puntual |
| `docs/changelog.md` | `## AAAA-MM-DD — Hx.y · Título`, lista de cambios, **"Cómo se usa"** (si cambia algo para quien usa el sistema) y **"Comandos ejecutados"** | Se agrega arriba |
| `docs/current_stage.md` | Resumen (etapa, fase, último hito, próximo, versión de la base), qué se hizo y por qué, tabla de archivos afectados, cómo probarlo, SQL a ejecutar, próximos pasos y avisos | Se reescribe |

### Registro de comandos

- Cada entrada del changelog termina con **"Comandos ejecutados"**: verificación, migración, generación y commit, con el resultado resumido (`✅ 42 passed`).
- El historial completo, por día, puede vivir en `docs/command_log/`.
- **Nunca** contraseñas, tokens ni valores del `.env`: `<oculto>`.

### "Cómo se usa"

Cuando el hito cambia algo que se usa (una pantalla, un endpoint, una variable de entorno), su entrada del changelog lleva una sección **"Cómo se usa"**:
- dónde está y los pasos numerados para usarlo o probarlo;
- qué permisos hacen falta;
- qué configurar en desarrollo;
- **qué todavía no funciona y en qué hito llega**, para que nadie lo busque.

Si algo no se puede probar a mano todavía (p. ej. falta una herramienta de desarrollo), se dice explícitamente y se anota un hito para resolverlo.

### Estilo de las explicaciones

- Para personas no técnicas también: qué cambia para quien usa el sistema, con un esquema en bloque de texto cuando ayuda.
- Pasos concretos para probarlo.
- Lo que la persona tiene que hacer (correr un SQL, completar una variable) en una sección propia, numerada.

## 3. Git

- Ramas: `main` (estable) ← `dev` (integración) ← `feature/hx.y-descripcion` (opcional).
- Mensaje: `Hx.y: descripción breve` + cuerpo con el porqué.
- Antes del commit: `git diff --stat` para confirmar el límite de archivos.
- **Los commits son de la persona, a su nombre** (procedimiento `std-commit-handoff`):
  - **ningún commit queda como hecho por un agente o asistente:** sin cambiar el usuario de git, sin `--author`, sin `Co-Authored-By`, `Generated with…` ni otras líneas, emojis o enlaces de la herramienta, tampoco en la descripción de un PR;
  - **el asistente no commitea ni hace push.** Deja el hito en stage y **entrega el mensaje recomendado**, listo para copiar: `Hx.y: descripción`, con el código del hito tal como está en el plan y en su orden;
  - **al terminar cada hito** se entrega ese mensaje. Antes de empezar el siguiente, se confirma con `git log -1` que el anterior ya está commiteado.

## 4. Verificación por hito

| Área | Mínimo |
|---|---|
| Backend | lint, límite de líneas, unitarios, integración del módulo ([stack.md §4](stack.md)) |
| Base | migración probada en una base descartable (nueva y desde la versión anterior); SQL entregado |
| Frontend | formato, lint y tipos ([stack.md §4](stack.md)); revisión en 390 / 768 / 1280 px |
| Docker | si cambió la imagen: reconstruir **y recrear** el contenedor; comprobar que queda `healthy` |
| Dependencias | si cambiaron: antigüedad mínima, auditoría y lockfile ([security.md §8](security.md)); antes de desplegar, la rutina completa |

Si algo falla, se informa con la salida y el hito no se da por hecho.

## 5. Checklists

**Antes de implementar**
- [ ] Dentro de la etapa activa.
- [ ] Flujos y reglas afectados revisados (y actualizados si cambian).
- [ ] Modelo y migración actualizados si cambia la persistencia.
- [ ] El hito tiene ≤ 5 archivos de trabajo (la documentación no cuenta).
- [ ] El identificador del hito no existe en el plan.
- [ ] El hito anterior ya está commiteado.
- [ ] Si es el inicio de una fase o pasó una semana desde la última: rutina de dependencias (`std-dependency-audit`, [security.md §8.4](security.md)).
- [ ] Si agrega o actualiza una dependencia, un runtime o una imagen: versión con la antigüedad mínima, revisada y con lockfile (pnpm).

**Antes del commit**
- [ ] Documentación tocada actualizada en este mismo commit, con "construido" / "diseño" al día.
- [ ] Ninguna consulta sin el filtro de organización cuando aplica.
- [ ] Errores alineados al contrato (`{data, error}` con `code`).
- [ ] UI con estados de carga, vacío y error.
- [ ] Ningún archivo > 200 líneas; lint, tipos y tests en verde.
- [ ] Plan, changelog (con "Cómo se usa" si aplica y "Comandos ejecutados") y estado actual actualizados.
