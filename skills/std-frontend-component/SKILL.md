---
name: std-frontend-component
description: Crea o modifica componentes, páginas, lógica de componentes, tipos y services del frontend siguiendo la norma del proyecto (vista sin lógica, lógica + service + cliente HTTP, regla de alcance, 200 líneas, tokens del tema), en el framework declarado en stack.md. Usar al tocar cualquier archivo del frontend o cuando el usuario pida una pantalla, un formulario, una tabla o un componente.
---

# Componentes y pantallas del frontend

La norma es **`docs/standards/frontend.md`** (y `design-system.md`, `responsive.md`, `naming.md`). Las tecnologías, carpetas y comandos están en **`docs/standards/stack.md`**. Esta skill no copia las normas: las aplica. Si falta `docs/standards/` o `stack.md` está sin completar, avisar y usar `std-stack-setup`.

## Procedimiento

1. **Leer** la norma, `stack.md` (§1 tecnologías, §2 carpetas, §3 equivalencias) y los componentes vecinos para imitar su forma. Revisar la spec del módulo (`docs/specs/frontend/<mod>.md`) si existe.
2. **Ubicar** cada pieza:
   - ruta delgada → renderiza un componente de `features/<mod>/components/`;
   - llamadas al API en `features/<mod>/services/` sobre el cliente HTTP único;
   - tipos y lógica reutilizable según la **regla de alcance** (componente → feature → `src/`).
3. **Separar** en la carpeta del componente: vista (solo marcado), lógica (`useX` o la equivalencia del stack), tipos, estilos si hay variantes, `parts/` si crece, `index`.
4. **Reutilizar el UI kit** (`components/ui/`). Si falta un componente genérico, crearlo ahí sin nombres de negocio.
5. **Aplicar los patrones obligatorios**:
   - estados de carga, vacío, error y datos;
   - listados con búsqueda a la izquierda y "Filtros (n)" a la derecha, etiquetas de filtros activos, paginación del servidor;
   - catálogos y ubicaciones cargados del API, con búsqueda en listas largas;
   - acciones críticas con confirmación (antes → después): "Motivo *" o "Comentario (opcional)" según lo que informe el backend para esa acción. Nada se "elimina": "Dar de baja" / "Reactivar";
   - botones según los permisos que informa el backend;
   - modales: columna en la que solo se desplaza el cuerpo. No se abre un modal encima de otro: la confirmación va como **hermana**, y un sub-paso (crear lo que falta) cambia el contenido del mismo modal y vuelve con lo creado elegido, sin perder lo cargado (`design-system.md §5.1`);
   - integraciones: si el backend responde "no configurado", la pantalla lo dice con su alternativa (p. ej. copiar) y nunca da por hecho un envío;
   - páginas públicas (sin sesión): fuera de las rutas protegidas, `noindex`, sin *referrer*, con estados "no disponible", "listo" y error.
6. **Estilo:** solo tokens del tema (y `*-foreground` solo sobre su color lleno); montos y fechas con los formateadores compartidos; mobile first (`std-responsive`).
7. **Nombres** descriptivos: `handleSubmitXForm`, `isLoadingX`, `selectedXId`, `fetchXList`.
8. **Verificar** con los comandos de `stack.md §4` (formato, lint, tipos) sobre los archivos tocados; ningún archivo > 200 líneas. Respetar las advertencias de `stack.md §5`.
9. **Informar** archivos tocados, comandos corridos con su resultado y cómo probarlo en pantalla.
