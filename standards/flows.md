# Flujos funcionales — cómo se escriben

> **Aplica a:** todo archivo de `docs/flows/` y su índice `docs/systemflowsIndex.md`. Relacionadas: [backend.md](backend.md) · [database.md](database.md) · [frontend.md](frontend.md)

Un flujo describe un comportamiento de punta a punta, **trazable hasta el código**: quién hace qué, en qué pantalla, qué función se llama, qué endpoint, qué fila cambia en la base y qué queda en la actividad. Quien lo lee tiene que poder implementarlo o revisarlo **sin abrir el código**, y quien abre el código tiene que poder ubicarlo en el flujo.

## 1. Dos niveles de documento

| Nivel                   | Archivo                                                       | Qué tiene                                                                                                                                            |
| ----------------------- | ------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Circuito**            | `docs/flows/NN-<circuito>.md`                                 | Los flujos `F#` del circuito, con el formato corto (§2). Es el mapa.                                                                                 |
| **Detalle de una fase** | `docs/flows/NNx-<detalle>.md` (ej. `04a-payment-checkout.md`) | Una fase de un flujo con pantalla, mensajes, estados y condiciones de UI (§3). Se crea cuando el `F#` del circuito ya no alcanza para implementarlo. |

- El detalle **complementa** al circuito, no lo repite: el `F#` del circuito enlaza al detalle y el detalle dice qué pasos del `F#` cubre.
- Los dos se listan en el índice.

## 2. Formato corto (un `F#` dentro del circuito)

```markdown
## F# — Nombre (Hx.y; RN-xx)

**Objetivo** · **Disparador / Entrada** · **Proceso** (pasos numerados) · **Salida** · **Validaciones** · **Reglas** · **Históricos**
```

- Un boceto `text` de la pantalla o del recorrido, si ayuda (como los de `current_stage.md`).
- La numeración `F#` no se reutiliza ni se renumera.

## 3. Formato de detalle (secciones, en este orden)

Se omite la sección que no aplica, pero no se cambia el orden.

### 3.1 Encabezado

```markdown
# <Nombre de la fase> (<qué abarca, en 3–5 palabras>)

Fase **después de** <evento> y **antes de** <estado siguiente>: <objetivo en una oración>.
Complementa [F# del circuito](NN-<circuito>.md#…) (pasos 2–4) con el detalle de **pantalla, acciones y condiciones de UI**.

**Backend:** módulo `<módulo>` (`router.py` · `service.py`) · **Reglas:** RN-xx, RN-yy · **Relacionados:** [otro detalle](…)
```

### 3.2 Alcance

