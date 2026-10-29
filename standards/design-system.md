# Sistema de diseño

> **Aplica a:** colores, tipografía, radios, sombras, gradientes, dark mode, charts y el UI kit (`components/ui/`). Relacionadas: [frontend.md](frontend.md) · [responsive.md](responsive.md)

## 1. Principio

**Cambiar la marca = editar solo el archivo de tema** (ruta en [stack.md §2](stack.md); por defecto `src/theme/theme.config.ts`). Ningún otro archivo define colores.

## 2. Piezas (ejemplo con Tailwind y variables CSS)

Con otra solución de estilos se mantiene la idea: una sola configuración que genera variables CSS (o tokens del framework) para claro y oscuro, y componentes que solo usan esos tokens.

```text
theme/
  theme.config.ts   ÚNICA fuente: paleta de marca (hex), tokens semánticos light/dark,
                    gradiente, sombras, radius, fuentes, locale y moneda
  color.utils.ts    funciones puras: hexToHsl, mezcla, contraste
  ThemeEngine.ts    clase: config → variables CSS (:root y .dark) + getColorToken(name, mode)
  ThemeStyle.tsx    server component: inyecta las variables en <head> desde el layout raíz
  ThemeProvider/    modo light/dark/system en el cliente (clase .dark en <html>)
  index.ts
```

- `tailwind.config` solo mapea nombres a `hsl(var(--token))`; no contiene valores.
- `globals.css` no contiene colores: solo `@tailwind`, resets y utilidades que leen variables.

## 3. Tokens

| Grupo | Tokens |
|---|---|
| Marca | `brand.*` (los colores de la marca), `gradient` |
| Superficies | `background`, `foreground`, `card`, `popover`, `muted`, `border`, `input`, `ring` |
| Acción | `primary`, `secondary`, `accent`, `destructive` (+ `*-foreground`) |
| Estado | `success`, `warning`, `info` (+ `*-foreground`) |
| Navegación | `sidebar`, `sidebar-foreground`, `sidebar-border`, `sidebar-accent` |
| Forma | `radius`, `font.sans`, `font.mono`, sombras de marca |
| Datos | `chart.1` … `chart.6` |

Los tokens semánticos se derivan de la marca (`primary: brand.<color>`), así un cambio de paleta se propaga solo.

## 4. Reglas de uso

- En componentes: clases semánticas (`bg-primary`, `text-muted-foreground`, `border-border`).
- **`*-foreground` va solo sobre su color lleno** (`bg-warning text-warning-foreground`): suele ser blanco.
  - **Sobre un fondo tenue** (`bg-warning/10`), el texto va en `text-foreground` o en el color mismo (`text-warning`), y el ícono en el color.
  - **Ejemplo de aviso legible:** `border border-warning/40 bg-warning/10 text-foreground`, con el ícono en `text-warning`.
- **Prohibido:** `#hex`, `rgb()`, `hsl(...)` literales y clases de paleta cruda o arbitraria (`bg-indigo-600`, `text-[#333]`).
- Gráficos SVG: variables en los atributos (`stroke="hsl(var(--chart-1))"`). Siguen el modo oscuro solos.
- Solo si una librería no acepta `var()`: `themeEngine.getColorToken("chart-1", resolvedColorMode)`.
- Dark mode con la clase `.dark`, gestionada por `ThemeProvider`; los tokens dark viven en la misma config.
- Efectos globales (p. ej. una sombra de marca en todas las tarjetas) se definen como token y una regla global; no se repiten en cada componente.
- Moneda y fecha: `lib/format` lee `locale` y `currency` de la config.
- Logos e imágenes de marca: se usa el archivo original (recortado si hace falta), nunca redibujado.

## 5. UI kit (`components/ui/`)

```text
Button/
  Button.tsx          vista (forwardRef si es un control)
  Button.styles.ts    buttonVariants = cva(base, { variants: { variant, size }, defaultVariants })
  Button.types.ts     ButtonProps = ButtonHTMLAttributes & VariantProps<typeof buttonVariants>
  index.ts
```

- Variantes estándar: `variant` (`primary | secondary | outline | ghost | destructive`) y `size` (`sm | md | lg`, más `icon`).
- Props booleanas con `is`/`has` (`isLoading`, `isFullWidth`); los botones usan `type="button"` por defecto.
- Compound components: `Card.Header`, `Card.Body`, `Modal.Footer`.
- Accesibles: foco visible (`ring`), `aria-*`, contraste AA.
- **El UI kit no conoce el dominio:** nada de nombres de negocio dentro de `components/ui/`.
- Componentes base recomendados: `Button`, `Input`, `Select`, `FormField`, `Card`, `Modal`, `DataTable`, `StatCard`, `FilterMenu`, `ActiveFilterChips`, `CriticalActionConfirm`.

### 5.1 `Modal`

- **Es una columna que nunca supera la pantalla** (`max-h-[calc(100dvh-2rem)]`): el título y el pie quedan siempre a la vista y **solo el cuerpo se desplaza**.
  - Un `<form>` que envuelve el cuerpo y el pie también es columna (`[&>form]:flex [&>form]:flex-col [&>form]:min-h-0`).
  - Los componentes que van adentro **no** se ponen alto propio.
- **No se abre un modal encima de otro ni se anida una confirmación adentro:** la confirmación (`CriticalActionConfirm`) se renderiza como **hermana** del modal.
- **Un sub-paso dentro del modal** (p. ej. dar de alta a una persona que falta mientras se carga un contrato):
  - se resuelve **cambiando el contenido del mismo modal**, con "← Volver";
  - al terminar, se vuelve al paso anterior con lo creado ya elegido;
  - el estado del formulario vive en un hook que sigue montado, así no se pierde lo cargado.

## 6. Checklist

- [ ] Ningún color fuera del archivo de tema (buscar `#[0-9a-f]{3,6}`, `rgb(` y `hsl(` en el frontend, salvo `theme/`).
- [ ] Al cambiar un color de marca cambian botones, navegación, gradiente y charts.
- [ ] El dark mode funciona en las pantallas tocadas.
- [ ] Los componentes del UI kit no tienen anchos fijos.
