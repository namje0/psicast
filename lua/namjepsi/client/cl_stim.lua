namjepsi.stimming = false

local function namjepsi_stim()
    if namjepsi.stimming or namjepsi.casting then return end
    local ply = LocalPlayer()
    local stim_count = LocalPlayer():GetAmmoCount( "namje_psychostim" )
    local energy = ply:GetNW2Float("namjepsi_energy")
    local max_energy = ply:GetNW2Int("namjepsi_max_energy")

    if stim_count <= 0 or energy >= max_energy then
        LocalPlayer():EmitSound( "player/suit_denydevice.wav")
    return end

    local vmanip_anim = VManip:GetCurrentAnim()
    if vmanip_anim then
        if vmanip_anim == "useinhaler" then
            VManip:Remove()
        else
            return
        end
    end
    namjepsi.stimming = true
    VManip:PlayAnim("useinhaler")

    timer.Simple(.3,function()
        LocalPlayer():EmitSound("inhale.wav")
        LocalPlayer():ScreenFade( SCREENFADE.IN, Color( 50, 100, 255, 50 ), .6, 0 )
        net.Start("namjepsi_stim")
        net.SendToServer()
    end)

    timer.Simple(1.2,function()
        namjepsi.stimming = false
    end)
end

concommand.Add("+psychostim", namjepsi_stim)
concommand.Add("-psychostim", function() end)

list.Add( "DesktopWindows", {
    icon = "vgui/stimlogo.png",
    title = "Use Stim",
    init = function() namjepsi_stim() end,
})