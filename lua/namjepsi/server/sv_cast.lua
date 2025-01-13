function namjepsi.cast(len, ply)
    if !IsValid(ply) or !ply:Alive() then return end
    print("cast")
end

net.Receive("namjepsi_cast", namjepsi.cast)