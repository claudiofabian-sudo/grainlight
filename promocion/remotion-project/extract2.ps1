$ErrorActionPreference = "Stop"
Stop-Process -Name mpv -Force -Confirm:$false -ErrorAction SilentlyContinue
$mpvc = "C:\Users\pinof\OneDrive\Escritorio\35MM emulator\mpv\mpv.com"
$src = "C:\glpromo\srcclips"
New-Item -ItemType Directory -Force $src | Out-Null

function Find1($dir, $pat) {
    (Get-ChildItem -LiteralPath $dir -File -Recurse -Depth 1 -ErrorAction SilentlyContinue |
     Where-Object { $_.Name -like $pat } | Select-Object -First 1).FullName
}
$INTER  = Find1 "H:\Movies\Interestellar(2014)" "*.mkv"
$HOBBIT = Find1 "H:\Movies\Hobbit (varias versiones)\Hobbit theatrical 4K REMUX" "El Hobbit (2012)*.mkv"
$DRAGON = Find1 "H:\Movies\Casa Dragon" "*S03E01*.mkv"

# id | archivo | inicio | segundos | recorte del contenido | escala destino
$jobs = @(
    # la ola: IMAX 1.78, llena el cuadro sin barras
    @{ id = "wave";    f = $INTER;  t = "01:12:40"; s = 8.5; crop = "null";              sc = "scale=1920:1080" },
    # Hobbit para el zoom al grano
    @{ id = "hobbit40";f = $HOBBIT; t = "00:40:38"; s = 7.5; crop = "crop=3840:1609:0:275"; sc = "scale=1920:-2" },
    # Casa del Dragon 2.0 para la comparativa de presets
    @{ id = "dragon";  f = $DRAGON; t = "00:58:04"; s = 6.0; crop = "null";              sc = "scale=1920:-2" }
)

foreach ($j in $jobs) {
    $out = "$src\$($j.id).mp4"
    if (Test-Path $out) { "$($j.id): ya extraido"; continue }
    if (-not $j.f) { throw "sin archivo: $($j.id)" }
    $chain = if ($j.crop -eq "null") { "$($j.sc):flags=lanczos,setsar=1" }
             else { "$($j.crop),$($j.sc):flags=lanczos,setsar=1" }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    & $mpvc --no-config --really-quiet --hwdec=auto-copy `
        "--start=$($j.t)" "--length=$($j.s)" "--vf=lavfi=[$chain]" `
        "--o=$out" --of=mp4 --ovc=libx264 --ovcopts=preset=fast,crf=12 --no-audio $j.f | Out-Null
    $sw.Stop()
    if (-not (Test-Path $out)) { throw "extraccion fallo: $($j.id)" }
    "{0}: {1:n1} MB en {2:n0}s" -f $j.id, ((Get-Item $out).Length / 1MB), $sw.Elapsed.TotalSeconds
}
"EXTRACCION 2 LISTA"