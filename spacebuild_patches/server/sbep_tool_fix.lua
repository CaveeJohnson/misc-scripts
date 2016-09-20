local function fixed_left_click_part(self, trace)
    if CLIENT then return end

    local model = self:GetClientInfo("model")
    local hab = self:GetClientNumber("hab_mod")
    local skin = self:GetClientNumber("skin")
    local glass = self:GetClientNumber("glass")
    local weld = self:GetClientNumber("weld")
    local pos = trace.HitPos

    local SMBProp = nil

    if hab == 1 then
        SMBProp = ents.Create("livable_module")
    else
        SMBProp = ents.Create("prop_physics")
    end

    SMBProp:SetModel(model)

    local skincount = SMBProp:SkinCount()
	SMBProp:SetNWInt("Skin",skinnum)
    local skinnum = nil
    if skincount > 5 then
        skinnum = skin * 2 + glass
    else
        skinnum = skin
    end

	SMBProp:SetNWInt("Skin", skinnum)

    SMBProp:SetSkin(skinnum)
    SMBProp:SetPos(pos - Vector(0, 0, SMBProp:OBBMins().z))

    SMBProp:Spawn()
    SMBProp:Activate()
	if weld == 1 and IsValid(trace.Entity) then
		constraint.Weld( SMBProp, trace.Entity, 0, trace.PhysicsBone, 0, collision == 1, false )
	end
	if CPPI then SMBProp:CPPISetOwner(self:GetOwner()) end -- The Fix
    undo.Create("SBEP Part")
    undo.AddEntity(SMBProp)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

	return true
end

local function fixed_left_click_door(self, tr)
if CLIENT then return end
	
	local ply = self:GetOwner()

	if ply:GetInfoNum( "sbep_door_wire", 1 ) == 0 and ply:GetInfoNum( "sbep_door_enableuse", 1 ) == 0 then
		umsg.Start( "SBEPDoorToolError_cl" , RecipientFilter():AddPlayer( ply ) )
			umsg.String( "Cannot be both unusable and unwireable." )
			umsg.Float( 1 )
			umsg.Float( 4 )
		umsg.End()
		return
	end

	local model = self:GetClientInfo( "model" )
	local pos = tr.HitPos

	local DoorController = ents.Create( "sbep_base_door_controller" )
	DoorController:SetModel( model )
	DoorController:SetSkin( ply:GetInfoNum( "sbep_door_skin", 0 ) )

	DoorController:SetUsable( ply:GetInfoNum( "sbep_door_enableuse", 1 ) == 1 )

	DoorController:Spawn()
	DoorController:Activate()
	
	DoorController:SetPos( pos - Vector(0,0, DoorController:OBBMins().z ) )
	DoorController:AddDoors()
	
	DoorController:MakeWire( ply:GetInfoNum( "sbep_door_wire", 1 ) == 1 )

	if CPPI then DoorController:CPPISetOwner(self:GetOwner()) end -- The Fix
	
	undo.Create("SBEP Door")
		undo.AddEntity( DoorController )
		if DoorController.DT then
			for _,door in ipairs( DoorController.DT ) do
				if CPPI then door:CPPISetOwner(self:GetOwner()) end -- The Fix
				undo.AddEntity( door )
			end
		end
		undo.SetPlayer( ply )
	undo.Finish()
	
	return true
end

local function fix(tool_name, method, fixed)
	local tool = weapons.GetStored("gmod_tool")
	if not tool then error"error fixing part spawner, gmod_tool not registered yet!" end
	
	tool = tool.Tool
	if not tool then error"error fixing part spawner, gmod_tool not set-up yet!" end
	
	tool = tool[tool_name]
	if not tool then error("error fixing part spawner, tool " .. tool_name .. " does not exist!") end
	
	local meth = tool[method]
	if not meth then error("error fixing part spawner, sbep_part_spawner does not have method " .. method .. "!") end
	
	tool[method] = fixed
end

local function fix_sbep()
fix("sbep_part_spawner", "LeftClick", fixed_left_click_part)
fix("sbep_door", "LeftClick", fixed_left_click_door)
end

hook.Add("InitPostEntity", "fix_sbep_part_spawner", fix_sbep)
