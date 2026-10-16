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
- Estados de carga, vacío y error; acciones críticas con confirmación y motivo.
