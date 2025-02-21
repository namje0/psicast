local cd_alpha, stim_alpha, dose_alpha, bar_alpha, cast_alpha, target_alpha, channel_alpha = 0, 0, 0, 0, 0, 0, 0

local target_lang = {
    ["prop_door_rotating"] = "Door",
    ["func_door"] = "Door",
    ["prop_physics"] = "Object",
}
local psi_bar = {
    x = ScreenScale(14),
    y = ScrH() - ScreenScale(45),
    w = ScreenScale(76.5),
    h = ScreenScale(5)
}
local bar_length = psi_bar.w
local trail_length = psi_bar.w

surface.CreateFont( "namjepsi_hud", {
    font = "Noto Sans SemiBold",
    extended = false,
    size = 30,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "namjepsi_hud_small", {
    font = "Noto Sans SemiBold",
    extended = false,
    size = 20,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

surface.CreateFont( "namjepsi_ui", {
    font = "Noto Sans SemiBold",
    extended = false,
    size = 52,
    weight = 800,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

local function namjepsi_hud()
    local ply = LocalPlayer()
    if !ply:GetNW2Bool("namjepsi_awakened") then return end

    local stim_amount = ply:GetAmmoCount( "namje_psychostim" )
    local energy = ply:GetNW2Float("namjepsi_energy")
    local max_energy = ply:GetNW2Int("namjepsi_max_energy")

    local psi_bar_bg_color = Color(78, 75, 66, bar_alpha)
    local psi_bar_color = Color(230, 221, 175, bar_alpha)
    local psi_trail_color = Color(153, 144, 120, bar_alpha)
    local psi_over_color = Color(186, 120, 174, bar_alpha)

    --energy bar
    if energy == max_energy then
        bar_alpha = math.Approach(bar_alpha, 0, 255 * FrameTime() * .7)
    else
        bar_alpha = math.Approach(bar_alpha, 255, 255 * FrameTime() * 2)
    end

    bar_length = psi_bar.w * math.Clamp(energy / max_energy, 0, 1)
    trail_length = math.Approach(trail_length, bar_length, FrameTime() * 70)
    if trail_length < bar_length then
        trail_length = bar_length
    end

    surface.SetDrawColor(psi_bar_bg_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, psi_bar.w, psi_bar.h)

    surface.SetDrawColor(psi_trail_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, trail_length, psi_bar.h)

    surface.SetDrawColor(psi_bar_color)
    surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, bar_length, psi_bar.h)

    local over_energy = energy - max_energy
    if over_energy > 0 then
        surface.SetDrawColor(psi_over_color)
        surface.DrawRect(psi_bar.x - (psi_bar.w / 20 / 2), psi_bar.y, psi_bar.w * (over_energy / max_energy), psi_bar.h)
    end

    --draw.SimpleText(math.floor(energy) .. "%", "GModToolHelp", ScreenScale(13), ScrH() - ScreenScale(45.2), psi_bar_bg_color, TEXT_ALIGN_BOTTOM, TEXT_ALIGN_RIGHT)

    --stim count
    surface.SetDrawColor(Color(255,255,255, stim_alpha))
    surface.SetMaterial(Material("vgui/stimlogo.png"))
    surface.DrawTexturedRect( ScreenScale(11), ScrH() - ScreenScale(63), ScreenScale(12), ScreenScale(12) )
    draw.SimpleText(stim_amount > 99 and "99+" or stim_amount, "GModToolSubtitle", ScreenScale(22), ScrH() - ScreenScale(62), Color(255, 255, 255, stim_alpha), TEXT_ALIGN_BOTTOM, TEXT_ALIGN_RIGHT)

    if stim_amount > 0 then
        stim_alpha = math.Approach(stim_alpha, 255, 255 * FrameTime() / 0.5)
    else
        stim_alpha = math.Approach(stim_alpha, 0, 255 * FrameTime() / 1)
    end

    --target
    if namjepsi.casting then
        local ability
        if namjepsi.current_slot then
            ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
        end
        if !ability then return end
        local is_targeting = istable(ability.targeting)
        if !is_targeting then
            target_alpha = 0
            return
        end
        target_alpha = math.Approach(target_alpha, 200, 200 * FrameTime() * 2)
        local target = !namjepsi.target and "none" or namjepsi.target:GetClass() == "player" and namjepsi.target:Name() or target_lang[namjepsi.target:GetClass()] or namjepsi.target:GetClass()
        draw.SimpleTextOutlined("TARGET: " .. target, "namjepsi_hud", ScrW() / 2, ScrH() - 380, Color(255, 255, 255, target_alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, math.Clamp(target_alpha, 0, 80)))
        if table.HasValue(ability.targeting, "player") then
            local text = namjepsi.self_target and "Cancel self target" or "Target self"
            draw.SimpleTextOutlined("[E] " .. text, "namjepsi_hud_small", ScrW() / 2, ScrH() - 350, Color(255, 255, 255, target_alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, math.Clamp(target_alpha, 0, 80)))
        end
    else
        target_alpha = 0
    end
end
hook.Add("HUDPaint", "namjepsi_hud", namjepsi_hud)

local function namjepsi_hand_ui(hands)
    local bone = hands:LookupBone("ValveBiped.Bip01_L_Hand") or hands:LookupBone("L Hand")
    if bone == nil then return end
    local hand = hands:GetBoneMatrix(bone)

    if hand and namjepsi.casting then 
        local alpha_factor = .75
        if game.SinglePlayer() and GetConVar("namjepsi_cast_slow"):GetBool() then
            alpha_factor = .5
        end
        cast_alpha = math.Approach(cast_alpha, 255, 255 * FrameTime() / alpha_factor)

        local ability, cooldown
        if namjepsi.current_slot then
            ability = namjepsi.abilities[LocalPlayer().namjepsi_slots[namjepsi.current_slot]]
            local cooldowns = LocalPlayer().namjepsi_cooldowns
            if cooldowns then
                cooldown = cooldowns[ability.intName]
            end
        end

        local pos, ang = ((hand:GetTranslation() + hand:GetAngles():Forward() * 3.2)  + hand:GetAngles():Right() * 2) + hand:GetAngles():Up() * 2.5, hand:GetAngles()
        ang:RotateAroundAxis(hand:GetAngles():Forward(),90)
        ang:RotateAroundAxis(hand:GetAngles():Right(), -28)

        cam.Start3D2D(pos, ang, 0.01)
        --draw.SimpleText("Energy: " .. math.floor(energy) .. "%", "GModToolHelp", 0, 0, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        --draw.SimpleText("Stim: " .. (stim_amount > 99 and "99+" or stim_amount), "GModToolHelp", 0, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(Color(78, 75, 66, math.Clamp(cast_alpha, 0, 155)))
        surface.DrawRect(0, 0, 300, 300)

        surface.SetDrawColor(ability and Color(ability.theme.r, ability.theme.g, ability.theme.b, cast_alpha) or Color(150,150,150, cast_alpha))
        surface.SetMaterial(Material("vgui/gradient.png"))
        surface.DrawTexturedRect( 0, 0, 300, 300 )

        surface.SetDrawColor(Color(255, 255 ,255, cast_alpha))
        surface.SetMaterial(ability and Material(ability.icon) or Material("vgui/noability.png"))
        surface.DrawTexturedRect( 0, 0, 300, 300 )

        --active cooldown
        if cooldown and ability then
            local time_remaining = math.max(0, cooldown - CurTime())
            local height = 300 * math.Clamp(time_remaining / ability.cooldown, 0, 1)
            surface.SetDrawColor(Color(206, 324, 74, math.Clamp(cast_alpha, 0, 200)))
            surface.DrawRect(0, 301 - height, 300, height, 0, 1)
        end

        --cost
        local can_cast = ability and LocalPlayer():GetNW2Float("namjepsi_energy") >= ability.cost()
        surface.SetDrawColor(can_cast and Color(206, 324, 74, cast_alpha) or Color(78, 75, 50, cast_alpha))
        surface.DrawRect(320, 0, 130, 50)

        surface.SetDrawColor(can_cast and Color(255, 255 ,255, cast_alpha) or Color(206, 324, 74, cast_alpha))
        surface.SetMaterial(Material("vgui/energy.png"))
        surface.DrawTexturedRect( 320, 0, 50, 50 )

        local cost
        if ability.castType == 1 then
            cost = ability and ability.cost()
        elseif ability.castType == 2 then
            cost = ability and ability.cost() / .2 .. "/s"
        end

        draw.SimpleText(cost or "--", "namjepsi_ui", 445, 51, can_cast and Color(78, 75, 50, cast_alpha) or Color(183, 66, 73, cast_alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        --cooldown
        surface.SetDrawColor(Color(78, 75, 50, cast_alpha))
        surface.DrawRect(320, 70, 150, 50)

        surface.SetDrawColor(Color(180, 180, 180, cast_alpha))
        surface.SetMaterial(Material("vgui/cooldown.png"))
        surface.DrawTexturedRect( 320, 70, 50, 50 )

        draw.SimpleText(ability and ability.cooldown .. "s" or "--", "namjepsi_ui", 465, 122, Color(255, 255, 255, cast_alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        cam.End3D2D()
    else
        cast_alpha = 0
    end
end

local function namjepsi_fx()
    local ply = LocalPlayer()
    if !IsValid(ply) and !ply:Alive() then return end
    local cursor = Material( "particle/particle_glow_04" )
    if !ply.namjepsi_slots or !namjepsi.current_slot then return end

    local ability = namjepsi.abilities[ply.namjepsi_slots[namjepsi.current_slot]]
    if !ability then return end

    if namjepsi.channeling and !namjepsi.self_target then
        channel_alpha = math.Approach(channel_alpha, 255, 255 * FrameTime() / 0.5)

        local args = namjepsi.channel_args
        if !IsValid(args) then return end
        cam.Start3D() -- Start the 3D function so we can draw onto the screen.
        render.StartWorldRings()
        render.AddWorldRing(type(args) != "Vector" and args:GetPos() or args, ability.channelRange + math.sin(RealTime() * 3), 2, 32)
        render.FinishWorldRings(Color(ability.theme.r, ability.theme.g, ability.theme.b, channel_alpha))
        render.SetMaterial(cursor)
        cam.End3D()
    else
        channel_alpha = 0
    end

    if !namjepsi.casting then return end
    local target_entities = istable(ability.targeting)

    if target_entities then
        local target
        namjepsi.pos = nil
        local target_types = ability.targeting
        if ability.areaTargeting then
            target = ability.areaTargeting(ply, namjepsi.range, namjepsi.self_target)
        else
            if namjepsi.self_target and table.HasValue(ability.targeting, "player") then
                target = ply
            else
                local tr = util.TraceLine( {
                    start = ply:GetShootPos(),
                    endpos = ply:GetShootPos() + ply:GetAimVector() * namjepsi.range,
                    filter = ply,
                    mask = MASK_SHOT_HULL
                } )
                if ( !IsValid( tr.Entity ) ) then
                    tr = util.TraceHull( {
                        start = ply:GetShootPos(),
                        endpos = ply:GetShootPos() + ply:GetAimVector() * namjepsi.range,
                        filter = ply,
                        mins = Vector( -10, -10, -8 ),
                        maxs = Vector( 10, 10, 8 ),
                        mask = MASK_SHOT_HULL
                    } )
                end
                if (table.HasValue(target_types,"npc")) then
                    if ( tr.Hit and tr.Entity:IsNPC()) then
                        target = tr.Entity
                    elseif ( tr.Hit and table.HasValue(target_types,tr.Entity:GetClass()) ) then
                        target = tr.Entity
                    end
                else
                    if ( tr.Hit and table.HasValue(target_types,tr.Entity:GetClass()) ) then
                        target = tr.Entity
                    end
                end
            end
        end

        if !target then
            if !namjepsi.invalid_pos then
                namjepsi.invalid_pos = true
            end
            namjepsi.target = nil
        else
            if namjepsi.invalid_pos then
                namjepsi.invalid_pos = false
            end
            namjepsi.target = target

            if target == ply then return end
            cam.Start3D() -- Start the 3D function so we can draw onto the screen.
            render.SetMaterial(cursor)
            cam.IgnoreZ(true)
            render.DrawSprite(target:LocalToWorld(target:OBBCenter()), 12 + math.sin(RealTime() * 12), 12 + math.sin(RealTime() * 12), Color(255, 255, 255, cast_alpha))
            cam.IgnoreZ(false)
            cam.End3D()
        end
    else
        local pos
        namjepsi.target = nil
        if ability.areaTargeting then
            pos = ability.areaTargeting(ply, namjepsi.range)
        else
            local tr = util.TraceLine( {
                start = ply:GetShootPos(),
                endpos = ply:GetShootPos() + ply:GetAimVector() * namjepsi.range,
                filter = ply,
                mask = MASK_SHOT
            } )
            pos = tr.HitPos
        end

        --only used when ability custom areaTaregting returns nil
        if !pos then
            if !namjepsi.invalid_pos then
                namjepsi.invalid_pos = true
            end
            local tr = util.TraceLine( {
                start = ply:GetShootPos(),
                endpos = ply:GetShootPos() + ply:GetAimVector() * namjepsi.range,
                filter = ply,
                mask = MASK_SHOT
            } )
            pos = tr.HitPos
            namjepsi.pos = nil

            cam.Start3D() -- Start the 3D function so we can draw onto the screen.
            render.SetMaterial(Material("vgui/noability.png"))
            cam.IgnoreZ(true)
            render.DrawSprite(pos, 30, 30, Color(255, 100, 100, cast_alpha))
            cam.IgnoreZ(false)
            cam.End3D()
        else
            if namjepsi.invalid_pos then
                namjepsi.invalid_pos = false
            end

            namjepsi.pos = pos
            --[[
                TODO: Occasionally these stencil rings break and just become a big sphere... find solution or replace with something else
            ]]
            cam.Start3D() -- Start the 3D function so we can draw onto the screen.
            render.StartWorldRings()
            render.AddWorldRing(pos, ability.radius + math.sin(RealTime() * 3), 4, 32)
            render.FinishWorldRings(Color(ability.theme.r, ability.theme.g, ability.theme.b, cast_alpha))
            render.SetMaterial(cursor)
            cam.IgnoreZ(true)
            render.DrawSprite(pos, 12 + math.sin(RealTime() * 12), 12 + math.sin(RealTime() * 12), Color(255, 255, 255, cast_alpha))
            cam.IgnoreZ(false)
            cam.End3D()
        end
    end
end

--TODO: Halos suck ass for outlines + shits on performance, change later?
local function namjepsi_target_halos()
    local ply = LocalPlayer()
    if !namjepsi.casting or !namjepsi.target then return end
    local ability = namjepsi.abilities[ply.namjepsi_slots[namjepsi.current_slot]]
    if !ability then return end

    local target = namjepsi.target == ply and nil or namjepsi.target
    if !target then return end
    halo.Add( {target}, ability.theme, 3, 3, 3, true, false )
end
hook.Add( "PreDrawHalos", "namjepsi_target_halos", namjepsi_target_halos )

hook.Add("PostDrawPlayerHands", "namjepsi_hand_ui", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if wep and wep.Base != "mg_base" then
        namjepsi_hand_ui(LocalPlayer():GetHands())
    end
end)

--mw base weps use custom arms
hook.Add("PostDrawViewModel", "namjepsi_hand_ui_mwbase", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if wep and wep.Base == "mg_base" then
        namjepsi_hand_ui(LocalPlayer():GetHands())
    end
end)

hook.Add( "RenderScreenspaceEffects", "namjepsi_fx", namjepsi_fx )

--stencil ring rendering source code from luabee gaming - https://www.youtube.com/watch?v=w4tt5pvbr6A
local color_mask2 = Color(0,0,0,0)

local function drawStencilSphere( pos, ref, compare_func, radius, color, detail )
    render.SetStencilReferenceValue( ref )
    render.SetStencilCompareFunction( compare_func )
    render.DrawSphere(pos, radius, detail, detail, color)
end

-- Call this before calling render.AddWorldRing()
function render.StartWorldRings()
    render.WORLD_RINGS = {}
    cam.IgnoreZ(false)
    render.SetStencilEnable(true)
    render.SetStencilTestMask(255)
    render.SetStencilWriteMask(255)
    render.ClearStencil()
    render.SetColorMaterial()
end

-- Args: pos = where, radius = how big, [thicc = how thick, detail = how laggy]
-- Detail must be an odd number or it will look like shit.
function render.AddWorldRing(pos, radius, thicc, detail)
    detail = detail or 24
    thicc = thicc or 10
    local z = {detail = detail, thicc = thicc, pos = pos, outer_r = radius, inner_r = math.max(radius-thicc,0)}
    table.insert(render.WORLD_RINGS, z)
end

-- Call this to actually draw the rings added with render.AddWorldRing()
function render.FinishWorldRings(color)
    local ply = LocalPlayer()
    local zones = render.WORLD_RINGS

    render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )

    for i, zone in ipairs(zones) do
        --local outer_r = zone.radius
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.outer_r, color_mask2, zone.detail ) -- big, inside-out
    end
    render.SetStencilZFailOperation( STENCILOPERATION_DECR )
    for i, zone in ipairs(zones) do
       -- local outer_r = zone.radius
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.outer_r, color_mask2, zone.detail ) -- big
    end
    render.SetStencilZFailOperation( STENCILOPERATION_INCR )
    for i, zone in ipairs(zones) do
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, -zone.inner_r, color_mask2, zone.detail ) -- small, inside-out
    end
    render.SetStencilZFailOperation( STENCILOPERATION_DECR )
    for i, zone in ipairs(zones) do
        drawStencilSphere(zone.pos, 1, STENCILCOMPARISONFUNCTION_ALWAYS, zone.inner_r, color_mask2, zone.detail ) -- small
    end
    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

    local cam_pos = ply:EyePos()
    local cam_angle = ply:EyeAngles()
    local cam_normal = cam_angle:Forward()
    cam.IgnoreZ(true)
    render.SetStencilReferenceValue( 1 )
    render.DrawQuadEasy(cam_pos + cam_normal * 10, -cam_normal,10000,10000,color,cam_angle.roll)
    cam.IgnoreZ(false)
    render.SetStencilEnable(false)
end
