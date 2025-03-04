local weapon_names = {
    [0] = "None",
    [1] = "Desert Eagle",
    [2] = "Dual Berettas",
    [3] = "Five-SeveN",
    [4] = "Glock-18",
    [7] = "AK-47",
    [8] = "AUG",
    [9] = "AWP",
    [10] = "FAMAS",
    [11] = "G3SG1",
    [13] = "Galil AR",
    [14] = "M249",
    [16] = "M4A4",
    [17] = "MAC-10",
    [19] = "P90",
    [20] = "Zone Repulsor",
    [23] = "MP5-SD",
    [24] = "UMP-45",
    [25] = "XM1014",
    [26] = "PP-Bizon",
    [27] = "MAG-7",
    [28] = "Negev",
    [29] = "Sawed-Off",
    [30] = "Tec-9",
    [31] = "Zeus x27",
    [32] = "P2000",
    [33] = "MP7",
    [34] = "MP9",
    [35] = "Nova",
    [36] = "P250",
    [37] = "Shield",
    [38] = "SCAR-20",
    [39] = "SG 553",
    [40] = "SSG-08",
    [41] = "Golden Knife",
    [42] = "Knife",
    [43] = "Flashbang",
    [44] = "HE Grenade",
    [45] = "Smoke Grenade",
    [46] = "Molotov",
    [47] = "Decoy Grenade",
    [48] = "Incendiary Grenade",
    [49] = "C4 Explosive",
    [50] = "Health Shot",
    [51] = "Terrorist Knife",
    [60] = "M4A1-S",
    [61] = "USP-S",
    [63] = "CZ75-Auto",
    [64] = "R8 Revolver",
    [68] = "Tactical Awareness Grenade",
    [69] = "Fists",
    [70] = "Breach Charge",
    [72] = "Tablet",
    [74] = "Melee",
    [75] = "Axe",
    [76] = "Hammer",
    [78] = "Spanner (Wrench)",
    [80] = "Ghost Knife",
    [81] = "Firebomb",
    [82] = "Diversion Device",
    [83] = "Frag Grenade",
    [84] = "Snowball",
    [85] = "Bump Mine",
    [500] = "Bayonet",
    [503] = "Classic Knife",
    [505] = "Flip Knife",
    [506] = "Gut Knife",
    [507] = "Karambit",
    [508] = "M9 Bayonet",
    [509] = "Huntsman Knife",
    [512] = "Falchion Knife",
    [514] = "Bowie Knife",
    [515] = "Butterfly Knife",
    [516] = "Shadow Daggers",
    [517] = "Paracord Knife",
    [518] = "Survival Knife",
    [519] = "Ursus Knife",
    [520] = "Navaja Knife",
    [521] = "Nomad Knife",
    [522] = "Stiletto Knife",
    [523] = "Talon Knife",
    [525] = "Skeleton Knife",
    [526] = "Kukri Knife"
}

local weapon_type_names = {
    [0]  = "Knife",
    [1]  = "Pistols",
    [2]  = "SMGs",
    [3]  = "Rifles",
    [4]  = "Heavy",
    [5]  = "Auto Snipers",  -- 原 sniper_rifle
    [6]  = "Bolt Snipers",  -- 原 machinegun
    [7]  = "C4",
    [8]  = "Taser",
    [9]  = "Grenades",  -- 原 grenade
    [10] = "Stackable Items",
    [11] = "Fists",
    [12] = "Breach Charge",
    [13] = "Bump Mine",
    [14] = "Tablet",
    [15] = "Melee",
    [16] = "Shield",
    [17] = "Zone Repulsor",
    [18] = "Unknown"
}

function normalize_yaw(yaw)
    return ((yaw + 180) % 360) - 180
end
    
function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end


local luaA = gui.ctx:find('lua>elements a');
local invisble_aimbot = gui.checkbox(gui.control_id('invisble aimbot'))
local disable_Distance = gui.slider(gui.control_id('aimobt_disable_Distance'), 0, 35, {'%.0fpx'})
local aimbot_smooth = gui.slider(gui.control_id('aimobt smooth'), 0, 100, {'%.0fdeg'})

