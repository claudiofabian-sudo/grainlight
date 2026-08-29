# GRAINLIGHT — promo film source

Motion-graphics project for `GRAINLIGHT-promo.mp4`, built with
[Remotion](https://remotion.dev) (React → video).

## Run it

```bash
npm install
npm start          # Remotion Studio: scrub and edit live
npm run build      # renders out/GRAINLIGHT-promo.mp4
```

Node 18+. If the bundled Chromium download fails, pass your own:
`--browser-executable="C:\Program Files\Google\Chrome\Application\chrome.exe"`.

## Where things live

| File | What it controls |
|------|------------------|
| `src/Promo.tsx` | The edit — scene timings (30 fps) and the block wipes between light and dark sections |
| `src/scenes.tsx` | The eight scenes |
| `src/theme.tsx` | Palette, gradients, type scale, easing, mask reveals, grain layer |
| `public/*.mp4` | Footage (see below) |
| `public/bed.m4a` | Projector-room sound bed — swap for music here |

## Design system

The piece alternates **paper** and **ink**. Light sections use a soft radial
gradient (`LIGHT_BG`), dark ones its mirror (`DARK_BG`). Every jump between
modes is crossed by a `BlockWipe` carrying the destination colour.

| Token | Value |
|-------|-------|
| Paper | `#FFFFFF` → `#EDEAE3` |
| Ink | `#0B0B0D` → `#060607` |
| Amber | `#E9A23B` — the only accent |
| Ember | `#F6CE8E` |

**Type:** Space Grotesk (headlines) + Inter (labels, body), both loaded via
`@remotion/google-fonts`. Headlines never fade in — they rise from behind a
mask edge (`<Mask>`).

## The footage

Cut from the owner's own 4K remuxes and processed by the real player:

| Clip | Source | What it is |
|------|--------|------------|
| `wave-clean` / `wave-grain` | Interstellar, 1:12:40 (IMAX 1.78) | Master vs GRAINLIGHT, frame-aligned |
| `hob-clean` / `hob-grain` | The Hobbit, 0:40:38 | Master vs GRAINLIGHT, for the zoom |
| `dra-p1…p4` | House of the Dragon S03E01, 0:58:04 | The same frame through all four presets |
| `hobbit-ambient` | The Hobbit, 2:29:26 | Real ambient-light fill |
| `forrest-ambient` | Forrest Gump, 1:38:17 | Ambient light, second example |
| `rotk-grain`, `spider-grain` | LOTR, Spider-Man | Treated shots for the closing strip |

The treated clips are **not simulations**: `capture.lua` steps the real player
one frame at a time with the shaders running and saves what the renderer
draws. The clean clips are the same frames captured the same way with the
shaders off, which is what keeps the comparison honest to the pixel.

Clips are stored as content only (no black bars baked in) except the ambient
ones, which are the full 16:9 canvas the player produces.

### Regenerating the footage

1. `extract2.ps1` — cuts fragments from the 4K remuxes into `srcclips/`
   (fast: direct encode, no video window).
2. `capture4.ps1` — plays each fragment in the real player with the right
   preset and grabs every frame, then encodes into `public/`.

Capturing drives a visible undecorated mpv window and screenshots it, so
don't lock the screen while it runs.

## Remotion licence

Free for individuals and small teams; companies of four or more need a
company licence. See https://remotion.dev/license
