local PLAYER = debug.getregistry().Player

pcall(require, "sourcenetinfo")

if not sourcenetinfo then return end

function PLAYER:CloseConnection()
	if self:IsBot() then
		error("Cannot close the connection of a bot (they don't have one!)")
	end
	self:GetNetChannel():SetChallengeNr(-1)
end

function PLAYER:CloseConnectionInstant()
	if not self:IsBot() then
		self:GetNetChannel():SetChallengeNr(-1)
	end
	timer.Simple(0.1, function()
		self:Kick("Connection closing")
	end)
end
