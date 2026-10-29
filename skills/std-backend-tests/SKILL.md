---
name: std-backend-tests
description: Escribe y corre los tests del backend (unitarios con repositories falsos e integración contra la base de desarrollo) con el runner declarado en stack.md. Usar al crear o modificar services, endpoints, reglas RN-xx o acciones críticas, al cerrar un hito, o cuando el usuario pregunte cómo se prueba una API.
---

# Tests del backend

La norma es **`docs/standards/testing.md`**; el runner, las carpetas y los comandos están en **`docs/standards/stack.md`**. Esta skill no copia la norma: la aplica.

## Procedimiento

1. **Leer** la norma, `stack.md` (§2 carpetas de tests, §3 fakes, §4 comandos), el service o endpoint y sus `RN-xx`.
2. **Unitario (§3):** por cada regla nueva o cambiada, un test del service.
   - Usar o crear el fake del repository con la **misma firma** que el real, heredando la guardia de acciones simulada.
   - Integraciones externas: fake del Port.
   - Solo datos sintéticos (ids aleatorios, textos genéricos).
3. **Integración (§4):** el endpoint completo, con las sesiones de prueba del proyecto.
   - Comprobar el **código** de error, no solo el estado HTTP.
   - Acciones críticas: `change_reason` de 3+ caracteres, y el caso sin motivo.
   - Lo preparado con el cliente de sistema se limpia al final, aunque el test falle.
   - Integraciones: el adaptador de prueba se activa solo dentro del test, reemplazando la lectura de la configuración. Lo enviado se lee de lo que registró el adaptador.
   - Credenciales de un solo uso: uso correcto, error con intentos que quedan, agotamiento, y que ya no sirve después de usarla o revocarla.
   - Si el test pasa de 200 líneas, se extraen helpers de preparación (`_create_…`, `_latest_…`).
4. **Correr** con los comandos de `stack.md §4`: unitarios y la integración del módulo; la suite completa solo al cerrar una fase o si se tocó algo compartido.
5. **Informar** el comando y el resultado (para "Comandos ejecutados" del changelog). Si algo falla, mostrar la salida y no dar el hito por hecho.
