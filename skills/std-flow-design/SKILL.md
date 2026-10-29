---
name: std-flow-design
description: Diseña y escribe los flujos funcionales del proyecto en docs/flows/ (circuitos F# y detalles de fase con estados, matriz de UI por rol, pasos función → HTTP → base, diagramas Mermaid de estados y secuencia, y limitaciones conocidas). Usar al documentar o cambiar un comportamiento, al diseñar un pedido del usuario antes de codificarlo, al actualizar un flujo en un hito, o cuando el usuario pida un flujo, un diagrama UML o "cómo funciona" una pantalla.
---

# Flujos funcionales

La norma es **[docs/standards/flows.md](../../docs/standards/flows.md)**. Esta skill no la copia: la aplica.

## Procedimiento

1. **Ubicar:** buscar el circuito en `docs/systemflowsIndex.md` y el `F#` afectado. Decidir el nivel (norma §1):
   - cambio chico → se edita el `F#` del circuito (formato corto, §2);
   - una fase con pantalla, estados o varios roles → detalle `docs/flows/NNx-<detalle>.md` (§3).
2. **Relevar del código, no de memoria** (si ya existe): el hook y la vista de la pantalla, el `service.ts` del frontend, el router y el service del backend, la migración del catálogo y sus triggers, y las reglas de negocio (`docs/business_rules.md`). Anotar las diferencias entre lo que dice la documentación y lo que hace el código.
3. **Escribir en el orden de §3:** encabezado → alcance → estados (diagrama + tabla) → entrada y carga inicial → catálogos y payloads → matriz de UI → flujos A, B, C… → secuencia → textos → recargas → archivos → limitaciones.
4. **Diagramas (§4):** `stateDiagram-v2` con los `code` del catálogo si cambia un estado; un `sequenceDiagram` del camino feliz (≤ 5 participantes); `flowchart` solo para decisiones con varias ramas.
5. **Controlar (§5 y §6):** cada paso con quién · acción · función · HTTP · efecto en la base; acciones críticas con su código y si el motivo es obligatorio; datos ficticios; limitaciones escritas; notificaciones documentadas según la regla 8 (el evento guardado, el canal y qué pasa si falla).
6. **Enlazar:** el `F#` del circuito al detalle, el detalle al `F#`, y los dos en el índice.
7. **Hito:** el flujo es documentación: **no cuenta** para el límite de 5 archivos de trabajo y va **en el mismo commit** que el código que lo cambia. Si es solo diseño, va en un hito propio, antes del código (primero la especificación).
8. **Estado:** cada flujo dice qué está **construido** y qué es **diseño**, y lista las limitaciones conocidas. Al construir algo, en ese mismo commit se actualiza la marca y se tachan o reescriben las limitaciones que se resolvieron.
