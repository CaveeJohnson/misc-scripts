local chan

local function valid_channel()
	return vis and vis.channel and IsValid(vis.channel) and vis.channel:GetState() == GMOD_CHANNEL_PLAYING
end

if valid_channel() then

	chan = vis.channel
	
end

surface.CreateFont("vis", {
	font = "Minecraftia",
	weight = 0,
	size = 22,
})

vis = {
	FFTMode = FFT_1024,
	Bars = 1024,
	ScreenWidth = ScrW(),
	SpecMiddle = 150,
	Offset = 200,
	Amp = 100,
	Clamp = 100,
	TransMult = 1.8,
	LerpFraction = 0.65,
	TrimLevel = 3.8,
	DynamicTrim = false,
	NameCol = Color(120, 120, 220, 255),
	
	Errors = {
		[-1] =		"Unknown Error",
		[0] =		"OK",
		[1] =		"Memory Error",
		[2] =		"Can't open the file",
		[3] =		"Can't find a free/valid driver",
		[4] =		"The sample buffer was lost",
		[5] =		"Invalid handle",
		[6] =		"Unsupported sample format",
		[7] =		"Invalid position",
		[8] =		"BASS_Init has not been successfully called",
		[9] =		"BASS_Start has not been successfully called",
		[14] =		"Already initialized",
		[18] =		"Can't get a free channel",
		[19] =		"An illegal type was specified",
		[20] =		"An illegal parameter was specified",
		[21] =		"No 3D support",
		[22] =		"No EAX support",
		[23] =		"Illegal device number",
		[24] =		"Not playing",
		[25] =		"Illegal sample rate",
		[27] =		"The stream is not a file stream",
		[29] =		"No hardware voices available",
		[31] =		"The MOD music has no sequence data",
		[32] =		"No internet connection could be opened",
		[33] =		"Couldn't create the file",
		[34] =		"Effects are not available",
		[37] =		"Requested data is not available",
		[38] =		"The channel is a 'decoding channel'",
		[39] =		"A sufficient DirectX version is not installed",
		[40] =		"Connection timedout",
		[41] =		"Unsupported file format",
		[42] =		"Unavailable speaker",
		[43] =		"Invalid BASS version (used by add-ons)",
		[44] =		"Codec is not available/supported",
		[45] =		"The channel/file has ended",
		[46] = 		"The device is busy",
		[102] = 	"Missing Filesystem",
	},
	
	levels = {},
	channel = chan,
	lerp_tbl = {},
}

function vis:Spectrum()

	if not self.channel or not IsValid(self.channel) then
	
		return
	
	end

	local data, levels = {}, {}
	local count = self.channel:FFT(data, self.FFTMode)
	
	for i = 1, count do

		local level = (data[i] or 0) ^ 2
		
		level = math.log10(level) / 10
		level = (1 - math.abs(level)) ^ 3 * self.Amp
		
		level = level + 1
		
		levels[i] = math.min(level, self.Clamp)
	end
	
	self.levels = levels
	
end

function vis:FancyTime(seconds)

	local seconds = math.Round(seconds, 0)

	local hours = math.floor(seconds / 60 / 60)
	local mins = math.floor(seconds / 60) % 60
	local secs = seconds % 60
	
	if hours < 10 then
		
		hours = "0" .. hours
		
	end
	
	if mins < 10 then
		
		mins = "0" .. mins
		
	end
	
	if secs < 10 then
		
		secs = "0" .. secs
		
	end
	
	return hours .. ":" .. mins .. ":" .. secs
	
end

local function set_channel(channel, Errors)

	vis.lerp_tbl = {}

	if Errors then
	
		vis.error = vis.Errors[Errors] or vis.Errors[-1]
		vis.channel = nil
		
		return
	
	end
	
	vis.error = nil
	vis.levels = {}
	vis.channel = channel
	
	vis:Spectrum()
	
end

function vis:StreamURI(uri)

	if self.channel then
	
		self.channel:Stop()
	
	end
	
	sound.PlayURL(uri, "noblock", set_channel)
	
end

function vis:StreamFile(path)

	if self.channel then
	
		self.channel:Stop()
	
	end

	sound.PlayFile(path, "noblock", set_channel)
	
end

function vis.DrawBars()

	local self 		= vis
	
	self:Spectrum()
	
	local levels 	= self.levels
	local width 	= self.ScreenWidth - (self.Offset * 2)
	local middle 	= self.SpecMiddle
	local count 	= self.Bars
	
	if levels and valid_channel() then
	
		local barcount, bc2 = math.min(#levels, self.Bars), 1
		local real_lvl = {}
	
		for i = 1, barcount do

			local level = levels[i]
			
			if not level or (self.DynamicTrim and level < self.TrimLevel) then
			
				continue
				
			end
			
			local lerped = Lerp(self.LerpFraction, self.lerp_tbl[bc2] or 0, level)
			
			if lerped ~= lerped then
			
				lerped = 0
				
			end
			
			real_lvl[bc2] = lerped
			
			bc2 = bc2 + 1
			
		end

		local curx, size = self.Offset, (width / bc2)

		for i = 1, bc2 - 1 do

			local level = real_lvl[i]
			local col
			local red = math.max(255 - level * 2.8, 0)
			local alpha = level * self.TransMult + 35
			
			col = Color(0, 0, 0, alpha)
			
			surface.SetDrawColor(col)
			surface.DrawRect(curx + 1, middle - level - 1, size, (level * 2.1) + 3)
			
			col = Color(255, red, red, alpha)
			
			surface.SetDrawColor(col)
			surface.DrawRect(curx, middle - level, size, (level * 2) + 1)
			
			curx = curx + size
			
		end
		
		vis.lerp_tbl = real_lvl
	
	end
	
	local data, data2 = "", ""
	
	if self.error then
	
		data = self.error
		
	elseif self.channel and IsValid(self.channel) then
	
		data = self:FancyTime(self.channel:GetTime()) .. " / " .. self:FancyTime(self.channel:GetLength())
		data2 = self.channel:GetFileName()
		
	end
	
	surface.SetFont("vis")
	
	local w, h
	
	w, h = surface.GetTextSize(data)
	
	surface.SetTextColor(color_white)
	surface.SetTextPos((self.ScreenWidth / 2) - (w / 2), middle - self.Clamp - h / 2)
	
	surface.DrawText(data)
	
	w, h = surface.GetTextSize(data2)
	
	surface.SetTextColor(self.NameCol)
	surface.SetTextPos((self.ScreenWidth / 2) - (w / 2), middle - self.Clamp - h - 8)
	
	surface.DrawText(data2)

end

function vis.cmd(ply, cmd, args, str)

	if #args < 1 or str:Trim() == "" then
		
		return
		
	end
	
	local self = vis
	local sound = args[1]
	
	if sound:match("https?://.+") then
	
		self:StreamURI(sound)
		
	else
	
		self:StreamFile(sound)
		
	end
	
end

hook.Add("HUDPaint", "vis_render", vis.DrawBars)
concommand.Add("vis", vis.cmd)
