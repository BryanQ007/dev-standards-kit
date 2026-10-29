<#
Menú interactivo del kit: pregunta qué instalar y llama a scripts\install.ps1 con esas opciones.
Primero muestra la simulación y recién instala si se confirma. No usa red ni privilegios.
Uso: .\install.ps1 (o doble clic en install.cmd) en la raíz del kit, o .\scripts\menu.ps1
#>
$ErrorActionPreference = "Stop"
$KitDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Installer = Join-Path $KitDir "scripts\install.ps1"
$KitVersion = (Get-Content (Join-Path $KitDir "VERSION") -ErrorAction SilentlyContinue | Select-Object -First 1)
$AllTools = @("agents", "claude", "cursor", "copilot", "windsurf", "cline", "gemini")
$SkillNames = @(Get-ChildItem -Path (Join-Path $KitDir "skills") -Directory | ForEach-Object { $_.Name })
$StackNames = @(Get-ChildItem -Path (Join-Path $KitDir "profiles") -Filter "*.md" -File | ForEach-Object { $_.BaseName })

function Show-Title([string]$Subtitle) {
  Write-Host ""
  Write-Host "=================================================="
  Write-Host "  dev-standards-kit $KitVersion · $Subtitle"
  Write-Host "=================================================="
}

function Read-Answer([string]$Question, [string]$DefaultValue) {
  $Prompt = if ($DefaultValue -ne "") { "$Question [$DefaultValue]" } else { $Question }
  $TypedAnswer = Read-Host $Prompt
  if ([string]::IsNullOrWhiteSpace($TypedAnswer)) { return $DefaultValue }
  return $TypedAnswer.Trim()
}

function Get-SkillSummary([string]$SkillName) {
  $DescriptionLine = Get-Content (Join-Path $KitDir "skills\$SkillName\SKILL.md") | Where-Object { $_ -like "description: *" } | Select-Object -First 1
  $FirstSentence = ($DescriptionLine -replace "^description: ", "") -replace "\. .*$", ""
  if ($FirstSentence.Length -gt 95) { $FirstSentence = $FirstSentence.Substring(0, 95) }
  return $FirstSentence
}

function Show-Skills {
  Show-Title "skills (procedimientos)"
  for ($SkillIndex = 0; $SkillIndex -lt $SkillNames.Count; $SkillIndex++) {
    Write-Host ("  {0,2}. {1,-24} {2}" -f ($SkillIndex + 1), $SkillNames[$SkillIndex], (Get-SkillSummary $SkillNames[$SkillIndex]))
  }
}

function Show-Stacks {
  Show-Title "perfiles de stack"
  for ($StackIndex = 0; $StackIndex -lt $StackNames.Count; $StackIndex++) {
    Write-Host ("  {0}. {1}" -f ($StackIndex + 1), $StackNames[$StackIndex])
  }
}

function Select-FromList([string[]]$Items, [string]$TypedNumbers) {
  $PickedItems = @()
  foreach ($TypedNumber in ($TypedNumbers -split "[ ,]+")) {
    $ParsedNumber = 0
    if ([int]::TryParse($TypedNumber, [ref]$ParsedNumber) -and $ParsedNumber -ge 1 -and $ParsedNumber -le $Items.Count) {
      $PickedItems += $Items[$ParsedNumber - 1]
    }
  }
  return $PickedItems
}

function Read-TargetFolder {
  while ($true) {
    $TypedFolder = Read-Answer "Ruta del proyecto (carpeta existente)" ""
    if ($TypedFolder -ne "" -and (Test-Path $TypedFolder -PathType Container)) { Show-GitLinkWarning $TypedFolder; return $TypedFolder }
    Write-Host "  No existe esa carpeta. Probá de nuevo (o Ctrl+C para salir)."
  }
}

