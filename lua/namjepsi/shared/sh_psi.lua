function namjepsi.give_psi(ply, psi)
    if !IsValid(ply) then return end
    if !namjepsi.abilities[psi] then print(psi .. " is not a valid ability!") return end

    if !ply.namjepsi_inv then
        ply.namjepsi_inv = {}
    end

    ply.namjepsi_inv[psi] = true

    print(ply:Name() .. " was given " .. namjepsi.abilities[psi]["name"])
end