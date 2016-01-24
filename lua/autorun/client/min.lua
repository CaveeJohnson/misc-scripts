if minmod and IsValid(minmod.Panel) then

	minmod.Panel:Remove()
	
end

local User 		= Material("deshou/Flag.png")
local Friend 	= Material("deshou/Shock.png")
local Self		= Material("deshou/Computer.png")
local Brick		= Material("deshou/Cube.png")
local Link		= Material("deshou/Flip 3D.png")
local Tick 		= Material("deshou/Check.png")
local Cross 	= Material("deshou/Disabled.png")

surface.CreateFont("minmod", {

	font = "HaxrCorp S8",
	size = 14,
	weight = 0,

})

surface.CreateFont("minmod2", {

	font = "HaxrCorp S8",
	size = 16,
	weight = 10,

})

minmod 			= {}
minmod.Tabs 	= {}
minmod.Friends 	= {}

minmod.Theme	= "Deshou"

--#333333 ... #2D2D2D ... #4E4E4E ... #A98D9B ... #D9BFC2 ... #CCCCCA

minmod.Colors 	= {

	Default = {
	
		White		= Color(255, 255, 255, 255),
		Alpha		= Color(  0,   0,   0,   0),

		SourceGray	= Color( 95,  97, 102, 230),
		--SourceGray	= Color(131, 131, 135, 195),
		DarkGray	= Color( 81,  81,  81, 255),
		
		Red			= Color(171,   0,   0, 255),
		Blue		= Color(  0,   0, 171, 255),
		
		IcoPrefix	= "icon16/",
	
	},
	
	Deshou = {
	
		White		= Color(255, 255, 255, 255),
		Alpha		= Color( 0,   0,   0,   0),

		SubGrey		= Color(51,  51,  51, 255),
		DarkGrey	= Color(45,  45,  45, 255),
		HighGrey	= Color(78,  78,  78, 255),
		LightGrey	= Color(204, 204, 202, 255),
		
		Pink		= Color(217, 191, 194, 255),
		Pink2		= Color(169, 141, 155, 255),
		
		IcoPrefix	= "deshou/",
	
	},
		
}
setmetatable(minmod.Colors, {__index = function(t, k) return t[minmod.Theme][k] end})

minmod.ply		= LocalPlayer()

function minmod:AddTab(tab)
	tab.Panel = vgui.Create("DPanel", minmod.TabContainer)
	
	tab.Panel.Tab = tab
	tab.Panel.Paint = function() end
	
	if tab.Width then self.Panel:SetSize(tab.Width, ScrH() - 100) end
	
	tab.Panel:Dock(FILL)
	
	tab:Init(tab.Panel)
	
	if tab.Refresh then tab:Refresh() end
	
	table.insert(minmod.Tabs, tab)
	
	local TabPanel = minmod.TabContainer:AddSheet("", tab.Panel, minmod.Colors.IcoPrefix .. tab.Icon .. ".png", false, false, tab.Description).Tab
		TabPanel.Paint = function(panel, w, h)
			
			if panel:IsActive() then
			
				surface.SetDrawColor(tab.Color)
				surface.DrawRect(0, 0, w - 6, 22)
				
			else
			
				local Col = table.Copy(tab.Color)
				Col.a = 100
			
				surface.SetDrawColor(Col)
				surface.DrawRect(0, 0, w - 6, 22)
				
			end
			
			--surface.SetDrawColor(0, 0, 0, 255)
			--surface.DrawOutlinedRect(0, 0, w - 6, 22)
			
		end
		
		TabPanel.Image:SetSize(16, 16)
	
end

function minmod:GetActiveTab()

	for _, sheet in next, self.TabContainer.Items do
	
		if sheet.Tab == self.TabContainer:GetActiveTab() then
		
			return sheet.Panel.Tab
			
		end
		
	end
	
end

function minmod:TabSelected(tab)

	if tab and tab.Refresh then
	
		tab:Refresh()
		
	end
	
end

