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

**Ante un cambio de negocio:** reglas → modelo y migración → flujo → specs → alcance → recién entonces código. La documentación funcional se actualiza **en el mismo hito** que el código, no solo los archivos de seguimiento.

**Etapa activa:** no se implementan tablas ni pantallas de etapas futuras.

## 2. Hitos

- El plan vive en `docs/plan.md`, por fases y hitos (`Hx.y`, con letras para subdividir: `H3.4a`, `H3.4b`).
- **Un hito = un commit = máx. 8 archivos:** hasta **5 de trabajo** + **3 de seguimiento**.
- Si necesita más de 5 de trabajo, se parte **antes** de empezar.
- Excepción: commits de solo renombrado (`git mv`, 100 % de similitud verificada con `git diff -M --stat`).
- Antes de iniciar una fase, sus hitos se desglosan en el plan.
- Si un cambio de backend depende de una migración que todavía no se corrió, el hito se parte para no romper el entorno en vivo.

### Archivos de seguimiento

| Archivo | Contenido | Modo |
|---|---|---|
| `docs/plan.md` | Marcar `[x]` el hito cerrado | Edición puntual |
| `docs/changelog.md` | `## AAAA-MM-DD — Hx.y · Título`, lista de cambios y **"Comandos ejecutados"** | Se agrega arriba |
| `docs/current_stage.md` | Resumen (etapa, fase, último hito, próximo, versión de la base), qué se hizo y por qué, tabla de archivos afectados, cómo probarlo, SQL a ejecutar, próximos pasos y avisos | Se reescribe |

### Registro de comandos

- Cada entrada del changelog termina con **"Comandos ejecutados"**: verificación, migración, generación y commit, con el resultado resumido (`✅ 42 passed`).
- El historial completo, por día, puede vivir en `docs/command_log/`.
- **Nunca** contraseñas, tokens ni valores del `.env`: `<oculto>`.

### Estilo de las explicaciones

- Para personas no técnicas también: qué cambia para quien usa el sistema, con un esquema en bloque de texto cuando ayuda.
- Pasos concretos para probarlo.
- Lo que la persona tiene que hacer (correr un SQL, completar una variable) en una sección propia, numerada.

## 3. Git

- Ramas: `main` (estable) ← `dev` (integración) ← `feature/hx.y-descripcion` (opcional).
- Mensaje: `Hx.y: descripción breve` + cuerpo con el porqué.
- Antes del commit: `git diff --stat` para confirmar el límite de archivos.
- La autoría y las líneas de atribución de los commits las define la persona responsable del repo; un asistente no agrega coautores si se le pidió que no lo haga, y si no tiene autorización para commitear, deja el hito en stage y sugiere el mensaje.

## 4. Verificación por hito

| Área | Mínimo |
|---|---|
| Backend | lint, límite de líneas, unitarios, integración del módulo ([stack.md §4](stack.md)) |
| Base | migración probada en una base descartable (nueva y desde la versión anterior); SQL entregado |
| Frontend | formato, lint y tipos ([stack.md §4](stack.md)); revisión en 390 / 768 / 1280 px |
| Docker | si cambió la imagen: reconstruir **y recrear** el contenedor; comprobar que queda `healthy` |

Si algo falla, se informa con la salida y el hito no se da por hecho.

## 5. Checklists

**Antes de implementar**
- [ ] Dentro de la etapa activa.
- [ ] Flujos y reglas afectados revisados (y actualizados si cambian).
- [ ] Modelo y migración actualizados si cambia la persistencia.
- [ ] El hito tiene ≤ 5 archivos de trabajo.

**Antes del commit**
- [ ] Ninguna consulta sin el filtro de organización cuando aplica.
- [ ] Errores alineados al contrato (`{data, error}` con `code`).
- [ ] UI con estados de carga, vacío y error.
- [ ] Ningún archivo > 200 líneas; lint, tipos y tests en verde.
- [ ] Plan, changelog (con comandos) y estado actual actualizados.
