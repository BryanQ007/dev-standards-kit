@echo off
rem Punto de entrada para Windows: doble clic abre el menu de instalacion del kit.
rem Solo ejecuta los scripts de este kit (-ExecutionPolicy Bypass vale para este proceso, no cambia la configuracion).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
pause