function minmod:Think()
	
	if not self.Panel or not IsValid(self.Panel) then return end
	
	local ActiveTab = self:GetActiveTab()
	
	if self.ActiveTab ~= ActiveTab then
	
		self.ActiveTab = ActiveTab
		minmod:TabSelected(ActiveTab)
		
	end
	
	if self.Panel:GetPos() > ScrW() and self.Closing then
	
		self.Closing = false
		self.Panel:SetVisible(false)
		gui.EnableScreenClicker(false)
		
	end
		
end

function minmod:Init()

	self.Panel = vgui.Create("DFrame")
		self.Panel:SetSize(350, ScrH() - 100)
		self.Panel:SetPos(ScrW() + 100, ScrH() / 2 - self.Panel:GetTall() / 2)
		
		self.Panel:ShowCloseButton(false)
		self.Panel:SetDraggable(false)
		self.Panel:LerpPositions(1, true)
		
		self.Panel:SetTitle("")
		
		self.Panel.Paint = function(panel, w, h)
		
			surface.SetDrawColor(minmod.Colors.SubGrey)
			surface.DrawRect(0, 0, w, h)
			
			draw.SimpleText("MINMOD", "minmod", 8, 4, minmod.Colors.Pink2)
			
			--surface.SetDrawColor(0, 0, 0, 255)
			--surface.DrawOutlinedRect(0, 0, w, h)
			
		end
	
	self.TabContainer = vgui.Create("DPropertySheet", self.Panel)
		self.TabContainer:SetPos(0, 0)
		self.TabContainer:Dock(FILL)
		
		self.TabContainer.Paint = function() end
		
	self.Panel:SetVisible(false)
	
end

function minmod:GetRate()

	if not self.Panel or not IsValid(self.Panel) then return 0 end

	return self.Panel:GetWide() / 4
	
end

function minmod:Show()

	if not self.Panel or not IsValid(self.Panel) then return end
	
	for _, tab in next, self.Tabs do
	
		if tab.Refresh then tab:Refresh() end
		
	end
	
	self.Panel:SetVisible(true)
	gui.EnableScreenClicker(true)
	
	self.Panel:SetKeyboardInputEnabled(false)
	self.Panel:SetMouseInputEnabled(true)
	
	self.Panel:SetPos(ScrW() - self.Panel:GetWide(), ScrH() / 2 - self.Panel:GetTall() / 2)
	
end

function minmod:Hide()

	if not self.Panel or not IsValid(self.Panel) then return end
	
	self.Panel:SetKeyboardInputEnabled(false)
	self.Panel:SetMouseInputEnabled(false)
	
	self.Panel:SetPos(ScrW() + 100, ScrH() / 2 - self.Panel:GetTall() / 2)
	
	self.Closing = true
	
end

function minmod.Toggle()

	local self = minmod

	if not self.Panel or not IsValid(self.Panel) then
	
		self:Init()
		
	return end

	if self.Panel:IsVisible() then
	
		self:Hide()
	
	else
	
		self:Show()
		
	end

end

function minmod:IsFriend(ply)

	if not ply or not IsValid(ply) then return false end
	
	if ply == minmod.ply then return true end
	
	local SelfFriend = self.Friends[ply:SteamID()]
	
	if SelfFriend == nil then SelfFriend = (ply:GetFriendStatus() == "friend") end
	
	return SelfFriend
	
end

function minmod:SetFriend(ply, bool)

	if not ply or not IsValid(ply) then return end
	
	if ply == minmod.ply then return end
	
	self.Friends[ply:SteamID()] = bool

end

function minmod:OnList(list, obj)

	minmod[list] = minmod[list] or {}
	
	return minmod[list][obj]
	
end

function minmod:AddToList(list, obj, bool)

	minmod[list] = minmod[list] or {}
	
	minmod[list][obj] = bool
	
end

function minmod:IsTarget(ent, ignoreTargetPly)

	if ent:IsPlayer() and (not self:IsFriend(ent) or ignoreTargetPly) then return true end
	if self:OnList("TargetEntities", ent) or self:OnList("TargetClasses", ent:GetClass()) then return true end
	
	return false
	
