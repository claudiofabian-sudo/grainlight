@echo off
setlocal
set "DIR=%~dp0"
set "MPV=%DIR%mpv\mpv.exe"

if not exist "%MPV%" (
    echo.
    echo  [35MM] No se encontro el motor de reproduccion.
    echo  Falta el archivo:  mpv\mpv.exe
    echo  Lee el README.md para instalarlo.
    echo.
    pause
    exit /b 1
)

if not "%~1"=="" (
    start "" "%MPV%" %*
    exit /b 0
)

for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command ^
  "Add-Type -AssemblyName System.Windows.Forms;" ^
  "$d = New-Object System.Windows.Forms.OpenFileDialog;" ^
  "$d.Filter = 'Peliculas (remux)|*.mkv;*.mp4;*.m2ts;*.ts;*.mov;*.avi|Todos los archivos|*.*';" ^
  "$d.Title = '35MM Emulator - Abrir pelicula';" ^
  "if ($d.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $d.FileName }"`) do set "FILE=%%F"

if not defined FILE exit /b 0
start "" "%MPV%" "%FILE%"
