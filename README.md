# 🎞️ GRAINLIGHT
### *Project your films with an analog soul.*

*(también conocido como 35MM Emulator — icono en `grainlight.ico`, acceso
directo `GRAINLIGHT.lnk`; si mueves la carpeta, ejecuta
`Crear acceso directo GRAINLIGHT.bat` para regenerarlo. Material
promocional en inglés en la carpeta `promocion\`.)*

Reproduce tus remux digitales **con la calidad original intacta** y una capa de
emulación de proyección 35mm aplicada **en tiempo real sobre la GPU**. Nada se
re-codifica, nada se pierde: el archivo se decodifica bit-perfect y los shaders
añaden encima grano, gate weave, parpadeo de lámpara, halation, viñeta, polvo y
pelusas — como una copia de cine proyectada en los 2000s.

> ⚠️ **Importante:** esto corre en el **PC** (conectado por HDMI al proyector).
> El Zidoo no puede ejecutar estos shaders — para usar el look 35mm, proyecta
> desde el PC. El motor gráfico (mpv + libplacebo) tiene una calidad de
> escalado y reproducción igual o superior a la del Zidoo.

## Instalación (una sola vez)

1. Descarga mpv para Windows (build de shinchiro, archivo
   `mpv-x86_64-...7z`) desde:
   https://github.com/shinchiro/mpv-winbuild-cmake/releases
2. Extrae **mpv.exe** dentro de la carpeta `mpv\` de este proyecto
   (debe quedar `mpv\mpv.exe`, junto a la carpeta `mpv\portable_config`).
3. Listo. Doble clic en **35MM Player.bat**.

## Uso

- Doble clic en `35MM Player.bat` → se abre un diálogo para elegir la película.
- También puedes **arrastrar un .mkv encima del .bat**.
- Arranca en pantalla completa con el **Preset 2 (Cine 2000s)** activo.

### Teclas

| Tecla | Función |
|-------|---------|
| **0** | **NADA DE NADA** — quita imagen 35mm, audio análogo, ambient y ajustes: remux 100% puro |
| **1** | Preset 1 · **Sutil** — grano fino Vision3, weave imperceptible |
| **2** | Preset 2 · **Cine 2000s** — print con contraste, halation, polvo ocasional |
| **3** | Preset 3 · **Copia veterana** — grano grueso, parpadeo, polvo y pelusas |
| **4** | Preset 4 · **Equilibrado** — los colores del preset 2 (print cálido + halation) con el grano grueso, pelusas y weave del preset 3 |
| **7** | Audio · **Limpio** — pista original del remux |
| **8** | Audio · **Óptico 35mm** — banda óptica de sala: compresión de cine, agudos redondeados |
| **9** | Audio · **Vinilo** — wow de 33rpm, calidez armónica |
| **+ / -** | Subir / bajar volumen |
| **m** / click der. | **Menú** — presets, pistas de audio, subtítulos, ambient, abrir película |
| **b** | Alternar modos **ambient** (off, ambilight, difuminado, sutil) |
| **M** | Silencio |
| **a** | Cambiar pista de audio |
| **s** / **S** | Cambiar / ocultar subtítulos |
| **n** | Subtítulos estilo **cine 35mm** — tipografía de sala e impresos en la película (con grano encima) |
| **t / T** | Subir / bajar los subtítulos (útil si la película trae barras codificadas) |
| **Espacio** | Pausa |
| **← →** | Saltar ±10 s · **↑ ↓** ±60 s |
| **f** | Pantalla completa |
| **i** | Estadísticas técnicas (bitrate, fps, códec…) |
| **r** | Restablecer imagen (si tocaste brillo/contraste/gamma sin querer) |
| **q** | Salir guardando la posición |

## Qué emula cada capa

| Capa | Qué hace |
|------|----------|
| **Grano** | Grano v2: hash entero PCG (sin patrones ni bandas posibles) + 3 octavas de ruido interpolado que aproximan la distribución gaussiana de los cristales de plata reales, más una chispa fina por píxel. Más denso en medios tonos, con leve variación de color por canal. Se aplica *después* del escalado para que quede nítido a la resolución del proyector. |
| **Gate weave** | Deriva lenta + micro-temblor por fotograma de la imagen, como el arrastre mecánico del proyector. |
| **Parpadeo** | Fluctuación sutil de brillo de la lámpara. |
| **Curva S + saturación** | La respuesta de contraste de un print fotoquímico: negros con cuerpo, color más vivo, ligera calidez de lámpara. |
| **Halation** | Halo cálido alrededor de las altas luces (rebote de luz en la base del film). |
| **Viñeta** | Caída de luz suave en las esquinas, propia de la óptica de proyección. |
| **Polvo y pelusas** | Motas y pelos que aparecen 1-2 fotogramas, como suciedad en la copia o en la ventanilla. |
| **Quemaduras de cigarro** | Marcas de cambio de rollo arriba a la derecha, como en las salas reales: una de aviso y otra 8 s después, de 4 fotogramas cada una. Cada 15 min en el preset 2, cada 12 en el 3 (ajustable con `CUE_PERIOD`, en segundos). |

## Audio análogo (teclas 7 / 8 / 9)

Igual que el video: la pista se decodifica intacta y los filtros se aplican
en tiempo real (script `scripts/audio-presets.lua`). Compatible con 5.1.

- **8 · Óptico 35mm** — respuesta en banda de una pista óptica de sala
  (55 Hz–9.5 kHz), realce de presencia en 2.2 kHz (inteligibilidad de
  diálogo) y compresión suave de cine.
- **9 · Vinilo** — calidez en graves (90 Hz), wow sutil a 0.55 Hz (como un
  plato de 33rpm) y un toque de brillo armónico muy discreto.
- **7 · Limpio** — vuelve a la pista original al instante.

El carácter de ambos viene de ecualización con forma, no de saturación: hay
un limitador transparente al final (`alimiter`) que solo evita picos, sin
añadir distorsión. Si aun así algo no te convence, dime si lo notas duro,
apagado o con eco raro — no puedo escucharlo yo mismo, así que la
descripción es la que me guía para el siguiente ajuste.

Los parámetros (frecuencias, profundidad del wow…) se editan
en `mpv\portable_config\scripts\audio-presets.lua`.

## Subtítulos estilo cine 35mm (tecla n o desde el menú)

Dos cosas a la vez: tipografía de sala (marfil cálido con contorno fino
oscuro, como los subtítulos grabados en las copias) y fusión de los
subtítulos con el fotograma **antes** de los shaders — el grano, el polvo y
hasta las quemaduras caen también sobre las letras, como si estuvieran
impresas en la película. Para lograrlo cambia temporalmente al renderizador
clásico (`vo=gpu`, el único que lo permite; la pantalla parpadea un instante
al activar/desactivar) y lo restaura al salir. Colores en
`mpv\portable_config\scripts\sub-style-35mm.lua`.

**Tamaño** (menú → Subtítulos → Tamaño): **Pequeño (~4%) / Normal (~5%) /
Grande (~6.3%) / XL (~7.8%) / XXL (~9.5%)** — porcentaje aproximado de
altura de mayúsculas respecto a la altura de la **imagen real** (Normal ≈
estándar de sala). Se aplica siempre (con o sin estilo cine, combinado con
el anclaje al contenido) y queda guardado.

En todos los submenús la opción activa se marca con `<<`, y **elegir una
opción no cierra el menú**: puedes probar presets/ambient/tamaños viendo el
resultado al instante; se cierra solo con Esc, m o volviendo atrás desde el
nivel principal. ("Abrir película…" sí lo cierra, porque abre el diálogo.)

**Fuentes de cine** (menú → Subtítulos → Fuente de cine): tipografías del
sistema asociadas a la subtitulación/rotulación de películas — Candara
(estilo grabado láser Titra), Century Gothic (geométrica de cartelas),
Franklin Gothic Medium (cartelera Hollywood), Tahoma (digital tipo Cinecav),
Gill Sans MT (copias británicas). La elegida queda guardada.

**Posición**: en modo normal los subtítulos van en la posición clásica de
cualquier reproductor (abajo, usando las franjas si las hay). El anclaje a
la imagen solo actúa con el **modo cine** activado:

**Anclados al contenido real**: al activar el modo cine se miden las barras
negras (aunque vengan codificadas dentro del archivo) y los subtítulos se
colocan a un **6% sobre el borde inferior de la imagen** (aproximado al
estándar de sala) con **tamaño proporcional a la imagen** — nunca en las
franjas negras. El margen se ajusta en `MARGIN` dentro de
`sub-style-35mm.lua`, y con **t / T** puedes retocar la altura al vuelo.

## Modos ambient (tecla b o desde el menú)

Para películas 21:9 (o 4:3) que dejan franjas negras en pantalla 16:9: el
relleno se genera a partir de la propia película (muy reducida, difuminada y
re-expandida), y el original se superpone **intacto** encima — cero pérdida.

1. **Ambilight** — reflejos de color lavados, como la tecnología de los
   televisores Philips.
2. **Expansión difuminada** — la película ampliada y desenfocada de fondo.
3. **Cine sutil** — brillo tenue apenas visible, como el modo ambiente de
   YouTube.

**Detección automática de barras codificadas**: la mayoría de remux 21:9
traen las franjas negras grabadas dentro del video (contenedor 16:9). Se
analizan automáticamente (~2 s tras abrir la película) y se recortan, con
dos consecuencias:

- Con un preset 35mm activo y **sin** ambient, el grano/polvo/viñeta/
  quemaduras actúan **solo sobre la imagen real** — las franjas quedan en
  negro absoluto (las pinta el renderizador, fuera de los shaders).
- Con un modo **ambient** activo, el relleno ocupa las franjas y los efectos
  cubren todo el lienzo (a propósito, para que se integre).

La detección necesita ver imagen: si la película arranca con minutos de
negro, puede no recortar — cambia de preset (tecla 1/2/3) en una escena
con imagen para re-medir.

Requiere copia por CPU del video (`hwdec=auto-copy-safe`, se activa solo);
en 4K sube algo el uso de procesador. Parámetros (desenfoque, saturación,
brillo del relleno) en `mpv\portable_config\scripts\ambient-modes.lua`.

## Idioma de la aplicación

En el menú: **Idioma / Language** → Español o English. Se guarda en
`mpv\portable_config\35mm-prefs.conf` y se recuerda entre sesiones
(igual que la fuente de subtítulos elegida).

## Ajustar a tu gusto

Cada preset es un archivo en `mpv\portable_config\shaders\`. Al principio de
cada bloque hay `#define` con los parámetros (GRAIN, WEAVE, VIGNETTE,
DUST_PROB…). Edita, guarda y vuelve a pulsar la tecla del preset — se recarga
al instante, incluso con la película en marcha.

## Consejos

- Pon la salida de video de Windows (o del proyector) a **23 Hz / 24 Hz** para
  cadencia de cine perfecta; `video-sync=display-resample` hace el resto.
- Si usas un **receptor AV** y quieres bitstream (TrueHD/Atmos/DTS-HD),
  descomenta la línea `audio-spdif=...` en `mpv\portable_config\mpv.conf`.
- Con material **HDR**: los presets están calibrados para SDR; funcionan en HDR
  pero el contraste/halation actúan distinto. Si tu proyector es SDR, mpv hace
  el tone-mapping automáticamente y los presets se ven como se diseñaron.

## Licencia

Los archivos propios de GRAINLIGHT (shaders, scripts Lua, configuración,
lanzadores, icono) están bajo licencia **MIT** — ver [`LICENSE`](LICENSE).

**mpv no se incluye en este repositorio.** Es un proyecto de terceros bajo
licencia GPL-2.0-or-later; descárgalo tú mismo siguiendo las instrucciones de
arriba. Su licencia es independiente de la de este proyecto.
