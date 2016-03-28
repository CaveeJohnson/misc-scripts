local function add()
	pcall(require, "cvar3")
	if cvar3 or debug.getregistry().ConVar.SetValue then -- hack
		local function SetConVar(cvar,val)
			local cv = GetConVar(cvar)
			if cv then
				cv:SetValue(val)
			else return false end
		end

		local function StripFlags(cvar,val)
			cv:SetFlags(bit.band(cvar:GetFlags(), bit.bnot(val, 0)))
		end

		aowl.AddCommand("cvar", function(ply, _, cvar, val)
			if not cvar or not val then return false, "invalid input" end
			if SetConVar(cvar, val:Trim()) == false then return false, "convar does not exist" end
		end, "developers")

		aowl.AddCommand("stripflags", function(ply, _, cvar)
			if not cvar then return false, "invalid input" end
			local cv = GetConVar(cvar)
			if not cv then return false, "convar does not exist" end
			StripFlags(cvar, FCVAR_CHEAT)
		end, "developers")
	end
	pcall(require, "sourcenetinfo")
	if sourcenetinfo then
		aowl.AddCommand("stoppackets",function(ply,_,who_r,time)
			time = tonumber(time or "") or 5
			time = math.ceil(time)
			local who = easylua.FindEntity(who_r)
			if not who then return false, aowl.TargetNotFound(who_r) end
			timer.Create("ddos_" .. ply:UniqueID(), 0.001, time * 100, function()
				if IsValid(who) then
					who:GetNetChannel():Reset()
					who:GetNetChannel():Transmit(false)
				end
			end)
			timer.Simple(time, function()
				if IsValid(who) then
					who:GetNetChannel():Transmit(true)
				end		
			end)
		end, "developers")
	end
end

if aowl then
	add()
else
	hook.Add("AowlInitialized","aowljunk",add)
end