end

function minmod:GetVarTable()

	return self.Vars or {}
	
end

function minmod:SetVar(name, val, icon)

	self.Vars = self.Vars or {}

	if not icon then
	
		self.Vars[name].Val = val
		
	return end
	
	self.Vars[name] = {Val = val, Icon = minmod.Colors.IcoPrefix .. icon .. ".png"}
	
end

function minmod:GetVar(name)

	self.Vars = self.Vars or {}

	if not self.Vars[name] then
	
		self:SetVar(name, true, "delete")
		
	return true end

	return self.Vars[name].Val
	
end

hook.Add("Think", "minmod_think", function() minmod:Think() end)

concommand.Add("minmod", minmod.Toggle)

minmod:Init()

--
-- START GUI DEFINITIONS
--

local PANEL
PANEL = {}

function PANEL:AddOption(strText, funcFunction, icon)

	local pnl = vgui.Create("DMenuOption", self)
		pnl:SetMenu(self)
		pnl:SetText(strText)
		
		pnl:SetTextColor(minmod.Colors.Pink)
	
		if icon then
		
			pnl:SetIcon(icon)
			pnl.m_Image:SetSize(16, 16)
			
		end
		
		pnl.Paint = function(panel, w, h)
		
			if panel.Hovered then
		
				surface.SetDrawColor(minmod.Colors.Pink2)
				surface.DrawRect(0, 0, w, h)
		
			end
		
		end
		
		if funcFunction then pnl.DoClick = funcFunction end
	
	self:AddPanel(pnl)
		
	return pnl

end

function PANEL:Paint(w, h)

	surface.SetDrawColor(minmod.Colors.DarkGrey)
	surface.DrawRect(0, 0, w, h)

end

derma.DefineControl("MinModRMBMenu", "", PANEL, "DMenu")

PANEL = {}

function PANEL:Paint(w, h) end

function PANEL:OnClickLine() end

function PANEL:AddPlayer(tbl)
	
	self.Options = self.Options or {}

	local ply = tbl.Ply
	local item = self:AddLine("")
	
	item.Player = ply
	
	if ply:IsPlayer() then
	
		item.Avatar = vgui.Create("AvatarImage", item)
		item.Avatar:SetPlayer(ply)
		item.Avatar:SetPos(0, 0)
		item.Avatar:SetSize(17, 17)
	
	else
	
		item.Avatar = vgui.Create("DModelPanel", item)
		item.Avatar:SetModel(tbl.Model)
		item.Avatar:SetPos(0, 0)
		item.Avatar:SetSize(17, 17)
		
		item.Avatar.LayoutEntity = function() return end
	
	end
	
	item.Paint = function(pan, w, h)
	
		if pan.Hovered then
		
			surface.SetDrawColor(minmod.Colors.Pink2)
			surface.DrawRect(0, 0, w, h)
		
		return end
	
		if pan.m_bAlt then
		
			surface.SetDrawColor(minmod.Colors.DarkGrey)
			surface.DrawRect(0, 0, w, h)
			
		end
	
	end
	
	item.PaintOver = function()
	
		if not IsValid(item.Player) then
		
			if #self:GetSelected() == 0 then self:SelectFirstItem() end
			
			self:RemoveLine(item:GetID())
			
			return
			
		end
		
		if ply:IsPlayer() then
		
			if ply == minmod.ply then
			
				surface.SetMaterial(Self)
			
			elseif minmod:IsFriend(ply) then
			
				surface.SetMaterial(Friend)
				
			else
				
				surface.SetMaterial(User)
				
			end
		
		else
		
			if minmod:IsTarget(ply) then
		
				surface.SetMaterial(Link)
				
			else
			
				surface.SetMaterial(Brick)
				
			end
		
		end
		
		local Offset = self.VBar.Enabled and -16 or 0
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(item:GetWide() - 20 + Offset, 0, 16, 16)
		
		draw.SimpleText(tbl.Name, "minmod", 28, 2, minmod.Colors.Pink)
		
	end
	
	item.OnMousePressed = function(pan, button)
		
		CloseDermaMenus()
		pan.menu = vgui.Create("MinModRMBMenu", pan)
		
		local Document = "deshou/Document.png"
		
		if ply:IsPlayer() then
		
			pan.menu:AddOption("Copy SteamID", function() SetClipboardText(ply:SteamID()) end, Document)
		
		else
		
			pan.menu:AddOption("Copy Model", function() SetClipboardText(tbl.Model) end, Document)
			
			pan.menu:AddOption("Copy Class", function() SetClipboardText(tbl.Class) end, Document)
		
		end
		
		for _, option in next, self.Options do
		
			if not option.Filt(ply) then continue end
		
			pan.menu:AddOption(option.Text, function() option.Func(ply) end, option.Icon)
			
		end
		
		pan.menu:Open()
			
	end
	
	return item
	
