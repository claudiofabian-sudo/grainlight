@echo off
title GRAINLIGHT - Remotion Studio
cd /d "%~dp0"
echo.
echo  Abriendo Remotion Studio...
echo  Se abrira en tu navegador. Para cerrarlo, cierra esta ventana.
echo.
if not exist "node_modules" (
    echo  Primera vez: instalando dependencias, esto tarda un par de minutos...
    call npm install --no-audit --no-fund
)
call npx remotion studio
pause
