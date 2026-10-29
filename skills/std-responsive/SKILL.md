---
name: std-responsive
description: Revisa y corrige que las pantallas sean responsive (mobile first, de 360 px a escritorio, sin scroll horizontal de la página). Usar al crear o modificar páginas, layouts o componentes visuales, o cuando el usuario diga que algo "no es responsive", "se sale de la pantalla" o "se ve mal en el celular".
---

# Responsive

La norma es **`docs/standards/responsive.md`**; la solución de estilos del proyecto está en **`docs/standards/stack.md §1`**. Esta skill no copia la norma: la aplica.

## Procedimiento

1. **Leer** la norma, la solución de estilos del stack y el componente o la página.
2. **Buscar** en los archivos tocados los patrones de la tabla §2 de la norma (en Tailwind: `w-[NNNpx]`, `grid-cols-2` sin base, filas sin `flex-wrap`, `p-6` sin `p-4`, textos sin `truncate`, tablas sin `overflow-x-auto`; con CSS propio: anchos fijos, media queries *max-width*, `overflow` faltante).
3. **Corregir mobile first:** el estilo base es el del celular; los breakpoints *min-width* agregan.
4. **No tocar el layout por página:** el menú en panel lateral debajo de 1024 px y su botón viven en los componentes de layout compartidos.
5. **Verificar** en 390, 768 y 1280 px según `responsive.md §3`:
   - **con navegador:** DevTools en modo dispositivo;
   - **sin navegador:** un navegador headless manejado por su protocolo de depuración. Se emula el ancho real, se espera en tiempo real y se mide `scrollWidth` contra el ancho;
   - **pantallas con datos:** se simulan las respuestas del API con datos ficticios, sin tocar datos reales;
   - **sesión:** si la pantalla necesita la de la persona y no se puede simular, decirlo: "no lo probé en la app".

   No confiar en `--screenshot` con reloj virtual, porque no espera la red. Respetar las advertencias de `stack.md §5`.
6. **Mirar las capturas**, no solo medir: contraste de avisos (`design-system.md §4`, nada de `*-foreground` sobre fondos tenues) y textos que se parten mal (códigos con `whitespace-nowrap`).
7. Cerrar con lint y tipos (`stack.md §4`) y anotar qué anchos se revisaron y con qué método.
