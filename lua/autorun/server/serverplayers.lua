local connectColor =		Color(255, 255, 0  , 255)
local joinColor =				Color(0  , 255, 0  , 255)
local disconnectColor =	Color(255, 0  , 0  , 255)
local normalColor =			Color(200, 200, 200, 255)
local addressColor =		Color(130, 130, 130, 255)
local geoColor =				Color(100, 80 , 200, 255)

--local regColor =				Color(218, 165, 32 , 255)
local cityColor =				Color(175, 238, 238, 255)
local countColor =			Color(240, 128, 128, 255)

local quit = {}
local address_lookup = {}

local relayChat = CreateConVar("player_join_relay", "1", FCVAR_ARCHIVE, "Should we send join/connect info to players?")
local function message(...)
	MsgC(...)

	if relayChat:GetBool() and chat then
		chat.AddText(...)
	end
end

local function sound(path)
	for k, v in ipairs(player.GetAll()) do
		v:ConCommand("play " .. path)
	end
end

local slots = game.MaxPlayers()

local connect_sound = "npc/scanner/scanner_nearmiss1.wav"
gameevent.Listen("player_connect")
hook.Add("player_connect", "EPOE.Information.PlayerConnect", function(data)
	message(connectColor, "[Connect] ", normalColor, data.name .. " (" .. data.networkid .. ") is connecting to the server.")
	MsgC(addressColor, " (" .. data.address .. ")\n") -- Never send players their IP address.

	quit[data.address] = true
	address_lookup[data.networkid] = data.address

	sound(connect_sound)
end)

local join_sound = "npc/roller/mine/rmine_blip1.wav"
hook.Add("PlayerInitialSpawn", "EPOE.Information.PlayerInitialSpawn", function(ply)
	local before = tobool(ply:GetPData("EPOE.Information.JoinedBefore", false) or "false") and "" or " for the first time"

	local address = ply:IPAddress()
	if address == "Error!" then address = "none" end
	local networkid = ply:SteamID()

	local count = #player.GetAll()
	message(joinColor, "[Join] ", normalColor, ply:Name() .. " (" .. networkid .. ") connected to the server" .. before .. ". (" .. count .. "/" .. slots .. ")")
	MsgC(addressColor, " (" .. address .. ")\n") -- Never send players their IP address.

	ply:SetPData("EPOE.Information.JoinedBefore", true)
	quit[address] = nil

	if PlyInfo then
		PlyInfo:GetInfo(ply)

		timer.Simple(2, function() if ply and IsValid(ply) then hook.Run("PostPlayerInfoSpawn", ply) end end)
	end

	sound(join_sound)
end)

local location_sound = "npc/roller/mine/rmine_chirp_quest1.wav"
hook.Add("PostPlayerInfoSpawn", "EPOE.Information.PostPlayerInfoSpawn", function(ply)
	local country =	PlyInfo:GetCountry(ply)	or "Anonymous Proxy"
	--local region =	PlyInfo:GetRegion(ply)
	local city =		PlyInfo:GetCity(ply)

	if not city or city == "ERROR" or city == "N/A" then
		message(geoColor, "[Location] ", normalColor, ply:Name() .. " is from ", countColor, country, normalColor, ".")
	else
		message(geoColor, "[Location] ", normalColor, ply:Name() .. " is from ", cityColor, city, normalColor, " in ", countColor, country, normalColor, ".")
	end
	Msg("\n")

	sound(location_sound)
end)

local dc_sound = "npc/roller/mine/combine_mine_deploy1.wav"
local dc_quitload = "vo/Citadel/br_youfool.wav"
gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "EPOE.Information.PlayerDisconnect", function(data)
	local networkid = data.networkid or "MISSING STEAMID"
	local address = address_lookup[data.networkid] or "none"

	local loading = quit[address] and "at the loading screen " or "from the server "
	if quit[address] and data.reason == "Disconnect by user." then sound(dc_quitload) else sound(dc_sound) end

	local count = #player.GetAll() - 1
	message(disconnectColor, "[Disconnect] ", normalColor, data.name .. " (" .. networkid .. ") disconnected " .. loading .. ". [" .. data.reason .. "] " .. (quit[address] and "" or "(" .. count .. "/" .. slots .. ")"))
	MsgC(addressColor, " (" .. address .. ")\n") -- Never send players their IP address.

	quit[address] = nil
end)
