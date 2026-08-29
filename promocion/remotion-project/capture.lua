-- Captura fotograma a fotograma la salida REAL del renderizador
-- (con los shaders de GRAINLIGHT aplicados) a una secuencia PNG.
local dir   = os.getenv("CAPDIR")
local total = tonumber(os.getenv("CAPFRAMES")) or 96
local i = 0
local busy = false

local function shoot()
    if busy then return end
    busy = true
    if i >= total then
        mp.msg.info("CAPTURA COMPLETA: " .. i .. " frames")
        mp.command("quit")
        return
    end
    mp.commandv("screenshot-to-file",
                string.format("%s/f%05d.png", dir, i), "window")
    i = i + 1
    mp.command("frame-step")
    busy = false
    mp.add_timeout(0.05, shoot)
end

mp.register_event("file-loaded", function()
    mp.set_property_bool("pause", true)
    mp.set_property("osd-level", "0")
    mp.add_timeout(1.2, shoot)
end)
