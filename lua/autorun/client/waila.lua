-- https://github.com/alexander-yakushev/awesompd/blob/master/utf8.lua

function utf8.charbytes (s, i)
   -- argument defaults
   i = i or 1
   local c = string.byte(s, i)

   -- determine bytes needed for character, based on RFC 3629
   if c > 0 and c <= 127 then
      -- UTF8-1
      return 1
   elseif c >= 194 and c <= 223 then
      -- UTF8-2
      return 2
   elseif c >= 224 and c <= 239 then
      -- UTF8-3
      return 3
   elseif c >= 240 and c <= 244 then
      -- UTF8-4
      return 4
   end
end

function utf8.sub (s, i, j)
   j = j or -1

   if i == nil then
      return ""
   end

   local pos = 1
   local bytes = string.len(s)
   local len = 0

   -- only set l if i or j is negative
   local l = (i >= 0 and j >= 0) or utf8.len(s)
   local startChar = (i >= 0) and i or l + i + 1
   local endChar = (j >= 0) and j or l + j + 1

   -- can't have start before end!
   if startChar > endChar then
      return ""
   end

   -- byte offsets to pass to string.sub
   local startByte, endByte = 1, bytes

   while pos <= bytes do
      len = len + 1

      if len == startChar then
	 startByte = pos
      end

      pos = pos + utf8.charbytes(s, pos)

      if len == endChar then
	 endByte = pos - 1
	 break
      end
   end

   return string.sub(s, startByte, endByte)
end

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

local waila_enable = CreateClientConVar("waila_enable", "1", true, true)

waila = {
	concol = Color(10 , 0  , 22 , 240),
	conedg = Color(90 , 0  , 190, 200),
	authco = Color(90 , 90 , 220, 255),
	infoco = Color(220, 220, 220, 255),
	subcol = Color(200, 200, 200, 255),
	bordth = 3,
	middle = ScrW() / 2,
	scrtop = 4,
	player = LocalPlayer(),
	textxo = 5 + 3,
	textyo = 2 + 3,
	bottom = true,
	fade = 25,

	toggles = {},

	maxlen = 40,
}

function waila:CreateToggle(key)
	self.toggles[key] = CreateClientConVar("waila_line_" .. key:lower(), "1", true, true)
end

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
				if not self.toggles[k]:GetBool() then continue end
				local v = istable(v) and v[1] or v

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
	surface.SetTextColor(self.titleColor)

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
			if not self.toggles[k]:GetBool() then continue end

			local col, text
			if istable(v) then
				col, text = v[2], v[1]
			else
				col, text = color_white, v
			end

			local kw, kh = surface.GetTextSize(k .. ": ")
			tw, th = surface.GetTextSize(text)

			surface.SetTextColor(self.infoco)

			surface.SetTextPos(x + self.textxo, y + ttl)
			surface.DrawText(k .. ": ")

			surface.SetTextColor(col)

			surface.SetTextPos(x + self.textxo + kw, y + ttl)
			surface.DrawText(text)

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

