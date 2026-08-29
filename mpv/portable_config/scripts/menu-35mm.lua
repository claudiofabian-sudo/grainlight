-- ============================================================
--  35MM EMULATOR — menu en pantalla
--  Abrir: tecla m o click derecho.
--  Navegar: flechas | elegir: Enter | volver: flecha izq | cerrar: Esc
--  Este script es ademas el "guardian" de preferencias:
--  ~~/35mm-prefs.conf  (lang=es|en, subfont=<nombre>)
-- ============================================================

local ov = mp.create_osd_overlay("ass-events")
ov.res_x, ov.res_y = 1280, 720
ov.z = 500

-- colores ASS (&HBBGGRR&)
local C_PANEL  = "&H0B0A09&"
local C_TITLE  = "&H55D9FF&"   -- dorado
local C_SEL    = "&H1FBFFF&"   -- ambar
local C_TEXT   = "&HE8E8E8&"
local C_DIM    = "&H8A8A8A&"

local stack = {}
local is_open = false

-- ------------------------------------------------------------
-- preferencias e idioma
-- ------------------------------------------------------------

local LANG = "es"
local SUBFONT = "Trebuchet MS"
local SUBSIZE = "normal"

local function prefs_path()
    return mp.command_native({ "expand-path", "~~/35mm-prefs.conf" })
end

local function load_prefs()
    local f = io.open(prefs_path(), "r")
    if not f then return end
    for line in f:lines() do
        local v = line:match("^lang%s*=%s*(%a+)")
        if v then LANG = v end
        local sf = line:match("^subfont%s*=%s*(.-)%s*$")
        if sf and sf ~= "" then SUBFONT = sf end
        local ss = line:match("^subsize%s*=%s*(%a+)")
        if ss then SUBSIZE = ss end
    end
    f:close()
end

local function save_prefs()
    local f = io.open(prefs_path(), "w")
    if not f then return end
    f:write("lang=" .. LANG .. "\n")
    f:write("subfont=" .. SUBFONT .. "\n")
    f:write("subsize=" .. SUBSIZE .. "\n")
    f:close()
end

load_prefs()
mp.set_property_native("user-data/35mm-lang", LANG)

local function T(es, en) return LANG == "en" and en or es end

local function set_lang(l)
    LANG = l
    mp.set_property_native("user-data/35mm-lang", l)
    save_prefs()
    mp.osd_message(l == "en" and "Language: English" or "Idioma: Español", 2)
end

-- ------------------------------------------------------------
-- acciones
-- ------------------------------------------------------------

local SHADER_DIR = "~~/shaders/"

local function set_preset(file, name)
    return function()
        mp.commandv("change-list", "glsl-shaders", "set", SHADER_DIR .. file)
        mp.osd_message("35MM: " .. name, 2.5)
    end
end

local function all_clean()
    mp.commandv("change-list", "glsl-shaders", "clr", "")
    mp.commandv("script-message", "audio-preset", "clean")
    mp.commandv("script-message", "ambient-mode", "off")
    for _, p in ipairs({ "brightness", "contrast", "gamma", "saturation", "hue" }) do
        mp.set_property(p, 0)
    end
    mp.osd_message(T("PURO — remux sin ningun efecto",
                     "PURE — remux with no effects at all"), 2.5)
end

local function open_file()
    local ps = "Add-Type -AssemblyName System.Windows.Forms; "
        .. "$d = New-Object System.Windows.Forms.OpenFileDialog; "
        .. "$d.Filter = 'Peliculas|*.mkv;*.mp4;*.m2ts;*.ts;*.mov;*.avi|Todos|*.*'; "
        .. "$d.Title = '35MM'; "
        .. "if ($d.ShowDialog() -eq 'OK') { [Console]::Out.Write($d.FileName) }"
    mp.command_native_async({
        name = "subprocess", playback_only = false, capture_stdout = true,
        args = { "powershell", "-NoProfile", "-STA", "-Command", ps },
    }, function(ok, res)
        if ok and res and res.stdout and res.stdout ~= "" then
            mp.commandv("loadfile", res.stdout)
        end
    end)
end

