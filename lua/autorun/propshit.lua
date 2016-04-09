if SERVER then
local autoSpawn = {
	gm_bluehills_test3 = {
		-- FFT Player
		[1] = {
			pos = Vector(-1477.0, 566.0, 470.0),
			angles = Angle(0.0, -180.0, 0.0),
			class = "fft_v2",
			callback = function(ent)
				ent:CPPISetOwner(game.GetWorld())
				ent:Play("monstercat")

				_G.map_fft = ent
			end,
		},

		-- Main PlayX
		[2] = {
			pos = Vector(770.0, 509.0, 305.0),
			angles = Angle(4.0, 90.0, 0.0),
			class = "gmod_playx",
			callback = function(ent)
				ent:SetModel("models/dav0r/camera.mdl")
				ent:CPPISetOwner(game.GetWorld())

				_G.map_playx = ent
			end,
		}
	}
}

local function propshit_autospawn()
	for k, v in ipairs(autoSpawn[game.GetMap()] or {}) do
		local e = ents.Create(v.class)
			e:SetPos(v.pos)
			e:SetAngles(v.angles)
		e:Spawn()
		e:Activate()

		e._propshit = true
		v.callback(e)
	end
end

hook.Add("InitPostEntity", "propshit_autospawn", propshit_autospawn)
concommand.Add("propshit_respawn_ents", function(p)
		if IsValid(p) and not p:IsAdmin() then return end
		for k, v in ipairs(ents.GetAll()) do if v._propshit then v:Remove() end end
		propshit_autospawn()
end)
end