do
	-- Pasted from nametags, modified to work for waila.
	local PlayerColors = {
		["0"]  = Color(0, 0, 0),
		["1"]  = Color(128, 128, 128),
		["2"]  = Color(192, 192, 192),
		["3"]  = Color(255, 255, 255),
		["4"]  = Color(0, 0, 128),
		["5"]  = Color(0, 0, 255),
		["6"]  = Color(0, 128, 128),
		["7"]  = Color(0, 255, 255),
		["8"]  = Color(0, 128, 0),
		["9"]  = Color(0, 255, 0),
		["10"] = Color(128, 128, 0),
		["11"] = Color(255, 255, 0),
		["12"] = Color(128, 0, 0),
		["13"] = Color(255, 0, 0),
		["14"] = Color(128, 0, 128),
		["15"] = Color(255, 0, 255),
	}
	local tags = {
		color = {
			default = { 255, 255, 255, 255 },
			callback = function(params)
				return Color(params[1], params[2], params[3], params[4])
			end,
			params = { "number", "number", "number", "number" }
		},
		hsv = {
			default = { 0, 1, 1 },
			callback = function(params)
				return HSVToColor(params[1] % 360, params[2], params[3])
			end,
			params = { "number", "number", "number" }
		},
	}
	local types = {
		["number"] = tonumber,
		["bool"] = tobool,
		["string"] = tostring,
	}
	local lib =
	{
		PI = math.pi,
		pi = math.pi,
		rand = math.random,
		random = math.random,
		randx = function(a,b)
			a = a or -1
			b = b or 1
			return math.Rand(a, b)
		end,

		abs = math.abs,
		sgn = function (x)
			if x < 0 then return -1 end
			if x > 0 then return  1 end
			return 0
		end,

		pwm = function(offset, w)
			w = w or 0.5
			return offset % 1 > w and 1 or 0
		end,

		square = function(x)
			x = math.sin(x)

			if x < 0 then return -1 end
			if x > 0 then return  1 end

			return 0
		end,

		acos = math.acos,
		asin = math.asin,
		atan = math.atan,
		atan2 = math.atan2,
		ceil = math.ceil,
		cos = math.cos,
		cosh = math.cosh,
		deg = math.deg,
		exp = math.exp,
		floor = math.floor,
		frexp = math.frexp,
		ldexp = math.ldexp,
		log = math.log,
		log10 = math.log10,
		max = math.max,
		min = math.min,
		rad = math.rad,
		sin = math.sin,
		sinc = function (x)
			if x == 0 then return 1 end
			return math.sin(x) / x
		end,
		sinh = math.sinh,
		sqrt = math.sqrt,
		tanh = math.tanh,
		tan = math.tan,

		clamp = math.Clamp,
		pow = math.pow,

		t = RealTime,
		time = RealTime,
	}
	local blacklist = { "repeat", "until", "function", "end" }

	function waila.NametagsTagParser(ply)
		local nick = ply:Nick()
		local nickColor = team.GetColor(ply:Team())

		if nick:match("<(.-)=(.-)>") or nick:match("(^%d+)") then
			local nickTags = {}
			local inCOD = false
			local CODchars = ""

			local nickChars = ply:Nick():Split("")
			local inMarkup = false
			local markupTag = ""
			local markupParams = {}
			local markupParam = ""
			local lookingForParams = false

			for i, char in next, nickChars do

				-- COD colors

				if not inMarkup and nick:match("(^%d+)") then
					if char == "^" then
						inCOD = true
						continue
					end

					if inCOD then
						if type(tonumber(char)) == "number" then
							CODchars = CODchars .. char
							continue
						elseif type(tonumber(char)) ~= "number" then
							local color = PlayerColors[CODchars]
							CODchars = ""
							if not color then inCOD = false continue end
							local colParams = {}
							colParams[1] = tostring(color.r)
							colParams[2] = tostring(color.g)
							colParams[3] = tostring(color.b)
							table.insert(nickTags, { tagName = "color", params = colParams })
							inCOD = false
							continue
						end
					end
				end

				-- markup

				if not inCOD and nick:match("<(.-)=(.-)>")then
					if char == "<" and not inMarkup then
						inMarkup = true
						continue
					elseif char == "=" and inMarkup and not lookingForParams then
						lookingForParams = true
						continue
					elseif char == ">" and inMarkup then
						table.insert(markupParams, markupParam)
						for k, param in pairs(markupParams) do
							markupParams[k] = param:Trim()
							param = markupParams[k]
							if param:sub(1, 1) == "[" and param:sub(-1, -1) == "]" then
								local exp = param:sub(2, -2)
								if not exp then continue end
								local ok = true
								for _, word in next, blacklist do
									if param:lower():match(word) then ok = false break end
								end
								if ok then
									local func = CompileString("return " .. exp, "nametags_exp", false)
									if type(func) == "function" then
										setfenv(func, lib)
										markupParams[k] = tostring(func())
									end
								end
							end
						end
						table.insert(nickTags, { tagName = markupTag, params = markupParams })
						inMarkup = false
						lookingForParams = false
						markupTag = ""
						markupParams = {}
						markupParam = ""
						continue
					end

					if inMarkup then
						if not lookingForParams then
							markupTag = markupTag .. char
							continue
						elseif lookingForParams and char == "," and not escaping then
							table.insert(markupParams, markupParam)
							markupParam = ""
							continue
						elseif lookingForParams and char == "\\" and not escaping then
							escaping = true
							continue
						else
							markupParam = markupParam .. char
							escaping = false
							continue
						end
					end
				end
			end

			nick = nick:gsub("<(.-)=(.-)>", "")
			nick = nick:gsub("(^%d+)", "")

			if #nickTags >= 1 then
				for i, tag in next, nickTags do -- for every tag in our name
					local nickTag, nickParams = tag.tagName, tag.params
					for tagName, tagData in next, tags do -- check the list of available tags
						if nickTag == tagName then -- if the tag matches then
							for k, Type in next, tagData.params do
								local param = nickParams[k]
								if param == nil or param == "" or type(types[Type](param)) ~= Type then
									nickParams[k] = tagData.default[k]
								end
							end
							nickColor = tagData.callback(nickParams)
							break
						end
					end
				end
			end
		end

		return nick, nickColor
	end