local function track_items(ttype)
    local items = {}
    if ttype == "sub" then
        items[#items + 1] = {
            label = T("Desactivar subtitulos", "Disable subtitles"),
            on = function()
                mp.set_property("sid", "no")
                mp.osd_message(T("Subtitulos desactivados", "Subtitles disabled"))
            end,
        }
    end
    for _, t in ipairs(mp.get_property_native("track-list", {})) do
        if t.type == ttype then
            local parts = {}
            if t.lang then parts[#parts + 1] = t.lang end
            if t.title then parts[#parts + 1] = t.title end
            if t.codec then parts[#parts + 1] = string.upper(t.codec) end
            if t["demux-channel-count"] then
                parts[#parts + 1] = t["demux-channel-count"] .. "ch"
            end
            local label = string.format("%d:  %s", t.id, table.concat(parts, "  -  "))
            if t.selected then label = label .. T("   (activa)", "   (active)") end
            items[#items + 1] = {
                label = label,
                on = function()
                    mp.set_property(ttype == "audio" and "aid" or "sid", t.id)
                    mp.osd_message((ttype == "audio" and "Audio " or "Subs ") .. label)
                end,
            }
        end
    end
    if #items == 0 then
        items = { { label = T("(no hay pistas)", "(no tracks)"), on = function() end } }
    end
    return items
end

-- fuentes reales usadas/asociadas a la subtitulacion de cine
local cine_fonts = {
    { font = "Candara",
      es = "grabado laser (estilo Titra)",      en = "laser engraving (Titra style)" },
    { font = "Century Gothic",
      es = "geometrica (cartelas clasicas)",    en = "geometric (classic title cards)" },
    { font = "Franklin Gothic Medium",
      es = "cartelera clasica Hollywood",       en = "classic Hollywood poster" },
    { font = "Tahoma",
      es = "digital de sala (estilo Cinecav)",  en = "digital cinema (Cinecav style)" },
    { font = "Gill Sans MT",
      es = "copias britanicas",                 en = "British prints" },
    { font = "Trebuchet MS",
      es = "estandar",                          en = "standard" },
}

local function font_items()
    local items = {}
    for _, cf in ipairs(cine_fonts) do
        local label = cf.font .. "  -  " .. T(cf.es, cf.en)
        if cf.font == SUBFONT then label = label .. "   <<" end
        items[#items + 1] = {
            label = label,
            on = function()
                SUBFONT = cf.font
                save_prefs()
                mp.commandv("script-message", "sub-font", cf.font)
            end,
        }
    end
    return items
end

local function size_items()
    local sizes = {
        { key = "small",  es = "Pequeño", en = "Small" },
        { key = "normal", es = "Normal",  en = "Normal" },
        { key = "large",  es = "Grande",  en = "Large" },
        { key = "xl",     es = "XL",      en = "XL" },
        { key = "xxl",    es = "XXL",     en = "XXL" },
    }
    local items = {}
    for _, s in ipairs(sizes) do
        local label = T(s.es, s.en)
        if s.key == SUBSIZE then label = label .. "   <<" end
        items[#items + 1] = {
            label = label,
            on = function()
                SUBSIZE = s.key
                save_prefs()
                mp.commandv("script-message", "sub-size", s.key)
            end,
        }
    end
    return items
end

local function sub_items()
    local items = track_items("sub")
    local cine = mp.get_property_native("user-data/sub35-cine", false)
    table.insert(items, 1, {
        label = T("Estilo cine 35mm: ", "35mm cinema style: ")
            .. (cine and T("ACTIVADO", "ON") or T("apagado", "off")),
        on = function() mp.commandv("script-message", "sub-style", "toggle") end,
    })
    table.insert(items, 2, {
        label = T("Fuente de cine...", "Cinema font..."),
        submenu = font_items,
    })
    table.insert(items, 3, {
        label = T("Tamaño...", "Size..."),
        submenu = size_items,
    })
    return items
end

local function root_items()
    return {
            { label = T("Imagen 35mm", "35mm picture"), submenu = function()
                local g = mp.get_property_native("glsl-shaders") or {}
                local joined = table.concat(g, ";")
                local function mk(tag)
                    if tag == "" then return #g == 0 and "   <<" or "" end
                    return joined:find(tag, 1, true) and "   <<" or ""
                end
                return {
                    { label = T("Sin efecto de imagen", "No picture effect") .. mk(""), on = function()
                        mp.commandv("change-list", "glsl-shaders", "clr", "")
                        mp.osd_message(T("35MM: OFF — imagen remux pura",
                                         "35MM: OFF — pure remux picture"), 2.5)
                    end },
                    { label = T("1  Sutil — grano fino Vision3",
                                "1  Subtle — fine Vision3 grain") .. mk("35mm-1"),
                      on = set_preset("35mm-1-sutil.glsl", "SUTIL") },
                    { label = T("2  Cine 2000s — print + halation + polvo",
                                "2  2000s cinema — print + halation + dust") .. mk("35mm-2"),
                      on = set_preset("35mm-2-cine2000.glsl", "CINE 2000s") },
                    { label = T("3  Copia veterana — grano grueso + pelusas",
                                "3  Worn print — coarse grain + hairs") .. mk("35mm-3"),
                      on = set_preset("35mm-3-veterana.glsl", "COPIA VETERANA") },
                    { label = T("4  Equilibrado — colores del 2 + grano del 3",
                                "4  Balanced — preset 2 colors + preset 3 grain") .. mk("35mm-4"),
                      on = set_preset("35mm-4-equilibrado.glsl", "EQUILIBRADO") },
                }
            end },
            { label = T("Audio analogo", "Analog audio"), submenu = function()
                local a = mp.get_property_native("user-data/35mm-audio") or "clean"
                local function mk(k) return a == k and "   <<" or "" end
                local function msg(k)
                    return function() mp.commandv("script-message", "audio-preset", k) end
                end
                return {
                    { label = T("Limpio — pista original", "Clean — original track") .. mk("clean"),
                      on = msg("clean") },
                    { label = T("Optico 35mm — sala de cine", "35mm optical — movie theater") .. mk("optical"),
                      on = msg("optical") },
                    { label = T("Vinilo — wow + calidez", "Vinyl — wow + warmth") .. mk("vinyl"),
                      on = msg("vinyl") },
                }
            end },
            { label = T("Ambient (rellenar franjas)", "Ambient (fill the bars)"), submenu = function()
                local am = mp.get_property_native("user-data/35mm-ambient") or "off"
                local function mk(k) return am == k and "   <<" or "" end
                local function msg(k)
                    return function() mp.commandv("script-message", "ambient-mode", k) end
                end
                return {
                    { label = T("Off — barras negras", "Off — black bars") .. mk("off"),
                      on = msg("off") },
                    { label = T("1  Ambilight — reflejos de color",
                                "1  Ambilight — color reflections") .. mk("ambilight"),
                      on = msg("ambilight") },
                    { label = T("2  Expansion difuminada", "2  Blurred expansion") .. mk("blur"),
                      on = msg("blur") },
                    { label = T("3  Cine sutil — estilo YouTube",
                                "3  Subtle cinema — YouTube style") .. mk("sutil"),
                      on = msg("sutil") },
                }
            end },
            { label = T("Pista de audio", "Audio track"),
              submenu = function() return track_items("audio") end },
            { label = T("Subtitulos", "Subtitles"), submenu = sub_items },
            { label = T("Idioma / Language"), submenu = function()
                local function mark(l, txt)
                    return txt .. (LANG == l and "   <<" or "")
                end
                return {
                    { label = mark("es", "Español"),  on = function() set_lang("es") end },
                    { label = mark("en", "English"),  on = function() set_lang("en") end },
                }
            end },
            { label = T("TODO limpio (remux puro)", "ALL clean (pure remux)"), on = all_clean },
            { label = T("Abrir pelicula...", "Open movie..."), on = open_file, close = true },
    }
end

-- ------------------------------------------------------------
-- render
-- ------------------------------------------------------------

local function render()
    local m = stack[#stack]
    -- regenerar los items en cada pintado: los marcadores << reflejan
    -- siempre el estado real, y elegir una opcion no cierra el menu
    m.items = m.gen()
    if m.sel > #m.items then m.sel = #m.items end
    if m.sel < 1 then m.sel = 1 end
    local x0, w = 84, 520
    local n = #m.items
    local line_h = 37
    local top = 120
    local panel_top = top - 52
    local panel_h = 52 + 14 + n * line_h + 46
    local L = {}
    L[#L + 1] = string.format(
        "{\\an7\\pos(0,0)\\bord0\\shad0\\1c%s\\1a&H2E&\\p1}m %d %d l %d %d l %d %d l %d %d{\\p0}",
        C_PANEL, x0 - 28, panel_top, x0 + w, panel_top,
        x0 + w, panel_top + panel_h, x0 - 28, panel_top + panel_h)
    L[#L + 1] = string.format(
        "{\\an7\\pos(%d,%d)\\bord0\\shad0\\fs31\\b1\\1c%s}%s",
        x0, panel_top + 8, C_TITLE, m.title)
    for i, it in ipairs(m.items) do
        local y = top + 8 + (i - 1) * line_h
        local marker = it.submenu and "  >" or ""
        if i == m.sel then
            L[#L + 1] = string.format(
                "{\\an7\\pos(%d,%d)\\bord0\\shad0\\fs26\\b1\\1c%s}>  %s%s",
                x0, y, C_SEL, it.label, marker)
        else
            L[#L + 1] = string.format(
                "{\\an7\\pos(%d,%d)\\bord0\\shad0\\fs26\\1c%s}    %s%s",
                x0, y, C_TEXT, it.label, marker)
        end
    end
    L[#L + 1] = string.format(
        "{\\an7\\pos(%d,%d)\\bord0\\shad0\\fs17\\1c%s}%s",
        x0, panel_top + panel_h - 32, C_DIM,
        T("flechas: mover      Enter: elegir      izq: volver      Esc / m: cerrar",
          "arrows: move      Enter: select      left: back      Esc / m: close"))
    ov.data = table.concat(L, "\n")
    ov:update()
end

-- ------------------------------------------------------------
-- navegacion
-- ------------------------------------------------------------

local key_names = {}

local function unbind()
    for _, name in ipairs(key_names) do mp.remove_key_binding(name) end
    key_names = {}
end

local function close_menu()
    if not is_open then return end
    is_open = false
    stack = {}
    ov:remove()
    unbind()
end

local function nav(d)
    local m = stack[#stack]
    m.sel = m.sel + d
    if m.sel < 1 then m.sel = #m.items end
    if m.sel > #m.items then m.sel = 1 end
    render()
end

local function go_back()
    if #stack > 1 then
        table.remove(stack)
        render()
    else
        close_menu()
    end
end

local function enter_item()
    local m = stack[#stack]
    local it = m.items[m.sel]
    if not it then return end
    if it.submenu then
        local title = it.label:gsub("%s*<<%s*$", "")
        stack[#stack + 1] = { title = title, sel = 1, gen = it.submenu }
        render()
    elseif it.on then
        if it.close then
            close_menu()
            it.on()
        else
            -- el menu queda abierto: se cierra solo con Esc / m / izq
            it.on()
            render()
        end
    end
end

local function bind()
    local function add(key, name, fn, opts)
        mp.add_forced_key_binding(key, name, fn, opts)
        key_names[#key_names + 1] = name
    end
    add("UP",    "m35-up",    function() nav(-1) end, { repeatable = true })
    add("DOWN",  "m35-down",  function() nav(1) end,  { repeatable = true })
    add("WHEEL_UP",   "m35-wup",   function() nav(-1) end)
    add("WHEEL_DOWN", "m35-wdown", function() nav(1) end)
    add("ENTER",     "m35-enter",   enter_item)
    add("KP_ENTER",  "m35-kpenter", enter_item)
    add("RIGHT",     "m35-right",   enter_item)
    add("LEFT",      "m35-left",    go_back)
    add("ESC",       "m35-esc",     close_menu)
    add("m",         "m35-close",   close_menu)
end

local function open_menu()
    if is_open then close_menu() return end
    is_open = true
    stack = { { title = "35MM EMULATOR", sel = 1, gen = root_items } }
    bind()
    render()
end

-- re-pintar en vivo cuando cambia el estado (los presets confirman
-- por mensaje asincrono; asi el << se actualiza al instante)
local function rerender()
    if is_open then render() end
end
mp.observe_property("user-data/35mm-audio", "native", rerender)
mp.observe_property("user-data/35mm-ambient", "native", rerender)
mp.observe_property("user-data/sub35-cine", "native", rerender)
mp.observe_property("glsl-shaders", "native", rerender)
mp.observe_property("track-list", "native", rerender)

mp.add_key_binding("m", "menu-toggle", open_menu)
mp.add_key_binding("MBTN_RIGHT", "menu-toggle-mouse", open_menu)

-- limpieza total tambien invocable desde input.conf (tecla 0)
mp.register_script_message("all-clean", all_clean)
mp.register_script_message("set-lang", set_lang)
