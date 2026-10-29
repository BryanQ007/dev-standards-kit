<#
Instala el kit de normas en un proyecto: copia archivos de texto, nada más.
Seguro por diseño: sin red, sin privilegios, no ejecuta lo que copia, simulación por defecto,
no sobrescribe (salvo -Force, que deja un respaldo .bak).

Uso (PowerShell 5.1 o 7):
  .\scripts\install.ps1 -Target ..\mi-proyecto                          # simulación
  .\scripts\install.ps1 -Target ..\mi-proyecto -Apply                   # copia
  .\scripts\install.ps1 -Target ..\mi-proyecto -Tools claude,cursor -Apply
  .\scripts\install.ps1 -Target ..\mi-proyecto -Stack nextjs-fastapi-postgres -Apply   # stack.md desde un perfil
  .\scripts\install.ps1 -ListStacks                                     # perfiles disponibles
  .\scripts\install.ps1 -PersonalSkills -Apply                          # skills en ~\.claude\skills
  .\scripts\install.ps1 -Target ..\proyecto-existente -Adopt -Apply    # proyecto ya creado: no pisa nada,
                                                                        # deja docs\adoption_report.md y los pasos
  .\scripts\install.ps1 -Target ..\mi-proyecto -Skills std-milestone,std-code-review -Apply
  .\scripts\install.ps1 -ListSkills                                     # skills disponibles
Menú interactivo: .\install.ps1 (o doble clic en install.cmd) en la raíz del kit.
Herramientas: claude, cursor, copilot, windsurf, cline, agents, gemini (por defecto: all). Skills: por defecto all.
Sin -Stack, docs\standards\stack.md queda como plantilla para completar (skill std-stack-setup).
Si la política de ejecución lo bloquea: powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 ...
#>
param(
  [string]$Target = "",
  [string[]]$Tools = @("all"),
  [string[]]$Skills = @("all"),
  [string]$Stack = "",
  [switch]$ListStacks,
  [switch]$ListSkills,
  [switch]$Apply,
  [switch]$Force,
  [switch]$PersonalSkills,
  [switch]$Adopt
)
$ErrorActionPreference = "Stop"
$KitDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SelectedTools = @($Tools | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim().ToLower() })
$AvailableStacks = @(Get-ChildItem -Path (Join-Path $KitDir "profiles") -Filter "*.md" -File | ForEach-Object { $_.BaseName })

$SelectedSkills = @($Skills | ForEach-Object { $_ -split "," } | ForEach-Object { $_.Trim().ToLower() })
$AvailableSkills = @(Get-ChildItem -Path (Join-Path $KitDir "skills") -Directory | ForEach-Object { $_.Name })

if ($ListStacks) { $AvailableStacks; exit 0 }
if ($ListSkills) { $AvailableSkills; exit 0 }
foreach ($SkillName in $SelectedSkills) {
  if ($SkillName -eq "all") { continue }
  if ($SkillName -notmatch '^[a-z0-9-]+$') { Write-Error "Nombre de skill inválido: $SkillName" }
  if ($AvailableSkills -notcontains $SkillName) { Write-Error "No existe la skill '$SkillName' (ver -ListSkills)." }
}
if ($Adopt -and $Force) { Write-Error "-Adopt no se combina con -Force: en un proyecto existente no se pisa nada." }
if ($Stack -ne "") {
  if ($Stack -notmatch '^[a-z0-9-]+$') { Write-Error "Nombre de perfil inválido: $Stack" }
  if ($AvailableStacks -notcontains $Stack) {
    Write-Error "No existe el perfil '$Stack'. Disponibles: $($AvailableStacks -join ', ')"
  }
}

function Test-ToolSelected([string]$ToolName) {
  return ($SelectedTools -contains "all") -or ($SelectedTools -contains $ToolName)
}

function Copy-KitFile([string]$RelativeSource, [string]$DestinationFile) {
  $SourceFile = Join-Path $KitDir $RelativeSource
  if (-not (Test-Path $SourceFile -PathType Leaf)) { Write-Warning "falta en el kit: $RelativeSource"; return }
  $DestinationExists = Test-Path $DestinationFile
  if ($DestinationExists -and -not $Force) {
    $ForceHint = if ($Adopt) { "" } else { " o usá -Force" }
    Write-Output "  = ya existe, no se toca: $DestinationFile (combinalo a mano$ForceHint)"; return
  }
  if (-not $Apply) { Write-Output "  + copiaría: $RelativeSource -> $DestinationFile"; return }
  $DestinationFolder = Split-Path $DestinationFile -Parent
  New-Item -ItemType Directory -Force -Path $DestinationFolder | Out-Null
  if ($DestinationExists) {
    Copy-Item $DestinationFile "$DestinationFile.bak" -Force
    Write-Output "  ~ respaldo: $DestinationFile.bak"
  }
  Copy-Item $SourceFile $DestinationFile -Force
  Write-Output "  + copiado: $DestinationFile"
}

function Copy-KitFolder([string]$RelativeFolder, [string]$DestinationFolder) {
  Get-ChildItem -Path (Join-Path $KitDir $RelativeFolder) -File | ForEach-Object {
    Copy-KitFile (Join-Path $RelativeFolder $_.Name) (Join-Path $DestinationFolder $_.Name)
  }
}