local modelBlacklist = {
	["models/props_vehicles/tanker001a.mdl"] = true,
	["models/props_vehicles/apc001.mdl"] = true,
	["models/props_combine/combinetower001.mdl"] = true,
	["models/cranes/crane_frame.mdl"] = true,
	["models/items/item_item_crate.mdl"] = true,
	["models/props/cs_militia/silo_01.mdl"] = true,
	["models/props/cs_office/microwave.mdl"] = true,
	["models/props/de_train/biohazardtank.mdl"] = true,
	["models/props_buildings/building_002a.mdl"] = true,
	["models/props_buildings/collapsedbuilding01a.mdl"] = true,
	["models/props_buildings/project_building01.mdl"] = true,
	["models/props_buildings/row_church_fullscale.mdl"] = true,
	["models/props_c17/consolebox01a.mdl"] = true,
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_c17/paper01.mdl"] = true,
	["models/props_c17/trappropeller_engine.mdl"] = true,
	["models/props_canal/canal_bridge01.mdl"] = true,
	["models/props_canal/canal_bridge02.mdl"] = true,
	["models/props_canal/canal_bridge03a.mdl"] = true,
	["models/props_canal/canal_bridge03b.mdl"] = true,
	["models/props_combine/combine_citadel001.mdl"] = true,
	["models/props_combine/combine_mine01.mdl"] = true,
	["models/props_combine/combinetrain01.mdl"] = true,
	["models/props_combine/combinetrain02a.mdl"] = true,
	["models/props_combine/combinetrain02b.mdl"] = true,
	["models/props_combine/prison01.mdl"] = true,
	["models/props_combine/prison01c.mdl"] = true,
	["models/props_industrial/bridge.mdl"] = true,
	["models/props_junk/garbage_takeoutcarton001a.mdl"] = true,
	["models/props_junk/gascan001a.mdl"] = true,
	["models/props_junk/glassjug01.mdl"] = true,
	["models/props_junk/trashdumpster02.mdl"] = true,
	["models/props_phx/amraam.mdl"] = true,
	["models/props_phx/ball.mdl"] = true,
	["models/props_phx/cannonball.mdl"] = true,
	["models/props_phx/huge/evildisc_corp.mdl"] = true,
	["models/props_phx/misc/flakshell_big.mdl"] = true,
	["models/props_phx/misc/potato_launcher_explosive.mdl"] = true,
	["models/props_phx/mk-82.mdl"] = true,
	["models/props_phx/oildrum001_explosive.mdl"] = true,
	["models/props_phx/torpedo.mdl"] = true,
	["models/props_phx/ww2bomb.mdl"] = true,
	["models/props_wasteland/cargo_container01.mdl"] = true,
	["models/props_wasteland/cargo_container01.mdl"] = true,
	["models/props_wasteland/cargo_container01b.mdl"] = true,
	["models/props_wasteland/cargo_container01c.mdl"] = true,
	["models/props_wasteland/depot.mdl"] = true,
	["models/xqm/coastertrack/special_full_corkscrew_left_4.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true,
	["models/props_c17/fountain_01.mdl"] = true,
	["models/props_trainstation/train003.mdl"] = true,
	["models/props_foliage/tree_poplar_01.mdl"] = true,
	["models/mechanics/solid_steel/i_beam2_32.mdl"] = true,
	["models/props_c17/furnituredrawer001a_chunk06.mdl"] = true,
	["models/mechanics/solid_steel/i_beam2_32.mdl"] = true,
	["models/props_phx/mechanics/slider2.mdl"] = true,
	["models/props_phx/gears/rack70.mdl"] = true,
	["models/mechanics/gears2/pinion_80t1.mdl"] = true,
	["models/nova/airboat_seat.mdl"] = true,
	["models/mechanics/robotics/a4.mdl"] = true,
	["models/mechanics/roboticslarge/claw_hub_8.mdl"] = true,
	["models/perftest/loader_static.mdl"] = true,
	["models/mechanics/robotics/e4.mdl"] = true,
	["models/mechanics/roboticslarge/e4.mdl"] = true,
	["models/perftest/rocksground01b.mdl"] = true,
	["models/mechanics/roboticslarge/g4.mdl"] = true,
	["models/mechanics/roboticslarge/e4.mdl"] = true,
	["models/mechanics/roboticslarge/j4.mdl"] = true,
	["models/props_animated_breakable/smokestack.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_01.mdl"] = true,
	["models/xqm/rails/slope_down_90.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_02.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_03.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_04.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_05.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_06.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_07.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_08.mdl"] = true,
	["models/xqm/coastertrack/special_full_loop_3.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_09.mdl"] = true,
	["models/props_animated_breakable/smokestack_gib_10.mdl"] = true,
	["models/xqm/coastertrack/special_full_corkscrew_right_4.mdl"] = true,
	["models/props_buildings/collapsedbuilding01awall.mdl"] = true,
	["models/props_buildings/collapsedbuilding02a.mdl"] = true,
	["models/props_buildings/collapsedbuilding02b.mdl"] = true,
	["models/xqm/coastertrack/special_half_corkscrew_right_4.mdl"] = true,
	["models/props_buildings/collapsedbuilding02c.mdl"] = true,
	["models/props_buildings/project_destroyedbuildings01.mdl"] = true,
	["models/props_buildings/project_building03_skybox.mdl"] = true,
	["models/props_buildings/project_building03.mdl"] = true,
	["models/props_buildings/project_building02_skybox.mdl"] = true,
	["models/props_buildings/project_building02.mdl"] = true,
	["models/props_buildings/project_building01_skybox.mdl"] = true,
	["models/props_buildings/factory_skybox001a.mdl"] = true,
	["models/xqm/coastertrack/special_full_corkscrew_right_3.mdl"] = true,
	["models/props_buildings/row_res_1_fullscale.mdl"] = true,
	["models/props_buildings/watertower_002a.mdl"] = true,
	["models/props_buildings/watertower_001c.mdl"] = true,
	["models/props_buildings/watertower_001a.mdl"] = true,
	["models/props_buildings/short_building001a.mdl"] = true,
	["models/props_buildings/row_res_2_fullscale.mdl"] = true,
	["models/props_buildings/row_res_2_ascend_fullscale.mdl"] = true,
	["models/xqm/coastertrack/special_full_corkscrew_left_2.mdl"] = true,
	["models/props_canal/generator01.mdl"] = true,
	["models/props_canal/generator02.mdl"] = true,
	["models/props_canal/locks_large.mdl"] = true,
	["models/props_canal/locks_large_b.mdl"] = true,
	["models/props_canal/locks_small.mdl"] = true,
	["models/props_canal/locks_small_b.mdl"] = true,
	["models/xqm/coastertrack/special_half_corkscrew_right_4.mdl"] = true,
	["models/props_canal/canal_bars001.mdl"] = true,
	["models/props_trainstation\train003.mdl"] = true,
	["models/props_canal/canal_bridge04.mdl"] = true,
	["models/props_canal/pipe_bracket001.mdl"] = true,
	["models/props_canal/canal_bridge_railing_lamps.mdl"] = true,
	["models/props_canal/canal_bridge_railing02.mdl"] = true,
	["models/props_canal/canal_bridge_railing01.mdl"] = true,
	["models/xqm/coastertrack/special_half_corkscrew_right_3.mdl"] = true,
	["models/props_canal/winch01.mdl"] = true,
	["models/props_canal/rock_riverbed01c.mdl"] = true,
	["models/props_canal/rock_riverbed01d.mdl"] = true,
	["models/props_canal/rock_riverbed02a.mdl"] = true,
	["models/props_canal/rock_riverbed02b.mdl"] = true,
	["models/props_canal/winch02c.mdl"] = true,
	["models/props_canal/winch02d.mdl"] = true,
	["models/props_canal/rock_riverbed01b.mdl"] = true,
	["models/props_canal/refinery_04.mdl"] = true,
	["models/props_canal/refinery_05.mdl"] = true,
	["models/xqm/rails/twist_90_left.mdl"] = true,
	["models/props_canal/canal_bars001.mdl"] = true,
	["models/props_canal/bridge_pillar02.mdl"] = true,
	["models/xqm/rails/loop_right.mdl"] = true,
	["models/props_citizen_tech/windmill_blade002a.mdl"] = true,
	["models/props_citizen_tech/till001a_base01.mdl"] = true,
	["models/props_citizen_tech/steamengine001a.mdl"] = true,
	["models/props_citizen_tech/guillotine001a_base01.mdl"] = true,
	["models/props_citizen_tech/firetrap_gashose01c.mdl"] = true,
	["models/props_citizen_tech/firetrap_gashose01b.mdl"] = true,
	["models/props_citizen_tech/firetrap_button01a.mdl"] = true,
	["models/props_citizen_tech/windmill_blade004a.mdl"] = true,
	["models/props_phx/misc/potato_launcher_chamber.mdl"] = true,
	["models/props_combine/combine_train02a.mdl"] = true,
}

local noSounds = {
	"vo/engineer_no01.mp3",
	"vo/engineer_no02.mp3",
	"vo/engineer_no03.mp3",
}

local log = CreateConVar("propshit_log", "1", FCVAR_ARCHIVE, "Enables the logging of prop spawns by propshit.")

local function PlayerSpawnProp(ply, model)
	local escapedModel = model:lower():gsub("\\","/"):gsub("//", "/"):Trim()
	if modelBlacklist[escapedModel] then
		if SERVER then ply:EmitSound(noSounds[math.random(1, #noSounds)], 140) end
	return false end

	if SERVER and log:GetBool() then print("PROP EVENT: ", ply, " -> ", escapedModel) end

	return true
end
hook.Add("PlayerSpawnProp", "propshit", PlayerSpawnProp)

local function CanDrive()
	return false
end
hook.Add("CanDrive", "propshit", CanDrive)

local function PlayerSpawnNPC()
	return false
end
hook.Add("PlayerSpawnNPC", "propshit", PlayerSpawnNPC)

local function PlayerSpawnRagdoll()
	return false
end
hook.Add("PlayerSpawnRagdoll", "propshit", PlayerSpawnRagdoll)

local spam = CurTime()
local function CanTool(ply, trace, mode)
	if mode == "duplicator" then
		if SERVER then ply:ChatPrint("The duplicator is not allowed here. Build your own stuff or use advdupe2!") end
	return false end

	if mode == "paint" then
		if SERVER and spam < CurTime() - 1 then ply:ChatPrint("Paint is banned here, there is no legitimate use for it.") spam = CurTime() end
	return false end

	if mode == "physprop" and trace.Entity:IsValid() and trace.Entity:GetClass() == "prop_vehicle_jeep" then
		return false
	end

	if trace.Entity.m_tblToolsAllowed then
		local vFound = false
		for k, v in pairs(trace.Entity.m_tblToolsAllowed) do
			if mode == v then vFound = true end
		end

		if not vFound then return false end
	end

	if trace.Entity.CanTool then
		return trace.Entity:CanTool(ply, trace, mode)
	end

	return true
end
hook.Add("CanTool", "propshit", CanTool)
