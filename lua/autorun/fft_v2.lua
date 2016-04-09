if SERVER then

util.AddNetworkString( "fft_v2" )
util.AddNetworkString( "fft_v2_valid" )
util.AddNetworkString( "fft_v2_request" )

net.Receive( "fft_v2", function( len, ply )
    local ent = net.ReadEntity()
    if not ent or not IsValid( ent ) then print( "[TrixMusic] Song ended, invalid entity?" ) return end
    --print( "[TrixMusic] " .. ply:Name() .. " says song ended" )

    table.insert( ent.ThinkEnd, ply:SteamID() )
    ent:TryNextSong()
end )

net.Receive( "fft_v2_valid", function( len, ply )
    local ent = net.ReadEntity()
    if not ent or not IsValid( ent ) then print( "[TrixMusic] Validate listener, invalid entity?" ) return end
    --print( "[TrixMusic] " .. ply:Name() .. " listens to music" )

    ent.Listeners[ ply:SteamID() ] = true
end )

net.Receive( "fft_v2_request", function( len, ply )
    local ent = net.ReadEntity()
    if not ent or not IsValid( ent ) then print( "[TrixMusic] Request time, invalid entity?" ) return end

    local time = net.ReadString()

    ent.Time = time + 2
end )

hook.Add( "PlayerInitialSpawn", "fft_v2", function( ply )
    for _, ent in pairs( ents.FindByClass( "fft_v2" ) ) do
        ent:RequestTime()

        timer.Simple( 2, function()
            net.Start( "fft_v2" )
                net.WriteString()
                net.WriteInt( tonumber( ent.Time ) or 0, 32 )
            net.Send( ply )
        end )
    end
end )

else

surface.CreateFont("fft_v2", {
    font = "Roboto",
    size = 100,
    weight = 800,
})

