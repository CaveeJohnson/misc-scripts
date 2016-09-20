AddCSLuaFile()

SafeZones = {}
SafeZones.Table = {}

SafeZones.SafeTime = 10
SafeZones.LeaveTime = 3

SafeZones.NoHUD = false
SafeZones.DisableProps = false

local run = false
function SafeZones:Register(id, mins, maxs)
	if not (isstring(id) and not self.Table[id] and isvector(mins) and isvector(maxs)) then return false end

	OrderVectors(mins, maxs)

	self.Table[id] = {mi = mins, ma = maxs, enabled = true}
	run = true
	return true
end

function SafeZones:GetList()
	return self.Table
end

function SafeZones:PlayerSafe(ply)
	local s = ply:GetNW2String("in_safe")
	return (s ~= "" and s) or false
end

function SafeZones:SetEnabled(id, bool)
	if not (isstring(id) and self.Table[id] and bool ~= nil) then return false end

	self.Table[id].enabled = bool
	return true
end

function SafeZones:ReDefine(id, mins, maxs)
	if not (isstring(id) and self.Table[id] and isvector(mins) and isvector(maxs)) then return false end

	OrderVectors(mins, maxs)

	self.Table[id].mi = mins
	self.Table[id].ma = maxs
	return true
end

function SafeZones:Remove(id)
		if not (isstring(id) and self.Table[id]) then return false end

		self.Table[id] = nil
		return true
end

if SERVER then

util.AddNetworkString("SafeZones")

function SafeZones:Network(hookName, ply)
	if not (isstring(hookName) and IsValid(ply) and ply:IsPlayer()) then return false end
	hook.Run(hookName, ply)

	net.Start("SafeZones")
		net.WriteString(hookName)
		net.WriteEntity(ply)
	net.Broadcast()

	return true
end

function SafeZones:ResetEnterTime(ply)
	if not (IsValid(ply) and ply:IsPlayer() and ply.enter_safe) then return false end

	ply.enter_safe = CurTime()
	return true
end

-- network hook calls
function SafeZones.Think()
	local zones = SafeZones:GetList()
	if not zones or not run then return end

	for ix, p in next,ents.GetAll() do
		local pos = p:GetPos()
		local zone

		for id, z in next,zones do
			if z.enabled and pos:WithinAABox(z.mi, z.ma) then
				zone = id

				break
			end
		end

		if zone then
			if not p:IsPlayer() then p.in_safe = true continue end
			
			if p.leave_safe then
				SafeZones:Network("StopLeaveSafeZone", p) --p:ChatPrint("StopLeaveSafeZone")
				p.leave_safe = nil
			end

			if p.in_safe == zone then continue end
			if p.in_safe then
				p.in_safe = zone
				p:SetNW2String("in_safe", zone)

				continue
			end

			if p.enter_safe and p.enter_safe < CurTime() - SafeZones.SafeTime then
				p.in_safe = zone
				p:SetNW2String("in_safe", zone)

				p.enter_safe = nil

				SafeZones:Network("EnterSafeZone", p) --p:ChatPrint("EnterSafeZone")

				continue
			end

			if not p.enter_safe then
				SafeZones:Network("StartEnterSafeZone", p) --p:ChatPrint("StartEnterSafeZone")
				p.enter_safe = CurTime()
			end
		else
			if not p:IsPlayer() then p.in_safe = false continue end
			
			if p.enter_safe then
				SafeZones:Network("StopEnterSafeZone", p) --p:ChatPrint("StopEnterSafeZone")
				p.enter_safe = nil
			end

			if p.leave_safe and p.leave_safe < CurTime() - SafeZones.LeaveTime then
				p.in_safe = nil
				p:SetNW2String("in_safe", "")

				p.leave_safe = nil

				SafeZones:Network("LeaveSafeZone", p) --p:ChatPrint("LeaveSafeZone")

				continue
			end

			if p.in_safe and not p.leave_safe then
				SafeZones:Network("StartLeaveSafeZone", p) --p:ChatPrint("StartLeaveSafeZone")
				p.leave_safe = CurTime()
			end
		end
	end
end
hook.Add("Think", "SafeZones.Think", SafeZones.Think)

function SafeZones.EntityTakeDamage(ent, dmg)
	if not run then return end
	local attacker = dmg:GetAttacker()

	if not (IsValid(ent) and IsValid(attacker)) then return end

	if attacker.in_safe then
		return dmg:SetDamage(0)
	end

	if attacker:IsPlayer() then SafeZones:ResetEnterTime(attacker) end

	if ent.in_safe then
		return dmg:SetDamage(0)
	end

	if not ent:IsPlayer() then SafeZones:ResetEnterTime(ent) end
