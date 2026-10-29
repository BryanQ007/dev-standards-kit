#!/usr/bin/env sh
# Punto de entrada del kit: abre el menú de instalación.
# Uso, después de clonar o descargar el kit: sh install.sh
# Sin menú (para scripts o CI): sh scripts/install.sh --help
exec sh "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/scripts/menu.sh" "$@"
