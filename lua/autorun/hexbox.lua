hexbox = {}

if CLIENT then
	surface.CreateFont("hexbox_console", {
		font = "Courier",
		size = 14,
		antialiasing = false,
		weight = 400,
	})

else
	require"sourcenetinfo"
	require"cvar3"
	require"usercmd"
	require"dns"

	dns.__lookup = dns.__lookup or dns.Lookup
	function dns.Lookup(name)
		return dns.__lookup(name, "8.8.8.8")
	end

	dns.__ping = dns.__ping or dns.Ping
	function dns.Ping(num)
		return dns.__ping("8.8.8.8", num)
	end

	function dns.IsHostOnline(str)
		local Online, err, code = dns.Ping(300)

		if not Online then
			return false, "Pinging google dns (8.8.8.8) failed! ("..err..(code and ", "..code or "")..")"
		end


		local Addr, err, code = dns.Lookup(str)
		if not Addr then
			return false, "Lookup "..str.." failed! ("..err..(code and ", "..code or "")..")"
		end

		return true, Addr
	end
end

hexbox.extraWeps = {
	"none",
	"weapon_crowbar",
	--"torch"
}
hexbox.nuke = {
	["weapon_357"] = true,
	["weapon_ar2"] = true,
	["weapon_bugbait"] = true,
	["weapon_crossbow"] = true,
	["weapon_frag"] = true,
	["weapon_pistol"] = true,
	["weapon_rpg"] = true,
	["weapon_shotgun"] = true,
	["weapon_slam"] = true,
	["weapon_smg1"] = true,
	["weapon_stunstick"] = true,
	["manhack_welder"] = true,
	["weapon_medkit"] = true,
	["weapon_flechettegun"] = true,
}
hexbox.nuke_ent = {
	["item_ammo_ar2"] = true,
	["item_ammo_pistol"] = true,
	["item_box_buckshot"] = true,
	["item_ammo_357"] = true,
	["item_ammo_smg1"] = true,
	["item_ammo_ar2_altfire"] = true,
	["item_ammo_crossbow"] = true,
	["item_ammo_smg1_grenade"] = true,
	["item_rpg_round"] = true,

	["item_battery"] = true,
	["item_healthvial"] = true,
	["item_healthkit"] = true,
	["item_suitcharger"] = true,
	["item_healthcharger"] = true,
	["item_suit"] = true,

	["prop_thumper"] = true,
	["combine_mine"] = true,
	["grenade_helicopter"] = true,
	["npc_grenade_frag"] = true,

	["sent_ball"] = true,
}

function hexbox.loadout(ply)
	for k, v in ipairs(hexbox.extraWeps) do ply:Give(v) end
	timer.Simple(0, function() ply:SelectWeapon("none") end)
end
if SERVER then hook.Add("PlayerLoadout", "hexbox_loadout", hexbox.loadout) end

function hexbox.nukeWeapons()
	local weps = list.GetForEdit"Weapon"
	for k, v in pairs(weps) do
		if hexbox.nuke[k] then weps[k] = nil end
	end
end
hook.Add("InitPostEntity", "hexbox_nukeweapons", hexbox.nukeWeapons)

function hexbox.nukeEnts()
	local ents = list.GetForEdit"SpawnableEntities"
	for k, v in pairs(ents) do
		if hexbox.nuke_ent[k] then ents[k] = nil end
	end
end
hook.Add("InitPostEntity", "hexbox_nukeents", hexbox.nukeEnts)

function hexbox.centerHack()
	for k, v in ipairs(ents.FindByClass("prop_*")) do
		if v.centergotten then continue end

		local p = v:GetPhysicsObject()
		if not (p and p:IsValid()) then continue end

		local c = p:GetMassCenter()
		if not c then continue end

		v.centergotten = true
		v:SetNW2Vector("obj_center", c)
	end
end
if SERVER then hook.Add("Think", "hexbox_centerhack", hexbox.centerHack) end

color_red = Color(255, 0, 0, 255)
color_green = Color(0, 255, 0, 255)
color_blue = Color(0, 0, 255, 255)