end

function PANEL:AddRMBOption(text, icon, func, filt)

	self.Options = self.Options or {}
	
	local option = {
	
		Text = text,
		Icon = minmod.Colors.IcoPrefix .. icon .. ".png",
		Func = func,
		Filt = filt,
	
	}
	
	table.insert(self.Options, option)
	
end

function PANEL:Populate(e)

	self:Clear()
	
	local players = {}
	if not e then
	
		for _, pl in next, player.GetAll() do
		
			table.insert(players, {Name = pl:Nick(), Ply = pl})
		
		end
		
	else
	
		for _, ent in next, ents.GetAll() do
		
			local class = ent:GetClass()
			if not class or class:StartWith("env_") or class:StartWith("prop_") or class:StartWith("weapon_") or class:find("viewmodel") or class == "beam" then continue end
		
			local name = ent.PrintName
			if ent:IsPlayer() or ent:EntIndex() < 1 or ent:IsWeapon() or ent:IsNPC() or name == "" then continue end
		
			local model = ent:GetModel()
			if not model or model == "" or not model:EndsWith(".mdl") then continue end
		
			table.insert(players, {Name = name or class, Ply = ent, Model = model, Class = class})
		
		end
	
	end
	
	table.SortByMember(players, "Name", function(a, b) return a > b end)
	
	for _, pl in next, players do
	
		self:AddPlayer(pl)
		
	end
	
end

derma.DefineControl("MinModEnts", "", PANEL, "DListView")

PANEL = {}

function PANEL:AddVar(name, icon)

	local item = self:AddLine("")
	
	item.Icon = vgui.Create("DImage", item)
	item.Icon:SetImage(icon)
	item.Icon:SetPos(0, 0)
	item.Icon:SetSize(17, 17)
	
	item.Paint = function(pan, w, h)
	
		if pan.Hovered then
		
			surface.SetDrawColor(minmod.Colors.Pink2)
			surface.DrawRect(0, 0, w, h)
		
		return end
	
		if pan.m_bAlt then
		
			surface.SetDrawColor(minmod.Colors.DarkGrey)
			surface.DrawRect(0, 0, w, h)
			
		end
	
	end
		
	item.PaintOver = function()
		
		if minmod:GetVar(name) then
	
			surface.SetMaterial(Tick)
			
		else
		
			surface.SetMaterial(Cross)
			
		end
		
		local Offset = self.VBar.Enabled and -16 or 0
		
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(item:GetWide() - 20 + Offset, 0, 16, 16)
		
		draw.SimpleText(name, "minmod", 28, 2, minmod.Colors.Pink)
		
	end
	
	item.OnMousePressed = function(pan, button)
	
		local Val = minmod:GetVar(name)
	
		surface.PlaySound(Val and "buttons/button10.wav" or "buttons/button9.wav")
		minmod:SetVar(name, not Val)
		
	end
	
end

function PANEL:Populate()
	
	self:Clear()
	
	local vars = minmod:GetVarTable()
	
	table.SortByMember(vars, "Name", function(a, b) return a > b end)
	
	for name, data in next, vars do
	
		self:AddVar(name, data.Icon)
		
	end
	
