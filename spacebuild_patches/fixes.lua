hook.Add("PhysgunPickup", "parent_fix", function(p, e)
	if e:GetParent():IsValid() then return false end
end)