end

function waila:Identity(ent)
	local name

	if ent:IsPlayer() then
		return self.NametagsTagParser(ent)
	end

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
	return name, color_white
end

function waila:GatherInfo()
	if not (self.player and IsValid(self.player)) then self.player = LocalPlayer() return end

	local trace = util.TraceLine(util.GetPlayerTrace(self.player))

	if not trace or not trace.Hit or not trace.Entity or not IsValid(trace.Entity) then
		return false
	end

	local ent = trace.Entity

	self.title, self.titleColor = self:Identity(ent)
	self.info = {}
		local s = self.info

		if ent.Health then
			local hp = ent:Health()

			if hp > 0 and hp == hp and hp ~= math.huge then
				s.Health = math.floor(hp)
			end
		end

		s.Model = ent:GetModel()

		if ent:GetMaterial() and ent:GetMaterial():Trim() ~= "" then
			s.Material = ent:GetMaterial()
		end

		if ent:IsPlayer() then
			if ent.GetCustomTitle then
				local title = ent:GetCustomTitle()

				if title and title:Trim() ~= "" then
					title = title:Trim()

					local len = utf8.len(title)
					s.Title = len < self.maxlen and title or utf8.sub(title:Trim(), 1, self.maxlen) .. "..."
				end
			end

			s.SteamID = ent:SteamID()
		end

		if ent.CPPIGetOwner then
			local owner = ent:CPPIGetOwner()

			if owner and owner:IsValid() and owner:IsPlayer() then
				s.Owner = {self:Identity(ent:CPPIGetOwner())}
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

waila:CreateToggle("Title")
waila:CreateToggle("SteamID")
waila:CreateToggle("Text")
waila:CreateToggle("Health")
waila:CreateToggle("Model")
waila:CreateToggle("Material")
waila:CreateToggle("Owner")
waila:CreateToggle("Purpose")
waila:CreateToggle("Contact")

local alpha = 0
function waila.Render()
	if not waila_enable:GetBool() then return end

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

	if hook.Run("HUDShouldDraw", "waila_container") == false then return end

	surface.SetAlphaMultiplier(alpha / 255)
		self:DrawContainer()
	surface.SetAlphaMultiplier(1)
end

hook.Add("HUDPaint", "waila_render", waila.Render)

local function False() return false end
hook.Add("HUDDrawTargetID", "waila_targetid", False)
