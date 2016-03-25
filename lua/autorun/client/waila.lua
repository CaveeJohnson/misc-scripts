surface.CreateFont("waila_title", {
	font = "Minecraftia",
	weight = 0,
	size = 22,
})

surface.CreateFont("waila_author", {
	font = "Minecraftia",
	weight = 0,
	size = 22,
	italic = true,
})

surface.CreateFont("waila_sub", {
	font = "Minecraftia",
	weight = 0,
	size = 20,
})

waila = {
	concol = Color(10 , 0  , 22 , 240),
	conedg = Color(90 , 0  , 190, 200),
	authco = Color(90 , 90 , 220, 255),
	subcol = Color(200, 200, 200, 255),
	bordth = 3,
	middle = ScrW() / 2,
	scrtop = 4,
	player = LocalPlayer(),
	textxo = 5 + 3,
	textyo = 2 + 3,
	bottom = true,
	fade = 25,
}

function waila:DrawContainer()
	self:PreDrawContents()

	local w = self.w
	local h = self.h
	local x = self.x
	local y = self.y

	do
		surface.SetDrawColor(self.concol)
		surface.DrawRect(x, y, w, h)
	end

	do
		surface.SetDrawColor(self.conedg)

		for i = 0, self.bordth - 1 do
			surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
		end

		surface.SetDrawColor(self.concol)

		local curx, cury
		do
			curx = x - self.bordth + 2
			cury = y + self.bordth - 2

			surface.DrawLine(curx, cury, curx, cury + h - 4)
		end

		do
			curx = x + w + self.bordth - 3
			cury = y + self.bordth - 2

			surface.DrawLine(curx, cury, curx, cury + h - 4)
		end

		do
			curx = x + 2
			cury = y + h + self.bordth - 3

			surface.DrawLine(curx, cury, curx + w - 4, cury)
		end

		do
			curx = x + 2
			cury = y - self.bordth + 2

			surface.DrawLine(curx, cury, curx + w - 4, cury)
		end
	end

	self:DrawContents(x, y, w, h)
end

function waila:PreDrawContents()
	if not self.title then
		error("Drawing with no info????")
	end

	do
		local lrgw = {}
		local tw, th, ttl = 0, 0, self.textyo

		do
			surface.SetFont("waila_title")
			tw, th = surface.GetTextSize(self.title)

			lrgw[#lrgw+1] = tw
			ttl = ttl + th + 3
		end

		ttl = ttl + 1

		do
			surface.SetFont("waila_sub")

			for k, v in next, self.info do
				local txt = k .. ": " .. tostring(v)
				tw, th = surface.GetTextSize(txt)

				lrgw[#lrgw+1] = tw
				ttl = ttl + th + 3
			end
		end

		do
			surface.SetFont("waila_sub")
			tw, th = surface.GetTextSize(self.author)

			lrgw[#lrgw+1] = tw + 14
			ttl = ttl + th + 3
		end

		local big = 0
		for i = 1, #lrgw do
			local t = lrgw[i]

			if t > big then
				big = t
			end
		end

		self.w = big + (self.textxo * 2)
		self.h = ttl + (self.textyo * 1.5)
	end

	do
		self.x = self.middle - (self.w / 2)
		self.y = (self.bottom and ScrH() - self.h - self.scrtop - self.bordth or self.scrtop + self.bordth)
	end
end

function waila:DrawContents(x, y, w, h)
	local tw, th, ttl = 0, 0, self.textyo
	surface.SetTextColor(color_white)

	do
		surface.SetFont("waila_title")
		tw, th = surface.GetTextSize(self.title)

		surface.SetTextPos(x + self.textxo, y + ttl)
		surface.DrawText(self.title)

		ttl = ttl + th + 3
	end

	ttl = ttl + 1

	do
		surface.SetFont("waila_sub")
		surface.SetTextColor(self.subcol)

		for k, v in next, self.info do
			local txt = k .. ": " .. tostring(v)
			tw, th = surface.GetTextSize(txt)

			surface.SetTextPos(x + self.textxo, y + ttl)
			surface.DrawText(txt)

			ttl = ttl + th + 3
		end
	end

	do
		surface.SetTextColor(self.authco)

		surface.SetFont("waila_author")
		tw, th = surface.GetTextSize(self.author)

		surface.SetTextPos(x + self.textxo, y + ttl)
		surface.DrawText(self.author)

		ttl = ttl + th + 3
	end
end

function waila:Identity(ent)
	local name

	if ent:IsPlayer() then return ent:Nick() end

	name = language.GetPhrase(
		(ent.Name and ent.Name:Trim() ~= "" and ent.Name) or
		(ent.PrintName and ent.PrintName:Trim() ~= "" and ent.PrintName or (ent.GetPrintName and ent:GetPrintName())) or
		ent:GetClass()
	)

	if ent.GetName and name ~= ent:GetName() and ent:GetName() ~= "" then
		local mapName = ent:GetName()
		mapName = mapName:Trim()

		if mapName == "" then return end
		name = name .. " (" .. mapName .. ")"
	end

	name = name .. " " .. ent:EntIndex()
	return name
end

function waila:GatherInfo()
	if not (self.player and IsValid(self.player)) then self.player = LocalPlayer() return end

	local trace = util.TraceLine(util.GetPlayerTrace(self.player))

	if not trace or not trace.Hit or not trace.Entity or not IsValid(trace.Entity) then
		return false
	end

	local ent = trace.Entity

	self.title = self:Identity(ent)
	self.info = {}
		local s = self.info
		s.Model = ent:GetModel()

		if ent:GetMaterial() and ent:GetMaterial():Trim() ~= "" then
			s.Material = ent:GetMaterial()
		end

		if ent:IsPlayer() then
			if ent.CustomTitle and ent.CustomTitle:Trim() ~= "" then
				s.Title = ent.CustomTitle
			end
			s.SteamID = ent:SteamID()
		end

		if ent.CPPIGetOwner and ent:CPPIGetOwner() and IsValid(ent:CPPIGetOwner()) and ent:CPPIGetOwner():IsPlayer() then
			if ent:CPPIGetOwner():Nick():Trim() ~= "" then
				s.Owner = ent:CPPIGetOwner():Nick()
			end
		end

		if ent.text then
			s.Text = ent.text
		end

		if ent.Purpose and ent.Purpose:Trim() ~= "" then
			s.Purpose = ent.Purpose
		end

		if ent.Contact and ent.Contact:Trim() ~= "" then
			s.Contact = ent.Contact
		end

		--[[if ent.GetTable then
			for k, v in pairs(ent:GetTable()) do
				if type(v) == "function" or type(v) == "table" then continue end

				s[k] = tostring(v)
			end
		end]]
	self.author = (ent.Author and ent.Author:Trim() ~= "" and ent.Author) or "Garry's Mod"

	return true
end

local alpha = 0
function waila.Render()
	local self = waila
	local draw = self:GatherInfo()

	if not self.info then return end

	if not draw then
		alpha = math.Clamp(alpha - self.fade, 0, 255)
	else
		alpha = math.Clamp(alpha + self.fade, 0, 255)
	end

	if alpha == 0 then
		return
	end

	surface.SetAlphaMultiplier(alpha / 255)
	self:DrawContainer()
	surface.SetAlphaMultiplier(1)

end

hook.Add("HUDPaint", "waila_render", waila.Render)