end

derma.DefineControl("MinModVars", "", PANEL, "MinModEnts")

local TAB

--
-- Player + Ent Targeting
--

TAB = {}

TAB.Color		= minmod.Colors.SubGrey
TAB.Icon		= "Network"

TAB.Width		= 220

function TAB:Init(panel)

	self.PlayerList = vgui.Create("MinModEnts", panel)
	self.PlayerList:AddColumn("")
	self.PlayerList:SetHideHeaders(true)
	
	self.PlayerList:AddRMBOption("Exclude Target", "Pin Up",
		function(ply)
		
			minmod:SetFriend(ply, true)
		
		end,
		function(ply)
		
			return not minmod:IsFriend(ply)
			
		end
	)
	
	self.PlayerList:AddRMBOption("Remove Exclusion", "Pin Down",
		function(ply)
			
			minmod:SetFriend(ply, false)
	
		end,
		function(ply)
		
			return minmod:IsFriend(ply) and ply ~= minmod.ply
			
		end
	)
	
	self.PlayerList:Dock(FILL)
	
end

function TAB:Refresh()

	if not self.Panel then return end
	
	self.PlayerList:Populate()
	
end

minmod:AddTab(TAB)

TAB = {}

TAB.Color		= minmod.Colors.SubGrey
TAB.Icon		= "Computer Search"

TAB.Width		= 220

function TAB:Init(panel)
	
	self.EntList = vgui.Create("MinModEnts", panel)
	self.EntList:AddColumn("")
	self.EntList:SetHideHeaders(true)
	
	self.EntList:AddRMBOption("Target", "Pin Up",
		function(ent)
		
			minmod:AddToList("TargetEntities", ent, true)
		
		end,
		function(ent)
		
			return not minmod:OnList("TargetEntities", ent)
			
		end
	)
	
	self.EntList:AddRMBOption("Remove Target", "Pin Down",
		function(ent)
			
			minmod:AddToList("TargetEntities", ent, false)
	
		end,
		function(ent)
		
			return minmod:OnList("TargetEntities", ent)
			
		end
	)
	
	self.EntList:AddRMBOption("Target Class", "Pin Up",
		function(ent)
		
			minmod:AddToList("TargetClasses", ent:GetClass(), true)
		
		end,
		function(ent)
		
			return not minmod:OnList("TargetClasses", ent:GetClass())
			
		end
	)
	
	self.EntList:AddRMBOption("Remove Target Class", "Pin Down",
		function(ent)
			
			minmod:AddToList("TargetClasses", ent:GetClass(), false)
	
		end,
		function(ent)
		
			return minmod:OnList("TargetClasses", ent:GetClass())
			
		end
	)
	
	self.EntList:Dock(FILL)
	
end

function TAB:Refresh()

	if not self.Panel then return end
	
	self.EntList:Populate(true)
	
end

minmod:AddTab(TAB)

--
-- Variables
--

TAB = {}

TAB.Color		= minmod.Colors.SubGrey
TAB.Icon		= "Gear"

TAB.Width		= 220

function TAB:Init(panel, w, h)

	self.VarList = vgui.Create("MinModVars", panel)
	self.VarList:AddColumn("")
	self.VarList:SetHideHeaders(true)
	
	self.VarList:Dock(FILL)

end

function TAB:Refresh()

	if not self.Panel then return end
	
	self.VarList:Populate()

end

minmod:AddTab(TAB)

--
-- Nothing Yet
--

TAB = {}

TAB.Color		= minmod.Colors.SubGrey
TAB.Icon		= "Message"

TAB.Width		= 220

function TAB:Init(panel, w, h)


end

function TAB:Refresh()


end

minmod:AddTab(TAB)

minmod:SetVar("Draw Chams", true, "Camera")
minmod:SetVar("Draw ESP", true, "Camera")