end
hook.Add("EntityTakeDamage", "SafeZones.EntityTakeDamage", SafeZones.EntityTakeDamage)

function SafeZones.SpawnCheck(ply)
	local zones = SafeZones:GetList()
	if not zones or not run then return end

	local pos = ply:GetPos()
	local zone

	for id, z in next,zones do
		if z.enabled and pos:WithinAABox(z.mi, z.ma) then
			zone = id

			break
		end
	end

	if zone then
		ply.in_safe = zone
		ply:SetNW2String("in_safe", zone)

		SafeZones:Network("EnterSafeZone", ply)
	end
end
hook.Add("PlayerSpawn", "SafeZones.PlayerSpawn", SafeZones.SpawnCheck)
hook.Add("PlayerInitialSpawn", "SafeZones.PlayerInitialSpawn", SafeZones.SpawnCheck)

function SafeZones.PlayerSpawnProp(ply)
	if SafeZones.DisableProps and SafeZones:PlayerSafe(ply) and not ply:IsAdmin() then return false end
end
hook.Add("PlayerSpawnProp", "SafeZones.PlayerSpawnProp", SafeZones.PlayerSpawnProp)

else

SafeZones.CurrentState = "LeaveSafeZone"
function SafeZones.IncomingHook()
	local hookName = net.ReadString()
	local ply = net.ReadEntity()

	if not (hookName and IsValid(ply)) then return end
	if ply == LocalPlayer() then SafeZones.CurrentState = hookName end

	hook.Run(hookName, ply)
end
net.Receive("SafeZones", SafeZones.IncomingHook)

local greenMat = Material("gm_construct/color_room", "smooth noclamp")
local v0 = Vector(0, 0, 0)
local a0 = Angle(0, 0, 0)
local col = Color(50, 180, 50, 255)

function SafeZones:Render(id)
	local t = self.Table[id]
	if not t then return false end

	render.DrawBox(v0, a0, t.mi, t.ma, col, true)
	return true
end

function SafeZones.PostDrawTranslucentRenderables()
	local zones = SafeZones:GetList()
	if not zones or not run then return end

	greenMat:SetFloat("$alpha", 0.2)

	cam.Start3D()
		render.SetMaterial(greenMat)

		for k, v in next,zones do
			if v.enabled then SafeZones:Render(k) end
		end
	cam.End3D()
end
hook.Add("PostDrawTranslucentRenderables", "SafeZones.PostDrawTranslucentRenderables", SafeZones.PostDrawTranslucentRenderables)

local dot = "."
local function _dots()
	local a = math.ceil(CurTime() % 3)
	return dot:rep(a)
end

local txt_color = Color (  0, 250, 154, 255)
local name_color = Color (218, 165,  32, 255)

function SafeZones.HUDPaint()
	if not run or SafeZones.NoHUD then return end

	local txt
	local s = SafeZones.CurrentState

	local p = LocalPlayer()
	local name = SafeZones:PlayerSafe(p)

	if s == "StartLeaveSafeZone" then
		txt = "Now leaving a SafeZone" .. _dots()
	elseif s == "StartEnterSafeZone" then
		txt = "Now entering a safezone" .. _dots()
	elseif s == "EnterSafeZone" or s == "StopLeaveSafeZone" or name then
		txt = "Inside a SafeZone."
	end
	if not txt then return end

	draw.SimpleTextOutlined(txt, "Trebuchet24", ScrW() / 2, 20, txt_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	if name then draw.SimpleTextOutlined(name, "Trebuchet24", ScrW() / 2, 40, name_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black) end
end
hook.Add("HUDPaint", "SafeZones.HUDPaint", SafeZones.HUDPaint)

end

local map = game.GetMap()
if map == "gm_bluehills_test3" then
local mins, maxs
mins = Vector (-1537.0590820312, -1541.6567382812, -215.96875)
maxs = Vector (1540.7696533203, 1536.2880859375, 2174.1103515625)

SafeZones:Register("Spawn", mins, maxs)
elseif map == "sb_twinsuns_fixed" then
mins = Vector (-13089.159179688, -13672.450195312, -4922.455078125)
maxs = Vector (-4467.015625, -4637.7783203125, 4740.8056640625)

SafeZones:Register("Earth", mins, maxs)
end
