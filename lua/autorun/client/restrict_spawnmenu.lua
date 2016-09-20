restrict = restrict or {}
restrict.spawnmenu = {}
restrict.spawnmenu.remove = {
	"#spawnmenu.category.saves",
	"#spawnmenu.category.dupes",
	"#spawnmenu.category.npcs",
}

hook.Add("InitPostEntity", "restrict", function() -- Delayed load
spawnmenu.Reload = spawnmenu.Reload or concommand.GetTable().spawnmenu_reload
function restrict.spawnmenu.reload(...)
	spawnmenu.Reload(...)

	if GetConVar("developer"):GetInt() < 2 then
		local i = 1
		for k, v in next, g_SpawnMenu.CreateMenu.Items do
			if table.HasValue(restrict.spawnmenu.remove, v.Name) then
				g_SpawnMenu.CreateMenu.tabScroller.Panels[i] = nil
				g_SpawnMenu.CreateMenu.Items[k] = nil
				v.Tab:Remove()
			end
			
			i = i + 1
		end
	end
end

concommand.Add("spawnmenu_reload", restrict.spawnmenu.reload)
restrict.spawnmenu.reload()
end)
