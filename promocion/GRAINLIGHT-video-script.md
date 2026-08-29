# GRAIN**LIGHT** — Promo film

### *"Project your films with an analog soul."*

**File:** `GRAINLIGHT-promo.mp4` · 62 s · 1920×1080 · 30 fps
**Footage:** the owner's own 4K remuxes — *Spider-Man: No Way Home*,
*Interstellar* (IMAX), *The Lord of the Rings: The Return of the King*,
*The Hobbit*, *House of the Dragon*, *Star Wars: The Force Awakens*.

> **Nothing is simulated.** Every treated shot was captured frame by frame
> from the real player with the shaders running — the four presets, the grain
> and the ambient-light fill are the software's actual output. The "before"
> clips are the same frames captured the same way with the shaders off, which
> is what makes the comparison honest to the pixel.

---

## Design system

The piece alternates **paper** and **ink**: it opens white, drops into the
footage, returns to white for the presets and the feature grid, and closes
white. Scenes never cut to black: the incoming one uncovers itself over the
outgoing one, led by a thin amber edge. The closing is a vertical push: the
feature section rides up and out while the wordmark follows it from below on
the same curve, so it reads as one continuous move.

| Token | Value | Use |
|-------|-------|-----|
| **Paper** | `#FFFFFF` → `#EDEAE3` | Light sections (soft radial gradient) |
| **Ink** | `#0B0B0D` → `#060607` | Dark sections (soft radial gradient) |
| **Amber** | `#E9A23B` | The projector lamp: the only accent |
| **Ember** | `#F6CE8E` | Warm highlight |

**The wordmark** is two-tone: **GRAIN** in the text colour, **LIGHT** in
amber — the lamp is literally in the name.

**Typography:** *Space Grotesk* for headlines, *Inter* for labels and body.
Headlines never fade in: they rise from behind a mask edge. Scenes never cut to black either — the incoming scene uncovers itself over the outgoing one, led by a thin amber edge. The closing is a vertical push: the
feature section rides up and out while the wordmark follows it from below on
the same curve, so it reads as one continuous move.

**No black bars** anywhere — scope footage runs edge to edge, and the only
bars in the film are in scene 05, where they exist to be filled.

---

## Voice-over script

~105 words over 62 seconds. Read low and unhurried. Timecodes match the edit.

| Time | On screen | Voice-over |
|------|-----------|------------|
| **0:00 – 0:03** | White. Two rules cross the paper; the wordmark rises. | *(silence)* |
| **0:03 – 0:08** | Black wipe. `01` — Interstellar's wave, untouched. **"PERFECT PIXELS." / "ZERO SOUL."** | *"Your remux is perfect. Every pixel exactly where the master put it."* … *"And completely lifeless."* |
| **0:08 – 0:14** | The master holds for a beat, then a blade of amber light crosses **Spider-Man** slowly, slides back to compare, and finishes. | *"Same file. Nothing re-encoded…"* |
| **0:14 – 0:20** | The same slow sweep on **Interstellar**. | *"…just a layer of real 35 mm projection…"* |
| **0:20 – 0:27** | And again on **The Return of the King**, closing on **"REAL 35 MM. LIVE."** | *"…rendered live on your GPU."* |
| **0:27 – 0:34** | Two cards spring in over **The Hobbit** and zoom together from 1× to 5×, counter running. **"LOOK CLOSER." → "GRAIN THAT BREATHES."** | *"Look closer. The grain isn't laid on top — every frame grows its own, the way silver halide does."* |
| **0:34 – 0:40** | The white section slides in. **"FOUR WAYS TO PROJECT."** A 2×2 grid: the same frame of **House of the Dragon** through all four presets. | *"Four presets. Subtle. Two-thousands cinema. A worn print. Or balanced — the colour of one, the texture of another."* |
| **0:40 – 0:50** | **The Hobbit** in scope, bars marked in amber; the fill spills into them. **"AMBIENT LIGHT."** Then the same on **The Return of the King** and **The Force Awakens**. | *"And when a film is wider than your screen, the bars don't stay empty. Ambient light fills them with the film itself."* |
| **0:50 – 0:58** | The white section slides in. **"ONE PLAYER. ANALOG SIMULATION."** Six features spring in, then a strip of four treated shots. | *"Grain. Gate weave. Halation. Dust and cue marks. Analog audio. Subtitles typeset into the emulsion."* |
| **0:58 – 1:02** | The feature section pushes up and out; the wordmark follows from below on paper, amber rule, tagline, `FREE AND OPEN SOURCE`. | *"GRAINLIGHT. Free and open source. Project your films with an analog soul."* |

---

## Notes

- **Pronunciation:** one word, stress on **GRAIN**.
- **The hook** is the beat after *"perfect"* — hold it before *"zero soul."*
- **Why "analog simulation"** and not "everything analog": the player
  simulates a photochemical print in real time; the file stays digital and
  untouched. The wording should stay honest about that.
- **Sound:** a plain projector-room tone (low rumble + 24 Hz shutter tick).
  Swap `public/bed.m4a` for music; a slow analog pad swelling at 0:08 and
  0:50 fits the cut.
- **Editing:** Remotion project in `remotion-project/`. Scene timings in
  `src/Promo.tsx`, design system in `src/theme.tsx`, footage pipeline in
  `extract2.ps1` + `capture4.ps1` + `capture5.ps1` + `capture6.ps1`.

## Before publishing

The footage comes from commercial films. Fine for a personal demo or a
private share, but a public upload will likely trip automated copyright
matching — swap in Creative Commons footage if you plan to post it.
GRAINLIGHT itself is free software (mpv, GPLv2+, plus original shaders and
scripts).