function Show-GitLinkWarning([string]$TargetFolder) {
  # Solo avisa: el instalador nunca copia .git, pero el kit no tiene que subirse con el proyecto.
  $TargetPath = (Resolve-Path $TargetFolder).Path.TrimEnd('\') + '\'
  if (($KitDir.TrimEnd('\') + '\').StartsWith($TargetPath, [System.StringComparison]::OrdinalIgnoreCase)) {
    & git -C $TargetPath check-ignore -q $KitDir 2>$null
    if ($LASTEXITCODE -ne 0) {
      Write-Host "  ⚠ El kit está DENTRO del proyecto y git no lo ignora: se subiría con el proyecto."
      Write-Host "    Agregá su carpeta al .gitignore del proyecto, o mové el kit afuera (README, 'Dónde poner el kit')."
    }
  }
  if (Test-Path (Join-Path $KitDir ".git")) {
    Write-Host "  ⓘ El kit tiene su propio .git (conectado a su repositorio). Lo instalado son copias sin vínculo;"
    Write-Host "    si no vas a modificar el kit, podés desconectarlo borrando $KitDir\.git."
  }
}

function Read-StackChoice {
  Show-Stacks
  Write-Host "  0. Plantilla en blanco (completar stack.md después)"
  $TypedStack = Read-Answer "Elegí el stack" "0"
  if ($TypedStack -eq "0") { return "" }
  $PickedStacks = @(Select-FromList $StackNames $TypedStack)
  if ($PickedStacks.Count -eq 0) { Write-Host "  Opción no válida: plantilla en blanco."; return "" }
  return $PickedStacks[0]
}

function Read-SkillsChoice {
  Show-Skills
  $TypedSkills = Read-Answer "Números de las skills, separados por espacio (o 'todas')" "todas"
  if ($TypedSkills -eq "todas") { return @("all") }
  $PickedSkills = @(Select-FromList $SkillNames $TypedSkills)
  if ($PickedSkills.Count -eq 0) { Write-Host "  Ninguna válida: se instalan todas."; return @("all") }
  return $PickedSkills
}

function Read-ToolsChoice {
  Show-Title "herramientas"
  for ($ToolIndex = 0; $ToolIndex -lt $AllTools.Count; $ToolIndex++) { Write-Host ("  {0}. {1}" -f ($ToolIndex + 1), $AllTools[$ToolIndex]) }
  Write-Host "  Las normas y los procedimientos se instalan siempre, uses la herramienta que uses."
  $TypedTools = Read-Answer "Números de las herramientas, separados por espacio ('todas' o 'ninguna')" "todas"
  if ($TypedTools -eq "todas") { return @("all") }
  if ($TypedTools -eq "ninguna") { return @("none") }
  $PickedTools = @(Select-FromList $AllTools $TypedTools)
  if ($PickedTools.Count -eq 0) { Write-Host "  Ninguna válida: se instalan todas."; return @("all") }
  return $PickedTools
}

function Invoke-Installation([string]$TargetFolder, [string]$StackName, [string[]]$Skills, [string[]]$Tools, [bool]$IsAdopt) {
  Show-Title "resumen"
  Write-Host "  Proyecto:     $TargetFolder"
  Write-Host ("  Stack:        " + $(if ($StackName -ne "") { $StackName } else { "plantilla en blanco" }))
  Write-Host ("  Skills:       " + ($Skills -join ","))
  Write-Host ("  Herramientas: " + ($Tools -join ","))
  if ($IsAdopt) { Write-Host "  Modo:         adopción (no pisa nada)" }
  $InstallerArguments = @{ Target = $TargetFolder; Skills = $Skills; Tools = $Tools }
  if ($StackName -ne "") { $InstallerArguments.Stack = $StackName }
  if ($IsAdopt) { $InstallerArguments.Adopt = $true }
  Write-Host ""
  Write-Host "SIMULACIÓN: esto es lo que se copiaría."
  & $Installer @InstallerArguments
  Write-Host ""
  $Confirmation = Read-Answer "¿Instalar ahora? (s/N)" "N"
  if ($Confirmation -match '^(s|si|sí)$') {
    & $Installer @InstallerArguments -Apply
    Write-Host ""
    Write-Host "Siguiente paso: revisá lo copiado con 'git diff' en el proyecto y seguí el README del kit (Tutoriales 1 a 4)."
  } else {
    Write-Host "No se instaló nada."
  }
}

while ($true) {
  Show-Title "instalador"
  Write-Host "  1. Instalar todo el kit (normas, todas las skills y las reglas de todas las herramientas)"
  Write-Host "  2. Instalar eligiendo skills y herramientas"
  Write-Host "  3. Adoptar el estándar en un proyecto ya creado (no pisa nada, deja el informe)"
  Write-Host "  4. Ver qué hace cada skill"
  Write-Host "  5. Ver los perfiles de stack"
  Write-Host "  0. Salir"
  switch (Read-Answer "Opción" "1") {
    "1" { $Folder = Read-TargetFolder; $StackName = Read-StackChoice; Invoke-Installation $Folder $StackName @("all") @("all") $false }
    "2" {
      $Folder = Read-TargetFolder; $StackName = Read-StackChoice; $Skills = Read-SkillsChoice; $Tools = Read-ToolsChoice
      Invoke-Installation $Folder $StackName $Skills $Tools $false
    }
    "3" { $Folder = Read-TargetFolder; $StackName = Read-StackChoice; $Tools = Read-ToolsChoice; Invoke-Installation $Folder $StackName @("all") $Tools $true }
    "4" { Show-Skills }
    "5" { Show-Stacks }
    { $_ -in @("0", "q", "salir") } { Write-Host "Listo."; exit 0 }
    default { Write-Host "  Opción no válida." }
  }
}