| Incluye                                    | No incluye (ver otro doc) |
| ------------------------------------------ | ------------------------- |
| `<Pantalla>` / `use<Pantalla>.ts`          | <tema> → [F# …](…)        |
| Endpoints y efecto en la base de esta fase | <tema> → [detalle …](…)   |

### 3.3 Estados (si la fase mueve un estado)

Un `stateDiagram-v2` con los **códigos del catálogo** (nunca nombres sueltos), la acción que dispara cada transición y una nota por estado que la UI trate distinto. Después, la tabla:

| Estado (`<catálogo>.code`) | Cómo lo trata la UI   | Qué puede pasar                      |
| -------------------------- | --------------------- | ------------------------------------ |
| `draft`                    | editable              | completar y confirmar                |
| `confirmed`                | solo lectura + Firmas | registrar firmas · anular con motivo |

- Se aclara **qué transición escribe el sistema** y cuál no: un código que existe en el catálogo pero que el código no escribe se marca así.
- Cada cambio de estado nombra su **histórico** (`<entidad>_status_history`, lo llena un trigger).

### 3.4 Entrada a la pantalla

| Origen | Ruta | Qué ve o qué se registra al entrar |
| ------ | ---- | ---------------------------------- |

**Carga inicial** (en el orden del hook):

| #   | Función del service                          | HTTP                         |
| --- | -------------------------------------------- | ---------------------------- |
| 1   | `documentsService.fetchDocument(documentId)` | `GET /api/v1/documents/{id}` |

### 3.5 Catálogos y payloads

- Tabla por catálogo que use la fase: `code` · quién lo usa · efecto.
- Cada cuerpo JSON (pedido o campo `jsonb`) **con un ejemplo** de datos ficticios: montos en centavos, ids como `"<uuid>"`, nombres "de prueba".

### 3.6 Matriz de UI por rol y estado

| Elemento de UI    | Rol A (ej. admin) | Rol B (ej. operador) | Condición (estado · datos · permiso)               |
| ----------------- | ----------------- | -------------------- | -------------------------------------------------- |
| [Registrar firma] | sí                | sí                   | `confirmed` · firmado adjunto · `document.confirm` |

- La condición nombra el **código de acción** (`app_actions.code`) y si exige motivo (regla de motivo del proyecto).
- Un elemento que está en pantalla pero no hace nada se marca **"sin acción"** y va a §3.12.

### 3.7 Flujos de la fase (A, B, C…)

Una subsección por recorrido, con letra: `## Flujo A — <qué>`.

| #   | Quién  | Acción en la UI  | Función                | HTTP                                                 | Efecto en la base                                    |
| --- | ------ | ---------------- | ---------------------- | ---------------------------------------------------- | ---------------------------------------------------- |
| A.1 | gestor | [Firmó en papel] | `recordPaperSignature` | `POST /api/v1/document-signers/{id}/paper-signature` | `document_signers.signed_at` · histórico · actividad |

Después de la tabla:

- el **cuerpo del pedido** en JSON;
- los **errores** que puede devolver (`409 signer_already_signed`, `400 reason_required`…);
- lo que **queda en la actividad** (RN-80), con el texto que se ve.

### 3.8 Secuencia del camino feliz

Un `sequenceDiagram` con, como máximo, estos participantes: actores (personas), pantalla, API, base. Los mensajes llevan el endpoint o la función real.

### 3.9 Textos que genera el sistema

Tabla de los textos fijos que ve el usuario (avisos, actividad, mensajes): contexto · texto · dónde aparece.

### 3.10 Recargas y eventos

Qué vuelve a cargar al guardar, al volver a la pantalla o por realtime.

### 3.11 Archivos

| Archivo                              | Rol               |
| ------------------------------------ | ----------------- |
| `<frontend>/src/features/…/useX.ts`  | lógica de la fase |
| `<backend>/app/modules/…/service.py` | reglas RN-xx      |

### 3.12 Limitaciones conocidas

Lista numerada de **diferencias entre lo documentado y lo que hace el código hoy**, y de decisiones de producto pendientes. Cada una con el hito que la resuelve, si lo hay. Nunca se esconden: se escriben acá.

## 4. Diagramas (Mermaid)

| Diagrama          | Cuándo                                                                | Reglas                                                                                                                                                               |
| ----------------- | --------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `stateDiagram-v2` | la fase mueve un estado                                               | códigos del catálogo · `[*]` al inicio y en terminales · cada flecha con la acción (`: confirmar\n(motivo opcional)`) · `note` solo para lo que la UI trata distinto |
| `sequenceDiagram` | camino feliz de punta a punta                                         | ≤ 5 participantes · alias cortos (`participant U as Gestor`) · cada mensaje con el endpoint o la función · `alt`/`opt` solo para un desvío importante                |
| `flowchart TD`    | decisión con varias ramas (qué método de firma, qué plantilla aplica) | rombos para las preguntas · ≤ 12 nodos                                                                                                                               |
| bloque `text`     | boceto de pantalla o de recorrido                                     | como los de `current_stage.md`                                                                                                                                       |

- Textos en español; identificadores (`code`, endpoints, funciones) entre comillas invertidas o tal como están en el código.
- Un diagrama **no reemplaza** a la tabla: la tabla es la fuente; el diagrama la resume.
- Si un diagrama pasa de unas 20 líneas, se parte.

## 5. Reglas de contenido

1. **Trazable:** cada paso nombra la función real, el endpoint con método y el efecto en la base (tabla y columna).
2. **Código del catálogo, no texto:** estados, tipos y roles por su `code` ([database.md](database.md)).
3. **Reglas por código:** `RN-xx`, nunca reescritas en el flujo.
4. **Sin datos reales:** ejemplos ficticios ("Titular de prueba", `DNI 30000001`, `"<uuid>"`). Nunca credenciales ni valores del `.env`.
5. **Acciones críticas:** se indica el código de acción, si el motivo es obligatorio u opcional (regla de motivo del proyecto) y qué queda en la actividad.
6. **Lo que el código no hace**, aunque exista en la UI o en el catálogo, se dice (§3.6 y §3.12).
7. **Nombres** de funciones y archivos como en el código ([naming.md](naming.md)).
8. **Notificaciones:** si el flujo dispara avisos, recordatorios, webhooks o mensajes, el paso dice qué evento se guarda (outbox), quién lo entrega, por qué canal y qué pasa si falla (reintento, error visible). La arquitectura se elige con [architecture.md §7.1](architecture.md); el flujo solo la documenta.
9. **Al día:** si un hito cambia el comportamiento, actualiza el flujo **en el mismo hito**.

## 6. Checklist

- [ ] El detalle enlaza a su `F#` y el `F#` al detalle; los dos están en el índice.
- [ ] Alcance con "Incluye / No incluye (ver otro doc)".
- [ ] Cada estado con el código del catálogo y su histórico.
- [ ] Cada paso con quién, acción, función, HTTP y efecto en la base.
- [ ] Cada JSON con un ejemplo ficticio.
- [ ] Matriz de UI con la condición y el código de acción.
- [ ] Un diagrama de secuencia del camino feliz; de estados si cambia un estado.
- [ ] Si hay notificaciones: el evento guardado, el canal, la entrega y qué pasa si falla.
- [ ] Limitaciones conocidas escritas (o "ninguna").
