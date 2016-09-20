local url = "http://hexahedron.pw/space_rules.html"
function OpenMOTD()
	hook.Remove("CalcView", "MOTD")

	local p = LocalPlayer()
	gui.EnableScreenClicker(true)

	local f = vgui.Create("DFrame")
	f:ShowCloseButton(false)
	f:SetSizable(false)
	f:SetDraggable(false)
	f:SetSize(850, 600)
	f:SetPos(ScrW()/2 - 425, ScrH()/2 - 300)

	f:SetTitle("Rules")
	f:SetIcon("icon16/cd_burn.png")

	local h = vgui.Create("DHTML", f)
	h:Dock(FILL)
	h:OpenURL(url)

	local d = vgui.Create("DButton", f)
	d:Dock(BOTTOM)
	d:SetHeight(20)
	d:SetIcon("icon16/cross.png")
	
	d.DoClick = function(s)
		p:ConCommand("disconnect")
	end

	d:SetText("Decline and Disconnect")

	local a = vgui.Create("DButton", f)
	a:Dock(BOTTOM)
	a:SetHeight(20)
	a:SetIcon("icon16/tick.png")
	
	a:DockMargin(0, 4, 0, 0)
	
	a.DoClick = function(s)
		if ValidPanel(f) then f:Close() gui.EnableScreenClicker(false) end
	end

	a:SetText("Accept Rules")

	f:MakePopup()
end
hook.Add("CalcView", "MOTD", OpenMOTD)
