require 'cairo'

local bg_image = nil
local img_w, img_h = 0, 0
local image_loaded = false

-- Interpolation Catmull-Rom
function catmull_rom(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t
    return 0.5 * ((2 * p1) + (-p0 + p2) * t + (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 + (-p0 + 3 * p1 - 3 * p2 + p3) * t3)
end

function conky_draw_wave()
    if conky_window == nil then return end
    
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    
    -- Chargement de l'image (une seule fois)
    if not image_loaded then
        bg_image = cairo_image_surface_create_from_png("/home/jean/Arvix/bg-react-sonor/audio2bg.png")
        if cairo_surface_status(bg_image) == CAIRO_STATUS_SUCCESS then
            img_w = cairo_image_surface_get_width(bg_image)
            img_h = cairo_image_surface_get_height(bg_image)
            image_loaded = true
        else
            print("Erreur chargement image")
        end
    end

    local fifo = io.open('/dev/shm/cava.fifo', 'r')
    if fifo then
        local line = fifo:read('*l')
        fifo:close()
        
        if line then
            local values = {}
            for value in string.gmatch(line, '([^;]+)') do
                table.insert(values, tonumber(value) or 0)
            end
            
            if #values > 3 and image_loaded then
                local w, h = conky_window.width, conky_window.height
                local segments = 10
                local fc = (h*0.96)/100--Facteur de grandissement 
                local step = w / ((#values - 1) * segments)
                
                -- Sauvegarder l'état
                cairo_save(cr)
                
                -- Créer le chemin de la courbe
                local y_first = h - values[1] * fc
                cairo_move_to(cr, 0, y_first)
                
                -- courbe lisse
                for i = 1, #values - 1 do
                    local p0 = values[math.max(1, i - 1)]
                    local p1 = values[i]
                    local p2 = values[i + 1]
                    local p3 = values[math.min(#values, i + 2)]
                    
                    for j = 0, segments - 1 do
                        local t = j / segments
                        local y = h - catmull_rom(p0, p1, p2, p3, t) * fc
                        local x = ((i - 1) * segments + j) * step
                        cairo_line_to(cr, x, y)
                    end
                end
                
                -- Fermer la forme
                cairo_line_to(cr, w, h - values[#values] * fc)
                cairo_line_to(cr, w, h)
                cairo_line_to(cr, 0, h)
                cairo_close_path(cr)
                cairo_clip(cr)
                

                --cairo_scale(cr, w / img_w, h / img_h) -- Si image de meme taille que l'ecran
                cairo_set_source_surface(cr, bg_image, 0, 0)
                cairo_paint(cr)
                
                -- Restaurer l'état
                cairo_restore(cr)
            end
        end
    end
    
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end