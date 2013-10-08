--[[
Clock Rings by anotherkamila, modified by gkoutsou

This script draws percentage meters as rings, and also draws clock hands! 
It is fully customisable; all options are described in the script. 

IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation fault if it tries to draw a ring straight away. 

To call this script in Conky, use the following (assuming that you save this script to ~/scripts/rings.lua):
	lua_load ~/scripts/clock_rings-v1.1.1.lua
	lua_draw_hook_pre clock_rings
To be able to change the colours when having updates (assuming you are using pacman) use the following
	${execi 119 ~/.config/conky/bin/update.bash}
	${execi 60 ~/.config/conky/bin/packages.bash}
To display the image, use the following
	${lua_parse draw_image}

Changelog:
+ v1.0 -- Original release (27.05.2013)
]]

--default_color = 0xd5ec8e
default_color_normal = 0x64A2CC
default_color_alert = 0xF2B9B9
default_color = default_color_normal
default_alpha = 0.5
default_center_x = 175
default_center_y = 175

-- Default colors for rings
ring_bg_alpha = 0.2
ring_fg_alpha = default_alpha

-- Image parameters
image_path = "~/.config/conky/images/arch_logo_normal.png"
image_path_alert = "~/.config/conky/images/arch_logo_alert.png"
image_selected = image_path
image_pos_x = 150
image_pos_y = 145

-- Clock coordinates
clock_x = default_center_x
clock_y = default_center_y

-- Clock hands parameters
clock_hour_r = 5
clock_hour_path_r = 59 + 3 + clock_hour_r
clock_mins_r = 3
clock_mins_path_r = 59 + 5 + clock_mins_r 

-- Clock hands colour & alpha
clock_hour_hand_color = 0xE88413
clock_mins_hand_color = 0xd5ec8e

-- Gauges parameters
gauges_num = 12
gauges_color = default_color
gauges_r = 125
gauges_big_start_r = 0.68 * gauges_r
gauges_big_end_r = 1.4 * gauges_r
gauges_small_start_r = 0.78 * gauges_r
gauges_small_end_r = 1.1 * gauges_r
--clock_gauges_alpha = default_alpha

settings_table = {
	{
		name = 'cpu',
		arg = 'cpu1',
		max = 100,
		x = default_center_x, y = default_center_y,
		radius = 52,
		thickness = 2,
		start_angle = 121,
		end_angle = 179,
		backwards = true
	},
	{
		name = 'cpu',
		arg = 'cpu2',
		max = 100,
		x = default_center_x, y = default_center_y,
		radius = 52,
		thickness = 2,
		start_angle = 181,
		end_angle = 239
	},
	{
		name = 'memperc',
		arg = '',
		max = 100,
		x = default_center_x, y = default_center_y,
		radius = 52,
		thickness = 5,
		start_angle = 1,
		end_angle = 118,
		backwards = true
	},
	{
		name = 'swapperc',
		arg = '',
		max = 100,
		x = default_center_x, y = default_center_y,
		radius = 52,
		thickness = 5,
		start_angle = 242,
		end_angle = 359
	},
	{
		name = 'fs_used_perc',
		arg  = '/',
		max  = 100,
		x = default_center_x, y = default_center_y,
		radius = 59,
		thickness = 3,
		start_angle = 1,
		end_angle = 359
	},
	{
		name = 'downspeedf',
		arg  = 'wlp3s0',
		max  = 10e3,
		x = default_center_x, y = default_center_y,
		radius = 75,
		thickness = 2,
		start_angle = 20,
		end_angle = 160
	},
	{
		name = 'upspeedf',
		arg  = 'wlp3s0',
		max  = 10e3,
		x = default_center_x, y = default_center_y,
		radius = 78,
		thickness = 2,
		start_angle = 20,
		end_angle = 160
	},
	{
		name = 'diskio_read',
		arg  = '/dev/sda',
		max  = 50e6,
		x = default_center_x, y = default_center_y,
		radius = 75,
		thickness = 2,
		start_angle = 200,
		end_angle = 340,
		backwards = true
	},
	{
		name = 'diskio_write',
		arg  = '/dev/sda',
		max  = 50e6,
		x = default_center_x, y = default_center_y,
		radius = 78,
		thickness = 2,
		start_angle = 200,
		end_angle = 340,
		backwards = true
	}
}

require 'cairo'

