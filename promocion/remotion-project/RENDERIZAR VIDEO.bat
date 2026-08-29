@echo off
title GRAINLIGHT - Renderizar
cd /d "%~dp0"
echo.
echo  Renderizando GRAINLIGHT-promo.mp4  (unos 4 minutos)
echo.
if not exist "node_modules" (
    echo  Primera vez: instalando dependencias...
    call npm install --no-audit --no-fund
)
call npx remotion render GrainlightPromo "out\GRAINLIGHT-promo.mp4" --browser-executable="C:\Program Files\Google\Chrome\Application\chrome.exe"
echo.
if exist "out\GRAINLIGHT-promo.mp4" (
    echo  Listo: out\GRAINLIGHT-promo.mp4
    echo  Copialo a la carpeta promocion cuando quieras.
) else (
    echo  Algo fallo. Revisa los mensajes de arriba.
)
pause
