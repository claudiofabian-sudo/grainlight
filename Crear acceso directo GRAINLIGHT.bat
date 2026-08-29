@echo off
rem Crea/regenera el acceso directo GRAINLIGHT.lnk con el icono,
rem apuntando al lanzador. Ejecutar de nuevo si mueves la carpeta.
setlocal
set "DIR=%~dp0"
powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell;" ^
  "$lnk = $ws.CreateShortcut('%DIR%GRAINLIGHT.lnk');" ^
  "$lnk.TargetPath = '%DIR%35MM Player.bat';" ^
  "$lnk.WorkingDirectory = '%DIR%';" ^
  "$lnk.IconLocation = '%DIR%grainlight.ico';" ^
  "$lnk.Description = 'GRAINLIGHT - Project your films with an analog soul';" ^
  "$lnk.Save()"
echo Acceso directo GRAINLIGHT.lnk creado.