hook.Add( "PostDrawOpaqueRenderables", "fft_v2", function()

    for _, ent in pairs( ents.FindByClass( "fft_v2" ) ) do

        if not IsValid( ent ) then continue end

        local pos = ent:GetPos() + ent:GetRight() * 10 * (25 / 2) + ent:GetUp() * 100
        local ang = ent:GetAngles()
        ang:RotateAroundAxis( ang:Right(), 90 )
        ang:RotateAroundAxis( ang:Up(), -90 )

        local songname = ent.SongName or ""

        local dur = ent.Sound and IsValid( ent.Sound ) and ent.Sound:GetLength() or "0"
        dur = tonumber( dur )

        local h = math.floor( dur / 60 / 60 )
        if math.abs( h ) < 1 then
            h = ""
        else
            h = h .. ":"
        end

        local m = math.floor( dur / 60 ) % 60
        if math.abs( m ) < 10 then m = "0" .. m end

        local s = math.floor( dur ) % 60
        if math.abs( s ) < 10 then s = "0" .. s end

        local durstr = h .. m .. ":" .. s

        local time = ent.Sound and IsValid( ent.Sound ) and ent.Sound:GetTime() or "0"
        time = tonumber( time )

        local h = math.floor( time / 60 / 60 )
        if math.abs( h ) < 1 then
            h = ""
        else
            h = h .. ":"
        end

        local m = math.floor( time / 60 ) % 60
        if math.abs( m ) < 10 then m = "0" .. m end

        local s = math.floor( time ) % 60
        if math.abs( s ) < 10 then s = "0" .. s end

        local timestr = h .. m .. ":" .. s

        cam.Start3D2D( pos, ang, 0.1 )
            draw.DrawText( songname, "fft_v2", 0, -100, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
            draw.DrawText( timestr .. "/" .. durstr, "fft_v2", 0, 0, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER )
        cam.End3D2D()

        if dur > 1 and time == dur and not ent.Ended then
            ent.Ended = true

            net.Start( "fft_v2" )
                net.WriteEntity( ent )
            net.SendToServer()

            print( "[TrixMusic] Song ended" )
        end

    end

end )

net.Receive( "fft_v2", function( len )
    local ent = net.ReadEntity()
    if not ent or not IsValid( ent ) then print( "[TrixMusic] FFT Ent is not valid") return end

    local url = net.ReadString()
    if not url or url == "" then print( "[TrixMusic] FFT Url is not valid") return end

    local time = net.ReadInt( 32 ) or 0

    ent:Play( url, time )
end )

net.Receive( "fft_v2_request", function( len )
    local ent = net.ReadEntity()
    if not ent or not IsValid( ent ) then print( "[TrixMusic] FFT Ent is not valid") return end

    net.Start( "fft_v2_request" )
        net.WriteEntity( ent )
        net.WriteString( tostring( ent.Sound:GetTime() ) )
    net.SendToServer()
end )

end

easylua.StartEntity( "fft_v2" )

ENT.Base = "base_gmodentity"
ENT.Type = "anim"

ENT.PrintName = "FFT Player"
ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"

if SERVER then

ENT.URL = {
  "http://futuretechs.eu/sounds/music/monstercat/list.php",
  "http://futuretechs.eu/sounds/music/xkito/list.php",
}

ENT.Songs = nil
ENT.OnGoing = nil

ENT.Listeners = {}
ENT.ThinkEnd = {}

function ENT:Initialize()
    self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
        phys:Wake()
		phys:EnableMotion( false )
	end

    self:SetColor( Color( 0, 0, 0, 0 ) )
end

function ENT:Play( name )
    local id = 0

    if name == "monstercat" then id = 1 end
    if name == "xkito" then id = 2 end

    if id == 0 then print( "[TrixMusic] Invalid name" ) return end

    self.Listeners = {}
    self.ThinkEnd = {}
    self.Time = 0

    local url = self.URL[ id ]

    http.Fetch( url, function( b )
        local songs = string.Explode( "\n", b )
        print( "[TrixMusic] Fetch success, results: " .. #songs )

        self.Songs = songs
        self.OnGoing = 1

        net.Start( "fft_v2" )
            net.WriteEntity( self )
            net.WriteString( self.Songs[self.OnGoing] )
            net.WriteInt( self.Time or 0, 32 )
        net.Broadcast()
    end, function()
        print( "[TrixMusic] Fetch failed" )
    end )
end

function ENT:TryNextSong()
    local listeners = self.Listeners
    local thinkend = self.ThinkEnd

    local failed = false

    for id, _ in pairs( listeners ) do
        if not table.HasValue( thinkend, id ) then
            local ply = player.GetBySteamID( id )
            if ply and IsValid( ply ) then
                failed = true
            end
        end
    end

    if not failed then
        self.OnGoing = self.OnGoing + 1
        if self.OnGoing > #self.Songs then print( "[TrixMusic] Playlist ended, cant play other songs." ) return end

        print( "[TrixMusic] Playing next song! (" .. self.OnGoing .. "/" .. #self.Songs .. ")" )

        net.Start( "fft_v2" )
            net.WriteEntity( self )
            net.WriteString( self.Songs[self.OnGoing] )
        net.Broadcast()
    end
end

function ENT:RequestTime()
    net.Start( "fft_v2_request" )
        net.WriteEntity( self )
    net.Broadcast()
end

else

ENT.AMP = 100

ENT.EM = ENT.EM or nil
ENT.Sound = ENT.Sound or nil
ENT.ParticleSpawn = CurTime()
ENT.Lerp = {}
ENT.LerpSpeed = 0.05
ENT.FFTCount = 25

function ENT:Initialize()
    if not self.EM then
        self.EM = ParticleEmitter( Vector( 0, 0, 0 ) )
    end
end

function ENT:Play( url, time )
    if self.Sound and IsValid( self.Sound ) and self.Sound:GetTime() > 0 then self.Sound:Stop() end

    local songname = string.Explode( "/", url )
    songname = songname[#songname]
    songname = string.sub( songname, 1, string.len( songname ) - 4 )

    self.SongName = songname

    sound.PlayURL( url, "noblock", function( s )
        if IsValid( s ) then
            s:SetPos( self:GetPos() + self:GetRight() * 10 * (25 / 2) )
            s:Play()
            s:SetTime( time or 0 )
            self.Sound = s
        else
            LocalPlayer():ChatPrint( "FFT_Ent - Failed (Wrong url?)" )
            print( "FFT_Ent - " .. url )
        end
    end )

    net.Start( "fft_v2_valid" )
        net.WriteEntity( self )
    net.SendToServer()

    self.Ended = false
    self.ThinkEnd = {}
end

function ENT:Think()
    if not self.EM or not IsValid( self.EM ) then
        self.EM = ParticleEmitter( Vector( 0, 0, 0 ) )
    end

    if not IsValid( self.Sound ) or not self.EM then return end
    self.Sound:SetPos( self:GetPos() + self:GetRight() * 10 * (25 / 2) )

    local pos1, pos2 = self:GetPos(), LocalPlayer():GetPos()
    local dist = pos1:Distance(pos2)

    if dist > 300 then
        local vol = 0
        if dist > 500 then vol = 0 end
        vol = 500 - dist
        vol = vol / 200
        vol = math.max( 0, vol )
        self.Sound:SetVolume( vol )
    else
        self.Sound:SetVolume( 1 )
    end

    local FFT = {}
    self.Sound:FFT( FFT, FFT_512 )

    if self.ParticleSpawn > CurTime() then return end
    self.ParticleSpawn = CurTime() + 0.008
    local H = 1

    for I=1,self.FFTCount do
        local fftval = (FFT[I] or 0) ^ 2
        fftval = math.log10( fftval ) / 10
        fftval = (1 - math.abs(fftval)) ^ 3 * self.AMP

        fftval = fftval + 5

        local oldval = self.Lerp[I] or 0

        if oldval ~= oldval then
            oldval = 0
        end

        fftval = Lerp( self.LerpSpeed, oldval, fftval )
        self.Lerp[I] = fftval

        local pos = self:GetPos() + (self:GetRight() * 10) * I + self:GetUp() * fftval
        local part = self.EM:Add( "sprites/orangecore1", pos )

        if part then
            local clr = HSVToColor( H, 1, 1 )
            part:SetColor( clr.r, clr.g, clr.b, 255 )
            part:SetVelocity( Vector( 0, 0, 0 ) )
            part:SetDieTime( 0.1 )
            part:SetStartSize( 3 )
            part:SetEndSize( 3 )
            part:SetAngles( (pos - LocalPlayer():GetShootPos()):Angle() )
            part:SetRollDelta( 0 )
            part:SetStartAlpha( 255 + 128 )
            part:SetEndAlpha( 255 + 128 )
            part:SetGravity( Vector( 0, 0, 0 ) )
            part:SetBounce( 0 )
        end

        H = H + 10
    end

    H = 1

    for I=1,self.FFTCount do
        local fftval = (FFT[I] or 0) ^ 2
        fftval = math.log10( fftval ) / 10
        fftval = (1 - math.abs(fftval)) ^ 3 * self.AMP

        fftval = fftval + 5
        local pos = self:GetPos() + (self:GetRight() * 10) * I
        local part = self.EM:Add( "sprites/orangecore1", pos )

        if part then
            local clr = HSVToColor( H, 1, 1 )
            part:SetColor( clr.r, clr.g, clr.b, 255 )
            part:SetVelocity( Vector( 0, 0, 0 ) )
            part:SetDieTime( 0.1 )
            part:SetStartSize( 3 )
            part:SetEndSize( 3 )
            part:SetAngles( (pos - LocalPlayer():GetShootPos()):Angle() )
            part:SetRollDelta( 0 )
            part:SetStartAlpha( 255 + 128 )
            part:SetEndAlpha( 255 + 128 )
            part:SetGravity( Vector( 0, 0, 0 ) )
            part:SetBounce( 0 )
        end

        H = H + 10
    end
end

function ENT:Draw()
    if not self.Sound then
        self:DrawModel()
    end
end

function ENT:OnRemove()
    if self.Sound and IsValid( self.Sound ) then
        self.Sound:Stop()
    end

    if self.EM then
        self.EM:Finish()
    end
end

end

easylua.EndEntity( false, true )
