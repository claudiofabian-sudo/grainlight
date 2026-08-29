-- ============================================================
--  35MM EMULATOR — modos ambient + gestion de barras negras
--  Tecla b: alternar modos ambient.
--
--  Este script coordina la geometria del video:
--  * Mide las barras negras codificadas (cropdetect).
--  * Si hay un preset 35mm activo (glsl-shaders) y barras
--    codificadas, RECORTA las barras: el grano/polvo/vineta solo
--    actuan sobre la imagen real, y las franjas quedan en negro
--    puro (las dibuja el reproductor, fuera de los shaders).
--  * Con un modo ambient activo, el lienzo es el relleno 16:9 y
--    los shaders lo cubren todo (incluido el relleno) — a proposito.
--  * Publica la geometria del contenido en user-data/35mm-rect
--    para el anclaje de subtitulos.
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

-- ---------- grafo de relleno ----------
-- IMPORTANTE: sigma debe ser MUY inferior a las dimensiones de la
-- version reducida (incluidos los planos de color, a mitad de
-- resolucion). Con sigma comparable al tamano, el gaussiano IIR de
-- gblur corrompe los bordes y tine todo de verde/morado.
local function fill(F, sigma, sat, bri)
    local down = string.format(
        "scale=w=2*trunc(iw/%d):h=2*trunc(ih/%d):flags=area", 2 * F, 2 * F)
    local blur = string.format("gblur=sigma=%g:steps=2", sigma)
    local look = string.format("eq=saturation=%g:brightness=%g", sat, bri)
    local up = string.format(
        "scale=w=2*trunc(max(iw*%d\\,ih*%d*16/9)/2):h=2*trunc(max(ih*%d\\,iw*%d*9/16)/2):flags=bicubic",
        F, F, F, F)
    return "split[a][b];[a]" .. down .. "," .. blur .. "," .. look .. ","
        .. up .. ",setsar=1[bg];[bg][b]overlay=x=(W-w)/2:y=(H-h)/2"
end

local modes = {
    { key = "off",
      label = function() return T("AMBIENT: OFF — barras negras",
                                  "AMBIENT: OFF — black bars") end,
      body = nil },
    { key = "ambilight",
      label = function() return T("AMBIENT 1: AMBILIGHT — reflejos de color",
                                  "AMBIENT 1: AMBILIGHT — color reflections") end,
      body = fill(24, 3.5, 1.45, -0.05) },
    { key = "blur",
      label = function() return T("AMBIENT 2: EXPANSION DIFUMINADA",
                                  "AMBIENT 2: BLURRED EXPANSION") end,
      body = fill(12, 5, 1.05, -0.18) },
    { key = "sutil",
      label = function() return T("AMBIENT 3: CINE SUTIL — brillo tenue (estilo YouTube)",
                                  "AMBIENT 3: SUBTLE CINEMA — faint glow (YouTube style)") end,
      body = fill(24, 4, 1.15, -0.42) },
}

local cur = 1
local seq = 0
mp.set_property_native("user-data/35mm-ambient", "off")
local raw_rect = nil   -- ultima medicion: {w,h,x,y,vw,vh}
local cropped = false  -- crop base activo (sin ambient)
local detecting = false

local function has_bars()
    return raw_rect and (raw_rect.w < raw_rect.vw or raw_rect.h < raw_rect.vh)
end

local function shaders_active()
    local g = mp.get_property_native("glsl-shaders")
    return g and #g > 0
end

-- publica la geometria del contenido segun el estado actual
local function publish_rect()
    if not raw_rect then
        mp.set_property_native("user-data/35mm-rect", nil)
        return
    end
    local r = raw_rect
    local pub
    if modes[cur].body then
        -- lienzo 16:9 del ambient, contenido centrado
        local H = math.max(r.h, math.floor(r.w * 9 / 16 / 2) * 2)
        pub = { h = r.h, y = math.floor((H - r.h) / 2), vh = H }
    elseif cropped then
        -- el video ES el contenido
        pub = { h = r.h, y = 0, vh = r.h }
    else
        pub = { h = r.h, y = r.y, vh = r.vh }
    end
    mp.set_property_native("user-data/35mm-rect", pub)
end

-- estado base del vf cuando ambient esta OFF:
-- crop si hay preset 35mm y barras codificadas; si no, limpio
local function ensure_base()
    if modes[cur].body then return end
    if shaders_active() and has_bars() then
        local r = raw_rect
        mp.set_property("hwdec", "auto-copy-safe")
        mp.commandv("vf", "set",
            string.format("lavfi=[crop=%d:%d:%d:%d]", r.w, r.h, r.x, r.y))
        cropped = true
    else
        mp.commandv("vf", "clr", "")
        mp.set_property("hwdec", "auto-safe")
        cropped = false
    end
    publish_rect()
