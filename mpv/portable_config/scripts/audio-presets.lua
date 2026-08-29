-- ============================================================
--  35MM EMULATOR — presets de audio analogo
--  Se aplican en tiempo real; el archivo no se toca.
-- ============================================================

-- ---------- idioma ----------
local LANG = "es"
local function T(es, en) return LANG == "en" and en or es end
do
    local path = mp.command_native({ "expand-path", "~~/35mm-prefs.conf" })
    local f = io.open(path, "r")
    if f then
        for line in f:lines() do
            local v = line:match("^lang%s*=%s*(%a+)")
            if v then LANG = v end
        end
        f:close()
    end
end
mp.observe_property("user-data/35mm-lang", "string", function(_, v)
    if v then LANG = v end
end)

-- v2: se retiro el "asoftclip" (saturacion dura) que llevaban ambos
-- presets. Sobre una mezcla real de cine (dialogo+musica+efectos a la
-- vez, no un tono limpio) esa saturacion se nota como aspereza/crujido.
-- Ahora el caracter viene de EQ con forma, y la seguridad de picos la
-- da un "alimiter" transparente (no anade armonicos, solo evita que
-- se pase de nivel).
local presets = {
    clean = {
        af  = "",
        msg = function() return T("AUDIO: LIMPIO — pista original del remux",
                                  "AUDIO: CLEAN — original remux track") end,
    },
    -- Sonido optico de sala 35mm: banda de una pista optica, con el
    -- realce de presencia (2.2 kHz) que da inteligibilidad de dialogo
    -- y un leve recorte en 350 Hz para quitar "caja". Compresion
    -- moderada tipo cine, limitador transparente en vez de saturacion.
    optical = {
        af  = "lavfi=[highpass=f=55,lowpass=f=9500,"
           .. "equalizer=f=2200:t=q:w=1.0:g=3.5,"
           .. "equalizer=f=350:t=q:w=1.2:g=-2.5,"
           .. "acompressor=threshold=-16dB:ratio=2.2:attack=12:release=180:makeup=1.8,"
           .. "alimiter=limit=0.95:attack=3:release=60]",
        msg = function() return T("AUDIO: OPTICO 35MM — sala de cine (banda optica + presencia)",
                                  "AUDIO: 35MM OPTICAL — movie theater (optical band + presence)") end,
    },
    -- Vinilo: calidez grave (90 Hz), leve suavizado de la presencia
    -- (3.2 kHz) tipico del trazado de aguja, wow sutil a 33rpm, y un
    -- excitador armonico muy discreto (blend bajo) para brillo sin
    -- aspereza.
    vinyl = {
        af  = "lavfi=[highpass=f=28,lowpass=f=15500,"
           .. "equalizer=f=90:t=q:w=1.0:g=2.0,"
           .. "equalizer=f=3200:t=q:w=1.3:g=-1.2,"
           .. "vibrato=f=0.55:d=0.025,"
           .. "aexciter=amount=0.55:blend=0.25,"
           .. "alimiter=limit=0.97:attack=3:release=60]",
        msg = function() return T("AUDIO: VINILO — calidez + wow sutil",
                                  "AUDIO: VINYL — warmth + subtle wow") end,
    },
}

mp.set_property_native("user-data/35mm-audio", "clean")

mp.register_script_message("audio-preset", function(name)
    local p = presets[name]
    if not p then
        mp.osd_message("Preset?: " .. tostring(name))
        return
    end
    mp.set_property("af", p.af)
    mp.set_property_native("user-data/35mm-audio", name)
    mp.osd_message(p.msg(), 2.5)
end)
