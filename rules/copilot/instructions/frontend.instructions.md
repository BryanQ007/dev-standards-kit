---
applyTo: "**/*.tsx,**/*.jsx,**/*.vue,**/*.svelte,**/*.css,**/*.scss"
---

# Frontend

Normas: `docs/standards/frontend.md`, `responsive.md`, `design-system.md`. Framework y comandos: `docs/standards/stack.md`. Ajustá `applyTo` a las extensiones de tu stack.

- Vista solo con marcado; estado, efectos y handlers en la lógica del componente (hook / composable / servicio); tipos y variantes aparte.
- Ningún componente llama al API directamente: `lógica → service → cliente HTTP`.
- Lógica y tipos según su alcance (componente → feature → `src/`).
- Solo tokens del tema; montos y fechas con los formateadores compartidos.
- Mobile first; tablas con scroll propio; grillas desde 1 columna.
- Estados de carga, vacío y error; acciones críticas con confirmación y motivo cuando el backend lo exige (si no, comentario opcional).
- `*-foreground` solo sobre su color lleno; sobre fondos tenues, `text-foreground` o el color (`design-system.md §4`).
- Modales: solo se desplaza el cuerpo; nunca un modal encima de otro (confirmación como hermana, sub-paso en el mismo modal con "← Volver") (`design-system.md §5.1`).
- Si el backend responde "no configurado", la pantalla lo dice y ofrece la alternativa; nunca da por hecho un envío.
- Paquetes con **pnpm** (`pnpm add`, `pnpm exec`, `pnpm dlx`), nunca npm/npx; versión con la antigüedad mínima de `stack.md` (`security.md §8`).
