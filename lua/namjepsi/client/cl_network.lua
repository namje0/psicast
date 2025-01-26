net.Receive("namjepsi_update_inventory", function()
    if !IsValid(LocalPlayer()) then return end
    LocalPlayer().namjepsi_inv = {}

    local count = net.ReadUInt(32)

    for i = 1, count do
        local ability = net.ReadString()
        LocalPlayer().namjepsi_inv[ability] = true
    end
    PrintTable(LocalPlayer().namjepsi_inv)
end)

net.Receive("namjepsi_update_slots", function()
    if !IsValid(LocalPlayer()) then return end
    LocalPlayer().namjepsi_slots = {}

    local count = net.ReadUInt(32)
    for i = 1, count do
        LocalPlayer().namjepsi_inv[count] = "none"
    end
end)