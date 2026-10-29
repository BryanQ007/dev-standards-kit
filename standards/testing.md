# Normas de tests

> **Aplica a:** los tests del backend y la verificación de cada hito (backend, base y frontend). El runner, las carpetas y los comandos están en [stack.md](stack.md); los ejemplos usan Python.

## 1. Niveles

| Nivel | Qué prueba | Contra qué | Dónde |
|---|---|---|---|
| **Unitario** | Las reglas de un service, aisladas | Repositories **falsos** en memoria, sin red | `tests/unit/` |
| **Integración (API)** | Endpoint completo: router → service → repository → DAO → base, con RLS, triggers y permisos reales | Base de desarrollo | `tests/` |
| **Base de datos** | Migraciones, triggers, funciones y RLS | Postgres descartable | scripts fuera del repo |
| **Frontend** | Formato, lint y tipos (y tests de componentes si existen) | herramientas de [stack.md §4](stack.md) | `<frontend>/` |

Unitario e integración **se complementan y no se reemplazan**: el unitario cubre cada rama rápido; el de integración demuestra la regla de punta a punta con la seguridad de la base.

## 2. Qué se prueba en cada módulo

- **Caso feliz** de cada endpoint o método del service.
- **Cada regla `RN-xx`:** un caso que la cumple y otro que la viola, comprobando el **código de error**, no solo el estado HTTP.
- **Aislamiento entre organizaciones:** lo de otra organización responde 404.
- **Acciones críticas:** sin permiso → 403 `action_not_allowed`; sin motivo (o con menos de 3 caracteres) → 400 `reason_required`, antes que cualquier otra regla; con motivo → queda en la actividad.
- **Bajas lógicas:** `DELETE` responde 405 y la baja deja `is_active = false`.

## 3. Tests unitarios con repositories falsos

```text
tests/unit/
  fakes/
    fake_app_action_guard.py          guardia de acciones simulada: base común de los fakes
    fake_organization_context.py      contexto de sesión (organización, rol, ámbito)
    fake_<modulo>_repository.py       uno por repository real; hereda de la guardia
  test_<modulo>_service.py
```

(Rutas de ejemplo; las del proyecto están en [stack.md §2](stack.md).)

Reglas de los fakes:
1. **Misma interfaz:** solo los métodos que usa el service, **con el mismo nombre y firma** que el real. Si el real cambia, el fake cambia en el mismo hito.
2. **Estado en memoria:** un `dict` por tabla, cargado por el test.
3. **Registran lo pedido** (cambios, motivos) para comprobarlo con `assert`.
4. **Permisos simulados igual que los reales:** código fuera del catálogo → `ValueError`; acción no permitida → `ForbiddenError(code="action_not_allowed")`; crítica con motivo corto → `ValidationError(code="reason_required")`; devuelve el motivo sin espacios.
5. **Datos sintéticos, nunca personales:** `uuid4()`, textos genéricos ("Registro de prueba", "Motivo de prueba"); nunca nombres, documentos, correos ni teléfonos, aunque parezcan ficticios.
6. **Sin lógica de negocio:** el fake guarda y devuelve. Lo que vive en un trigger se prueba en integración.
7. Integraciones externas (almacenamiento, PDF, OCR, proveedores): fakes del **Port**, nunca del SDK.

## 4. Tests de integración

- Cliente HTTP de pruebas sobre la app creada por la App Factory, en memoria (p. ej. `httpx.AsyncClient` + `ASGITransport` en FastAPI, `supertest` en NestJS, `APIClient` en DRF).
- Sesiones por fixture que **registran una organización con el registro real del sistema**, inician sesión y se borran al terminar.
- Los datos se crean **por la API**, como un usuario. El cliente de sistema solo prepara lo que la API todavía no permite crear, y se limpia en un `finally`.
- Configuraciones que cambian el comportamiento (planes, límites, flags) se fijan en una fixture para que el resultado no dependa del `.env`.
- **Integraciones en un test de punta a punta:**
  - el adaptador de prueba se activa **solo durante ese test** (reemplazando la lectura de la configuración), nunca en el `.env`;
  - lo que "se envió" (p. ej. un código) se lee de lo que registró el adaptador;
  - el test también prueba el camino "no configurado".
- **Flujos con credenciales de un solo uso** (enlaces, códigos): se prueba el uso correcto, el error (intentos que quedan), el agotamiento y que el enlace **ya no sirve** después de usarlo o revocarlo.
- **Ante un 500 o un dato que falta en una prueba contra el entorno real:** primero se mira qué hay en la base (solo lectura) y qué versión de migración tiene, antes de tocar código.

## 5. Nombres y forma

- Archivo: según la convención del runner ([stack.md §2](stack.md)); un archivo por módulo y nivel.
- Test: `test_<qué>_<condición>` (o `it("<qué> <condición>")`) en el idioma del equipo (`test_baja_sin_motivo_responde_reason_required`). Nada de `test_1` ni `test_ok`.
- Estructura **preparar → ejecutar → comprobar**, con variables descriptivas (`deactivate_response`, nunca `res`).
- Ningún archivo de tests supera 200 líneas.

## 6. Cómo se corren

Con los comandos de [stack.md §4](stack.md): unitarios, integración de un módulo, suite completa, lint y límite de líneas. Si el proyecto corre en contenedores, los comandos se ejecutan dentro del contenedor del backend.

## 7. En cada hito

- Se corren los **unitarios** y la **integración del módulo tocado**; el changelog los anota en "Comandos ejecutados" con el resultado.
- La **suite completa** al cerrar una fase o si se tocó algo compartido (`shared/`, `conftest.py`, migraciones).
- Si un test falla, se informa con su salida y el hito **no** se marca como hecho.

## 8. Checklist

- [ ] Cada `RN-xx` nueva o cambiada tiene test unitario y al menos un caso de integración.
- [ ] Las acciones críticas tienen el caso sin motivo.
- [ ] Los fakes tienen la misma firma que el real y solo datos sintéticos.
- [ ] Sin credenciales, datos personales ni valores del `.env` en los tests.
- [ ] Lint, límite de líneas y tests pasan ([stack.md §4](stack.md)).