end

-- mide barras negras codificadas y llama cb(rect|nil);
-- deja puesto el cropdetect: el caller decide el vf definitivo
local det_seq = 0
local function detect(cb)
    det_seq = det_seq + 1
    local my = det_seq
    mp.set_property("hwdec", "auto-copy-safe")
    mp.commandv("vf", "set", "@ambdet:lavfi=[cropdetect=round=2:reset=0]")
    local tries = 0
    local function fin()
        if my ~= det_seq then return end
        local md = mp.get_property_native("vf-metadata/ambdet")
        -- la metadata puede tardar tras reiniciar el decodificador
        if (not md or not md["lavfi.cropdetect.w"]) and tries < 3 then
            tries = tries + 1
            mp.add_timeout(0.8, fin)
            return
        end
        local vw = mp.get_property_number("width")
        local vh = mp.get_property_number("height")
        local rect = nil
        if vw and vh then
            rect = { w = vw, h = vh, x = 0, y = 0, vw = vw, vh = vh }
            if md then
                local w = tonumber(md["lavfi.cropdetect.w"])
                local h = tonumber(md["lavfi.cropdetect.h"])
                local x = tonumber(md["lavfi.cropdetect.x"])
                local y = tonumber(md["lavfi.cropdetect.y"])
                if w and h and x and y and w > 0 and h > 0 then
                    -- solo barras horizontales O verticales claras; si ambas
                    -- dimensiones encogen es una escena oscura, no barras
                    local letterbox = (w >= vw * 0.98) and (h < vh * 0.95) and (h >= vh * 0.4)
                    local pillarbox = (h >= vh * 0.98) and (w < vw * 0.95) and (w >= vw * 0.4)
                    if letterbox or pillarbox then
                        rect = { w = w, h = h, x = x, y = y, vw = vw, vh = vh }
                    end
                end
            end
        end
        cb(rect)
    end
    mp.add_timeout(1.2, fin)
end

-- garantiza el estado correcto; mide una vez por archivo si hace falta
local function ensure()
    if modes[cur].body then return end
    if not mp.get_property_number("width") then return end
    if shaders_active() and raw_rect == nil and not detecting then
        detecting = true
        detect(function(rect)
            detecting = false
            raw_rect = rect
            ensure_base()
        end)
    else
        ensure_base()
    end
end

local function apply(i)
    cur = i
    seq = seq + 1
    local my = seq
    local m = modes[i]
    mp.set_property_native("user-data/35mm-ambient", m.key)

    if not m.body then
        ensure()   -- vuelve al estado base (crop si corresponde)
        mp.osd_message(m.label(), 2.5)
        return
    end

    mp.osd_message(T("Analizando barras negras...", "Analyzing black bars..."), 1.5)
    detect(function(rect)
        if my ~= seq then return end
        raw_rect = rect or raw_rect
        local crop = ""
        if has_bars() then
            local r = raw_rect
            crop = string.format("crop=%d:%d:%d:%d,", r.w, r.h, r.x, r.y)
        end
        cropped = false
        mp.commandv("vf", "set", "lavfi=[" .. crop .. m.body .. "]")
        publish_rect()
        mp.osd_message(m.label(), 2.5)
    end)
end

-- re-deteccion bajo demanda (la piden los subtitulos estilo cine)
mp.register_script_message("detect-bars", function()
    if modes[cur].body then
        apply(cur)
        return
    end
    detecting = true
    detect(function(rect)
        detecting = false
        raw_rect = rect or raw_rect
        ensure_base()
    end)
end)

mp.register_script_message("ambient-mode", function(key)
    for i, m in ipairs(modes) do
        if m.key == key then apply(i) return end
    end
end)

mp.register_script_message("ambient-cycle", function()
    apply(cur % #modes + 1)
end)

-- al cambiar los presets 35mm, ajustar el crop base
mp.observe_property("glsl-shaders", "native", function()
    ensure()
end)

-- archivo nuevo: la geometria anterior ya no vale
mp.register_event("file-loaded", function()
    raw_rect = nil
    cropped = false
    mp.set_property_native("user-data/35mm-rect", nil)
    if modes[cur].body then
        mp.add_timeout(0.4, function() apply(cur) end)
    else
        mp.add_timeout(0.4, ensure)
    end
end)
