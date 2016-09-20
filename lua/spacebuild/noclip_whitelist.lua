noclip_whitelist = noclip_whitelist or {
}

hook.Add("PlayerNoClip", "noclip_whitelist", function(p)
	if noclip_whitelist[p:SteamID()] then
		return true
	end
end)

if SERVER then
	util.AddNetworkString("noclip_whitelist")
	
	local function send(ply)
		net.Start("noclip_whitelist")
			net.WriteTable(noclip_whitelist)
		if ply then net.Send(ply) else net.Broadcast() end
	end
	
	local function whitelist(sid)
		noclip_whitelist[sid] = true
		send()
	end
	
	local function remove(sid)
		noclip_whitelist[sid] = nil
		send()
	end
	
	hook.Add("PlayerInitialSpawn", "noclip_whitelist", send)
	
	if aowl then
		aowl.AddCommand({"nc", "ncwhite", "whitelistnc"}, function(ply, line, target)
			local ent = easylua.FindEntity(target)
			if ent:IsPlayer() then whitelist(ent:SteamID()) end
		end, "moderators")
		
		aowl.AddCommand({"removenc", "ncremove"}, function(ply, line, target)
			local ent = easylua.FindEntity(target)
			if ent:IsPlayer() then remove(ent:SteamID()) end
		end, "moderators")
	end
else
	net.Receive("noclip_whitelist", function()
		noclip_whitelist = net.ReadTable()
	end)
end