if CLIENT then -- HUD
	hexbox.hide = {
		CHudAmmo = true,
		CHudBattery = true,
		CHudHealth = true,
		CHudPoisonDamageIndicator = true,
	}

	local centers = CreateClientConVar("hexbox_centers", "0", true)
	local hud = CreateClientConVar("hexbox_hud", "1", true)

	function hexbox.hud()
		if hud:GetBool() then
			local ply = LocalPlayer()
			local x, y = 5, ScrH() - 5
			local str, tW, tH

			local name = ply:Nick():lower():Trim():gsub(" ", "_") .. "_pc"

			local maxvelo = 3000
			local segments = #name + 13
			local prepend = math.floor(math.log10(maxvelo))

			local time = ply:GetPlayTimeTable()
			time = (time.h < 10 and "0" .. time.h or time.h) .. ":" .. (time.m < 10 and "0" .. time.m or time.m) .. " h"

			local velo = math.floor(ply:GetAbsVelocity():Length())
			str = math.min(velo, maxvelo)

			local actualprepend = prepend - math.floor(math.log10(velo))

			local used = math.floor(str / maxvelo * segments)
			local left = segments - used

			str = ("#"):rep(used)
			str = time .. "    [" .. str .. ("-"):rep(left) .. "] " .. (velo ~= 0 and ("0"):rep(actualprepend) .. velo or ("0"):rep(prepend) .. "0") .. " u/s"

			surface.SetFont("hexbox_console")
			tW, tH = surface.GetTextSize(str)

			y = y - tH - 2

			surface.SetDrawColor(color_black)
			surface.DrawRect(x, y - 1, tW + 6, tH + 2)

			surface.SetTextColor(color_white)--Color(50, 255, 100, 255))
			surface.SetTextPos(x + 3, y - 1)
			surface.DrawText(str)

			y = y - tH - 2

			str = "[root@" .. name .. " hexbox]$ gmod_track_stats.sh"

			surface.SetFont("hexbox_console")
			tW, tH = surface.GetTextSize(str)

			surface.SetDrawColor(color_black)
			surface.DrawRect(x, y - 1, tW + 6, tH + 2)

			surface.SetTextColor(color_white)
			surface.SetTextPos(x + 3, y)
			surface.DrawText(str)
		end

		if centers:GetBool() then
			for k, v in ipairs(ents.FindByClass("prop_*")) do
				local p = v.obj_center
				if not p then p = v:GetNW2Vector("obj_center") v.obj_center = p end

				if p then
					local c = v:LocalToWorld(p)

					local f = (c + v:GetAngles():Forward() * 10):ToScreen()
					local r = (c + v:GetAngles():Right() * 10):ToScreen()
					local u = (c + v:GetAngles():Up() * 10):ToScreen()

					c = c:ToScreen()

					if c then
						surface.SetDrawColor(color_red)
						surface.DrawLine(c.x, c.y, f.x, f.y)

						surface.SetDrawColor(color_blue)
						surface.DrawLine(c.x, c.y, r.x, r.y)

						surface.SetDrawColor(color_green)
						surface.DrawLine(c.x, c.y, u.x, u.y)
					end
				end
			end
		end
	end
	hook.Add("HUDPaint", "hexbox_hud", hexbox.hud)

	function hexbox.hideHUDElements(element)
		if hexbox.hide[element] then return false end
	end
	hook.Add("HUDShouldDraw", "hexbox_hidehudelements", hexbox.hideHUDElements)

	function hexbox.noTarget()
		local gm = gmod.GetGamemode() or GM or GAMEMODE or {}
		function gm:HUDDrawTargetID()

		end
	end
	hook.Add("InitPostEntity", "hexbox_notarget", hexbox.noTarget)
	hexbox.noTarget()

	local autoJump = CreateClientConVar("hexbox_autojump", "0", true)

	function hexbox.autojump(cmd)
		if not autoJump:GetBool() then return end

		local ply = LocalPlayer()
		if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:WaterLevel() > 1 then return end

		if not ply:OnGround() then
			cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
		end
	end
	hook.Add("CreateMove", "hexbox_autojump", hexbox.autojump)
end


-- HUD DONE
-- Fix physclip
-- Tool searching
-- ENT Blacklist DONE
-- ACF config DONE
