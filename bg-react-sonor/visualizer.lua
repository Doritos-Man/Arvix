require 'cairo'

local bg_image = nil
local img_w, img_h = 0, 0
local image_loaded = false
local cairo_line_to = cairo_line_to
local cairo_move_to = cairo_move_to
local insert = table.insert
local tour = 0
-- Interpolation Catmull-Rom (La fonction reste la même)
function catmull_rom(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t
    return 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3)
end

function conky_draw_wave()
    if conky_window == nil then return end
    
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    
    -- 1. Chargement de l'image (Une seule fois au démarrage)
    if not image_loaded then
        bg_image = cairo_image_surface_create_from_png("/home/jean/Arvix/bg-react-sonor/audiobg.png")
        if cairo_surface_status(bg_image) == CAIRO_STATUS_SUCCESS then
            img_w = cairo_image_surface_get_width(bg_image)
            img_h = cairo_image_surface_get_height(bg_image)
            image_loaded = true
        end
    end

    local fifo = io.open('/dev/shm/arvix_cava.fifo', 'r')
    if fifo then
        local line = fifo:read('*l')
        fifo:close()
        
        if line then
            local values = {}
            for value in string.gmatch(line, '([^;]+)') do insert(values, tonumber(value) or 0) end
            
            if #values > 3 then
                local w, h = conky_window.width, conky_window.height
                local segments = 10
                local fc = (h * 0.95) / 100
                local step = w / ((#values - 1) * segments)
                
                local y_first = h - values[1] * fc
                cairo_move_to(cr, 0, y_first)
                
                for i = 1, #values - 1 do
                    local p0, p1, p2, p3 = values[math.max(1, i-1)], values[i], values[i+1], values[math.min(#values, i+2)]
                    for j = 0, segments - 1 do
                        local t = j / segments
                        local y = h - catmull_rom(p0, p1, p2, p3, t) * fc
                        cairo_line_to(cr, ((i - 1) * segments + j) * step, y)
                    end
                end
                -- Fermeture de la forme pour le remplissage
                cairo_line_to(cr, w, h - values[#values] * fc)
                cairo_line_to(cr, w, h)
                cairo_line_to(cr, 0, h)
                cairo_close_path(cr)

                cairo_clip(cr)
                
                cairo_scale(cr, w/img_w, h/img_h)
                cairo_set_source_surface(cr, bg_image, 0, 0)
                cairo_paint(cr)
                
                cairo_stroke(cr)

            end
        end
    end
    
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end