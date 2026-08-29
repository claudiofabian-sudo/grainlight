-- ============================================================
--  35MM EMULATOR — subtitulos estilo cine 35mm
--  Tecla n (o desde el menu).
--  1) Tipografia de sala (fuente elegible desde el menu).
--  2) blend-subtitles=video: los subtitulos se fusionan con el
--     fotograma ANTES de los shaders (grano encima). gpu-next lo
--     ignora, por eso cambia temporalmente a vo=gpu y lo restaura.
-- ============================================================

-- ---------- idioma y preferencias ----------
local LANG = "es"
local SUBFONT = "Trebuchet MS"
local SUBSIZE = "normal"
-- Sobre la base estandar (mayusculas ~5% de la altura de imagen):
-- pequeno ~4%, normal ~5%, grande ~6.3%, XL ~7.8%, XXL ~9.5%
local SIZE_FACTORS = { small = 0.80, normal = 1.0, large = 1.25, xl = 1.55, xxl = 1.9 }
local function T(es, en) return LANG == "en" and en or es end
do
    local path = mp.command_native({ "expand-path", "~~/35mm-prefs.conf" })
    local f = io.open(path, "r")
    if f then
        for line in f:lines() do
            local v = line:match("^lang%s*=%s*(%a+)")
            if v then LANG = v end
            local sf = line:match("^subfont%s*=%s*(.-)%s*$")
            if sf and sf ~= "" then SUBFONT = sf end
            local ss = line:match("^subsize%s*=%s*(%a+)")
            if ss and SIZE_FACTORS[ss] then SUBSIZE = ss end
        end
        f:close()
    end
end
local function size_factor() return SIZE_FACTORS[SUBSIZE] or 1.0 end
-- tamano base elegido, aplicado siempre (con o sin modo cine)
mp.set_property_number("sub-scale", size_factor())
mp.observe_property("user-data/35mm-lang", "string", function(_, v)
    if v then LANG = v end
end)

local cine_props = {
    ["sub-bold"]          = "yes",
    ["sub-color"]         = "#F2E5B2",   -- marfil calido, como sub grabado
    ["sub-border-size"]   = "1.7",
    ["sub-border-color"]  = "#1A140C",
    ["sub-shadow-offset"] = "1.2",
    ["sub-shadow-color"]  = "#59000000",
    ["sub-spacing"]       = "0.8",
    ["sub-ass-override"]  = "force",     -- aplica tambien a subs ASS
    ["blend-subtitles"]   = "video",     -- subs dentro de la emulsion
    ["sub-use-margins"]   = "no",        -- anclados al area de imagen
}

local saved = nil
local saved_vo = nil

-- ---------- anclaje al contenido real ----------
-- Los subtitulos se colocan a MARGIN (fraccion de la altura del
-- contenido) sobre el borde inferior de la IMAGEN real (no de las
-- barras negras), y su tamano se escala a la altura del contenido.
-- Aproximado al estandar de sala (linea base a ~8% del borde).
local MARGIN = 0.06

local function anchor()
    if not saved then return end
    local r = mp.get_property_native("user-data/35mm-rect")
    if not (r and r.h and r.y and r.vh and r.vh > 0) then return end
    local pos = ((r.y + r.h) - MARGIN * r.h) / r.vh * 100
    mp.set_property_number("sub-pos", math.floor(pos + 0.5))
    mp.set_property_number("sub-scale", r.h / r.vh * size_factor())
end

mp.observe_property("user-data/35mm-rect", "native", function(_, _)
    anchor()
end)

local function set_state(on)
    mp.set_property_native("user-data/sub35-cine", on)
end
set_state(false)

local function enable()
    if saved then return end
    saved = {}
    saved["sub-font"] = mp.get_property("sub-font")
    mp.set_property("sub-font", SUBFONT)
    for k, v in pairs(cine_props) do
        saved[k] = mp.get_property(k)
        mp.set_property(k, v)
    end
    saved["sub-pos"] = mp.get_property("sub-pos")
    -- el renderizador cambia al final (reinicia la salida de video)
    saved_vo = mp.get_property("vo")
    mp.set_property("vo", "gpu")
    set_state(true)
    mp.osd_message(T("SUBTITULOS: estilo CINE 35MM — impresos en la pelicula",
                     "SUBTITLES: 35MM CINEMA style — printed on the film"), 2.5)
    -- pedir la geometria del contenido para anclar al area de imagen
    if mp.get_property_native("user-data/35mm-rect") then
        anchor()
    else
        mp.commandv("script-message", "detect-bars")
    end
end

local function disable()
    if not saved then return end
    for k, v in pairs(saved) do
        mp.set_property(k, v)
    end
    saved = nil
    -- el tamano elegido se mantiene tambien en estilo normal
    mp.set_property_number("sub-scale", size_factor())
    if saved_vo then
        mp.set_property("vo", saved_vo)
        saved_vo = nil
    end
    set_state(false)
    mp.osd_message(T("SUBTITULOS: estilo normal", "SUBTITLES: normal style"), 2.5)
end

-- archivo nuevo: re-medir si el modo cine sigue activo
mp.register_event("file-loaded", function()
    if saved then
        mp.add_timeout(0.5, function()
            if saved and not mp.get_property_native("user-data/35mm-rect") then
                mp.commandv("script-message", "detect-bars")
            end
        end)
    end
end)

mp.register_script_message("sub-style", function(arg)
    if arg == "cine" then enable()
    elseif arg == "normal" then disable()
    else
        if saved then disable() else enable() end
    end
end)

-- cambio de fuente (desde el menu); si el modo esta activo, aplica ya
mp.register_script_message("sub-font", function(font)
    if not font or font == "" then return end
    SUBFONT = font
    if saved then mp.set_property("sub-font", font) end
    mp.osd_message(T("Fuente de subtitulos: ", "Subtitle font: ") .. font, 2)
end)

-- cambio de tamano (desde el menu): pequeno / normal / grande
local SIZE_NAMES = {
    small  = function() return T("PEQUEÑO", "SMALL") end,
    normal = function() return T("NORMAL", "NORMAL") end,
    large  = function() return T("GRANDE", "LARGE") end,
    xl     = function() return "XL" end,
    xxl    = function() return "XXL" end,
}
mp.register_script_message("sub-size", function(key)
    if not SIZE_FACTORS[key] then return end
    SUBSIZE = key
    if saved and mp.get_property_native("user-data/35mm-rect") then
        anchor()
    else
        mp.set_property_number("sub-scale", size_factor())
    end
    mp.osd_message(T("Tamaño de subtitulos: ", "Subtitle size: ") .. SIZE_NAMES[key](), 2)
end)
