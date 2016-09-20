local messages = {
	"Don't forget you can use precision alignment's mass center mode to help center your gyropod!",
	"Check out this guide for help with the basics! https://steamcommunity.com/sharedfiles/filedetails/?id=129010634",
	"If you require noclip then ask an admin to whitelist you for this session!",
	"sv_allowcslua is enabled so feel free to load custom lua, just not cheats!",
	"Are we missing an addon or tool (excluding CAP)? Contact Q2F2!",
	"Want more slots and a higher prop limit, or maybe CAP? Contact Q2F2 about helping fund the server!",
}

timer.Create("announcer", 160, 0, function()
	local msg = table.Random(messages)
	
	chat.AddText(GLib.Colors.Gray, "[", GLib.Colors.Orange, "HH-SB", GLib.Colors.Gray, "] ",
	color_white, msg)
end)
