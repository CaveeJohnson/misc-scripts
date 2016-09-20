hook.Add("PlayerDeathSound", "CDeath", function()
    return true
end)

local t = {"02", "03", "06", "07", "08", "08", "09"}

hook.Add("PlayerDeath", "CDeath", function(ply)
    local s = "npc_barney.ba_pain" .. t[math.random(1, #t)]
    ply:EmitSound(s)
end)