function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
	local w,h=conky_window.width,conky_window.height

	local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
	
	local angle_0=sa*(2*math.pi/360)-math.pi/2
	local angle_f=ea*(2*math.pi/360)-math.pi/2
	local t_arc=t*(angle_f-angle_0)

	-- Draw background ring
	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(default_color, ring_bg_alpha))
	cairo_set_line_width(cr, ring_w)
	cairo_stroke(cr)

	-- Draw indicator ring
	if pt['backwards'] then
		cairo_arc(cr,xc,yc,ring_r,angle_f-t_arc,angle_f)
	else
		cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
	end
	cairo_set_source_rgba(cr, rgb_to_r_g_b(default_color, ring_fg_alpha))
	cairo_stroke(cr)
end

function draw_clock_hands(cr,xc,yc)
	local mins, hours, mins_arc, hours_arc
	local hour_hand_x, hour_hand_y, mins_hand_x, mins_hand_y 

	cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)

	mins  = os.date("%M")
	hours = os.date("%I")

	mins_arc  = (2*math.pi/60)*mins
	hours_arc = (2*math.pi/12)*hours+mins_arc/12

	-- Draw hour hand
	hour_hand_x = xc + clock_hour_path_r*math.sin(hours_arc)
	hour_hand_y = yc - clock_hour_path_r*math.cos(hours_arc)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(clock_hour_hand_color, default_alpha))
	cairo_arc(cr, hour_hand_x, hour_hand_y, clock_hour_r, 0, 2*math.pi)
	cairo_stroke(cr)
	--cairo_fill(cr)

	-- Draw minute hand
	mins_hand_x = xc + clock_mins_path_r*math.sin(mins_arc)
	mins_hand_y = yc - clock_mins_path_r*math.cos(mins_arc)

	cairo_set_source_rgba(cr, rgb_to_r_g_b(clock_mins_hand_color, default_alpha))
	cairo_arc(cr, mins_hand_x, mins_hand_y, clock_mins_r, 0, 2*math.pi)
	cairo_stroke(cr)
	--cairo_fill(cr)
end

function draw_clock_gauges(cr, xc, yc)
	local step = 2*math.pi/gauges_num;

	cairo_set_line_width(cr, 1)
	for i = 0, gauges_num-1 do
		local gx_i = xc + ((i%2 == 0) and gauges_big_start_r or gauges_small_start_r)*math.sin(i*step)
		local gy_i = yc - ((i%2 == 0) and gauges_big_start_r or gauges_small_start_r)*math.cos(i*step)
		local gx_o = xc + ((i%2 == 0) and gauges_big_end_r or gauges_small_end_r)*math.sin(i*step)
		local gy_o = yc - ((i%2 == 0) and gauges_big_end_r or gauges_small_end_r)*math.cos(i*step)

		local pat = cairo_pattern_create_linear(gx_i,gy_i,gx_o,gy_o)
		cairo_pattern_add_color_stop_rgba(pat, 0, rgb_to_r_g_b(gauges_color,default_alpha))
		cairo_pattern_add_color_stop_rgba(pat, 1, rgb_to_r_g_b(gauges_color,0))

		cairo_set_source(cr,pat)

		cairo_move_to(cr, gx_i,gy_i)
		cairo_line_to(cr, gx_o,gy_o)

		cairo_stroke(cr)
	end
end

function check_alert()
	local alert=conky_parse("${if_existing /home/gkoutsou/test 1}1${else}0${endif}")
	if alert == "1" then
		gauges_color = default_color_alert
		default_color = default_color_alert
		image_selected = image_path_alert
	else
		gauges_color = default_color_normal
		default_color = default_color_normal
		image_selected = image_path
	end

end

function conky_draw_image()
	return "${image " .. image_selected .. " -p " .. image_pos_x .."," .. image_pos_y .."}"
end

function conky_clock_rings()
	local function setup_rings(cr,pt)
		local str=''
		local value=0

		str=string.format('${%s %s}',pt['name'],pt['arg'])
		str=conky_parse(str)

		value=tonumber(str)
		if value == nil then value = 0 end
		pct=value/pt['max']

		draw_ring(cr,pct,pt)
	end

	-- Check that Conky has been running for at least 5s

	if conky_window==nil then return end
	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

	local cr=cairo_create(cs)	

	local updates=conky_parse('${updates}')
	update_num=tonumber(updates)

	if update_num > 2 then
		for i in pairs(settings_table) do
			setup_rings(cr,settings_table[i])
		end
	else
		for i in pairs(settings_table) do
			draw_ring(cr, 0, settings_table[i])
		end
	end

	check_alert()
	draw_clock_hands(cr,clock_x,clock_y)
	draw_clock_gauges(cr, clock_x, clock_y)
end
