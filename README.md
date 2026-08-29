# 🎞️ GRAINLIGHT
### *Project your films with an analog soul.*

[![License: MIT](https://img.shields.io/badge/license-MIT-e9a23b.svg)](LICENSE)
[![Platform: Windows](https://img.shields.io/badge/platform-Windows-blue.svg)](#installation-one-time)
[![Built on mpv](https://img.shields.io/badge/built%20on-mpv-333333.svg)](https://mpv.io)
[![Watch the demo](https://img.shields.io/badge/YouTube-Watch%20the%20demo-FF0000.svg?logo=youtube&logoColor=white)](https://youtu.be/dEPVlZFU_wQ)
[![Support the project](https://img.shields.io/badge/♥-Support%20this%20project-e9a23b.svg)](https://claude.ai/code/artifact/ff9db8fa-eec5-4b0a-b70d-caf9f123894a)

Plays your digital remuxes **at their original quality** and adds a layer of
real-time 35 mm projection emulation, **rendered live on your GPU**. Nothing
is re-encoded, nothing is lost: the file decodes bit-perfect, and shaders
add organic grain, gate weave, lamp flicker, halation, vignette, dust and
hairs on top — like a 2000s movie-theater print.

*(Icon in `grainlight.ico`, shortcut launcher `GRAINLIGHT.lnk` — if you move
the folder, run `Crear acceso directo GRAINLIGHT.bat` to regenerate it.
Promo material in `promocion/`.)*

> ⚠️ **This runs on your PC** (connected to the projector over HDMI), not on
> a network player like a Zidoo — those can't run GLSL shaders. mpv's
> graphics engine (libplacebo) matches or beats dedicated players for
> scaling and playback quality anyway.

## Support this project

GRAINLIGHT is free and always will be. If it's useful to you, here's every
way to help fund it — and whatever comes next:
**[claude.ai/code/artifact/…](https://claude.ai/code/artifact/ff9db8fa-eec5-4b0a-b70d-caf9f123894a)**

## Installation (one time)

1. Download mpv for Windows (shinchiro's build, file
   `mpv-x86_64-...7z`) from:
   https://github.com/shinchiro/mpv-winbuild-cmake/releases
2. Extract **mpv.exe** into this project's `mpv\` folder
   (you should end up with `mpv\mpv.exe`, next to `mpv\portable_config`).
3. Done. Double-click **35MM Player.bat**.

## Usage

- Double-click `35MM Player.bat` → a file picker opens to choose a movie.
- You can also **drag an .mkv onto the .bat**.
- Starts in fullscreen with **Preset 2 (2000s Cinema)** active.

### Keys

| Key | Function |
|-----|----------|
| **0** | **CLEAN SLATE** — removes 35mm image, analog audio, ambient and any adjustments: 100% pure remux |
| **1** | Preset 1 · **Subtle** — fine Vision3-style grain, imperceptible weave |
| **2** | Preset 2 · **2000s Cinema** — print with contrast, halation, occasional dust |
| **3** | Preset 3 · **Worn Print** — coarse grain, flicker, dust and hairs |
| **4** | Preset 4 · **Balanced** — preset 2's warm print colors with preset 3's coarse grain, hairs and weave |
| **7** | Audio · **Clean** — original remux track |
| **8** | Audio · **35mm Optical** — theater optical band: cinema compression, rounded highs |
| **9** | Audio · **Vinyl** — 33rpm wow, harmonic warmth |
| **+ / -** | Volume up / down |
| **m** / right-click | **Menu** — presets, audio/subtitle tracks, ambient, open file |
| **b** | Cycle **ambient** modes (off, ambilight, blurred, subtle) |
| **M** | Mute |
| **a** | Cycle audio track |
| **s** / **S** | Cycle / hide subtitles |
| **n** | **Cinema-style subtitles** — theater typeface, printed into the film (with grain on top) |
| **t / T** | Raise / lower subtitles (useful if the film has baked-in bars) |
| **Space** | Pause |
| **← →** | Seek ±10 s · **↑ ↓** ±60 s |
| **f** | Fullscreen |
| **i** | Technical stats (bitrate, fps, codec…) |
| **r** | Reset image (if you bumped brightness/contrast/gamma by accident) |
| **q** | Quit, saving position |

## What each layer emulates

| Layer | What it does |
|-------|--------------|
| **Grain** | v2 grain: integer PCG hashing (no banding, no repeating patterns) + 3 octaves of interpolated noise approximating the Gaussian distribution of real silver-halide crystals, plus a fine per-pixel sparkle. Denser in midtones, with a touch of per-channel color variation. Applied *after* scaling so it stays crisp at your display resolution. |
| **Gate weave** | Slow drift plus per-frame micro-jitter, like a projector's mechanical pull-down. |
| **Flicker** | Subtle lamp-brightness fluctuation. |
| **S-curve + saturation** | A photochemical print's contrast response: solid blacks, livelier color, slight lamp warmth. |
| **Halation** | A warm halo around highlights (light bouncing off the film base). |
| **Vignette** | Soft light falloff in the corners, from the projection lens. |
| **Dust & hairs** | Specks and fibers that last 1–2 frames, like debris on the print or in the gate. |
| **Cue marks** | Reel-change marks in the top-right corner, just like real theaters: a warning dot and, 8 s later, a change dot, 4 frames each. Every 15 min on preset 2, every 12 on preset 3 (tunable via `CUE_PERIOD`, in seconds). |

## Analog audio (keys 7 / 8 / 9)

Same principle as the video: the track decodes intact and filters apply in
real time (`scripts/audio-presets.lua`). Works with 5.1.

- **8 · 35mm Optical** — the band response of a theater optical track
  (55 Hz–9.5 kHz), a presence lift at 2.2 kHz for dialogue clarity, and
  gentle cinema-style compression.
- **9 · Vinyl** — low-end warmth (90 Hz), a subtle 0.55 Hz wow (like a
  33rpm turntable), and a light touch of harmonic sheen.
- **7 · Clean** — back to the original track instantly.

Both presets get their character from shaped EQ, not saturation — there's a
transparent limiter (`alimiter`) at the end that only catches peaks, adding
no distortion of its own.

Parameters (frequencies, wow depth…) live in
`mpv\portable_config\scripts\audio-presets.lua`.

## Cinema-style subtitles (key n or from the menu)

Two things at once: a theater typeface (warm ivory with a thin dark outline,
like subtitles burned into a print) and blending the subtitles into the
frame **before** the shaders run — grain, dust, even cue marks fall on the
letters too, as if they were printed into the film. To pull that off it
switches temporarily to the classic renderer (`vo=gpu`, the only one that
supports it; the screen flashes once on toggle) and restores the modern one
on exit. Colors live in `mpv\portable_config\scripts\sub-style-35mm.lua`.

**Size** (menu → Subtitles → Size): **Small (~4%) / Normal (~5%) / Large
(~6.3%) / XL (~7.8%) / XXL (~9.5%)** — approximate capital-letter height
relative to the height of the **actual picture** (Normal ≈ theater
standard). Always applied (with or without cinema mode, combined with
content-anchoring) and remembered.

In every submenu the active choice is marked with `<<`, and **picking an
option doesn't close the menu** — try presets/ambient/sizes and see the
result instantly; it only closes with Esc, m, or backing out from the top
level. ("Open movie…" does close it, since it opens a file dialog.)

**Cinema fonts** (menu → Subtitles → Cinema font): system typefaces tied to
real film subtitling/titling — Candara (laser-engraved Titra style),
Century Gothic (geometric title-card look), Franklin Gothic Medium
(classic Hollywood poster), Tahoma (digital cinema, Cinecav-style), Gill
Sans MT (British prints). Your pick is remembered.

**Position**: in normal mode subtitles sit in the classic spot any player
uses (bottom, using the bars if there are any). Content-anchoring only
kicks in with **cinema mode** active:

**Anchored to the real picture**: turning on cinema mode measures the black
bars (even when they're baked into the file) and places subtitles **6%
above the bottom of the picture** (close to theater standard) at a **size
proportional to the picture** — never inside the black bars. The margin is
`MARGIN` inside `sub-style-35mm.lua`, and **t / T** nudge the height live.

## Ambient modes (key b or from the menu)

For 21:9 (or 4:3) films that leave black bars on a 16:9 screen: the fill is
generated from the film itself (heavily reduced, blurred, and re-expanded),
with the original overlaid **untouched** on top — zero quality loss.

1. **Ambilight** — washed color reflections, like Philips TV tech.
2. **Blurred expansion** — the film enlarged and blurred behind itself.
3. **Subtle cinema** — a faint glow, barely visible, like YouTube's ambient
   mode.

**Automatic baked-in bar detection**: most 21:9 remuxes have the black bars
recorded right into the video (16:9 container). GRAINLIGHT detects them
automatically (~2 s after opening the film) and crops them, with two
consequences:

- With a 35mm preset active and ambient **off**, grain/dust/vignette/cue
  marks act **only on the real picture** — the bars stay pure black
  (painted by the renderer, outside the shaders).
- With an **ambient** mode active, the fill takes over the bars and the
  effects cover the whole canvas (on purpose, so it reads as one image).

Detection needs to see picture: if a film opens on minutes of black, it may
not crop yet — switch presets (key 1/2/3) during a lit scene to re-measure.

Requires a CPU copy of the video (`hwdec=auto-copy-safe`, enabled
automatically); on 4K this raises CPU usage somewhat. Parameters (blur,
saturation, fill brightness) live in
`mpv\portable_config\scripts\ambient-modes.lua`.

## App language

From the menu: **Idioma / Language** → Spanish or English. Saved to
`mpv\portable_config\35mm-prefs.conf` and remembered between sessions
(along with your chosen subtitle font).

## Tuning it to taste

Each preset is a file in `mpv\portable_config\shaders\`. At the top of each
block are `#define`s for the parameters (GRAIN, WEAVE, VIGNETTE,
DUST_PROB…). Edit, save, and press the preset's key again — it reloads
instantly, even mid-playback.

## Tips

- Set Windows' (or the projector's) video output to **23 Hz / 24 Hz** for
  perfect cinema cadence; `video-sync=display-resample` handles the rest.
- Using an **AV receiver** and want bitstreaming (TrueHD/Atmos/DTS-HD)?
  Uncomment the `audio-spdif=...` line in `mpv\portable_config\mpv.conf`.
- **HDR material**: presets are tuned for SDR; they still work on HDR but
  contrast/halation behave differently. On an SDR display, mpv tone-maps
  automatically and the presets look as designed.

## License

GRAINLIGHT's own files (shaders, Lua scripts, configuration, launchers,
icon) are **MIT licensed** — see [`LICENSE`](LICENSE).

**mpv itself is not bundled in this repository.** It's a third-party
project under the GPL-2.0-or-later license; download it yourself following
the instructions above. Its license is independent of this project's.
