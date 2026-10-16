# Normas de frontend

> **Aplica a:** `<frontend>/`. Independiente del framework: las rutas, extensiones y comandos concretos están en [stack.md](stack.md). Los ejemplos usan React + TypeScript; en otro framework se aplica la equivalencia de [stack.md §3](stack.md).
> Relacionadas: [responsive.md](responsive.md) · [design-system.md](design-system.md) · [naming.md](naming.md)

## 1. Reglas duras

- **Máximo 200 líneas por archivo** (regla del linter). Al acercarse a 150, partir en `parts/` o extraer lógica o helpers.
- **Vista sin lógica:** el archivo de vista solo tiene marcado y composición. Estado, efectos, llamadas y reglas van en su archivo de lógica (hook, composable o servicio del componente).
- **Los componentes no llaman al API directamente:** siempre `lógica del componente → service del feature → cliente HTTP único`.
- **Sin colores hardcodeados**: solo tokens del tema ([design-system.md](design-system.md)).
- **Sin montos ni fechas formateados a mano:** usar los formateadores compartidos.
- Tipado estricto: nada de `any` ni props sin tipar.
- **Las reglas de negocio no viven en el frontend:** el frontend muestra, valida forma y consulta permisos; decide el backend.

## 2. Estructura de un componente

```text
NombreComponente/
  NombreComponente.<vista>     vista (presentacional)
  useNombreComponente.<ext>    lógica propia: estado, handlers, llamadas a services
  NombreComponente.styles.<ext>  clases y variantes (si las hay)
  NombreComponente.types.<ext>   props y tipos propios
  parts/                       subcomponentes, con la misma estructura
  index.<ext>                  exporta el componente
```

- Carpeta y archivos del componente en **PascalCase**; la lógica con prefijo `use`.
- Sin estado → se omite la lógica; sin variantes → se omite `.styles`. La vista nunca absorbe esa lógica.

## 3. Dónde vive cada cosa (regla de alcance)

| Lo usa… | Lógica reutilizable | Tipos |
|---|---|---|
| un solo componente | carpeta del componente | `Componente.types` |
| 2+ componentes del mismo feature | `features/<mod>/hooks/` | `features/<mod>/types/` |
| 2+ features, o es genérico | `src/hooks/` | `src/types/` |

- Los tipos del API se **generan** desde la especificación cuando el stack lo permite.
- Cuando algo pasa a usarse en un segundo lugar, se **mueve** al nivel correspondiente. No se duplica.

## 4. Estructura de `src/`

```text
<rutas>/          solo rutas: delgadas, renderizan un componente de feature
theme/            sistema de diseño (único lugar con colores)
lib/http/         cliente HTTP (clase) y su error tipado
lib/format/       formateadores de moneda y fecha (locale desde el tema)
lib/<auth>/       cliente del proveedor de Auth
components/ui/    UI kit genérico (Button, Input, Select, Modal, DataTable, FilterMenu…)
components/       layout/, charts/ y compartidos
features/<mod>/   services/ · types/ · hooks/ · components/
hooks/  types/    compartidos entre features
```

## 5. Patrones

- **Container / Presentational:** la lógica es el contenedor; la vista es presentacional.
- **Service layer + Facade:** `features/<mod>/services/<mod>.service` expone funciones tipadas sobre el cliente HTTP.
- **Composición:** pantallas con componentes pequeños; uno con varias secciones se parte en `parts/`.
- **Estados de UI obligatorios:** cargando, vacío, error y datos.
- **Acciones críticas:** antes de guardar, un paso de **confirmación** con qué va a pasar (antes → después) y el **motivo**. El botón se muestra solo si el usuario tiene el permiso. Si el backend rechaza, la confirmación queda abierta con el error.
- **Nada se "elimina":** los botones son "Dar de baja" / "Reactivar", con confirmación y motivo.

### Filtros de listados (obligatorio)

- Arriba de la tabla: **búsqueda a la izquierda** y, **a la derecha**, un solo botón **"Filtros (n)"** que abre un panel **superpuesto** (no empuja el contenido). Se cierra con clic afuera, `Esc` o "Listo", y trae "Limpiar todo".
- Sobre la tabla, **etiquetas de filtros activos** ("Estado: Activo ×") y "Limpiar filtros".
- **Los filtros se combinan con Y**; solo la búsqueda de texto usa O entre columnas. Lo resuelve el backend.
- Cambiar un filtro vuelve a la primera página, y la exportación usa los mismos filtros.

### Formularios

- Los valores de catálogo (estados, tipos, medios, ubicaciones oficiales) se cargan **del API**, nunca de listas escritas en el componente.
- Los selectores de listas largas tienen **búsqueda**.
- Los errores del backend se muestran por campo cuando `details` lo permite; si no, arriba del formulario.

## 6. Ejemplo (React + TypeScript)

```ts
// features/projects/services/projects.service.ts
export const projectsService = {
  fetchProjectsPage: (listQuery: ListQuery) => apiClient.get<ListPage<Project>>("/projects", listQuery),
  createProject: (newProjectData: ProjectCreate) => apiClient.post<Project>("/projects", newProjectData),
}
```

```ts
// features/projects/components/ProjectsTable/useProjectsTable.ts
export function useProjectsTable() {
  const [projectTableRows, setProjectTableRows] = useState<Project[]>([])
  const [isLoadingProjects, setIsLoadingProjects] = useState(true)
  const [projectsLoadError, setProjectsLoadError] = useState<string | null>(null)
  useEffect(() => {
    projectsService
      .fetchProjectsPage({ page: 1 })
      .then((projectsPage) => setProjectTableRows(projectsPage.items))
      .catch((loadError: ApiError) => setProjectsLoadError(loadError.message))
      .finally(() => setIsLoadingProjects(false))
  }, [])
  return { projectTableRows, isLoadingProjects, projectsLoadError }
}
```

```tsx
// features/projects/components/ProjectsTable/ProjectsTable.tsx
export function ProjectsTable() {
  const { projectTableRows, isLoadingProjects } = useProjectsTable()
  if (isLoadingProjects) return <TableSkeleton />
  return <DataTable rows={projectTableRows} columns={PROJECTS_TABLE_COLUMNS} />
}
```

En Vue la vista es el `<template>` del `.vue` y la lógica un composable `useProjectsTable.ts`; en Angular, el template y un servicio del componente. La separación es la misma.

## 7. Entorno

- Las variables públicas del frontend llegan al navegador: **nunca** secretos.
- Las advertencias propias del framework (builds, caché, variables incrustadas al compilar) están en [stack.md §5](stack.md).

## 8. Checklist antes de cerrar un hito

- [ ] Se ve bien en 390, 768 y 1280 px, sin scroll horizontal ([responsive.md](responsive.md)).
- [ ] Nombres descriptivos ([naming.md](naming.md)).
- [ ] Ningún archivo supera 200 líneas; formato, lint y tipos pasan (comandos en [stack.md §4](stack.md)).
- [ ] Las vistas no tienen estado ni llamadas al API.
- [ ] Lógica y tipos ubicados según la regla de alcance.
- [ ] Sin colores, montos ni fechas formateados a mano.
- [ ] Estados de carga, vacío y error presentes.
