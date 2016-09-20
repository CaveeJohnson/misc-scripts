local hud_lifesupport
do
	local MaxAmounts = 4000
	local MaxAmountsDivide = MaxAmounts/100

	local Display_temperature = GetConVar("LS_Display_Temperature")
	local Display_hud = GetConVar("LS_Display_HUD")

	function hud_lifesupport()
	end
end
hook.Add("HUDPaint", "hud_lifesupport", hud_lifesupport)

local hud_shoulddraw
do
	local hud_dontdraw = {
		--LS_Core_HUDPaint = true,
		CHudHealth = true,
		CHudBattery = true,
	}
	function hud_shoulddraw(e)
		if hud_dontdraw[e] then return false end
	end
end
hook.Add("HUDShouldDraw", "hud_shoulddraw", hud_shoulddraw)

local hud_main
do
	if hud_avatar_panel then hud_avatar_panel:Remove() end
	hud_avatar_panel = vgui.Create("AvatarImage")
	
	local panel_init = false
	local background = Color(000, 000, 000, 128)
	
	local slope = 10
	
	local user = Material("icon16/user.png")
	local heart = Material("icon16/heart.png")
	local shield = Material("icon16/shield.png")
	local feed = Material("icon16/feed.png")
	local feed_add = Material("icon16/feed_add.png")
	local feed_error = Material("icon16/feed_error.png")
	local function surface_draw_bar(x, y, w, h, col, ico)
		surface.SetDrawColor(background)
		draw.NoTexture()
		
		local struct = {
			{x = x + w, y = y - h},
			{x = x + w - slope, y = y},
			{x = x, y = y},
			{x = x, y = y - h},
		}
		surface.DrawPoly(struct)
		surface.DrawRect(x, y - h, h, h)
		
		surface.SetMaterial(ico or user)
		surface.SetDrawColor(255, 255, 255, 255)
		
		surface.DrawTexturedRect(x + h/2 - 8, y - h + h/2 - 8, 16, 16)
	end
	
	if SafeZones then
		SafeZones.NoHUD = true
	end
	
	local update = ScrW()
	function hud_main()
		local s_w, s_h = ScrW(), ScrH()
		local c, i, s = 0, 20, 3 -- Current, Interval, Spacing
		local ow, oh = 10, 10
		local p = LocalPlayer()
		
		local w = 220 + (64 + 3) + 1
		
		local function add_c(n) c = c + n + s end
		local function add_w(n) w = w + slope + s end
 		local function h() return s_h - oh - c end
		
		-- Dont forget this is bottom -> top
			
		if not panel_init or s_w ~= update then
			hud_avatar_panel:SetPlayer(LocalPlayer(), 64)
			hud_avatar_panel:SetPos(ow, h() - 64 - 1)
			hud_avatar_panel:SetSize(64, 64)
			hud_avatar_panel.Think = function() local a = hook.Run("HUDShouldDraw", "hud_main") if not a then hud_avatar_panel:SetVisible(false) end end
			
			panel_init = true
			update = s_w
		end
		
		hud_avatar_panel:SetVisible(true)
		
		ow = ow + (64 + 3) + 1
		w = w - (64 + 3) - 1
		
		surface_draw_bar(ow, h(), w, i, background, shield)
			draw.SimpleText(p:Armor() .. " / 255", "BudgetLabel", ow + i + s, h() - i/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			add_c(i) add_w(slope)
		surface_draw_bar(ow, h(), w, i, background, heart)
			draw.SimpleText(p:Health() .. " / " .. p:GetMaxHealth(), "BudgetLabel", ow + i + s, h() - i/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			add_c(i) add_w(slope)
		surface_draw_bar(ow, h(), w, i, background, user)
			draw.SimpleText(p:Nick(), "BudgetLabel", ow + i + s, h() - i/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			add_c(i) add_w(slope)
			
		ow = ow - (64 + 3) - 1
		w = w + (64 + 3) + 1
			
		if SafeZones then
			local txt
			local st = SafeZones.CurrentState

			local p = LocalPlayer()
			local name = SafeZones:PlayerSafe(p)
			
			local ico

			if st == "StartLeaveSafeZone" then
				txt = "Now leaving a SafeZone"
				ico = feed_error
			elseif st == "StartEnterSafeZone" then
				txt = "Now entering a safezone"
				ico = feed_add
			elseif st == "EnterSafeZone" or st == "StopLeaveSafeZone" or name then
				txt = "Inside a SafeZone"
				ico = feed
			end
			
			if txt then
				surface_draw_bar(ow, h(), w, i, background, ico)
					surface.SetFont("BudgetLabel")
					local tw = surface.GetTextSize(txt)
					
					draw.SimpleText(txt, "BudgetLabel", ow + i + s, h() - i/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					if name then draw.SimpleText(" : " .. name, "BudgetLabel", ow + i + s + tw, h() - i/2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
					add_c(i) add_w(slope)
			end
		end
	end
end
hook.Add("HUDPaint", "hud_main", hud_main)
