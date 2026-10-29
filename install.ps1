<#
Punto de entrada del kit: abre el menú de instalación.
Uso, después de clonar o descargar el kit: .\install.ps1 (o doble clic en install.cmd)
Sin menú (para scripts o CI): .\scripts\install.ps1 -Target ... (ver Get-Help .\scripts\install.ps1)
#>
& (Join-Path $PSScriptRoot "scripts\menu.ps1")
