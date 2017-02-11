local size = 48
local live_color = Color(255, 255, 40 , 255)
local dead_color = Color(100, 100, 100, 255)
local alpha_live = 200
local alpha_dead = 200

local function render1(self, w, h)
	local col  = self:GetChecked() and live_color or dead_color
	local col2 = self:GetChecked() and dead_color or live_color
	local a    = self:GetChecked() and alpha_live or alpha_dead

	surface.SetDrawColor(col)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(col2.r, col2.g, col2.b, a)
	surface.DrawLine(w - 1, 0, w - 1, h)
	surface.DrawLine(0, h - 1, w, h - 1)
end

local function renderR1(self, w, h)
	render1(self, w, h)

	surface.DrawLine(0, 0, 0, h)
end

local function renderC1(self, w, h)
	render1(self, w, h)

	surface.DrawLine(0, 0, w, 0)
end

local function renderCR1(self, w, h)
	render1(self, w, h)

	surface.DrawLine(0, 0, 0, h)
	surface.DrawLine(0, 0, w, 0)
end

gol_f = gol_f
local function buildPanel(rmv)
	if IsValid(gol_f) then
		if rmv then
			gol_f:Remove()
		elseif not gol_f:IsVisible() then
			return gol_f:SetVisible(true)
		else
			return
		end
	end

	gol_f = vgui.Create("DFrame")
	local f = gol_f

	f:SetDeleteOnClose(false)

	f.array = {}

	function f.array.get(r, c)
		return (f.array[r] or {})[c]
	end

	function f.array.getAlive()
		local t = {}

		for r = 1, size do
			for c = 1, size do
				local ch = f.array[r][c]

				if ch:GetChecked() then
					t[#t + 1] = ch
				end
			end
		end

		return t
	end

	function f.array.simulate()
		for r = 1, size do
			for c = 1, size do
				local v = f.array[r][c]
				local live = v:getLiveNeighbors()

				v.shouldToggle = false

				if v:GetChecked() then -- Alive
					if #live < 2 then -- Underpopulation death
						v.shouldToggle = true
					elseif #live > 3 then -- Overpopulation death
						v.shouldToggle = true
					end
				else -- Dead
					if #live == 3 then -- Reproduction
						v.shouldToggle = true
					end
				end
			end
		end

		for r = 1, size do
			for c = 1, size do
				local v = f.array[r][c]

				if v.shouldToggle then
					v:Toggle()
				end
			end
		end
	end

	for r = 1, size do
		f.array[r] = {}

		for c = 1, size do
			f.array[r][c] = vgui.Create("DCheckBox", f)
			local ch = f.array[r][c]

			ch:SetSize(16, 16)
			ch:SetPos(r * 16, c * 16 + 16)

			ch.r = r
			ch.c = c

			local func = render1
			if c == 1 then
				func = r == 1 and renderCR1 or renderC1
			elseif r == 1 then
				func = renderR1
			end

			ch.Paint = func

			function ch:genNeighbors()
				self.n_t = {
					f.array.get(r - 1, c    ), --
					f.array.get(r + 1, c    ), --
					f.array.get(r - 1, c - 1), --
					f.array.get(r + 1, c + 1), --

					f.array.get(r - 1, c + 1), --
					f.array.get(r + 1, c - 1), --
					f.array.get(r    , c + 1), --
					f.array.get(r    , c - 1), --
				}

				return self.n_t
			end

			function ch:getNeighbors()
				return self.n_t or ch:genNeighbors()
			end

			function ch:getLiveNeighbors()
				local t = self:getNeighbors()
				local ret = {}

				for i = 1, 8 do
					local v = t[i]

					if v and v:GetChecked() then -- May be nil on edge case
						ret[#ret + 1] = v
					end
				end

				return ret
			end
		end
	end

	for r = 1, size do -- Slower startup for faster runtime
		for c = 1, size do
			local ch = f.array[r][c]

			ch:genNeighbors()
		end
	end

	f:SetTitle("Conway's Game of Life: Derma CheckBox edition")

	f.controls = vgui.Create("DPanel", f)
	local c = f.controls

	c:Dock(BOTTOM)

	f.controls.left = vgui.Create("DPanel", f.controls)
	local l = f.controls.left

	l:Dock(LEFT)
	l:SetWide(110)

	f.controls.left.tickButton = vgui.Create("DButton", f.controls.left)
	local b = f.controls.left.tickButton

	b:Dock(BOTTOM)
	b:SetText("Simulate 1tp")

	b.DoClick = f.array.simulate

	f.controls.tpSelect = vgui.Create("DNumberScratch", f.controls)
	local n = f.controls.tpSelect

	n:Dock(LEFT)
	n:SetMax(300)
	n:SetMin(1)
	n:SetValue(25)

	f.controls.left.timerButton = vgui.Create("DButton", f.controls.left)
	local t = f.controls.left.timerButton

	t:Dock(TOP)
	t:SetText("Start Automata")

	local lastTick = 0
	local function automata()
		hook.Add("DrawOverlay", "automata", function()
			local tm = CurTime()
			if tm < lastTick + (n:GetFloatValue() / 100) then return end

			f.array.simulate()
			lastTick = tm
		end)
	end

	local function destroy()
		hook.Remove("DrawOverlay", "automata")
	end

	function t.DoClick()
		if t.tog then
			destroy()

			t:SetText("Start Automata")
			b:SetEnabled(true)
		else
			automata()

			t:SetText("Stop Automata")
			b:SetEnabled(false)
		end

		t.tog = not t.tog
	end

	f.controls:SetHeight(44)

	local _, h = f.controls:GetSize()
	local s = size * 16 + 32
	f:SetSize(s, s + 16 + h)
	f:Center()

	f:MakePopup()

	function f:OnClose()
		destroy()
	end
end

if IsValid(gol_f) then
	if gol_f:IsVisible() then
		buildPanel(true)
	else
		gol_f:Remove()
	end
end
concommand.Add("gameoflife", function() buildPanel() end)
