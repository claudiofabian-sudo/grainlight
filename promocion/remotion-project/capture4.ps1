$ErrorActionPreference = "Stop"
$mpv  = "C:\Users\pinof\OneDrive\Escritorio\35MM emulator\mpv\mpv.exe"
$mpvc = "C:\Users\pinof\OneDrive\Escritorio\35MM emulator\mpv\mpv.com"
$src  = "C:\glpromo\srcclips"
$pub  = "C:\glpromo\public"
$S = "~~/shaders/"

# La ventana siempre 1920x1080; el contenido se recorta al codificar.
#   wave     : IMAX 1.78 -> llena el cuadro, sin recorte
#   hobbit40 : scope 1920x804 -> banda de 138
#   dragon   : 2.00  1920x960 -> banda de 60
$jobs = @(
    @{ o = "wave-clean";  i = "wave";     n = 200; sh = "";                             crop = "" },
    @{ o = "wave-grain";  i = "wave";     n = 200; sh = "$($S)35mm-4-equilibrado.glsl";  crop = "" },
    @{ o = "hob-clean";   i = "hobbit40"; n = 176; sh = "";                             crop = "crop=1920:804:0:138" },
    @{ o = "hob-grain";   i = "hobbit40"; n = 176; sh = "$($S)35mm-4-equilibrado.glsl";  crop = "crop=1920:804:0:138" },
    @{ o = "dra-p0";      i = "dragon";   n = 132; sh = "";                             crop = "crop=1920:960:0:60" },
    @{ o = "dra-p1";      i = "dragon";   n = 132; sh = "$($S)35mm-1-sutil.glsl";        crop = "crop=1920:960:0:60" },
    @{ o = "dra-p2";      i = "dragon";   n = 132; sh = "$($S)35mm-2-cine2000.glsl";     crop = "crop=1920:960:0:60" },
    @{ o = "dra-p3";      i = "dragon";   n = 132; sh = "$($S)35mm-3-veterana.glsl";     crop = "crop=1920:960:0:60" },
    @{ o = "dra-p4";      i = "dragon";   n = 132; sh = "$($S)35mm-4-equilibrado.glsl";  crop = "crop=1920:960:0:60" }
)

foreach ($j in $jobs) {
    $out = "$pub\$($j.o).mp4"
    if (Test-Path $out) { "$($j.o): ya existe"; continue }
    $dir = "C:\glpromo\cap4-$($j.o)"
    if (Test-Path $dir) { Remove-Item $dir -Recurse -Force }
    New-Item -ItemType Directory -Force $dir | Out-Null
    $env:CAPDIR = ($dir -replace '\\', '/')
    $env:CAPFRAMES = "$($j.n)"

    & $mpv --load-scripts=no "--script=C:\glpromo\capture.lua" --osc=no --osd-level=0 `
        --sub-visibility=no "--geometry=1920x1080+0+0" --no-border --keepaspect-window=no `
        --no-audio --keep-open=no --save-position-on-quit=no `
        "--glsl-shaders=$($j.sh)" "$src\$($j.i).mp4" | Out-Null

    $got = (Get-ChildItem "$dir\*.png" -ErrorAction SilentlyContinue).Count
    if ($got -lt $j.n) { throw "$($j.o): captura incompleta $got/$($j.n)" }

    $vf = if ($j.crop) { "--vf=lavfi=[$($j.crop)]" } else { "--vf=" }
    & $mpvc --no-config --really-quiet "mf://$(($dir -replace '\\','/'))/*.png" --mf-fps=24 `
        $vf "--o=$out" --of=mp4 --ovc=libx264 --ovcopts=preset=slow,crf=17 --no-audio | Out-Null
    if (-not (Test-Path $out)) { throw "encode fallo: $($j.o)" }
    "{0}: {1} frames -> {2:n1} MB" -f $j.o, $got, ((Get-Item $out).Length / 1MB)
    Remove-Item $dir -Recurse -Force
}
"CAPTURAS V4 LISTAS"