function Copy-StandardsInto([string]$StandardsFolder) {
  Get-ChildItem -Path (Join-Path $KitDir "standards") -File | ForEach-Object {
    if ($_.Name -eq "stack.md" -and $Stack -ne "") {
      Copy-KitFile (Join-Path "profiles" "$Stack.md") (Join-Path $StandardsFolder "stack.md")
    } else {
      Copy-KitFile (Join-Path "standards" $_.Name) (Join-Path $StandardsFolder $_.Name)
    }
  }
}

function Copy-SkillsInto([string]$SkillsFolder) {
  Get-ChildItem -Path (Join-Path $KitDir "skills") -Directory | ForEach-Object {
    if (-not (($SelectedSkills -contains "all") -or ($SelectedSkills -contains $_.Name))) { return }
    Copy-KitFile (Join-Path "skills" (Join-Path $_.Name "SKILL.md")) (Join-Path $SkillsFolder (Join-Path $_.Name "SKILL.md"))
  }
}

if (-not $Apply) { Write-Output "SIMULACIÓN (no se copia nada). Agregá -Apply para instalar." }

if ($PersonalSkills) {
  $PersonalSkillsFolder = Join-Path $HOME ".claude\skills"
  Write-Output "Skills personales de Claude Code -> $PersonalSkillsFolder"
  Copy-SkillsInto $PersonalSkillsFolder
  if ($Target -eq "") { exit 0 }
}

if ($Target -eq "" -or -not (Test-Path $Target -PathType Container)) {
  Write-Error "Indicá un proyecto existente con -Target <carpeta>."
}
$TargetDir = (Resolve-Path $Target).Path
if ($TargetDir -eq $KitDir) { Write-Error "El destino no puede ser el propio kit." }
Write-Output "Proyecto: $TargetDir"

$StackLabel = if ($Stack -ne "") { $Stack } else { "plantilla para completar" }
Write-Output "Normas -> docs\standards\ (stack: $StackLabel)"
Copy-StandardsInto (Join-Path $TargetDir "docs\standards")
# Procedimientos neutrales: cualquier asistente (o persona) los lee desde ahí, use la herramienta que use.
Write-Output "Procedimientos (skills) -> docs\standards\skills\"
Copy-SkillsInto (Join-Path $TargetDir "docs\standards\skills")

if (Test-ToolSelected "claude") {
  Write-Output "Claude Code"
  Copy-KitFile "rules\claude\CLAUDE.md" (Join-Path $TargetDir "CLAUDE.md")
  if (-not $PersonalSkills) { Copy-SkillsInto (Join-Path $TargetDir ".claude\skills") }
}
if (Test-ToolSelected "agents") {
  Write-Output "AGENTS.md (Codex, Cursor, Jules, Zed, Aider...)"
  Copy-KitFile "rules\agents\AGENTS.md" (Join-Path $TargetDir "AGENTS.md")
}
if (Test-ToolSelected "cursor") { Write-Output "Cursor"; Copy-KitFolder "rules\cursor\rules" (Join-Path $TargetDir ".cursor\rules") }
if (Test-ToolSelected "copilot") {
  Write-Output "GitHub Copilot"
  Copy-KitFile "rules\copilot\copilot-instructions.md" (Join-Path $TargetDir ".github\copilot-instructions.md")
  Copy-KitFolder "rules\copilot\instructions" (Join-Path $TargetDir ".github\instructions")
}
if (Test-ToolSelected "windsurf") { Write-Output "Windsurf"; Copy-KitFolder "rules\windsurf\rules" (Join-Path $TargetDir ".windsurf\rules") }
if (Test-ToolSelected "cline") { Write-Output "Cline"; Copy-KitFolder "rules\cline" (Join-Path $TargetDir ".clinerules") }
if (Test-ToolSelected "gemini") {
  Write-Output "Gemini CLI"
  Copy-KitFile "rules\gemini\GEMINI.md" (Join-Path $TargetDir "GEMINI.md")
  if (-not (Test-ToolSelected "agents")) { Write-Warning "GEMINI.md apunta a AGENTS.md: instalá también 'agents'." }
}

if ($Adopt) {
  Write-Output "Adopción en un proyecto existente"
  Copy-KitFile "templates\adoption_report.md" (Join-Path $TargetDir "docs\adoption_report.md")
  Write-Output @"
Próximos pasos (proyecto existente):
  1. Combiná a mano los archivos marcados "ya existe, no se toca".
  2. Completá docs\standards\stack.md con lo que usa el proyecto (procedimiento std-stack-setup).
  3. Corré la auditoría de solo lectura: docs\standards\skills\std-project-adoption\SKILL.md
     (o pedile a tu asistente "auditá el proyecto con std-project-adoption"). Llena docs\adoption_report.md.
  4. Corregí primero lo urgente del informe; después aprobá el plan de adaptación que se agrega a docs\plan.md.
  5. Ejecutá el plan de a un hito por vez (std-milestone y std-commit-handoff).
"@
}

if ($Stack -eq "") { Write-Output "Pendiente: completá docs\standards\stack.md (a mano o con la skill std-stack-setup)." }
Write-Output "Listo. Revisá los archivos copiados y commitealos en el proyecto si corresponde."
