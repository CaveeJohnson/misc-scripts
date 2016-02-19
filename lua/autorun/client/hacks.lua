local ply = LocalPlayer()

surface.CreateFont("BudgetLabel2", {
	font 	= "Courier New",
	size 	= 15,
	weight 	= 400,
	outline = true,
})

local drawOver = {
	"This copy of Garry's Mod is not genuine",
	"Build " .. VERSION,
	"Garry's Mod 13",
}

local messages = {
	"Attempting to bruteforce RCON",
	"Filestealing gamemode and addons",
	"Attempting to upload dlls",
	"Attempting to backdoor files",
	"Detecting and disabling anti-cheats",
	"Detecting admins",
	"Attempting to disable admin powers",
	"Loading core",
	"Loading external",
	"Loading plugins",
	"Loading modmenu",
	"Setting up callback to hexahedron mainframe",
	"Scanning for function signitures",
	"Hooking PainTraverse",
	"Hooking g_pLuaInterface",
	"Finalizing",
	"Cleaning up data",
	"Secondary Finalization",
	"All done",
}

drawnMessages = {
}

local dots = ""
local iteration = 1
local function doDots()
	if #dots > 2 then
		drawnMessages[iteration] = messages[iteration] .. "... *DONE*"
		iteration = iteration + 1
		if iteration > #messages then
			timer.Destroy("__dots")
			drawnMessages = {"FINISHED LOADING!"}
		return end
		dots = ""
		return
	end
	dots = dots .. "."
	drawnMessages[iteration] = messages[iteration] .. dots
end

local title = "H@x@h@dr@n M@@nfr@m@ H@ck@r"
local vowels = {"a","e","i","o","u"}
local function getTitle()
	local newT = ""

	for c in title:gmatch(".") do
		if c == "@" then newT = newT .. table.Random(vowels) continue end
		newT = newT .. c
	end

	return newT
end

local function done() return drawnMessages[1] == "FINISHED LOADING!" end
local eyeRape = CreateConVar("mainframe_eyehack", 1, FCVAR_ARCHIVE, "Should we hack your eye mainframes?")

local function draw()
	if done() and eyeRape:GetBool() then
		local col = HSVToColor(math.random(359), math.Rand(0.8, 1), math.Rand(0.8, 1))
			col.a = 20
		surface.SetDrawColor(col)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end

	surface.SetFont("BudgetLabel")
	surface.SetTextColor(color_white)

	local cy, cx = ScrH() - 5, ScrW() - 5
	for k, v in pairs(drawOver) do
		local w, h = surface.GetTextSize(v)

		cy = cy - h
		surface.SetTextPos(cx - w, cy)
		surface.DrawText(v)
	end

	cy, cx = 5, 5
	surface.SetFont("BudgetLabel2")

	for k, v in pairs(drawnMessages) do
		local w, h = surface.GetTextSize(v)

		surface.SetTextPos(cx, cy)
		surface.DrawText(v)

		cy = cy + h
	end

	cy, cx = 5, ScrW() / 2
	if done() then
		local v = getTitle()
		local w, h = surface.GetTextSize(v)

		surface.SetTextPos(cx - w / 2, (cy + math.random(-1, 1)))
		surface.DrawText(v)
	end
end

hook.Add("HUDPaint", "__hacks", draw)
timer.Create("__dots", 0.3, 0, doDots)
