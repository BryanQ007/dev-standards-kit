# Responsive (obligatorio)

> **Aplica a:** toda pantalla, layout y componente visual del frontend. Relacionadas: [frontend.md](frontend.md) · [design-system.md](design-system.md)

Toda pantalla funciona **desde 360 px** (celular) hasta escritorio, **sin scroll horizontal de la página**.

> Las clases de ejemplo son de Tailwind. Con otra solución de estilos se aplican los mismos breakpoints (640 / 768 / 1024 / 1280 px) y las mismas reglas con media queries *min-width*.

## 1. Reglas

- **Mobile first:** las clases sin prefijo son para celular; `sm:` (640), `md:` (768), `lg:` (1024) y `xl:` (1280) **agregan**. Nunca al revés.
- **Layout de la app:**
  - Desde `lg`, el menú lateral es fijo (p. ej. 240 px, colapsable a 64 px).
  - Debajo de `lg` se oculta y se abre como **panel lateral** desde un botón de menú en la barra superior.
  - El panel se cierra al navegar, al tocar el fondo o con `Esc`.
  - Se usa `h-dvh` y `min-w-0` en el contenedor principal para que el contenido no empuje el ancho.
- **Anchos:** nada de anchos fijos mayores a 320 px sin prefijo de breakpoint (`w-[400px]` → `w-full max-w-[400px]`). Imágenes con `h-auto max-w-full`.
- **Grillas:** arrancan en 1 columna y crecen (`grid-cols-1 sm:grid-cols-2 lg:grid-cols-4`).
- **Filas de controles:** `flex-wrap`, o pasan a columna (`flex-col sm:flex-row`).
- **Espaciado:** contenido de página `p-4 sm:p-6`; barra superior `px-4 sm:px-6`.
- **Textos:** títulos y celdas largas con `truncate` o `min-w-0`; textos secundarios de la barra superior ocultos en celular (`hidden sm:block`).
- **Tablas:** dentro de un contenedor `overflow-x-auto`; las celdas no se parten (`whitespace-nowrap`). El scroll horizontal queda dentro de la tabla, nunca en la página.
- **Tarjetas con montos:** texto y padding más chicos en celular y corte de línea permitido; nunca se desbordan.
- **Listas largas dentro de tarjetas:** scroll interno con alto máximo, y la cantidad de registros junto al título.
- **Pestañas o barras fijas:** van justo debajo de la barra superior, fuera del área que scrollea, con su propio padding inferior; nada se ve por encima ni por debajo al hacer scroll.
- **Táctil:** botones e íconos clicables de al menos 40 × 40 px.
- **UI kit:** sus componentes se adaptan al ancho del contenedor; nunca anchos fijos.

## 2. Patrones que rompen el celular (buscar en cada cambio)

| Patrón | Corrección |
|---|---|
| `w-[NNNpx]`, `w-80`, `w-96`, `min-w-[…]` sin prefijo | `w-full max-w-[…]` o con prefijo `sm:` |
| `grid-cols-2` (o más) sin base de 1 columna | `grid-cols-1 sm:grid-cols-2` |
| Fila de controles sin `flex-wrap` | `flex-wrap` o `flex-col sm:flex-row` |
| `p-6` / `px-6` fijo | `p-4 sm:p-6` |
| Título o celda larga sin `truncate` / `min-w-0` | agregar |
| Tabla fuera de `overflow-x-auto` | envolver |

## 3. Verificación

Cada pantalla tocada se revisa en **390 px**, **768 px** y **1280 px**:

- Con el servidor de desarrollo, en DevTools → modo dispositivo.
- **Sin navegador a mano:** se maneja un navegador headless por su **protocolo de depuración** (Chrome DevTools Protocol, desde un script o con Playwright/Puppeteer). Se emula el ancho real (`Emulation.setDeviceMetricsOverride`, con `mobile` en los anchos chicos), se espera en **tiempo real** y se captura. En la misma corrida se mide `document.documentElement.scrollWidth`: si es mayor que el ancho, hay scroll horizontal.
- **Trampas conocidas:**
  - La captura simple con `--screenshot` y `--virtual-time-budget` **no espera la red**: la página queda en "cargando".
  - Las ventanas headless no bajan de ~500 px, así que una captura de "390 px" sale recortada.
  - El `<iframe>` sirve solo para páginas estáticas.
- **Pantallas con datos:** las respuestas del backend se **simulan en el navegador** (`Fetch.enable` + `Fetch.fulfillRequest`) con datos ficticios, así se revisan todos los estados sin tocar datos reales.
- **Pantallas públicas** (sin sesión): se revisan también contra el backend real con un token inventado, para ver el estado "no disponible".
- El hito anota en el changelog qué anchos se revisaron.

## 4. Checklist

- [ ] Sin scroll horizontal de la página en 390, 768 y 1280 px.
- [ ] Ningún patrón de la tabla §2 en los archivos tocados.
- [ ] Botones e íconos con área táctil ≥ 40 px.
- [ ] Menú lateral en panel debajo de `lg`.