minmod.chamsmat = CreateMaterial("minmod_chams", "VertexLitGeneric", {
	["$basetexture"] = "models/debug/debugwhite",
	["$model"] = 1,
	["$translucent"] = 1,
	["$alpha"] = 1,
	["$nocull"] = 1,
	["$ignorez"] = 1
})

minmod.ESPData = {

	Name		= function(e) return (e.Nick and e:Nick()) or e.PrintName or e:GetClass() end,
	RealName	= function(e) return (e.SteamName and e:SteamName() ~= e:Nick() and e:SteamName()) or nil end,

}

local hasbeenon = false
function minmod:ClearDraw(ent)

	if ent then
		
		ent.HasBeenDrawn = false
		ent:SetColor(minmod.Colors.White)
		
	return end

	for index, ent in next, ents.GetAll() do
		
		if not ent.HasBeenDrawn then continue end
		
		ent.HasBeenDrawn = false
		ent:SetColor(minmod.Colors.White)
		
	end
	
end

function minmod:ESPDraw()
	
	if not self:GetVar("Draw Chams") then
	
		if hasbeenon then
		
			self:ClearDraw()
			
			hasbeenon = false
			
		end
	
	else
	
	hasbeenon = true
	
	cam.Start3D()
		render.SuppressEngineLighting(true)
		render.SetBlend(0.5)
		render.MaterialOverride(self.chamsmat)
		
		render.SetColorModulation(1, 1, 1)
	
		for index, ent in next, ents.GetAll() do
		
			if not self:IsTarget(ent, true) then
			
				if ent.HasBeenDrawn then self:ClearDraw() end
			
			continue end
			
			ent.HasBeenDrawn = true
			
			local Class = ent:GetClass()
			
			if ent:IsPlayer() then
			
				if ent:IsDormant() then
				
					render.SetColorModulation(0.45, 0.36, 0.34)
					
				else
				
					render.SetColorModulation(0.85, 0.76, 0.74)
				
				end
				
			elseif Class:find("printer") then
			
				render.SetColorModulation(0.9, 0.9, 0.9)
			
			else
			
				render.SetColorModulation(0.7, 0.7, 0.7)
			
			end
			
			ent:DrawModel()
			ent:SetColor(minmod.Colors.Alpha)
			ent:SetRenderMode(RENDERMODE_TRANSALPHA)
			
		end
		
		render.SetColorModulation(1, 1, 1)
		
		render.MaterialOverride(nil)
		render.SetBlend(1)
		render.SuppressEngineLighting(false)
	
	cam.End3D()
	
	end
	
	if not self:GetVar("Draw ESP") then
	
		-- Nothing here yet
	
	else
	
	for index, ent in next, ents.GetAll() do
		
		if not self:IsTarget(ent, true) then continue end
		
		local pos 	= ent:GetPos():ToScreen()
		local x, y 	= pos.x, pos.y
		
		for k, v in next, minmod.ESPData do
		
			if not v(ent) then continue end
		
			surface.SetFont("minmod2")
		
			local text = k .. ": " .. v(ent)
			local w, h = surface.GetTextSize(text)
		
			surface.SetTextColor(minmod.Colors.DarkGrey)
		
			surface.SetTextPos(x - w / 2 + 1, y + 1)
			surface.DrawText(text)

			surface.SetTextColor(minmod.Colors.Pink)
		
			surface.SetTextPos(x - w / 2, y)
			surface.DrawText(text)
			
			y = y + h
			
		end
		
	end
	
	end

end
hook.Add("RenderScreenspaceEffects", "\0minmod_chams", function() minmod:ESPDraw() end)

minmod:SetVar("Enable Auto-Jump", true, "Arrow Up")

function minmod:BHop(cmd)

	if not self:GetVar("Enable Auto-Jump") then
	
		-- Nothing here yet
	
	else

	if not minmod.ply:IsOnGround() then
	
		cmd:SetButtons(bit.band(cmd:GetButtons(), bit.bnot(IN_JUMP)))
		
	end
	
	end
	
end
hook.Add("CreateMove", "\0minmod_bhop", function(cmd) minmod:BHop(cmd) end)
