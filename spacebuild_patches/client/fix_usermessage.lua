local function AddResource(um)
    local ent = um:ReadEntity()
    local res = um:ReadString()
    if not (ent and ent.resources) then return end -- Fix, inserting into none existing table
    table.insert(ent.resources, res)
    if MainFrames[ent:EntIndex()] and MainFrames[ent:EntIndex()]:IsActive() and MainFrames[ent:EntIndex()]:IsVisible() then
        local LeftTree = MainFrames[ent:EntIndex()].lefttree
        LeftTree.Items = {}
        if ent.resources and table.Count(ent.resources) > 0 then -- Why check here if you already tried fucking forcing it in?
            for k, v in pairs(ent.resources) do
                local title = v;
                local node = LeftTree:AddNode(title)
                node.res = v
                function node:DoClick()
                    MainFrames[ent:EntIndex()].SelectedNode = self
                end
            end
        end
    end
end

usermessage.Hook("LS_Add_ScreenResource", AddResource)