local row_invisble_aimbot = gui.make_control('invisble aimbot', invisble_aimbot);
local row_disable_Distance = gui.make_control('aimbot Disable', disable_Distance);
local row_aimbot_smooth = gui.make_control('aimbot smooth', aimbot_smooth);
luaA:add(row_invisble_aimbot)
luaA:add(row_disable_Distance)
luaA:add(row_aimbot_smooth)
luaA:reset()


function aimbot()
    local lp = entities.get_local_pawn();
    local view_angles = game.input:get_view_angles();
    local w,h = game.engine:get_screen_size(); 

    local Nearest_aimbot_player_distance = math.huge
    if not lp or not lp:is_alive() or not view_angles then
        return
    end


    local new_target = nil
    entities.players:for_each(function(entry)
        if entry and entry.had_dataupdate and entry.entity:is_alive() and entry.entity ~= lp and entry.entity:is_enemy() then
            local enemy_pos = entry.entity:get_eye_pos()
            
            local point = math.world_to_screen(enemy_pos)
            local crosshair_vec2 = draw.vec2(w / 2, h / 2)
            local enemy_to_distance = math.sqrt((crosshair_vec2.x - point.x)^2 + (crosshair_vec2.y - point.y)^2)

            
            if enemy_to_distance < Nearest_aimbot_player_distance then
                Nearest_aimbot_player_distance = enemy_to_distance  
                new_target = entry.handle  
            end
        end


    end)


    if new_target and new_target:valid() and new_target:get() and invisble_aimbot:get_value():get() then
        new_target = new_target:get()
        local enemy_pos = new_target:get_eye_pos()
        local eye_pos = lp:get_eye_pos()
        local point = math.world_to_screen(enemy_pos)
        local crosshair_vec2 = draw.vec2(w / 2, h / 2)
        local enemy_to_distance = math.sqrt((crosshair_vec2.x - point.x)^2 + (crosshair_vec2.y - point.y)^2)

        local dir = math.vec3(enemy_pos.x - eye_pos.x, 
        enemy_pos.y - eye_pos.y, 
        enemy_pos.z - eye_pos.z)

        local raw_target_yaw = math.deg(math.atan2(dir.y, dir.x))
        local target_pitch = math.deg(math.atan2(-dir.z, math.sqrt(dir.x * dir.x + dir.y * dir.y)))

        raw_target_yaw = normalize_yaw(raw_target_yaw)    
        target_pitch = clamp(target_pitch, -89, 89)

        local delta_yaw = normalize_yaw(raw_target_yaw - view_angles.y)
        local delta_pitch = target_pitch - view_angles.x

        local weapon = lp:get_active_weapon()
        local weapon_fov_int = 0
        local weapon_fov_Gui = "legit>weapon>" .. weapon_names[weapon:get_id()] .. ">aim>aim fov"

        if not gui.ctx:find(weapon_fov_Gui) then
            weapon_fov_Gui = "legit>weapon>" .. weapon_type_names[weapon:get_type()] .. ">aim>aim fov"
            if not gui.ctx:find(weapon_fov_Gui) then
                weapon_fov_Gui = "legit>weapon>general>aim>aim fov"
                weapon_fov_int = gui.ctx:find(weapon_fov_Gui):get_value():get()
            end
            weapon_fov_int = gui.ctx:find(weapon_fov_Gui):get_value():get()
        else
            weapon_fov_int = gui.ctx:find(weapon_fov_Gui):get_value():get()
        end

        if enemy_to_distance > weapon_fov_int * 9 then
            return
        end

        if enemy_to_distance < disable_Distance:get_value():get() then
            return
        end

        local gui_smooth = aimbot_smooth:get_value():get()
        local smooth = gui_smooth * 0.01
        local smooth_factor = math.max(0.05, 1 - smooth) 

        local smoothed_yaw = normalize_yaw(view_angles.y + delta_yaw * smooth_factor)
        local smoothed_pitch = clamp(view_angles.x + delta_pitch * smooth_factor, -89, 89)

        game.input:set_view_angles(math.vec3(smoothed_pitch, smoothed_yaw, 0))




    end
end

events.present_queue:add(aimbot)
