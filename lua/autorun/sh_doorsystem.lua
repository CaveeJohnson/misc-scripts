AddCSLuaFile()

DoorSystem = {}

if SERVER then

DoorSystem.Interface = {}

local def = {}
for i = 0, 9, 1 do
	def[i] = false
end

function DoorSystem:CleanInterface(sid)
	local interface = self.Interface[sid]
	if not (interface and interface.ents) then return false end

	for k, v in next, interface.ents do
		if not (v.ent and IsValid(v.ent)) then table.remove(self.Interface[sid].ents, k) end
	end

	return true
end

function DoorSystem:CreateDoor(ent, ply, channel)
	if not (ent and not ent:IsWorld() and not ent:IsPlayer() and ply and ply:IsPlayer() and channel and isnumber(channel) and channel <= 10 and channel >= 0) then return false end -- Stop buggering

	local sid = ply:SteamID()
	if not self.Interface[sid] then self.Interface[sid] = {chan = def, ents = {}} end

	self:CleanInterface(sid)
	table.insert(self.Interface[sid].ents, {ent = ent, channel = channel})

	ent:CallOnRemove("Door", function(s) DoorSystem:RemoveDoor(s) end)

	undo.Create("Door")
		undo.AddFunction(function(t, e) DoorSystem:RemoveDoor(e) end, ent)
		undo.SetPlayer(ply)

		undo.SetCustomUndoText("Undone Door Creation")
	undo.Finish()

	return true
end

function DoorSystem:RemoveDoor(ent)
	print(self, ent)
	if not (ent and not ent:IsWorld() and not ent:IsPlayer()) then return false end

	self:CleanInterface(sid)

	local interface = self.Interface
	local found = false

	for sid, v in next, interface do
		for i, t in next, v.ents do
			if t.ent == ent then
				self:Fade(ent, false)
				table.remove(self.Interface[sid].ents, i)

				found = true
			end
		end
	end

	return found
end

function DoorSystem:CreateKeypad(trace, ply, channel, password)
	return true
end

local _R = debug.getregistry()
function DoorSystem:Fade(ent, state)
	if not (ent and not ent:IsWorld() and not ent:IsPlayer() and state ~= nil) then return false end

	if state and not ent.IsFaded then
		ent.fadeBackup = {["SetMaterial"] = ent:GetMaterial() or ""}

		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:SetMaterial("models/shadertest/shader3")
	elseif not state and ent.IsFaded then
		ent:SetMaterial("")

		local t = _R.Entity
		if ent.fadeBackup and t then
			for k, v in next,ent.fadeBackup do
				if t[k] then t[k](ent, istable(v) and unpack(v) or v) end
			end
		end

		ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	else
		return false
	end

	ent.IsFaded = state

	return true
end

function DoorSystem:Toggle(ply, channel)
	if not (ply and ply:IsPlayer() and channel and isnumber(channel) and channel <= 10 and channel >= 0) then return false end

	local sid = ply:SteamID()
	if not (self.Interface[sid] and self.Interface[sid].ents and #self.Interface[sid].ents > 0) then return false end

	self:CleanInterface(sid)

	local s = self.Interface[sid].chan[channel] -- State of channel
	s = not s

	self.Interface[sid].chan[channel] = s

	for i, v in next, self.Interface[sid].ents do
		local c = v.channel
		if c ~= channel then continue end
		local e = v.ent

		DoorSystem:Fade(e, s)
	end

	return true
end

end
