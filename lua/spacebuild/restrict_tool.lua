restrict = restrict or {}
restrict.tools = {
	duplicator = "a massive minge device, use advdupe or advdupe2 instead",
	paint = "annoying and useless",
	balloon = "causes physics crashes",
}
restrict.tools.message = "This tool is blocked as it is "

local color1, color2 = Color(0, 255, 0), Color(255, 165, 0)
local curtime = 0

hook.Add("CanTool", "restrict", function(ply, trace, mode)
	if restrict.tools and restrict.tools[mode] then
		if SERVER then return false end
		
		if curtime < CurTime() then
			chat.AddText(color2, restrict.tools.message, color1, restrict.tools[mode], color2, ".")
			
			curtime = CurTime() + 2
		end
		
		return false
	end
end)
